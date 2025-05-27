import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/landmark.dart';
import '../DATABASE/BOXES/LandMarkApiModelBox.dart';
import '../DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../VersioInfo.dart';
import '../config.dart';
import 'RefreshTokenAPI.dart';
import 'package:hive/hive.dart';


class landmarkApi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/landmarks";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<land> fetchLandmarkData({String? id = null, bool outdoor = false}) async {
    print("landmark");
    accessToken = signInBox.get("accessToken");
    final LandMarkBox = LandMarkApiModelBox.getData();
    print("version check${VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(id)}");
    print("landmark version check${id}");
    if(LandMarkBox.containsKey(id??buildingAllApi.getStoredString()) && VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(id??buildingAllApi.getStoredString()) && VersionInfo.buildingLandmarkDataVersionUpdate[id??buildingAllApi.getStoredString()]! == false){
      print("LANDMARK DATA FORM DATABASE ");
      print(id??buildingAllApi.getStoredString());
      Map<String, dynamic> responseBody = LandMarkBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      print("Himanshuch ${land.fromJson(responseBody).landmarks![0].buildingName}");
      return land.fromJson(responseBody);
    }
    final stackTrace = StackTrace.current;
    print("landmarkAPI Stack: \n$stackTrace");
    print("outdoor boolean $outdoor");
    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString(),
      "outdoor": outdoor
    };
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
        // 'Authorization': AppConfig.Authorization
      },
    );
    if (response.statusCode == 200) {
      // Map<String, dynamic> encryptedResponseBody = json.decode(response.body);
      // String decryptedData = encryptDecrypt(encryptedResponseBody['encryptedData']);
        Map<String, dynamic> responseBody = json.decode(response.body);
        print("checkid $id");
        String APITime = responseBody['landmarks'][0]['updatedAt']!;
        final landmarkData = LandMarkApiModel(responseBody: responseBody);

        print('LANDMARK DATA FROM API');
        print(responseBody.containsValue("polylineExist"));
        // print(LandMarkBox.length);
        //LandMarkApiModel? demoresponseBody = LandMarkBox.getAt(0);
        //print(demoresponseBody?.responseBody);
        LandMarkBox.put(land.fromJson(responseBody).landmarks![0].buildingID,landmarkData);

        // print(LandMarkBox.length);
        // print('TESTING LANDMARK API DATABASE OVER');
        landmarkData.save();


        //print("object ${responseBody['landmarks'][0].runtimeType}");
        return land.fromJson(responseBody);

    }
    else if (response.statusCode == 403) {
      print('LANDMARK DATA API in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      return fetchLandmarkData(id: id, outdoor: outdoor);
    }
    else {

      HelperClass.showToast("MishorError in LANDMARK API API");
      throw Exception('Failed to load data for bid ${id??buildingAllApi.getStoredString()} ${response.body} ${response.statusCode}');
    }
  }
}