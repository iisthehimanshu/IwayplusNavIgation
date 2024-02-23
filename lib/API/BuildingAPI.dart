import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../APIMODELS/BuildingAPIModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'buildingAllApi.dart';
import 'guestloginapi.dart';
import 'package:hive/hive.dart';


class BuildingAPI {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/get/venue";
  String token = "";

  Future<BuildingAPIModel> fetchBuildData() async {
    // final LandMarkBox = LandMarkApiModelBox.getData();
    //
    // if(LandMarkBox.containsKey(buildingAllApi.getStoredString())){
    //   print("LANDMARK DATA FORM DATABASE ");
    //   // print("DATABASE SIZE: ${LandMarkBox.length}");
    //   //print(LandMarkBox.getAt(0)?.responseBody.values);
    //   Map<String, dynamic> responseBody = LandMarkBox.get(buildingAllApi.getStoredString())!.responseBody;
    //   print(LandMarkBox.keys);
    //   // print("object ${responseBody['landmarks'][0].runtimeType}");
    //   return land.fromJson(responseBody);
    // }

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "venueName": buildingAllApi.getStoredVenue(),
    };
    print("inside land");
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );
    print("response code in land is ${response.statusCode}");
    if (response.statusCode == 200) {
      Map<String,dynamic> responseBody = json.decode(response.body);
      //final LandMarkBox = LandMarkApiModelBox.getData();

      print(responseBody);
      print('BUILDING DATA FROM API');
      // print(LandMarkBox.length);
      //LandMarkApiModel? demoresponseBody = LandMarkBox.getAt(0);
      //print(demoresponseBody?.responseBody);
      // LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);

      // print(LandMarkBox.length);
      // print('TESTING LANDMARK API DATABASE OVER');
      //landmarkData.save();

      //print("object ${responseBody['landmarks'][0].runtimeType}");
      return BuildingAPIModel.fromJson(responseBody);
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}

