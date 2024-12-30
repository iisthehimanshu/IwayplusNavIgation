import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../NAVIGATION/config.dart';


class SendOTPAPI{

  final String baseUrl = "${AppConfig.baseUrl}/auth/otp/send";
  final String xaccesstoken = AppConfig.xaccesstoken;
  Future<bool> sendOTP(String username) async {
    final Map<String, dynamic> data = {
      "username": username,
      "digits":4,
      "appName":"IWAYMAPS"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token':xaccesstoken
      },
    );

    if (response.statusCode == 200) {
      return true;
      // return HelperClass.showToast("OTP sent successfully");
    } else {
      print("SendOTPAPI--response.statusCode${response.statusCode} ${response.body}");
      return false;
    }
  }
}