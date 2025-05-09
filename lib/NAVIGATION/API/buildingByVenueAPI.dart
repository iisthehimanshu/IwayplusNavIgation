import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/DATABASE/BOXES/BuildingByVenueAPIBOX.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/BuildingByVenueAPIModel.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/Buildingbyvenue.dart';
import '../config.dart';
import 'RefreshTokenAPI.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;


class Buildingbyvenueapi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/building/get/venue";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");


  Future<List<Buildingbyvenue>> fetchBuildingIDS(String id) async {
    //final BuildingByVenueBox = BuildingByVenueAPIBOX.getData();

    bool isInternetConnected = await HelperClass.checkInternetConnectivity();


    // if(!isInternetConnected && BuildingByVenueBox.length != 0){
    //   List<dynamic> responseBody = BuildingByVenueBox.get(0)!.responseBody;
    //   print("INTERNET IS NOT CONNECTED!! BUILDINGBYVENUE API DATA COMMING FROM DATABASE $responseBody");
    //   List<Buildingbyvenue> buildingList = responseBody.map((data) => Buildingbyvenue.fromJson(data)).toList();
    //   return buildingList;
    // }

    final Map<String, dynamic> data = {
      "venueName": id //venue Name
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      // final buildingByVenueData = BuildingByVenueAPIModel(responseBody: responseBody);
      print("BUILDINGBYVENUE API DATA FROM API $responseBody");
      //BuildingByVenueBox.add(buildingByVenueData);
      // buildingByVenueData.save();
      List<Buildingbyvenue> buildingList = responseBody.map((data) => Buildingbyvenue.fromJson(data)).toList();
      return buildingList;

    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return fetchBuildingIDS(id);
    } else {
      print("else ${response.body}");
      print(response.body);
      throw Exception('Failed to load landmark data');
    }
  }

  static Future<void> findBuildings({String? venue}) async {
    List<Buildingbyvenue> allBuildings = await Buildingbyvenueapi().fetchBuildingIDS(venue??buildingAllApi.selectedVenue).timeout(const Duration(seconds: 5), onTimeout: () {
      print("Timeout: Failed to fetch building IDS within 5 seconds");
      return []; // Return an empty list on timeout
    });
    if (allBuildings.isEmpty) return; // Exit if no buildings fetched
    String? selectedID;
    String? selectedBuildingID;
    Map<String, g.LatLng> allBuildingID = {};
    if (allBuildings.isNotEmpty){
      allBuildings.sort((a, b) => DateTime.parse(a.createdAt!).compareTo(DateTime.parse(b.createdAt!)));
      print("allBuildings ${allBuildings[0].sId}");

      for (var element in allBuildings){
        g.LatLng kk = g.LatLng(element.coordinates![0], element.coordinates![1]);
        allBuildingID[element.sId!] = kk;
      }
      print("allBuildingID.keys ${allBuildingID.keys.toList()}");
      selectedID = allBuildings[0].sId;
      selectedBuildingID = allBuildings[0].sId;
    }else{
      print("Failed to fetch building IDS: buildings is Empty");
    }
    if (selectedID != null && selectedBuildingID != null && allBuildingID.isNotEmpty) {
      buildingAllApi.selectedID = selectedID;
      buildingAllApi.selectedBuildingID = selectedBuildingID;
      buildingAllApi.allBuildingID = allBuildingID;
      print("Success to fetch building IDS: ${buildingAllApi.allBuildingID}");
    }else{
      print("Failed to fetch building IDS: selectedID $selectedID   selectedBuildingID $selectedBuildingID   allBuildingID ${allBuildingID.length}");
    }

  }
}