import 'dart:convert';

import 'package:geodesy/geodesy.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';

import '../APIMODELS/outbuildingmodel.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';
import "package:http/http.dart" as http;

class OutBuildingData{

 static Future<OutBuildingModel?> outBuildingData(double latitude1,double longitude1,double latitude2,double longitude2) async{
   var signInBox = Hive.box('SignInDatabase');
   String token = signInBox.get("accessToken");






    var headers = {
      'Content-Type': 'application/json',
      'x-access-token':'${token}'
    };
    var request = http.Request('POST', Uri.parse('https://dev.iwayplus.in/secured/outdoor-wayfinding/'));
    request.body = json.encode({
      "campusId": buildingAllApi.outdoorID,
      "source": [longitude1, latitude1],
      "destination": [longitude2, latitude2]
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res=await http.Response.fromStream(response);
      Map<String, dynamic> jsonMap = json.decode(res.body);
      return OutBuildingModel.fromJson(jsonMap);
      // print(await response.stream.bytesToString());
    }
    else {
      if (response.statusCode == 403) {
        RefreshTokenAPI.fetchPatchData();
        return OutBuildingData.outBuildingData(latitude1,longitude1,latitude2,longitude2);
      }
   // print(response.reasonPhrase);
      return null;
    }

  }
}