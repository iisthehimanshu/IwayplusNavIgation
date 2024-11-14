import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '/ONLY NAVIGATION/API/RefreshTokenAPI.dart';

class FCMServer{

  final String baseUrl = "https://dev.iwayplus.in/secured/fcm/save";
  String userID = Hive.box('SignInDatabase').get("userId");
  String accessToken = Hive.box('SignInDatabase').get("accessToken");

  Future<void> sendFCM(String FCM_token) async {

    final Map<String, dynamic> data = {
      "userId": userID,
      "fcmToken": FCM_token,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      print("FCM TOKEN SEND SUCCESSFULLY");
    }else if (response.statusCode == 403) {
      print("FCM TOKEN SEND IN 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      if (accessToken != null) {
        return FCMServer().sendFCM(FCM_token);
      } else {
        throw Exception('Access token is null from the refresh API');
      }
    }
    else {
      print(response.statusCode);
      print(Exception);
    }
  }
}