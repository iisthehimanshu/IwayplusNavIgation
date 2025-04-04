import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../DATABASE/BOXES/WayPointModelBOX.dart';
import '../DATABASE/DATABASEMODEL/WayPointModel.dart';
import '../VersioInfo.dart';
import '../config.dart';
import '../waypoint.dart';
import 'RefreshTokenAPI.dart';


class waypointapi {

  final String baseUrl = "${AppConfig.baseUrl}/secured/indoor-path-network";
  String token = "";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  String getDecryptedData(String encryptedData){
    Map<String, dynamic> encryptedResponseBody = json.decode(encryptedData);
    String newResponse=encryptDecrypt(encryptedResponseBody['encryptedData']);
    //print("new response ${newResponse}");
    List<dynamic> originalList = jsonDecode(newResponse);
    // Wrap in landmarks header
    // Map<String, dynamic> wrappedResponse = {
    //   "polyline": originalList
    // };
    return jsonEncode(originalList);
  }
  Future<List<PathModel>> fetchwaypoint(id,{bool outdoor = false}) async {
    accessToken = signInBox.get("accessToken");


    final WayPointBox = WayPointModeBOX.getData();

    if(WayPointBox.containsKey(id) && VersionInfo.polylineDataVersionUpdate==false){
      print("WAYPOINT DATA FROM DATABASE");
      List<dynamic> responseBody = WayPointBox.get(id)!.responseBody;
      List<PathModel> wayPointList = responseBody.map((data) => PathModel.fromJson(data as Map<dynamic, dynamic>)).toList();
      print("building ${wayPointList[0].buildingID}");
      return wayPointList;
    }

    final Map<String, dynamic> data = {
      "building_ID": id??buildingAllApi.getStoredString(),
      "outdoor": outdoor
    };


    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        'Authorization': AppConfig.Authorization
      },
    );
    if (response.statusCode == 200) {
      print("WAYPOINT DATA FROM API");
      try{
        List<dynamic> jsonData = json.decode(response.body);
        List<PathModel> wayPointList = jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
        final wayPointData = WayPointModel(responseBody: jsonData);
        if(wayPointList.isNotEmpty){
          WayPointBox.put(wayPointList[0].buildingID, wayPointData);
          wayPointData.save();
        }
        return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
      }catch(e){
        String finalResponse=getDecryptedData(response.body);
        List<dynamic> jsonData = json.decode(finalResponse);
        List<PathModel> wayPointList = jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
        final wayPointData = WayPointModel(responseBody: jsonData);
        if(wayPointList.isNotEmpty){
          WayPointBox.put(wayPointList[0].buildingID, wayPointData);
          wayPointData.save();
        }
        return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
      }


    }else if (response.statusCode == 403) {
      print("WAYPOINT DATA FROM API IN 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;

      final response = await http.post(
        Uri.parse(baseUrl), body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );
      if (response.statusCode == 200) {
        print("WAYPOINT DATA FROM API AFTER 403");
        List<dynamic> jsonData = json.decode(response.body);
        List<PathModel> wayPointList = jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
        final wayPointData = WayPointModel(responseBody: jsonData);
        if(wayPointList.isNotEmpty){
          WayPointBox.put(wayPointList[0].buildingID, wayPointData);
          wayPointData.save();
        }
        return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
      }else{
        print('WAYPOINT DATA EMPTY FROM API AFTER 403');
        List<PathModel> ll = [];
        return ll;
      }
    }else {
      if(kDebugMode) {
        HelperClass.showToast("MishorError in WAYPOINT API API");
      }
      print("API Exception");
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}