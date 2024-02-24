import 'dart:convert';
import 'package:http/http.dart' as http;

import '../APIMODELS/beaconData.dart';
import 'guestloginapi.dart';


class beaconapi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/beacons";
  String token = "";

  Future<List<beacon>> fetchBeaconData() async {
    await guestApi().guestlogin().then((value){
      if(value.accessToken != null) {
        token = value.accessToken!;
      }
    });
    final Map<String, dynamic> data = {
      "buildingId": "65d887a5db333f89457145f6",
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
      List<dynamic> responseBody = json.decode(response.body);
      List<beacon> beaconList = responseBody.map((data) => beacon.fromJson(data)).toList();
      return beaconList;
    } else {
      print(Exception);
      throw Exception('Failed to load beacon data');
    }
  }
}