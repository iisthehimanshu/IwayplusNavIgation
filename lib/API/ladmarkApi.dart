import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'buildingAllApi.dart';
import 'guestloginapi.dart';
import 'package:hive/hive.dart';


class landmarkApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/landmarks";
  String token = "";

  Future<land> fetchLandmarkData() async {
    final LandMarkBox = LandMarkApiModelBox.getData();

    if(LandMarkBox.containsKey(buildingAllApi.getStoredString())){
      print("LANDMARK DATA FORM DATABASE ");
      Map<String, dynamic> responseBody = LandMarkBox.get(buildingAllApi.getStoredString())!.responseBody;
      print(LandMarkBox.keys);
      return land.fromJson(responseBody);
    }

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": buildingAllApi.getStoredString(),
    };
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      String APITime = responseBody['landmarks'][0]['updatedAt']!;
      final landmarkData = LandMarkApiModel(responseBody: responseBody);
      if(!LandMarkBox.containsKey(buildingAllApi.getStoredString())){
        print('LANDMARK DATA FROM API');
        LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);
        landmarkData.save();
        return land.fromJson(responseBody);
      }else{
        Map<String, dynamic> databaseresponseBody = LandMarkBox.get(buildingAllApi.getStoredString())!.responseBody;
        String LastUpdatedTime = databaseresponseBody['landmarks'][0]['updatedAt']!;
        print("APITime");
        if(APITime==LastUpdatedTime){
          print("LANDMARK DATA FROM DATABASE");
          print("Current Time: ${APITime} Lastupdated Time: ${LastUpdatedTime}");
          return land.fromJson(databaseresponseBody);
        }else{
          print("LANDMARK DATA FROM DATABASE AND UPDATED");
          print("Current Time: ${APITime} Lastupdated Time: ${LastUpdatedTime}");
          LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);
          landmarkData.save();
          return land.fromJson(responseBody);
        }
      }
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}

