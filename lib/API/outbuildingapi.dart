import 'dart:convert';

import 'package:geodesy/geodesy.dart';

import '../APIMODELS/outbuildingmodel.dart';
import 'guestloginapi.dart';
import "package:http/http.dart" as http;

class OutBuildingData{

 static Future<OutBuildingModel?> outBuildingData(double latitude1,double longitude1,double latitude2,double longitude2) async{
   String token="";
    await guestApi().guestlogin().then((value){
      if(value.accessToken != null) {
        token = value.accessToken!;
      }
    });





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
   // print(response.reasonPhrase);
      return null;
    }

  }
}