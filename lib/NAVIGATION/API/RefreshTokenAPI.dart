import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../DATABASE/BOXES/PatchAPIModelBox.dart';

class RefreshTokenAPI {

  static String baseUrl = kDebugMode? "https://dev.iwayplus.in/api/refreshToken?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edff" : "https://dev.iwayplus.in/api/refreshToken?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edff";

  static Future<String> refresh() async {
    var signInBox = Hive.box('SignInDatabase');
    String refreshToken = signInBox.get("refreshToken");
    print("refreshToken");
    print(refreshToken);

    final Map<String, dynamic> data = {
      "refreshToken": refreshToken,
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
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
      print("in refreshTOken");
      Map<String, dynamic> responseBody = json.decode(response.body);
      final newAccessToken = responseBody["accessToken"];
      final newRefreshToken = responseBody["refreshToken"];
      signInBox.delete("accessToken");
      signInBox.put("accessToken", newAccessToken);
      print("New access token: ${signInBox.get("accessToken")}");

      signInBox.delete("refreshToken");
      signInBox.put("refreshToken", newRefreshToken);
      print("New refresh token: ${signInBox.get("refreshToken")}");

      return newAccessToken;
    } else if (response.statusCode == 400) {
      return "400";
    } else {
      print("Error refreshing tokens:");
      print(response.statusCode);
      throw Exception('Failed to refresh tokens');
    }
  }
}
