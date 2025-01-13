import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/GlobalAnnotation.dart';
import 'RefreshTokenAPI.dart';


class GlobalAnnotation {

  String baseUrl = "https://dev.iwayplus.in/secured/get-global-annotation/";
  String token = "";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<MainModel> fetchGlobalAnnotationData(id) async {
    accessToken = signInBox.get("accessToken");


    final response = await http.get(
      Uri.parse(baseUrl+id),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final completeData = MainModel.fromJson(jsonData);
        print("globalannotation data $jsonData");
        return completeData;

    }else if (response.statusCode == 403) {
      print("WAYPOINT DATA FROM API IN 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      return fetchGlobalAnnotationData(id);
    }else {
      if(kDebugMode) {
        HelperClass.showToast("MishorError in WAYPOINT API API");
      }
      print("API Exception ${response.body}");
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}