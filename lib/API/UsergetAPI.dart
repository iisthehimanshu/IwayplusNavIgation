import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/APIMODELS/UsergetAPIModel.dart';
import 'package:iwaymaps/Elements/UserCredential.dart';

import '../Elements/HelperClass.dart';
import 'RefreshTokenAPI.dart';


class UsergetAPI{

  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/user/get" : "https://maps.iwayplus.in/secured/user/get";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  var userInfoBox=Hive.box('UserInformation');

  Future<void> getUserDetailsApi(String userId) async {
    print('ingetuser');

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode({"userId": userId}),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      print('UsergetAPI FROM API');
      UsergetAPIModel currentUsergetAPI = UsergetAPIModel.fromJson(responseBody);
      print("response.statusCode--");
      print(currentUsergetAPI);
      UserCredentials().setUserId(currentUsergetAPI.sId!);
      userInfoBox.put("sId", currentUsergetAPI.sId);
      userInfoBox.put("name", currentUsergetAPI.name);
      userInfoBox.put("updatedAt", currentUsergetAPI.updatedAt);
      userInfoBox.put("createdAt", currentUsergetAPI.createdAt);
      userInfoBox.put("iV", currentUsergetAPI.iV);
      userInfoBox.put("roles", currentUsergetAPI.roles);
      userInfoBox.put("appId", currentUsergetAPI.appId);
      userInfoBox.put("disabilities", currentUsergetAPI.disabilities);
      userInfoBox.put("dob", currentUsergetAPI.dob);
      userInfoBox.put("email", currentUsergetAPI.email);
      userInfoBox.put("gender", currentUsergetAPI.gender);
      userInfoBox.put("favourites", currentUsergetAPI.favourites);
      userInfoBox.put("mobile", currentUsergetAPI.mobile);
      userInfoBox.put("mobileVerification", currentUsergetAPI.mobileVerification);
      userInfoBox.put("username", currentUsergetAPI.username);
      print(userInfoBox.keys);


    } else if (response.statusCode == 403) {
      print('UsergetAPI in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;

      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({"userId": userId}),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        print('UsergetAPI in 403');
        UsergetAPIModel currentUsergetAPI = UsergetAPIModel.fromJson(responseBody);
        print("response.statusCode--");
        print(currentUsergetAPI);
        UserCredentials().setUserId(currentUsergetAPI.sId!);
        userInfoBox.put("sId", currentUsergetAPI.sId);
        userInfoBox.put("name", currentUsergetAPI.name);
        userInfoBox.put("updatedAt", currentUsergetAPI.updatedAt);
        userInfoBox.put("createdAt", currentUsergetAPI.createdAt);
        userInfoBox.put("iV", currentUsergetAPI.iV);
        userInfoBox.put("roles", currentUsergetAPI.roles);
        userInfoBox.put("appId", currentUsergetAPI.appId);
        userInfoBox.put("disabilities", currentUsergetAPI.disabilities);
        userInfoBox.put("dob", currentUsergetAPI.dob);
        userInfoBox.put("email", currentUsergetAPI.email);
        userInfoBox.put("gender", currentUsergetAPI.gender);
        userInfoBox.put("favourites", currentUsergetAPI.favourites);
        userInfoBox.put("mobile", currentUsergetAPI.mobile);
        userInfoBox.put("mobileVerification", currentUsergetAPI.mobileVerification);
        userInfoBox.put("username", currentUsergetAPI.username);
        print(userInfoBox.keys);


      }else{
        HelperClass.showToast('Failed to load data');
        throw Exception('Failed to load data');
      }
    } else {
      HelperClass.showToast('Failed to load data');
      throw Exception('Failed to load data');
    }


  }

}