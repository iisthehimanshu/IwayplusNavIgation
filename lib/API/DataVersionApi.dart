import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import '../DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
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
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/data-version" : "https://maps.iwayplus.in/secured/data-version";
  static var signInBox = Hive.box('SignInDatabase');
  var versionBox = Hive.box('VersionData');
  String accessToken = signInBox.get("accessToken");

  final DataBox = DataVersionLocalModelBOX.getData();
  bool shouldBeInjected = false;

  Future<void> fetchDataVersionApiData(String id) async {
    accessToken = signInBox.get("accessToken");

    final Map<String, dynamic> data = {
      "building_ID": id,
    };

    try {
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
        final apiData = DataVersion.fromJson(responseBody);
        print("apiData.versionData!.buildingID");
        print(apiData.versionData!.buildingID);

        if (DataBox.containsKey(apiData.versionData!.buildingID)) {
          print('DATA ALREADY PRESENT');
          final databaseData = DataVersion.fromJson(
              DataBox.get(apiData.versionData!.buildingID)!.responseBody);
          if (apiData.versionData!.buildingDataVersion !=
              databaseData.versionData!.buildingDataVersion) {
            print("match ${apiData.versionData!.buildingID!} and $id");
            VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!
                .buildingID!] = true;
            shouldBeInjected = true;
            print("Building Version Change = true ${apiData.versionData!
                .buildingDataVersion} ${databaseData.versionData!
                .buildingDataVersion}");
          } else {
            print("match ${apiData.versionData!.buildingID!} and $id");

            VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            print("Building Version Change = false");
          }

          if (apiData.versionData!.patchDataVersion !=
              databaseData.versionData!.patchDataVersion) {
            VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                .buildingID!] = true;
            shouldBeInjected = true;
            print("Patch Version Change = true ${apiData.versionData!
                .patchDataVersion} ${databaseData.versionData!
                .patchDataVersion}");
          } else {
            print("match ${apiData.versionData!.buildingID!} and $id");

            VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            print("Patch Version Change = false");
          }

          if (apiData.versionData!.landmarksDataVersion !=
              databaseData.versionData!.landmarksDataVersion) {
            VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                .buildingID!] = true;
            shouldBeInjected = true;
            print("Landmark Version Change = true ${apiData.versionData!
                .landmarksDataVersion} ${databaseData.versionData!
                .landmarksDataVersion}");
          } else {
            print("match ${apiData.versionData!.buildingID!} and $id");

            VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            print("Landmark Version Change = false");
          }

          if (apiData.versionData!.polylineDataVersion !=
              databaseData.versionData!.polylineDataVersion) {
            VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                .buildingID!] = true;
            shouldBeInjected = true;
            print("Polyline Version Change = true ${apiData.versionData!
                .polylineDataVersion} ${databaseData.versionData!
                .polylineDataVersion}");
          } else {
            print("match ${apiData.versionData!.buildingID!} and $id");

            VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            print(VersionInfo.buildingPolylineDataVersionUpdate[apiData
                .versionData!.buildingID!]);
            print(apiData.versionData!.buildingID!);
            print("Polyline Version Change = false");
          }
          if (shouldBeInjected) {
            final dataVersionData = DataVersionLocalModel(
                responseBody: responseBody);
            DataBox.delete(DataVersion
                .fromJson(responseBody)
                .versionData!
                .buildingID);
            print("database deleted ${DataBox.containsKey(DataVersion
                .fromJson(responseBody)
                .versionData!
                .buildingID)}");
            DataBox.put(DataVersion
                .fromJson(responseBody)
                .versionData!
                .buildingID, dataVersionData);
            print("New Data ${DataVersion
                .fromJson(responseBody)
                .versionData!
                .buildingID} ${dataVersionData}");
            dataVersionData.save();
          }
        } else {
          print('DATA NOT PRESENT');
          VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!
              .buildingID!] = false;
          VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
              .buildingID!] = false;
          VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
              .buildingID!] = false;
          VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
              .buildingID!] = false;
          if (!shouldBeInjected) {
            print('DATA INJECTED');
            final dataVersionData = DataVersionLocalModel(
                responseBody: responseBody);
            DataBox.put(DataVersion
                .fromJson(responseBody)
                .versionData!
                .buildingID, dataVersionData);
            dataVersionData.save();
          }
        }
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
          print("DATA VERSION API DATA FROM API AFTER 403");
          Map<String, dynamic> responseBody = json.decode(response.body);
          final apiData = DataVersion.fromJson(responseBody);
          if (DataBox.containsKey(apiData.versionData!.buildingID)) {
            print('DATA ALREADY PRESENT');
            final databaseData = DataVersion.fromJson(
                DataBox.get(apiData.versionData!.buildingID)!.responseBody);
            if (apiData.versionData!.buildingDataVersion !=
                databaseData.versionData!.buildingDataVersion) {
              VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!
                  .buildingID!] = true;
              shouldBeInjected = true;
              print("Building Version Change = true ${apiData.versionData!
                  .buildingDataVersion} ${databaseData.versionData!
                  .buildingDataVersion}");
            } else {
              VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!
                  .buildingID!] = false;
              print("Building Version Change = false");
            }

            if (apiData.versionData!.patchDataVersion !=
                databaseData.versionData!.patchDataVersion) {
              VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                  .buildingID!] = true;
              shouldBeInjected = true;
              print("Patch Version Change = true ${apiData.versionData!
                  .patchDataVersion} ${databaseData.versionData!
                  .patchDataVersion}");
            } else {
              VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                  .buildingID!] = false;
              print("Patch Version Change = false");
            }

            if (apiData.versionData!.landmarksDataVersion !=
                databaseData.versionData!.landmarksDataVersion) {
              VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                  .buildingID!] = true;
              shouldBeInjected = true;
              print("Landmark Version Change = true ${apiData.versionData!
                  .landmarksDataVersion} ${databaseData.versionData!
                  .landmarksDataVersion}");
            } else {
              VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                  .buildingID!] = false;
              print("Landmark Version Change = false");
            }

            if (apiData.versionData!.polylineDataVersion !=
                databaseData.versionData!.polylineDataVersion) {
              VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                  .buildingID!] = true;
              shouldBeInjected = true;
              print("Polyline Version Change = true ${apiData.versionData!
                  .polylineDataVersion} ${databaseData.versionData!
                  .polylineDataVersion}");
            } else {
              VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                  .buildingID!] = false;
              print(VersionInfo.buildingPolylineDataVersionUpdate[apiData
                  .versionData!.buildingID!]);
              print(apiData.versionData!.buildingID!);
              print("Polyline Version Change = false");
            }
            if (shouldBeInjected) {
              print("shouldBeInjected");
              final dataVersionData = DataVersionLocalModel(
                  responseBody: responseBody);
              DataBox.delete(DataVersion
                  .fromJson(responseBody)
                  .versionData!
                  .buildingID);
              print("database deleted ${DataBox.containsKey(DataVersion
                  .fromJson(responseBody)
                  .versionData!
                  .buildingID)}");
              DataBox.put(DataVersion
                  .fromJson(responseBody)
                  .versionData!
                  .buildingID, dataVersionData);
              print("New Data ${DataVersion
                  .fromJson(responseBody)
                  .versionData!
                  .buildingID} ${dataVersionData}");
              dataVersionData.save();
            } else {
              print("!shouldBeInjected");
            }
          } else {
            print('DATA NOT PRESENT');
            VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                .buildingID!] = false;
            if (!shouldBeInjected) {
              print('DATA INJECTED');
              final dataVersionData = DataVersionLocalModel(
                  responseBody: responseBody);
              DataBox.put(DataVersion
                  .fromJson(responseBody)
                  .versionData!
                  .buildingID, dataVersionData);
              dataVersionData.save();
            }
          }
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
    }catch(e){
      VersionInfo.buildingBuildingDataVersionUpdate[id] = false;
      VersionInfo.buildingPatchDataVersionUpdate[id] = false;
      VersionInfo.buildingLandmarkDataVersionUpdate[id] = false;
      VersionInfo.buildingPolylineDataVersionUpdate[id] = false;
    }
  }
}