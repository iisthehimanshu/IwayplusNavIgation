import 'dart:collection';
import 'dart:convert';
import 'package:geodesy/geodesy.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import 'package:iwayplusnav/Elements/HelperClass.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/buildingAll.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';

class buildingAllApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/all";
  var signInBox = Hive.box('SignInDatabase');
  String token = "";
  static String selectedID="";
  static String selectedBuildingID="";
  static String selectedVenue="";
  static HashMap<String,LatLng> allBuildingID = new HashMap();
  static String outdoorID = "";


  Future<List<buildingAll>> fetchBuildingAllData() async {
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();
    token = signInBox.get("accessToken");
    print("checking wilson");
    print(token);

    if(BuildingAllBox.length!=0){
      print("BUILDINGALL API DATA FROM DATABASE");
      print(BuildingAllBox.length);
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAll> buildingList = responseBody.map((data) => buildingAll.fromJson(data)).toList();
      return buildingList;
    }

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
      print("InbuildingAllApi");
      print(response.statusCode);
      if (response.statusCode == 403) {
        print("In response.statusCode == 403");
        print(token);
        RefreshTokenAPI.fetchPatchData();
        print("newToken");
        token = signInBox.get("accessToken");
        return buildingAllApi().fetchBuildingAllData();
      }
      print(response.statusCode);
      print(response.body);
      HelperClass.showToast("MishorError in BuildingAll API");
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

  static HashMap<String,LatLng> getStoredAllBuildingID(){
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