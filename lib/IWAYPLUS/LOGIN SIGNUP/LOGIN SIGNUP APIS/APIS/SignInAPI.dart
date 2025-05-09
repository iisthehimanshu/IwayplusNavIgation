import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../NAVIGATION/Encryption/EncryptionService.dart';
import '../../../../NAVIGATION/config.dart';
import '../MODELS/SignInAPIModel.dart';

class SignInAPI{
  Encryptionservice encryptionService = Encryptionservice();
  final String baseUrl = "${AppConfig.baseUrl}/auth/signin2";

  Future<SignInApiModel?> signIN(String username, String password) async {

    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
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

    //Map<String, dynamic> responseBody = json.decode(response.body);
    print("Response body is ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseBody = json.decode(response.body);
        print("response body--");
        print(responseBody);
        SignInApiModel ss = new SignInApiModel();
        ss.accessToken = responseBody["accessToken"];
        ss.refreshToken = responseBody["refreshToken"];
        ss.payload?.userId = responseBody["payload"]["userId"];
        ss.payload?.roles = responseBody["payload"]["roles"];
        saveInDatabase(responseBody);
        return ss;
      } catch (e) {
        print("Error occurred during data parsing: $e");
        throw Exception('Failed to parse data');
      }
    } else {
      print("Code is ${response.statusCode}");
      return null;
    }
  }

  void saveInDatabase(Map<String, dynamic> responseBody){
    var signInBox = Hive.box('SignInDatabase');
    signInBox.put("accessToken", responseBody["accessToken"]);
    signInBox.put("refreshToken", responseBody["refreshToken"]);
    signInBox.put("userId", responseBody["payload"]["userId"]);
    List<dynamic> roles = responseBody["payload"]["roles"];
    print(responseBody["payload"]["roles"].runtimeType);
    signInBox.put("roles", roles);

    print("Sign in details saved to database");
  }

  Future<int> sendOtpForgetPassword(String user) async {
    final Map<String, dynamic> data = {"username": "${user}", "digits":4,"appId":"com.iwayplus.candor"};
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/otp/username'),
      body: encryptionService.encrypt(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': encryptionService.authorization,
      },
    );
    print("sendOtpForgetPassword");
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      response.body;
      print(response.body);
      return 1;
    }else {
      print("response.reasonPhrase");
      print(response.reasonPhrase);
      return 0;
    }
  }

  Future<int> changePassword(String user, String pass, String otp) async {
    final Map<String, dynamic> data = {
      "username": "$user",
      "password": "$pass",
      "otp": "$otp",
      "appId":"com.iwayplus.candor"

    };
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/reset-password'),
      body: encryptionService.encrypt(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': encryptionService.authorization,
      },
    );
    print("response while changing pass");
    // print(response);
    if (response.statusCode == 200) {
      print(await response.body);
      return 1;
    } else {
      print("response.reasonPhrase");
      print(response.body);
      return 0;
    }
  }

}