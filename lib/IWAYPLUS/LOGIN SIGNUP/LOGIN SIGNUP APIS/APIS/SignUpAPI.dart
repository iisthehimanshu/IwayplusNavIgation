import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../../../NAVIGATION/config.dart';
import '/IWAYPLUS/Elements/HelperClass.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
class SignUpAPI{
  final String baseUrl = "https://dev.iwayplus.in/auth/signup";
  final jsonEncoder = JsonEncoder();
  String encryptDecrypt(String input, String key){
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      // XOR each character of the input with the corresponding character of the key
      result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }
  Future<bool> signUP(String username,String name, String password,String OTP) async {
    final String xaccesstoken = AppConfig.xaccesstoken;
    // Encrypt each field
    final Map<String, dynamic> data = {
      "username": username,
      "name": name,
      "password": password,
      "otp": OTP,
      "appId":"com.iwayplus.navigation"
    };
    var finalData=jsonEncoder.convert(data);
    final encryptedData = encryptDecrypt(finalData,'X7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=');
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode({"encryptedData":encryptedData}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'e28cdb80-c69a-11ef-aa4e-e7aa7912987a',
        'x-access-token':xaccesstoken,
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