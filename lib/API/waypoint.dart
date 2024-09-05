import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/DATABASE/BOXES/WayPointModelBOX.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/WayPointModel.dart';
import '../APIMODELS/guestloginmodel.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';

import '../Elements/HelperClass.dart';
import '../VersioInfo.dart';
import '../waypoint.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';


class waypointapi {

  final String baseUrl = "https://dev.iwayplus.in/secured/indoor-path-network";
  String token = "";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");


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
        'x-access-token': accessToken
      },
    );
    if (response.statusCode == 200) {
      print("WAYPOINT DATA FROM API");
      List<dynamic> jsonData = json.decode(response.body);
      List<PathModel> wayPointList = jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
      final wayPointData = WayPointModel(responseBody: jsonData);
      if(wayPointList.isNotEmpty){
        WayPointBox.put(wayPointList[0].buildingID, wayPointData);
        wayPointData.save();
      }
      return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
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



//
//
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:iwaymaps/DATABASE/BOXES/WayPointModelBOX.dart';
// import 'package:iwaymaps/DATABASE/DATABASEMODEL/WayPointModel.dart';
// import '../APIMODELS/guestloginmodel.dart';
//
// import '../waypoint.dart';
// import 'guestloginapi.dart';
//
//
// class waypointapi {
//
//   final String baseUrl = "https://dev.iwayplus.in/secured/indoor-path-network";
//   String token = "";
//
//
//   Future<List<PathModel>> fetchwaypoint(id) async {
//
//     final WayPointBox = WayPointModeBOX.getData();
//
//     if(WayPointBox.containsKey(id)){
//       print("WAYPOINT DATA FROM DATABASE");
//       List<dynamic> responseBody = WayPointBox.get(id)!.responseBody;
//       List<PathModel> wayPointList = responseBody.map((data) => PathModel.fromJson(data as Map<dynamic, dynamic>)).toList();
//       print("building ${wayPointList[0].buildingID}");
//       return wayPointList;
//     }
//
//     final Map<String, dynamic> data = {
//       "building_ID": id
//     };
//
//     await guestApi().guestlogin().then((value){
//       if(value.accessToken != null){
//         token = value.accessToken!;
//       }
//     });
//
//     final response = await http.post(
//       Uri.parse(baseUrl), body: json.encode(data),
//       headers: {
//         'Content-Type': 'application/json',
//         'x-access-token': token
//       },
//     );
//     if (response.statusCode == 200) {
//       print("WAYPOINT DATA FROM API");
//       List<dynamic> jsonData = json.decode(response.body);
//       List<PathModel> wayPointList = jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
//       final wayPointData = WayPointModel(responseBody: jsonData);
//       if(wayPointList.isNotEmpty){
//         WayPointBox.put(wayPointList[0].buildingID, wayPointData);
//         wayPointData.save();
//       }
//       return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
//     } else {
//       print("API Exception");
//       print(response.statusCode);
//       throw Exception('Failed to load data');
//     }
//   }
// }