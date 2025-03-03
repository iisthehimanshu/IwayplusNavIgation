import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../APIMODELS/FingerPrintData.dart';
import '../SharedPreferenceHelper.dart';
import 'RefreshTokenAPI.dart';
class fingerPrintingGetApi {
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/get-fingerprinting-data/" : "https://maps.iwayplus.in/secured/get-fingerprinting-data/";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");

  Future<FingerPrintData?> Finger_Printing_GET_API(String building_ID) async {
    // try {
      final response = await http.get(
        Uri.parse(baseUrl + building_ID),
        headers:{
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );
      if (response.statusCode == 200){
        print(response.body);
        // Check if response body is empty or invalid
        if (response.body.isEmpty){
          print("Empty response body");
          return null;
        }
        // Decode safely with try-catch
        // try {
          Map<String, dynamic> responseBody = json.decode(response.body);
          // If response is null or invalid
          if (responseBody.isEmpty) {
            print("Response body is empty or null");
            return null;
          }
          // Handle null values inside FingerPrintData
          return FingerPrintData.fromJson(responseBody);
        // } catch (e) {
        //   print("Error decoding JSON: $e");
          return null;
        //}
      } else if (response.statusCode == 403) {
        print("Token expired. Refreshing...");
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        return Finger_Printing_GET_API(building_ID);
      } else {
        print("Error: ${response.body}");
        throw Exception('Failed to load Finger_Printing_GET_API data');
      }
    // } catch (e) {
     // print("Exception in API call: $e");
      return null;
   // }
  }

}
