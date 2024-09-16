import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/DATABASE/BOXES/BuildingAPIModelBox.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import '../APIMODELS/Building.dart';
import '/Elements/HelperClass.dart';
import 'RefreshTokenAPI.dart';
import 'buildingAllApi.dart';
import 'guestloginapi.dart';


class BuildingAPI {
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/building/get/venue" : "https://maps.iwayplus.in/secured/building/get/venue";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<Building> fetchBuildData() async {
    accessToken = signInBox.get("accessToken");
    print("buildingapi");
    // final LandMarkBox = LandMarkApiModelBox.getData();
    //
    // if(LandMarkBox.containsKey(buildingAllApi.getStoredString())){
    //   print("LANDMARK DATA FORM DATABASE ");
    //   // print("DATABASE SIZE: ${LandMarkBox.length}");
    //   //print(LandMarkBox.getAt(0)?.responseBody.values);
    //   Map<String, dynamic> responseBody = LandMarkBox.get(buildingAllApi.getStoredString())!.responseBody;
    //   print(LandMarkBox.keys);
    //   // print("object ${responseBody['landmarks'][0].runtimeType}");
    //   return land.fromJson(responseBody);
    // }
    final BuildingBox = BuildingAPIModelBox.getData();

    if(BuildingBox.length !=0){
      print("BUILDING API DATA FROM DATABASE");
      print(BuildingBox.length);
      Map<String, dynamic> responseBody = BuildingBox.getAt(0)!.responseBody;
      //List<Building> buildingList = responseBody.map((key, value) => null)
      return Building.fromJson(responseBody);
    }


    final Map<String, dynamic> data = {
      "venueName": buildingAllApi.getStoredVenue(),
    };
    print("inside land");
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    print("response code in land is ${response.statusCode}");
    if (response.statusCode == 200) {
      Map<String,dynamic> responseBody = json.decode(response.body);
      final BuildingData = BuildingAPIModel(responseBody: responseBody);

      print(responseBody);
      print('BUILDING DATA FROM API');
      // print(LandMarkBox.length);
      //LandMarkApiModel? demoresponseBody = LandMarkBox.getAt(0);
      //print(demoresponseBody?.responseBody);
      // LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);

      // print(LandMarkBox.length);
      // print('TESTING LANDMARK API DATABASE OVER');
      //landmarkData.save();

      //print("object ${responseBody['landmarks'][0].runtimeType}");
      
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
        // print(LandMarkBox.length);
        //LandMarkApiModel? demoresponseBody = LandMarkBox.getAt(0);
        //print(demoresponseBody?.responseBody);
        // LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);

        // print(LandMarkBox.length);
        // print('TESTING LANDMARK API DATABASE OVER');
        //landmarkData.save();

        //print("object ${responseBody['landmarks'][0].runtimeType}");

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

