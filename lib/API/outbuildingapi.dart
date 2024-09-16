import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geodesy/geodesy.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';

import '../APIMODELS/outbuildingmodel.dart';
import '../Elements/HelperClass.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';
import "package:http/http.dart" as http;

class OutBuildingData{

  static Future<OutBuildingModel?> outBuildingData(double latitude1,double longitude1,double latitude2,double longitude2) async{
    var signInBox = Hive.box('SignInDatabase');
   String accessToken = signInBox.get("accessToken");
   String refreshToken = signInBox.get("refreshToken");


    var headers = {
      'Content-Type': 'application/json',
      'x-access-token':'${accessToken}'
    };
    var request = http.Request('POST', Uri.parse(kDebugMode? 'https://dev.iwayplus.in/secured/outdoor-wayfinding/' : 'https://maps.iwayplus.in/secured/outdoor-wayfinding/'));
    request.body = json.encode({
      "campusId": buildingAllApi.outdoorID,
      "source": [longitude1, latitude1],
      "destination": [longitude2, latitude2]
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("OUTBUILDINGAPI DATA FROM API");
      var res=await http.Response.fromStream(response);
      Map<String, dynamic> jsonMap = json.decode(res.body);
      return OutBuildingModel.fromJson(jsonMap);
      // print(await response.stream.bytesToString());
    }else if (response.statusCode == 403) {
      print("OUTBUILDING API in error 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      var headers = {
        'Content-Type': 'application/json',
        'x-access-token':'${accessToken}'
      };
      var request = http.Request('POST', Uri.parse('https://dev.iwayplus.in/secured/google/routing'));
      request.body = json.encode({
        "source": {
          "lat": latitude1,
          "lng": longitude1
        },
        "destination": {
          "lat": latitude2,
          "lng": longitude2,
        }
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print("OUTBUILDINGAPI DATA FROM API AFTER 403");
        var res=await http.Response.fromStream(response);
        return OutBuildingModel.fromJson(json.decode(res.body));
      }else{
        print("OUTBUILDINGAPI DATA EMPTY FROM API AFTER 403");
        return null;
      }
    } else {
      HelperClass.showToast("MishorError in Outbuilding API");
      return null;
    }

  }
}