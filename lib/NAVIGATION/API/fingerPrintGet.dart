import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../APIMODELS/FingerPrintData.dart';
import 'RefreshTokenAPI.dart';


class fingerPrintingGetApi {
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/get-fingerprinting-data/" : "https://maps.iwayplus.in/secured/get-fingerprinting-data/";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<FingerPrintData?> Finger_Printing_GET_API(String building_ID) async {

    accessToken = signInBox.get("accessToken");

    final response = await http.get(
      Uri.parse(baseUrl+building_ID),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    print("response ${response.statusCode}  ${response.body}");
    if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        if(json.decode(response.body) == null){
          return null;
        }
        return FingerPrintData.fromJson(responseBody);

    }else if(response.statusCode == 403){
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return Finger_Printing_GET_API(building_ID);
    } else {
      print(response.body);
      throw Exception('Failed to load Finger_Printing_GET_API data');
    }
  }
}
