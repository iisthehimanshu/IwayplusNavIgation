import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '/API/BuildingAPI.dart';
import '/API/buildingAllApi.dart';
import '/APIMODELS/DataVersion.dart';
import '/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import '/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '/Elements/HelperClass.dart';

import '../APIMODELS/beaconData.dart';
import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';


class DataVersionApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/data-version";
  static var signInBox = Hive.box('SignInDatabase');
  var versionBox = Hive.box('VersionData');
  String accessToken = signInBox.get("accessToken");


  Future<Map<String, dynamic>> fetchDataVersionApiData(String id) async {
    accessToken = signInBox.get("accessToken");

    final Map<String, dynamic> data = {
      "building_ID": id,
    };


    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );

    if (response.statusCode == 200) {
      print("DATA VERSION API DATA FROM API");
      Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      // print(responseBody);
      // print(DataVersion.fromJson(responseBody).versionData!.landmarksDataVersion);
      DataVersion DataVersionData = DataVersion.fromJson(responseBody);
      VersionInfo.patchDataVersion = DataVersionData.versionData!.patchDataVersion!;
      VersionInfo.buildingDataVersion = DataVersionData.versionData!.buildingDataVersion!;
      VersionInfo.polylineDataVersion = DataVersionData.versionData!.polylineDataVersion!;
      VersionInfo.landmarksDataVersion = DataVersionData.versionData!.landmarksDataVersion!;


      //versionBox.put("landmarksDataVersion", DataVersionData.versionData!.landmarksDataVersion);
      // print(DataVersionData.versionData!.buildingID);
      // if(!versionBox.containsKey(DataVersionData.versionData!.buildingID)) {
      //   print("VersionBox is empty");
      //   versionBox.put(
      //       DataVersionData.versionData!.buildingID, DataVersionData);
      //   //versionBox.close();
      // }else{
      //   print("VersionBox is notEmpty");
      // }
      // print(versionBox.keys);

      //List<DataVersionModel> DataVersionList = responseBody.map((data) => DataVersionModel.fromJson(data)).toList();


      // print(DataVersionList[0].landmarksDataVersion);

      return responseBody;
      // return DataVersionData;

    } else if (response.statusCode == 403) {

      print('DATA VERSION API in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;

      final Map<String, dynamic> data = {
        "building_ID": id,
      };


      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );

      if (response.statusCode == 200) {
        print("DATA VERSION API DATA FROM API");
        Map<String, dynamic> responseBody = json.decode(response.body);
        // print(responseBody);
        // print(DataVersion.fromJson(responseBody).versionData!.landmarksDataVersion);
        DataVersion DataVersionData = DataVersion.fromJson(responseBody);
        VersionInfo.patchDataVersion = DataVersionData.versionData!.patchDataVersion!;
        VersionInfo.buildingDataVersion = DataVersionData.versionData!.buildingDataVersion!;
        VersionInfo.polylineDataVersion = DataVersionData.versionData!.polylineDataVersion!;
        VersionInfo.landmarksDataVersion = DataVersionData.versionData!.landmarksDataVersion!;


        //versionBox.put("landmarksDataVersion", DataVersionData.versionData!.landmarksDataVersion);
        // print(DataVersionData.versionData!.buildingID);
        // if(!versionBox.containsKey(DataVersionData.versionData!.buildingID)) {
        //   print("VersionBox is empty");
        //   versionBox.put(
        //       DataVersionData.versionData!.buildingID, DataVersionData);
        //   //versionBox.close();
        // }else{
        //   print("VersionBox is notEmpty");
        // }
        // print(versionBox.keys);

        //List<DataVersionModel> DataVersionList = responseBody.map((data) => DataVersionModel.fromJson(data)).toList();


        // print(DataVersionList[0].landmarksDataVersion);

        return responseBody;
        // return DataVersionData;

      }else{
        HelperClass.showToast("response.statusCode");
        throw Exception('Failed to load data');
      }
    } else {
      print(response.statusCode);

      print("Mishorcheck");
      print(Exception);
      throw Exception('Failed to load beacon data');

    }
  }
}