import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../APIMODELS/DataVersion.dart';
import '../DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import '../DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '../config.dart';
import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';

class DataVersionApi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/data-version";
  static final signInBox = Hive.box('SignInDatabase');
  final versionBox = Hive.box('VersionData');
  final dataBox = DataVersionLocalModelBOX.getData();

  Future<void> fetchDataVersionApiData(String buildingId) async {
    String accessToken = signInBox.get("accessToken");
    bool shouldBeInjected = false;

    // Check if data exists locally
    // final localData = dataBox.get(buildingId);
    //
    // // If local data not present and internet not available, throw error
    // if (localData == null && !(await _hasInternet())) {
    //   throw Exception("No local data and no internet connection available.");
    // }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({"building_ID": buildingId}),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        debugPrint("Fetched Data Version from API");

        final responseBody = json.decode(response.body);
        final apiData = DataVersion.fromJson(responseBody);
        final buildingID = apiData.versionData!.buildingID!;

        final existing = dataBox.get(buildingID);
        final isPresent = existing != null;

        VersionInfo.buildingBuildingDataVersionUpdate[buildingID] = false;
        VersionInfo.buildingPatchDataVersionUpdate[buildingID] = false;
        VersionInfo.buildingLandmarkDataVersionUpdate[buildingID] = false;
        VersionInfo.buildingPolylineDataVersionUpdate[buildingID] = false;

        if (isPresent) {
          final localData = DataVersion.fromJson(existing.responseBody);

          shouldBeInjected |= _compareVersion(
            "BuildingData",
            buildingID,
            apiData.versionData!.buildingDataVersion,
            localData.versionData!.buildingDataVersion,
                (flag) => VersionInfo.buildingBuildingDataVersionUpdate[buildingID] = flag,
          );

          shouldBeInjected |= _compareVersion(
            "PatchData",
            buildingID,
            apiData.versionData!.patchDataVersion,
            localData.versionData!.patchDataVersion,
                (flag) => VersionInfo.buildingPatchDataVersionUpdate[buildingID] = flag,
          );

          shouldBeInjected |= _compareVersion(
            "LandmarkData",
            buildingID,
            apiData.versionData!.landmarksDataVersion,
            localData.versionData!.landmarksDataVersion,
                (flag) => VersionInfo.buildingLandmarkDataVersionUpdate[buildingID] = flag,
          );

          shouldBeInjected |= _compareVersion(
            "PolylineData",
            buildingID,
            apiData.versionData!.polylineDataVersion,
            localData.versionData!.polylineDataVersion,
                (flag) => VersionInfo.buildingPolylineDataVersionUpdate[buildingID] = flag,
          );
        } else {
          debugPrint("No local data found. Injecting new data.");
          shouldBeInjected = true;
        }

        if (shouldBeInjected) {
          final newData = DataVersionLocalModel(responseBody: responseBody);
          dataBox.put(buildingID, newData);
          await newData.save();
          debugPrint("Data for building $buildingID updated.");
        }

      } else if (response.statusCode == 403) {
        debugPrint("403 Unauthorized. Refreshing token...");
        await RefreshTokenAPI.refresh();
        await fetchDataVersionApiData(buildingId);
      } else {
        debugPrint("API error ${response.statusCode}");
        throw Exception('Failed to load data version: ${response.body}');
      }

    } catch (e) {
      debugPrint("Error fetching data version for $buildingId: $e");
      _resetVersionFlags(buildingId);
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await http
          .get(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
          .timeout(const Duration(seconds: 5));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }


  bool _compareVersion(
      String type,
      String id,
      dynamic apiVersion,
      dynamic localVersion,
      void Function(bool) setFlag,
      ) {
    if (apiVersion != localVersion) {
      debugPrint("$type Version Change for $id: $localVersion → $apiVersion");
      setFlag(true);
      return true;
    } else {
      debugPrint("$type Version Unchanged for $id");
      setFlag(false);
      return false;
    }
  }

  void _resetVersionFlags(String buildingId) {
    VersionInfo.buildingBuildingDataVersionUpdate[buildingId] = false;
    VersionInfo.buildingPatchDataVersionUpdate[buildingId] = false;
    VersionInfo.buildingLandmarkDataVersionUpdate[buildingId] = false;
    VersionInfo.buildingPolylineDataVersionUpdate[buildingId] = false;
  }
}
