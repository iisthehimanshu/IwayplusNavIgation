import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/NAVIGATION/APIMODELS/outdoormodel.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/DataVersion.dart';
import '../APIMODELS/DataVersionApiMultipleModel.dart';
import '../DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import '../DATABASE/BOXES/DataVersionMultipleLocalModelBOX.dart';
import '../DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '../DATABASE/DATABASEMODEL/DataVersionMultipleLocalModel.dart';
import '../config.dart';

import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';


class DataVersionApiMultiple {
  final String baseUrl = "${AppConfig.baseUrl}/secured/data-versions-multiple";
  static var signInBox = Hive.box('SignInDatabase');
  var versionBox = Hive.box('VersionData');
  String accessToken = signInBox.get("accessToken");

  final DataBox = DataVersionMultipleLocalModelBOX.getData();
  bool shouldBeInjected = false;

  Future<void> fetchDataVersionApiData(String venuename) async {
    accessToken = signInBox.get("accessToken");

    final Map<String, dynamic> data = {
      "venueName": "${venuename}"
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
      print("DATA VERSION API MULTIPLE DATA FROM API");
      List<dynamic> res = json.decode(response.body);
      print("Total entries: ${res.length}");
      print(DataBox.keys);
      print(DataBox.values);

      for (var item in res) {
        DataVersionApiMultipleModel model = DataVersionApiMultipleModel.fromJson(item);
        if(DataBox.containsKey(model.buildingID)){
          print('DATA ALREADY PRESENT');
          final dataBaseData = DataBox.get(model.buildingID)?.responseBody;
          final modelConvertedDataBaseData = DataVersionApiMultipleModel.fromJson(dataBaseData);
          print("Building-- ${modelConvertedDataBaseData.buildingID}");
          print(modelConvertedDataBaseData.buildingID);
          if (model.buildingDataVersion != modelConvertedDataBaseData.buildingDataVersion) {
            VersionInfo.buildingBuildingDataVersionUpdate[model.buildingID!] = true;
            shouldBeInjected = true;
            print("Building Version Change = true ${model.buildingDataVersion} ${modelConvertedDataBaseData.buildingDataVersion}");
          } else {
            VersionInfo.buildingBuildingDataVersionUpdate[model.buildingID!] = false;
            print("Building Version Change = false");
          }

          if (model.patchDataVersion != modelConvertedDataBaseData.patchDataVersion) {
            VersionInfo.buildingPatchDataVersionUpdate[model.buildingID!] = true;
            shouldBeInjected = true;
            print("Patch Version Change = true ${model.patchDataVersion} ${modelConvertedDataBaseData.patchDataVersion}");
          } else {
            VersionInfo.buildingPatchDataVersionUpdate[model.buildingID!] = false;
            print("Patch Version Change = false");
          }

          if (model.landmarksDataVersion != modelConvertedDataBaseData.landmarksDataVersion) {
            VersionInfo.buildingLandmarkDataVersionUpdate[model.buildingID!] = true;
            shouldBeInjected = true;
            print("Landmark Version Change = true ${model.landmarksDataVersion} ${modelConvertedDataBaseData.landmarksDataVersion}");
          } else {
            VersionInfo.buildingLandmarkDataVersionUpdate[model.buildingID!] = false;
            print("Landmark Version Change = false");
          }

          if (model.polylineDataVersion != modelConvertedDataBaseData.polylineDataVersion) {
            VersionInfo.buildingPolylineDataVersionUpdate[model.buildingID!] = true;
            shouldBeInjected = true;
            print("Polyline Version Change = true ${model.polylineDataVersion} ${modelConvertedDataBaseData.polylineDataVersion}");
          } else {
            VersionInfo.buildingPolylineDataVersionUpdate[model.buildingID!] = false;
            print(VersionInfo.buildingPolylineDataVersionUpdate[model!.buildingID!]);
            print("Polyline Version Change = false");
          }
          if (shouldBeInjected) {
            final dataVersionData = DataVersionLocalModel(responseBody: item);
            DataBox.delete(model.buildingID);
            print("database deleted ${model.buildingID}");
            DataBox.put(model.buildingID, item);
            print("New DATA INJECTED ${model.buildingID} ${dataVersionData}");
            dataVersionData.save();
          }

        }else{
          print('DATA NOT PRESENT');
          VersionInfo.buildingBuildingDataVersionUpdate[model.buildingID!] = false;
          VersionInfo.buildingPatchDataVersionUpdate[model.buildingID!] = false;
          VersionInfo.buildingLandmarkDataVersionUpdate[model.buildingID!] = false;
          VersionInfo.buildingPolylineDataVersionUpdate[model.buildingID!] = false;
          if (!shouldBeInjected) {
            print('New DATA INJECTED');
            final dataVersionData = DataVersionMultipleLocalModel(responseBody: item);
            DataBox.put(model.buildingID, dataVersionData);
            dataVersionData.save();
          }
          DataBox.put(model.buildingID, DataVersionMultipleLocalModel(responseBody: item));
        }
      }
    } else if (response.statusCode == 403) {
      print('DATA VERSION API in error 403');
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;

      final Map<String, dynamic> data = {
        "venueName": "Ashoka University"
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
        print("DATA VERSION API DATA FROM API AFTER 403");
        Map<String, dynamic> responseBody = json.decode(response.body);
        final apiData = DataVersion.fromJson(responseBody);

      } else {
        HelperClass.showToast("Unable to load session!! Try again");
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