import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../APIMODELS/QRDataAPIModel.dart';


class QRDataAPI{
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<List<QRDataAPIModel>?> fetchQRData(String id)async{
    final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/building-qrs/$id" : "https://maps.iwayplus.in/secured/building-qrs/$id";

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<QRDataAPIModel> qrDataList = jsonResponse
          .map((data) => QRDataAPIModel.fromJson(data))
          .toList();
      print("QRDataAPI DATA FROM API");
      return qrDataList;

    }else{
      return null;
    }
  }
}