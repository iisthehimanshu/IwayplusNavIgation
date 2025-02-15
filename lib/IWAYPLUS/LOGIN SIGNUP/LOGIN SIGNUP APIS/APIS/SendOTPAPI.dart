import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../../../NAVIGATION/config.dart';
class SendOTPAPI{
  final String baseUrl = "${AppConfig.baseUrl}/auth/otp/send";
  final String xaccesstoken = AppConfig.xaccesstoken;
  final jsonEncoder = JsonEncoder();
  String encryptDecrypt(String input, String key){
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++){
      //XOR each character of the input with the corresponding character of the key
      result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }
  Future<bool> sendOTP(String username)async{
    final Map<String, dynamic> data={
      "username": username,
      "digits":4,
      "appName":"IWAYMAPS"
    };
    var finalData=jsonEncoder.convert(data);
    final encryptedData = encryptDecrypt(finalData,'X7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=');
    print("encrypted data ${encryptedData.toString()}");
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode({"encryptedData":encryptedData.toString()}),
      headers:{
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

    if (response.statusCode == 200) {
      return true;
      // return HelperClass.showToast("OTP sent successfully");
    } else {
      print("SendOTPAPI--response.statusCode${response.statusCode} ${response.body}");
      return false;
    }
  }
}