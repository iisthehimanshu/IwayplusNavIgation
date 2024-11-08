import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../APIMODELS/QRDataAPIModel.dart';


class QRDataAPI{
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<List<QRDataAPIModel>?> fetchQRData(List<String> id)async{
    print("IDfetchQRData");
    print(id);
    final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/building-qrs" : "https://maps.iwayplus.in/secured/building-qrs";
    final Map<String, dynamic> data = {
      "buildingIds": id
    };
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      print("QRDataAPI DATA FROM API");
      print(jsonResponse);
      List<QRDataAPIModel> qrDataList = jsonResponse
          .map((data) => QRDataAPIModel.fromJson(data))
          .toList();
      return qrDataList;
    }else{
      return null;
    }
  }
}