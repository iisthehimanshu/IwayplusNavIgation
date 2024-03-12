import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/buildingAll.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'guestloginapi.dart';

class buildingAllApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/all";
  String token = "";
  static String selectedID="";
  static String selectedVenue="";
  static List<String> allBuildingID = [];

  Future<List<buildingAll>> fetchBuildingAllData() async {
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();



    if(BuildingAllBox.length!=0){
      print("BUILDINGALL API DATA FROM DATABASE");
      print(BuildingAllBox.length);
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAll> buildingList = responseBody.map((data) => buildingAll.fromJson(data)).toList();

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
      print("BUILDINGALL API DATA FROM API");
      List<dynamic> responseBody = json.decode(response.body);
      final buildingData = BuildingAllAPIModel(responseBody: responseBody);
      BuildingAllBox.add(buildingData);
      buildingData.save();
      List<buildingAll> buildingList = responseBody.map((data) => buildingAll.fromJson(data)).toList();

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

  static void setStoredAllBuildingID(List<String> value){
    allBuildingID = value;
  }

  static List<String> getStoredAllBuildingID(){
    return allBuildingID;
  }


  // Method to set the stored string
  static void setStoredVenue(String value) {
    selectedVenue = value;
    //print("Set${selectedID}");
  }

  // Method to get the stored string
  static String getStoredVenue() {
    //print(selectedID);
    return selectedVenue;
  }

}