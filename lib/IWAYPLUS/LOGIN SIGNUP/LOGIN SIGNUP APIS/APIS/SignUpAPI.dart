import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../NAVIGATION/config.dart';
import '../../../Elements/HelperClass.dart';
class SignUpAPI{

  final String xaccesstoken = AppConfig.Authorization;

  Future<bool> signUP(String username,String name, String password,String OTP) async {
    final String baseUrl = "${AppConfig.baseUrl}/auth/signup";
    final Map<String, dynamic> data = {
      "username": username,
      "name": name,
      "password": password,
      "otp": OTP,
      "appId":"com.iwayplus.candor"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: EncryptedbodyForApi(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': xaccesstoken,
      },
    );
    print('---response--- ${response.statusCode}');
    print(response.body);
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

  Future<bool> checkUserExists(String username) async {
    return false;
  }

}