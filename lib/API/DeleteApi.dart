import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/Elements/HelperClass.dart';

import 'RefreshTokenAPI.dart';

class DeleteApi {
  static String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/user/delete" : "https://maps.iwayplus.in/secured/user/delete";
  static var signInBox = Hive.box('SignInDatabase');
  static String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  static Future<bool> deleteData() async {

    String userid = signInBox.get("userId");

    final Map<String, dynamic> data = {
      "userId": userid
    };

    final response = await http.delete(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );


    if (response.statusCode == 200) {
      print('DELETE API DONE 200');
      Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      HelperClass.showToast(responseBody['message']);
      return true;
    }else if (response.statusCode == 403) {
      print('DELETE API in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      final response = await http.delete(
        Uri.parse(baseUrl), body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );

      if (response.statusCode == 200) {
        print('DELETE API DONE 200 AFTER 403');
        Map<String, dynamic> responseBody = json.decode(response.body);
        print(responseBody);
        HelperClass.showToast(responseBody['message']);
        return true;
      }else{
        print('DELETE API NOT DONE AFTER 403');
        return false;
      }

    }
    else {
      HelperClass.showToast(response.statusCode.toString());
      return false;
    }
  }
}
