import 'dart:convert';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '/IWAYPLUS/DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';

import '/IWAYPLUS/APIMODELS/LocalNotificationAPIModel.dart';
import '../DATABASE/BOXES/LocalNotificationAPIDatabaseModelBOX.dart';

class LocalNotificationAPI{
  final String baseUrl = kDebugMode? 'https://dev.iwayplus.in/secured/get-notifications?page=-1&appId=com.iwayplus.navigation' : 'https://dev.iwayplus.in/secured/get-notifications?page=-1&appId=com.iwayplus.navigation';
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");
  final NotifiBox = LocalNotificationAPIDatabaseModelBOX.getData();
  Future<List<NotificationsInLocalNotificationModule>> getNotifications()async {
    List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    bool deviceConnected = false;
    // if(connectivityResult.contains(ConnectivityResult.mobile)){
    //   deviceConnected = true;
    // }else if(connectivityResult.contains(ConnectivityResult.wifi) ){
    //   deviceConnected = true;
    // }
    if(!deviceConnected && NotifiBox.containsKey("com.iwayplus.navigation")){
      print("LocalNotificationAPI DATA FROM DATABASE");
      Map<String, dynamic> responseBody = NotifiBox.get("com.iwayplus.navigation")!.responseBody;
      LocalNotificationAPIModel notificationData =LocalNotificationAPIModel.fromJson(responseBody);
      List<NotificationsInLocalNotificationModule> notificationsList = notificationData.notifications!;
      return notificationsList;
    }
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
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
      print("LocalNotificationAPI DATA FROM API");
      Map<String, dynamic> responseBody =  json.decode(response.body);
      LocalNotificationAPIModel notificationData =LocalNotificationAPIModel.fromJson(responseBody);
      List<NotificationsInLocalNotificationModule> notificationsList = notificationData.notifications!;
      final notificationSaveData = LocalNotificationAPIDatabaseModel(responseBody: responseBody);
      NotifiBox.put("com.iwayplus.navigation", notificationSaveData);
      notificationSaveData.save();
      return notificationsList;
    }
    else {
    print(response.reasonPhrase);
    return [];
    }
  }
}