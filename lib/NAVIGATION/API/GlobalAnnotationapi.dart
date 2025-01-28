import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/GlobalAnnotationModel.dart';
import 'RefreshTokenAPI.dart';


class GlobalAnnotation {

  String baseUrl = "https://dev.iwayplus.in/secured/get-global-annotation/";
  String token = "";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<GlobalModel> fetchGlobalAnnotationData(id, {String? newaccesstoken}) async {
    print("old access token $accessToken");
    print("old refreshToken  $refreshToken");
    //accessToken = signInBox.get("accessToken");
    final response = await http.get(
      Uri.parse(baseUrl+id),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': newaccesstoken??accessToken,
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
    print("globalannotation data ${response.body}");
    print("globalannotation data ${response.statusCode}");
    if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final completeData = GlobalModel.fromJson(jsonData);
        print("globalannotation data $jsonData");
        return completeData;

    }else if (response.statusCode == 403) {
      print("globalannotation data  IN 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      return fetchGlobalAnnotationData(id,newaccesstoken: newAccessToken);
    }else {
      if(kDebugMode) {
        HelperClass.showToast("MishorError in globalannotation data ");
      }
      print("API Exception ${response.body}");
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}