import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/BuildingAPIModelBox.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../config.dart';
import '/NAVIGATION/APIMODELS/Building.dart';
import 'RefreshTokenAPI.dart';


class BuildingAPI {
  final String baseUrl = "${AppConfig.baseUrl}/secured/building/get/venue";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<Building> fetchBuildData() async {
    accessToken = signInBox.get("accessToken");
    final BuildingBox = BuildingAPIModelBox.getData();
    if(BuildingBox.length !=0){
      print("BUILDING API DATA FROM DATABASE");
      print(BuildingBox.length);
      Map<String, dynamic> responseBody = BuildingBox.getAt(0)!.responseBody;
      return Building.fromJson(responseBody);
    }
    final Map<String, dynamic> data = {
      "venueName": buildingAllApi.getStoredVenue(),
    };
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    if (response.statusCode == 200) {
      print("responseeeee ${response.body}");
      Map<String,dynamic> responseBody = json.decode(response.body);
      final BuildingData = BuildingAPIModel(responseBody: responseBody);
      print(responseBody);
      print('BUILDING DATA FROM API');
      BuildingBox.put(buildingAllApi.getStoredString(), BuildingData);
      BuildingData.save();
      return Building.fromJson(responseBody);
    }else if (response.statusCode == 403) {
      print('BUILDING DATA API in error 403');
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
        Map<String,dynamic> responseBody = json.decode(response.body);
        final BuildingData = BuildingAPIModel(responseBody: responseBody);
        print(responseBody);
        print('BUILDING DATA FROM API AFTER 403');
        BuildingBox.put(buildingAllApi.getStoredString(), BuildingData);
        BuildingData.save();
        return Building.fromJson(responseBody);
      }else{
        print('BUILDING DATA EMPTY FROM API AFTER 403');
        Building buildingData = Building();
        return buildingData;
      }
    } else {
      HelperClass.showToast("MishorError in Building API");
      throw Exception('Failed to load data');
    }
  }
}

