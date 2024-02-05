import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/buildingAllModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'guestloginapi.dart';

class buildingAll {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/all";
  String token = "";

  Future<List<buildingAllModel>> fetchBuildingAllData() async {

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      List<buildingAllModel> buildingList = responseBody.map((data) => buildingAllModel.fromJson(data)).toList();
      return buildingList;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}