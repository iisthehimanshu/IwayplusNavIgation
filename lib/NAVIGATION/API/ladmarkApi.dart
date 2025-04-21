import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../config.dart';
import '/NAVIGATION/APIMODELS/landmark.dart';
import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';
import 'package:hive/hive.dart';


class landmarkApi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/landmarks";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  String encryptDecrypt(String input, String key){
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      // XOR each character of the input with the corresponding character of the key
      result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }
String getDecryptedData(String encryptedData){
  Map<String, dynamic> encryptedResponseBody = json.decode(encryptedData);
  String newResponse=encryptDecrypt(encryptedResponseBody['encryptedData'], "xX7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=");
  List<dynamic> originalList = jsonDecode(newResponse);
  // Wrap in landmarks header
  Map<String, dynamic> wrappedResponse = {
    "landmarks": originalList
  };
  return jsonEncode(wrappedResponse);
}
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
        'x-access-token': accessToken,
        'Authorization': 'e28cdb80-c69a-11ef-aa4e-e7aa7912987a'
      },
    );
    if (response.statusCode == 200) {
      try{
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

      }catch(e){
        String finalResponse=getDecryptedData(response.body);
        // Output the transformed response
        Map<String, dynamic> responseBody = json.decode(finalResponse);
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

    String finalResponse=getDecryptedData(response.body);
      // Output the transformed response
      Map<String, dynamic> responseBody = json.decode(finalResponse);
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
      // if(!LandMarkBox.containsKey(buildingAllApi.getStoredString())){
      //   print('LANDMARK DATA FROM API');
      //   LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);
      //   landmarkData.save();
      //   return land.fromJson(responseBody);
      // }else{
      //   Map<String, dynamic> databaseresponseBody = LandMarkBox.get(buildingAllApi.getStoredString())!.responseBody;
      //   String LastUpdatedTime = databaseresponseBody['landmarks'][0]['updatedAt']!;
      //   print("APITime");
      //   if(APITime==LastUpdatedTime){
      //     print("LANDMARK DATA FROM DATABASE");
      //     print("Current Time: ${APITime} Last updated Time: ${LastUpdatedTime}");
      //     return land.fromJson(databaseresponseBody);
      //   }else{
      //     print("LANDMARK DATA FROM DATABASE AND UPDATED");
      //     print("Current Time: ${APITime} Last updated Time: ${LastUpdatedTime}");
      //     LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);
      //     landmarkData.save();
      //     return land.fromJson(responseBody);
      //   }
      // }
    } else if (response.statusCode == 403) {
      print('LANDMARK DATA API in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        String APITime = responseBody['landmarks'][0]['updatedAt']!;
        final landmarkData = LandMarkApiModel(responseBody: responseBody);

        print('LANDMARK DATA FROM API AFTER 403');
        print(responseBody.containsValue("polylineExist"));
        LandMarkBox.put(land.fromJson(responseBody).landmarks![0].buildingID,landmarkData);
        landmarkData.save();
        return land.fromJson(responseBody);
      }else{
        print('LANDMARK DATA EMPTY FROM API AFTER 403');
        land landData = land();
        return landData;
      }
    } else {
      HelperClass.showToast("MishorError in LANDMARK API API");
      throw Exception('Failed to load data');
    }
  }
}