import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'guestloginapi.dart';
import 'package:hive/hive.dart';


class landmarkApi {
  final String baseUrl = "https://maps.iwayplus.in/secured/landmarks";
  String token = "";

  Future<land> fetchLandmarkData() async {
    final LandMarkBox = LandMarkApiModelBox.getData();

    if(LandMarkBox.length!=0){
      // print("COMING FROM DATABASE ");
      // print("DATABASE SIZE: ${LandMarkBox.length}");
      //print(LandMarkBox.getAt(0)?.responseBody.values);
      Map<String, dynamic> responseBody = LandMarkBox.getAt(0)!.responseBody;
     // print("object ${responseBody['landmarks'][0].runtimeType}");
      return land.fromJson(responseBody);
    }

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": "659001bce6c204e1eec04c0f",
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
      Map<String, dynamic> responseBody = json.decode(response.body);
      //final LandMarkBox = LandMarkApiModelBox.getData();
      final landmarkData = LandMarkApiModel(responseBody: responseBody);

      //print('TESTING LANDMARK API DATABASE START');
      // print(LandMarkBox.length);
      //LandMarkApiModel? demoresponseBody = LandMarkBox.getAt(0);
      //print(demoresponseBody?.responseBody);
      LandMarkBox.add(landmarkData);

      // print(LandMarkBox.length);
      // print('TESTING LANDMARK API DATABASE OVER');
      //landmarkData.save();

      //print("object ${responseBody['landmarks'][0].runtimeType}");
      return land.fromJson(responseBody);
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}

