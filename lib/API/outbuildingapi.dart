import 'dart:convert';

import 'package:geodesy/geodesy.dart';
import 'package:hive/hive.dart';

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
      var res=await http.Response.fromStream(response);
      return buildingData(res.body);
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