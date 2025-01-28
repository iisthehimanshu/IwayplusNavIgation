import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '/IWAYPLUS/Elements/HelperClass.dart';

import '/NAVIGATION/API/RefreshTokenAPI.dart';

class RatingsaveAPI{
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/rating-save" : "https://dev.iwayplus.in/secured/rating-save";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");

  Future<void> saveRating(String feedback,int rating,String userId,String username, String sourceId,String destinationID,String appId) async {
    final Map<String, dynamic> data = {
      "userId": userId,
      "username": username??'username',
      "sourceId": sourceId,
      "destinationId": destinationID,
      "rating": rating,
      "feedback": feedback,
      "appId": "com.iwayplus.navigation"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        'X-Content-Type-Options': 'nosniff', // Prevent MIME sniffing
        'X-Frame-Options': 'SAMEORIGIN', // Prevent embedding in iframe
        'X-XSS-Protection': '1; mode=block', // Prevent reflected XSS attacks
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload', // Enforce HTTPS
        'Content-Security-Policy': "frame-ancestors 'self'", // Limit who can embed the app
        'Referrer-Policy': 'no-referrer', // Prevent sending referrer information
        'X-Permitted-Cross-Domain-Policies': 'none',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    if (response.statusCode == 200) {
      print('RatingsaveAPI STATUS 200!! SUCCESS');
      Map<String,dynamic> responseBody = json.decode(response.body);
      HelperClass.showToast(responseBody["message"]);
    }else if(response.statusCode == 403){
      print('RatingsaveAPI in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;

      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'X-Content-Type-Options': 'nosniff', // Prevent MIME sniffing
          'X-Frame-Options': 'SAMEORIGIN', // Prevent embedding in iframe
          'X-XSS-Protection': '1; mode=block', // Prevent reflected XSS attacks
          'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload', // Enforce HTTPS
          'Content-Security-Policy': "frame-ancestors 'self'", // Limit who can embed the app
          'Referrer-Policy': 'no-referrer', // Prevent sending referrer information
          'X-Permitted-Cross-Domain-Policies': 'none',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
      if (response.statusCode == 200) {
        print('RatingsaveAPI STATUS 200!! SUCCESS');
        Map<String,dynamic> responseBody = json.decode(response.body);
        HelperClass.showToast("Response saved successfully");
      }else{
        print('RatingsaveAPI Response 403');
        HelperClass.showToast('Failed to load data');
      }


    }else{
      HelperClass.showToast('Failed to load data');
      throw Exception('Failed to load data');
    }


  }


}