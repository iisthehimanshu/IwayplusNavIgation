import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/NAVIGATION/API/BuildingAPI.dart';
import 'package:iwaymaps/NAVIGATION/config.dart';
import 'package:permission_handler/permission_handler.dart';
import '../APIMODELS/beaconData.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '/IWAYPLUS/Elements/HelperClass.dart';

import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';


class beaconapi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/building/beacons";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");
  String encryptDecrypt(String input, String key){
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      // XOR each character of the input with the corresponding character of the key
      result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }
  String getDecryptedData(String encryptedData){
    Map<String, dynamic> encryptedResponseBody = json.decode(encryptedData);
    String newResponse=encryptDecrypt(encryptedResponseBody['encryptedData'], "xX7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=");
    List<dynamic> originalList = jsonDecode(newResponse);
    // Wrap in landmarks header
    Map<String, dynamic> wrappedResponse = {
      "landmarks": originalList
    };
    return jsonEncode(wrappedResponse);
  }

  Future<List<beacon>> fetchBeaconData(String id) async {

    print("beacon---");
    print(baseUrl);
    accessToken = signInBox.get("accessToken");
    final BeaconBox = BeaconAPIModelBOX.getData();

    print("beaconapi $id");
    print(BeaconBox.containsKey(id));
    print(VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(id));
    // print(VersionInfo.buildingLandmarkDataVersionUpdate[id]!);
    // if(VersionInfo.buildingLandmarkDataVersionUpdate.isEmpty || (BeaconBox.containsKey(id) && VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(id) && VersionInfo.buildingLandmarkDataVersionUpdate[id]! == false)){
    //   print("BEACON DATA FROM DATABASE");
    //   print(BeaconBox.keys);
    //   print(BeaconBox.values);
    //   if(BeaconBox.get(id) != null ){
    //     List<dynamic> responseBody = BeaconBox.get(id)!.responseBody;
    //     List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
    //     return beaconList;
    //   }
    //
    // }

    final Map<String, dynamic> data = {
      "buildingId": id,
    };
    print("Mishordata");
    print(data);

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      print("BEACON DATA FROM API");
        print("beaconapiresponse ${response.body}");
        List<dynamic> responseBody = json.decode(response.body);
        List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
        print("response.statusCode");
        print("beaconList $beaconList $id");
        final beaconData = BeaconAPIModel(responseBody: responseBody);
        print(beaconData);
        String i = id;
        if(beaconList.isNotEmpty){
          i=beaconList[0].buildingID!;
        }
        BeaconBox.put(i,beaconData);
        beaconData.save();
        print(BeaconBox.keys);
        if(kDebugMode && Platform.isAndroid) {
          List<dynamic> JSONresponseBody = json.decode(response.body);
          String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
          saveJsonToAndroidDownloads("beacon$id", formattedJson);
        }
        return beaconList;
    }
    else if (response.statusCode == 403) {
      print("BEACON API in error 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );
      if (response.statusCode == 200) {
        print("BEACON API DATA FROM API AFTER 403");
        List<dynamic> responseBody = json.decode(response.body);
        List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
        print("response.statusCode");
        beaconList.forEach((beacon){
          print(beacon.name);
        });
        print("beaconList $beaconList");
        final beaconData = BeaconAPIModel(responseBody: responseBody);
        String i = id;
        if(beaconList.isNotEmpty){
          i=beaconList[0].buildingID!;
        }
        BeaconBox.put(i,beaconData);
        beaconData.save();

        return beaconList;

      }else {
        print("BEACON API EMPTY DATA FROM API AFTER 403");
        List<beacon> beaconList = [];
        return beaconList;

      }

    } else {

      // HelperClass.showToast("MishorError in BuildingAll API");
      HelperClass.showToast("Error Code ${response.statusCode.toString()}");
      throw Exception('Failed to load data');
    }
  }
  Future<void> saveJsonToAndroidDownloads(String fileName, String jsonString) async {

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    }

    if (downloadsDir == null || !downloadsDir.existsSync()) {
      print("❌ Could not access Downloads folder.");
      return;
    }

    final filePath = '${downloadsDir.path}/$fileName.json';
    final file = File(filePath);

    try {
      await file.writeAsString(jsonString, flush: true);
      print("✅ JSON file saved at: $filePath");
    } catch (e) {
      print("❌ Error writing JSON file: $e");
    }
  }

}