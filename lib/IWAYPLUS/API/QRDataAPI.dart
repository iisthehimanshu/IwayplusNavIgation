import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '/IWAYPLUS/APIMODELS/QRDataAPIModel.dart';


class QRDataAPI{
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<List<QRDataAPIModel>?> fetchQRData(List<String> id)async{
    print("IDfetchQRData");
    print(id);
    final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/building-qrs" : "https://dev.iwayplus.in/secured/building-qrs";
    final Map<String, dynamic> data = {
      "buildingIds": id
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
      List<dynamic> jsonResponse = jsonDecode(response.body);
      print("QRDataAPI DATA FROM API");
      print(jsonResponse);
      List<QRDataAPIModel> qrDataList = jsonResponse
          .map((data) => QRDataAPIModel.fromJson(data))
          .toList();
      return qrDataList;
    }else{
      return null;
    }
  }
}