import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../NAVIGATION/Encryption/EncryptionService.dart';
import '../../../../NAVIGATION/config.dart';
import '../../../Elements/HelperClass.dart';
class SignUpAPI{
  Encryptionservice encryptionService = Encryptionservice();

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
      body: encryptionService.encrypt(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': encryptionService.authorization,
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