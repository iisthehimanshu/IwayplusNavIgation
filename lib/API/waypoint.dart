import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/guestloginmodel.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';

import '../waypoint.dart';
import 'guestloginapi.dart';


class waypointapi {

  final String baseUrl = "https://dev.iwayplus.in/secured/indoor-path-network";
  String token = "";


  Future<List<PathModel>> fetchwaypoint({String? id=null}) async {
    final Map<String, dynamic> data = {
      "building_ID": id??buildingAllApi.getStoredString()
    };

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
    } else {
      print("API Exception");
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}
