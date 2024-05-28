import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';

class SendOTPAPI{

  final String baseUrl = "https://dev.iwayplus.in/auth/otp/send";

  void sendOTP(String username) async {
    final Map<String, dynamic> data = {
      "username": username,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
        return HelperClass.showToast("OTP sent successfully");
    } else {
      print("SendOTPAPI--response.statusCode${response.statusCode} ${response.body}");
      return null;
    }
  }
}