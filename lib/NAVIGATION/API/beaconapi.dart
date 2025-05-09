import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/beaconData.dart';

import '../DATABASE/BOXES/BeaconAPIModelBOX.dart';
import '../DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '../VersioInfo.dart';
import '../config.dart';
import 'RefreshTokenAPI.dart';


class beaconapi {
  final String baseUrl = "${AppConfig.baseUrl}/secured/building/beacons";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<List<beacon>> fetchBeaconData(String id) async {

    accessToken = signInBox.get("accessToken");
    final BeaconBox = BeaconAPIModelBOX.getData();

    // print(VersionInfo.buildingLandmarkDataVersionUpdate[id]!);
    if(VersionInfo.buildingLandmarkDataVersionUpdate.isEmpty || (BeaconBox.containsKey(id) && VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(id) && VersionInfo.buildingLandmarkDataVersionUpdate[id]! == false)){
      if(BeaconBox.get(id) != null ){
        List<dynamic> responseBody = BeaconBox.get(id)!.responseBody;
        List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
        return beaconList;
      }

    }

    final Map<String, dynamic> data = {
      "buildingId": id,
    };
    final response = await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
        // 'Authorization' : AppConfig.Authorization
      },
    );

    if (response.statusCode == 200) {
      //   Map<String, dynamic> encryptedResponseBody = json.decode(response.body);
      // String decryptedData = encryptDecrypt(encryptedResponseBody['encryptedData']);
      List<dynamic> responseBody = json.decode(response.body);


      List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
        final beaconData = BeaconAPIModel(responseBody: responseBody);
        String i = id;
        if(beaconList.isNotEmpty){
          i=beaconList[0].buildingID!;
        }
        BeaconBox.put(i,beaconData);
        beaconData.save();
        return beaconList;


    }else if (response.statusCode == 403) {
      String newAccessToken = await RefreshTokenAPI.refresh();
      accessToken = newAccessToken;
      return fetchBeaconData(id);

    } else {

      // HelperClass.showToast("MishorError in BuildingAll API");
      HelperClass.showToast("Error Code ${response.statusCode.toString()}");
      throw Exception('Failed to load data');
    }
  }
}