import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/API/BuildingAPI.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/APIMODELS/DataVersion.dart';
import 'package:iwaymaps/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';

import '../APIMODELS/beaconData.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';


class DataVersionApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/data-version";
  var signInBox = Hive.box('SignInDatabase');
  var versionBox = Hive.box('VersionData');
  String token = "";


  Future<dynamic> fetchDataVersionApiData({String? id}) async {
    token = signInBox.get("accessToken");

    final Map<String, dynamic> data = {
      "building_ID": id??buildingAllApi.getStoredString(),
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
      print("DATA VERSION API DATA FROM API");
      Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      print(DataVersion.fromJson(responseBody).versionData!.landmarksDataVersion);
      DataVersion DataVersionData = DataVersion.fromJson(responseBody);
      //versionBox.put("landmarksDataVersion", DataVersionData.versionData!.landmarksDataVersion);
      print(DataVersionData.versionData!.buildingID);
      if(!versionBox.containsKey(DataVersionData.versionData!.buildingID)) {
        print("VersionBox is empty");
        versionBox.put(
            DataVersionData.versionData!.buildingID, DataVersionData);
        //versionBox.close();
      }else{
        print("VersionBox is notEmpty");
      }
      print(versionBox.keys);

      //List<DataVersionModel> DataVersionList = responseBody.map((data) => DataVersionModel.fromJson(data)).toList();


      // print(DataVersionList[0].landmarksDataVersion);

      return DataVersion.fromJson(responseBody);

    } else {
      print(response.statusCode);

      print("Mishorcheck");
      print(Exception);
      throw Exception('Failed to load beacon data');

    }
  }
}