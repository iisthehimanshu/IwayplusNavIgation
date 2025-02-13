import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../APIMODELS/FingerPrintData.dart';
import '../SharedPreferenceHelper.dart';
import 'RefreshTokenAPI.dart';


class fingerPrintingGetApi {
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/get-fingerprinting-data/" : "https://maps.iwayplus.in/secured/get-fingerprinting-data/";
  String accessToken = "";

  Future<FingerPrintData?> Finger_Printing_GET_API(String building_ID) async {
    SharedPreferenceHelper prefs = await SharedPreferenceHelper.getInstance();
    accessToken = await prefs.getMap("signin")!["accessToken"];

    final response = await http.get(
      Uri.parse(baseUrl+building_ID),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    if (response.statusCode == 200) {
      print(response.body);
      try{
        Map<String, dynamic> responseBody = json.decode(response.body);
        if(json.decode(response.body) == null){
          return null;
        }
        return FingerPrintData.fromJson(responseBody);
      }catch(e){
        return null;
      }

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
