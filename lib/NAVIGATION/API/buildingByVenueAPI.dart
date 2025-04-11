import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/API/buildingAllApi.dart';
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
      List<Buildingbyvenue> buildingList = responseBody.map((data) => Buildingbyvenue.fromJson(data)).toList();
      return buildingList;

    } else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return fetchBuildingIDS(id);
    } else {
      print(response.body);
      throw Exception('Failed to load landmark data');
    }
  }

  static void findBuildings(List<Buildingbyvenue> allBuildings){
    try {
      String? selectedID;
      String? selectedBuildingID;
      Map<String, g.LatLng> allBuildingID = {};
      List<Buildingbyvenue> buildings = [];

      for (var building in allBuildings) {
        if (building.venueName == buildingAllApi.selectedVenue) {
          buildings.add(building);
        }
      }

      if (buildings.isNotEmpty) {
        for (var element in buildings) {
          g.LatLng kk = g.LatLng(
              element.coordinates![0], element.coordinates![1]);
          allBuildingID[element.sId!] = kk;
        }
        selectedID = allBuildingID.keys.first;
        selectedBuildingID = allBuildingID.keys.first;
      }


      if (selectedID != null && selectedBuildingID != null &&
          allBuildingID.isNotEmpty) {
        buildingAllApi.selectedID = selectedID;
        buildingAllApi.selectedBuildingID = selectedBuildingID;
        buildingAllApi.allBuildingID = allBuildingID;
      }
    }catch(e){
      print("Failed to fetch building IDS");
    }
  }

}