import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/Elements/HelperClass.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';

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

    print("Response body is ${response.statusCode}");

    if (response.statusCode == 200) {
      try {
        return HelperClass.showToast("OTP sent successfully");
      } catch (e) {
        print("Error occurred during data parsing: $e");
        throw Exception('Failed to parse data');
      }
    } else {
      print("Code is ${response.statusCode}");
      return null;
    }
  }
}