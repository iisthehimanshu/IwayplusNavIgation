import 'dart:collection';
import 'dart:convert';
import 'package:geodesy/geodesy.dart';
import 'package:http/http.dart' as http;
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/buildingAll.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import '../DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import '../DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import 'guestloginapi.dart';

class buildingAllApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/all";
  String token = "";
  static String selectedID="65d88662db333f894570bad3";
  static String selectedBuildingID="65d88662db333f894570bad3";
  static String selectedVenue="";
  static Map<String,LatLng> allBuildingID = {"65d88662db333f894570bad3": LatLng( 28.71644, 77.11121),
  };
  static String outdoorID = "";


  void checkForUpdate() async {
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();

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
      List<dynamic> responseBody = json.decode(response.body);
      final buildingData = BuildingAllAPIModel(responseBody: responseBody);
      String APITime = responseBody[0]['updatedAt']!;

      if(BuildingAllBox.length==0){
        print("BUILDINGALL UPDATE BOX EMPTY AND SAVED IN THE DATABASE");
        BuildingAllBox.add(buildingData);
        buildingData.save();
      }else{
        List<dynamic> databaseresponseBody = BuildingAllBox.getAt(0)!.responseBody;
        String LastUpdatedTime = databaseresponseBody[0]['updatedAt']!;
        if(APITime != LastUpdatedTime){
          print("BUILDINGALL UPDATE API DATA FROM DATABASE AND UPDATED");
          print("Current Time: ${APITime} Last updated Time: ${LastUpdatedTime}");
          BuildingAllBox.add(buildingData);
          buildingData.save();
        }
      }
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }

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
      List<dynamic> responseBody = json.decode(response.body);
      final buildingData = BuildingAllAPIModel(responseBody: responseBody);
      print("BUILDING API DATA FROM API");
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
  static Future<void> setStoredString(String value) async {
    selectedID = value;
    return;
  }

  // Method to get the stored string
  static String getStoredString() {
    return selectedID;
  }

  static void setStoredAllBuildingID(HashMap<String,LatLng> value){
    allBuildingID = value;
  }

  static Map<String,LatLng> getStoredAllBuildingID(){
    return allBuildingID;
  }


  // Method to set the stored string
  static void setStoredVenue(String value) {
    selectedVenue = value;
    //print("Set${selectedID}");
  }

  static void setSelectedBuildingID(String value)async{
    print("inside inside set id $value");
    selectedBuildingID = value;
    return;
  }

  static String getSelectedBuildingID() {
    return selectedBuildingID;
  }

  // Method to get the stored string
  static String getStoredVenue() {
    //print(selectedID);
    return selectedVenue;
  }

}