import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/API/BuildingAPI.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';

import '../APIMODELS/beaconData.dart';
import '../VersioInfo.dart';
import 'RefreshTokenAPI.dart';
import 'guestloginapi.dart';


class beaconapi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/beacons";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<List<beacon>> fetchBeaconData(String id) async {
    print("beacon");
    accessToken = signInBox.get("accessToken");
    final BeaconBox = BeaconAPIModelBOX.getData();
    if(BeaconBox.containsKey(id)){
      print("BEACON DATA FROM DATABASE");
      print(BeaconBox.keys);
      print(BeaconBox.values);

      if(BeaconBox.get(id) != null && !VersionInfo.landmarksDataVersionUpdate){

        List<dynamic> responseBody = BeaconBox.get(id)!.responseBody;
        List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
        return beaconList;
      }

    }

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
        'x-access-token': accessToken
      },
    );

    if (response.statusCode == 200) {
      print("BEACON DATA FROM API");
      List<dynamic> responseBody = json.decode(response.body);
      List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
      print("response.statusCode");
      print("beaconList $beaconList");
      final beaconData = BeaconAPIModel(responseBody: responseBody);
      if(beaconList.isNotEmpty){
        BeaconBox.put(beaconList[0].buildingID,beaconData);
        beaconData.save();
      }


      return beaconList;

    }else if (response.statusCode == 403) {
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
        print("beaconList $beaconList");
        final beaconData = BeaconAPIModel(responseBody: responseBody);
        if(beaconList.isNotEmpty){
          BeaconBox.put(beaconList[0].buildingID,beaconData);
          beaconData.save();
        }
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
}