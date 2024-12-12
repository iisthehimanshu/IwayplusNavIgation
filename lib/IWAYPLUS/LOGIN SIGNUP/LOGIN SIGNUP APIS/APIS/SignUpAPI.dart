import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '/IWAYPLUS/ELEMENTS/HelperClass.dart';
class SignUpAPI{

  final String baseUrl = "https://dev.iwayplus.in/auth/signup";

  Future<bool> signUP(String username,String name, String password,String OTP) async {
    final Map<String, dynamic> data = {
      "username": username,
      "name": name,
      "password": password,
      "otp": OTP,
      "appId":"com.iwayplus.navigation"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status']) {
        return true;
      } else {
        print("SignUpAPI--response.statusCode ${responseData['status']} ");
        HelperClass.showToast(responseData["message"]);
      }
    } else {
      var responseData = json.decode(response.body);
      print("SignUpAPI--response.statusCode response.body ${response.statusCode} ${response.body}");
      HelperClass.showToast(responseData["message"]);
    }
    return false;
  }
}