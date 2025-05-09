import 'dart:convert';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../APIMODELS/patchDataModel.dart';
import '../DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import '../config.dart';
import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';

class patchAPI {
  String token = "";
  final String baseUrl = "${AppConfig.baseUrl}/secured/patch/get?format=v2";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<patchDataModel> fetchPatchData({String? id = null}) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    String deviceManufacturer = "Unknown";
    String deviceModel = "Unknown";

    if (kIsWeb) {
      deviceManufacturer = "WEB";
      deviceModel = "WEB";
    } else {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceManufacturer = androidInfo.manufacturer ?? "Unknown";
        deviceModel = androidInfo.model ?? "Unknown";
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceManufacturer = "Apple"; // iPhones are always manufactured by Apple
        deviceModel = iosInfo.utsname.machine ?? "Unknown";
      } else {
        // Handle other platforms if needed (macOS, Windows, Linux)
        deviceManufacturer = "Unknown Platform";
        deviceModel = "Unknown Platform";
      }
    }
    print("checking data ${id ?? buildingAllApi.getStoredString()}");
    print(accessToken);
    print(refreshToken);

    accessToken = signInBox.get("accessToken");

    final PatchBox = PatchAPIModelBox.getData();
    print("Patch getting for $id");
    if (PatchBox.containsKey(id ?? buildingAllApi.getStoredString()) &&
        VersionInfo.buildingPatchDataVersionUpdate
            .containsKey(id ?? buildingAllApi.getStoredString()) &&
        VersionInfo.buildingPatchDataVersionUpdate[
                id ?? buildingAllApi.getStoredString()]! ==
            false) {
      print("PATCH API DATA FROM DATABASE");
      print(PatchBox.get(id ?? buildingAllApi.getStoredString())!.responseBody);
      Map<String, dynamic> responseBody =
          PatchBox.get(id ?? buildingAllApi.getStoredString())!.responseBody;
      return patchDataModel.fromJson(responseBody);
    }

    final Map<String, dynamic> data = {
      "id": id ?? buildingAllApi.getStoredString(),
      "manufacturer": deviceManufacturer,
      "devicemodel": deviceModel
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
        // 'Authorization': AppConfig.Authorization
      },
    );
    if (response.statusCode == 200) {
      print("data from patch ${response.body}");
      // Map<String, dynamic> encryptedResponseBody = json.decode(response.body);
      // String decryptedData = encryptDecrypt(encryptedResponseBody['encryptedData']);
      Map<String, dynamic> responseBody = json.decode(response.body);

      final patchData = PatchAPIModel(responseBody: responseBody);
      print("patchdata $responseBody for id $id");
      PatchBox.put(patchDataModel.fromJson(responseBody).patchData!.buildingID,
          patchData);
      patchData.save();
      print("PATCH API DATA FROM API");
      return patchDataModel.fromJson(responseBody);
    } else if (response.statusCode == 403) {
      print("PATCH API in error 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      return fetchPatchData(id: id);
    } else {
      print("PATCH API in else error");
      print(Exception);
      throw Exception(
          'Failed to load data ${id ?? buildingAllApi.getStoredString()} ${response.statusCode} ${response.body}');
    }
  }
}
