import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/buildingAllModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'guestloginapi.dart';

class buildingAllApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/all";
  String token = "";
  static String selectedID="";

  Future<List<buildingAllModel>> fetchBuildingAllData() async {
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();

    if(BuildingAllBox.length!=0){
      print("BUILDING API DATA FROM DATABASE");
      print(BuildingAllBox.length);
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAllModel> buildingList = responseBody.map((data) => buildingAllModel.fromJson(data)).toList();

      return buildingList;
    }

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );
    if (response.statusCode == 200) {
      print("BUILDING API DATA FROM API");
      List<dynamic> responseBody = json.decode(response.body);
      final buildingData = BuildingAllAPIModel(responseBody: responseBody);
      BuildingAllBox.add(buildingData);
      List<buildingAllModel> buildingList = responseBody.map((data) => buildingAllModel.fromJson(data)).toList();
      return buildingList;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
  // Method to set the stored string
  static void setStoredString(String value) {
    selectedID = value;
    print("Set${selectedID}");
  }

  // Method to get the stored string
  static String getStoredString() {
    print(selectedID);
    return selectedID;
  }

}