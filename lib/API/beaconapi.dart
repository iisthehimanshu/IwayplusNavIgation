import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/API/BuildingAPI.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';

import '../APIMODELS/beaconData.dart';
import 'guestloginapi.dart';


class beaconapi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/beacons";
  String token = "";

  Future<List<beacon>> fetchBeaconData() async {
    print("beacon");
    final BeaconBox = BeaconAPIModelBOX.getData();
    if(BeaconBox.containsKey(buildingAllApi.getStoredString())){
      print("BEACON DATA FROM DATABASE");
      print(BeaconBox.keys);
      print(BeaconBox.values);
      List<dynamic> responseBody = BeaconBox.get(buildingAllApi.getStoredString())!.responseBody;
      List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
      return beaconList;
    }

    try{
      await guestApi().guestlogin().then((value){
      if(value.accessToken != null) {
        token = value.accessToken!;
      }
    });
    final Map<String, dynamic> data = {
      "buildingId": buildingAllApi.getStoredString(),
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
      print("BEACON DATA FROM API");
      List<dynamic> responseBody = json.decode(response.body);
      List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
      print("beaconList $beaconList");
      final beaconData = BeaconAPIModel(responseBody: responseBody);
      BeaconBox.put(beaconList[0].buildingID,beaconData);
      beaconData.save();

      return beaconList;
    } else {
      print(Exception);
      throw Exception('Failed to load beacon data');
    }}catch(e){
      List<beacon> beaconlist = [];
      return beaconlist;
    }
  }
}