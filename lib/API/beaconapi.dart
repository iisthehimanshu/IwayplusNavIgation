import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/API/BuildingAPI.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'package:iwayplusnav/Elements/HelperClass.dart';

import '../APIMODELS/beaconData.dart';
import 'guestloginapi.dart';


class beaconapi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/beacons";
  String token = "";

  Future<List<beacon>> fetchBeaconData({String? id}) async {
    print("beacon");
    final BeaconBox = BeaconAPIModelBOX.getData();
    if(BeaconBox.containsKey(id??buildingAllApi.getStoredString())){
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
    print("Mishor");
    print(id);
    print(buildingAllApi.getStoredString());
    print(buildingAllApi.getStoredString().runtimeType);

    final Map<String, dynamic> data = {
      "buildingId": id??buildingAllApi.getStoredString(),
    };
    print("Mishordata");
    print(data);

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
      print("response.statusCode");
      print("beaconList $beaconList");
      final beaconData = BeaconAPIModel(responseBody: responseBody);
      BeaconBox.put(beaconList[0].buildingID,beaconData);
      beaconData.save();

      return beaconList;
    } else {
      HelperClass.showToast("MishorError in Beacon API");
      print(Exception);
      print("Mishorcheck");
      print(Exception);
      throw Exception('Failed to load beacon data');

    }}catch(e){
      HelperClass.showToast("MishorError in Beacon API");
      List<beacon> beaconlist = [];
      print("Mishorcheck");
      print(e);
      return beaconlist;
    }
  }
}