import 'dart:convert';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/APIMODELS/patchDataModel.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'package:iwaymaps/Navigation.dart';
import 'package:permission_handler/permission_handler.dart';


import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';

class patchAPI {

  String token = "";
  final String baseUrl = "https://dev.iwayplus.in/secured/patch/get";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");


  Future<patchDataModel> fetchPatchData({String? id = null}) async {
    print("checking data");
    print(accessToken);
    print(refreshToken);


    accessToken = signInBox.get("accessToken");

    final PatchBox = PatchAPIModelBox.getData();
    if(PatchBox.containsKey(id??buildingAllApi.getStoredString()) && !VersionInfo.patchDataVersionUpdate){
      print("PATCH API DATA FROM DATABASE");
      print(PatchBox.get(buildingAllApi.getStoredString())!.responseBody);
      Map<String, dynamic> responseBody = PatchBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      return patchDataModel.fromJson(responseBody);
    }



    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString()
    };

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
      print("PATCH API DATA FROM API");
      return patchDataModel.fromJson(responseBody);

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
        print("PATCH API EMPTY DATA FROM API AFTER 403");
        patchDataModel patchData = patchDataModel();
        return patchData;
      }
    } else {
      print("PATCH API in else error");
      print(Exception);
      throw Exception('Failed to load data');
    }
  }



}
