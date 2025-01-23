import 'dart:convert';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '/NAVIGATION/APIMODELS/patchDataModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/Navigation.dart';
import 'package:permission_handler/permission_handler.dart';


import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';

class patchAPI {

  String token = "";
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/patch/get" : "https://maps.iwayplus.in/secured/patch/get";
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
    // //print("new response ${newResponse}");
    Map<String,dynamic> originalList = jsonDecode(newResponse);
    // Wrap in landmarks header
    Map<String, dynamic> wrappedResponse = {
      "patchData": originalList
    };
    return jsonEncode(wrappedResponse);
  }


  Future<patchDataModel> fetchPatchData({String? id = null}) async {
    String manufacturer = kIsWeb?"WEB":await DeviceInformation.deviceManufacturer;
    String deviceModel = kIsWeb?"WEB":await DeviceInformation.deviceModel;
    print("checking data ${id??buildingAllApi.getStoredString()}");
    print(accessToken);
    print(refreshToken);

    accessToken = signInBox.get("accessToken");

    final PatchBox = PatchAPIModelBox.getData();
    print("Patch getting for $id");
    if(PatchBox.containsKey(id??buildingAllApi.getStoredString()) && VersionInfo.buildingPatchDataVersionUpdate.containsKey(id??buildingAllApi.getStoredString()) && VersionInfo.buildingPatchDataVersionUpdate[id??buildingAllApi.getStoredString()]! == false){
      print("PATCH API DATA FROM DATABASE");
      print(PatchBox.get(id?? buildingAllApi.getStoredString())!.responseBody);
      Map<String, dynamic> responseBody = PatchBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      return patchDataModel.fromJson(responseBody);
    }



    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString(),
      "manufacturer":manufacturer,
      "devicemodel": deviceModel
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        'Authorization': 'e28cdb80-c69a-11ef-aa4e-e7aa7912987a'
      },
    );
    if (response.statusCode == 200) {
      print("data from patch ${response.body}");
      try{
        Map<String, dynamic> responseBody = json.decode(response.body);
        final patchData = PatchAPIModel(responseBody: responseBody);
        print("patchdata $responseBody for id $id");
        PatchBox.put(patchDataModel.fromJson(responseBody).patchData!.buildingID,patchData);
        patchData.save();
        print("PATCH API DATA FROM API");
        return patchDataModel.fromJson(responseBody);
      }catch(e){
        String finalResponse=getDecryptedData(response.body);
        Map<String, dynamic> responseBody = json.decode(finalResponse);
        final patchData = PatchAPIModel(responseBody: responseBody);
        print("patchdata $responseBody for id $id");
        PatchBox.put(patchDataModel.fromJson(responseBody).patchData!.buildingID,patchData);
        patchData.save();
        print("PATCH API DATA FROM API");
        return patchDataModel.fromJson(responseBody);
      }


    }else if (response.statusCode == 403)  {
      print("PATCH API in error 403");
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
        Map<String, dynamic> responseBody = json.decode(response.body);

        final patchData = PatchAPIModel(responseBody: responseBody);
        PatchBox.put(patchDataModel.fromJson(responseBody).patchData!.buildingID,patchData);
        patchData.save();
        print("PATCH API DATA FROM API AFTER 403");
        return patchDataModel.fromJson(responseBody);

      }else{
        print("${response.body}  PATCH API EMPTY DATA FROM API AFTER 403");
        patchDataModel patchData = patchDataModel();
        return patchData;
      }
    } else {
      print("PATCH API in else error");
      print(Exception);
      throw Exception('Failed to load data ${id??buildingAllApi.getStoredString()} ${response.statusCode} ${response.body}');
    }
  }



}