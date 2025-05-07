import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../NAVIGATION/Encryption/EncryptionService.dart';
import '../../../../NAVIGATION/config.dart';

class SendOTPAPI{
  Encryptionservice encryptionService = Encryptionservice();
  final String baseUrl = "${AppConfig.baseUrl}/auth/otp/send";
  Future<bool> sendOTP(String username) async {
    final Map<String, dynamic> data = {
      "username": username,
      "digits":4,
      "appName":"Speja"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: encryptionService.encrypt(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token':encryptionService.authorization
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("SendOTPAPI--response.statusCode${response.statusCode} ${response.body}");
      return false;
    }
  }
}