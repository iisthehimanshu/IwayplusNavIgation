import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/NAVIGATION/config.dart';
import '../../../../NAVIGATION/API/RefreshTokenAPI.dart';
import '../../../DATABASE/BOXES/SignINAPIModelBox.dart';
import '../../../Elements/UserCredential.dart';
import '../MODELS/SignInAPIModel.dart';

class SignInAPI{

  final String baseUrl = "${AppConfig.baseUrl}/auth/signin2";
  final jsonEncoder = JsonEncoder();
  String encryptDecrypt(String input, String key){
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      // XOR each character of the input with the corresponding character of the key
      result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }

  Future<SignInApiModel?> signIN(String username, String password) async {
    //final signindataBox = FavouriteDataBaseModelBox.getData();
    // final SigninBox = SignINAPIModelBox.getData();
    final String xaccesstoken = AppConfig.xaccesstoken;
    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "appId":"com.iwayplus.navigation"
    };
    var finalData=jsonEncoder.convert(data);
    final encryptedData = encryptDecrypt(finalData,'X7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=');
    print("encrypted data ${encryptedData}");
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode({"encryptedData":encryptedData.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token':xaccesstoken,
        'Authorization': 'e28cdb80-c69a-11ef-aa4e-e7aa7912987a',
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
    //Map<String, dynamic> responseBody = json.decode(response.body);
    print("Response body is ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      //print("Response body is $responseBody");
      try {
        Map<String, dynamic> responseBody = json.decode(response.body);
        print("response body--");
        print(responseBody);
        SignInApiModel ss = new SignInApiModel();
        ss.accessToken = responseBody["accessToken"];
        ss.refreshToken = responseBody["refreshToken"];
        ss.payload?.userId = responseBody["payload"]["userId"];
        ss.payload?.roles = responseBody["payload"]["roles"];
        // print("printing box length ${SigninBox.length}");

        if(!kIsWeb){
        }
        var signInBox = Hive.box('SignInDatabase');
        signInBox.put("accessToken", responseBody["accessToken"]);
        signInBox.put("refreshToken", responseBody["refreshToken"]);
        signInBox.put("userId", responseBody["payload"]["userId"]);
        List<dynamic> roles = responseBody["payload"]["roles"];
        print(responseBody["payload"]["roles"].runtimeType);
        signInBox.put("roles", roles);
        //------STORING USER CREDENTIALS FROM DATABASE----------
        // UserCredentials.setAccessToken(signInBox.get("accessToken"));
        // UserCredentials.setRefreshToken(signInBox.get("refreshToken"));
        // List<dynamic> rolesList = signInBox.get("roles");
        // UserCredentials.setRoles(rolesList);
        // UserCredentials.setUserId(signInBox.get("userId"));

        //--------------------------------------------------------

        print("Sign in details saved to database");
        // Use signInResponse as needed


        return ss;
      } catch (e) {
        print("Error occurred during data parsing: $e");
        throw Exception('Failed to parse data');
      }
    } else {
      if (response.statusCode == 403) {
        print("In response.statusCode == 403");
        RefreshTokenAPI.refresh();
        return SignInAPI().signIN(username,password);
      }
      print("Code is ${response.statusCode}");
      return null;
    }
  }
  static Future<int> sendOtpForgetPassword(String user) async {

    String encryptDecrypt(String input, String key){
      StringBuffer result = StringBuffer();
      for (int i = 0; i < input.length; i++) {
        // XOR each character of the input with the corresponding character of the key
        result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
      }
      return result.toString();
    }
    final jsonEncoder = JsonEncoder();
    final String xaccesstoken = AppConfig.xaccesstoken;
    var headers = {
      'Content-Type': 'application/json',
      'x-access-token':xaccesstoken,
      'Authorization': 'e28cdb80-c69a-11ef-aa4e-e7aa7912987a',
      'X-Content-Type-Options': 'nosniff', // Prevent MIME sniffing
      'X-Frame-Options': 'SAMEORIGIN', // Prevent embedding in iframe
      'X-XSS-Protection': '1; mode=block', // Prevent reflected XSS attacks
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload', // Enforce HTTPS
      'Content-Security-Policy': "frame-ancestors 'self'", // Limit who can embed the app
      'Referrer-Policy': 'no-referrer', // Prevent sending referrer information
      'X-Permitted-Cross-Domain-Policies': 'none',
      'Pragma': 'no-cache',
      'Expires': '0',
    };
    var request = http.Request(
        'POST', Uri.parse('${AppConfig.baseUrl}/auth/otp/username'));
    var finalData=jsonEncoder.convert({"username": "${user}", "digits":4,"appId":"com.iwayplus.navigation"});
    final encryptedData = encryptDecrypt(finalData,'X7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=');
    request.body = json.encode({"encryptedData":encryptedData});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return 1;
    } else {
      print("response.reasonPhrase");
      print(response);
      return 0;
    }
  }
  static Future<int> changePassword(String user, String pass, String otp) async {
    final String xaccesstoken = AppConfig.xaccesstoken;
    String encryptDecrypt(String input, String key){
      StringBuffer result = StringBuffer();
      for (int i = 0; i < input.length; i++){
        // XOR each character of the input with the corresponding character of the key
        result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
      }
      return result.toString();
    }
    final jsonEncoder = JsonEncoder();
    var headers = {
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
    };
    var request = http.Request(
        'POST', Uri.parse('https://dev.iwayplus.in/auth/reset-password'));
    var finalData=jsonEncoder.convert({
      "username": "$user",
      "password": "$pass",
      "otp": "$otp",
      "appId":"com.iwayplus.navigation"
    });
    final encryptedData = encryptDecrypt(finalData,'X7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=');
    request.body = json.encode({"encryptedData":encryptedData.toString()});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return 1;
    } else {
      print("response.reasonPhrase");
      print(response.reasonPhrase);
      return 0;
    }
  }

}