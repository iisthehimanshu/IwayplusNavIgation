import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../APIMODELS/SensorFingerprint.dart';
import 'RefreshTokenAPI.dart';


class fingerPrintingApi {
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/admin/add-fingerprinting-data" : "https://maps.iwayplus.in/admin/add-fingerprinting-data";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<bool> Finger_Printing_API(String building_ID, Data fingerPrint) async {

    print("buildigid:${building_ID}");

    if(fingerPrint.sensorFingerprint == null){
      print("fail 1");
      return false;
    }


    accessToken = signInBox.get("accessToken");

    final Map<String, dynamic> data = {
      "building_ID": building_ID,
      "fingerPrintData": {fingerPrint.position:fingerPrint.sensorFingerprint}
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      print("fail 2");
      return true ;
    }else if(response.statusCode == 403){
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return Finger_Printing_API(building_ID,fingerPrint);
    } else {
      print("fail 3");
      return false;
      throw Exception('Failed to load Finger_Printing_API data');
    }
  }
}
