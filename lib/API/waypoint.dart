import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/DATABASE/BOXES/WayPointModelBOX.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/WayPointModel.dart';
import '../APIMODELS/guestloginmodel.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';

import '../waypoint.dart';
import 'guestloginapi.dart';


class waypointapi {

  final String baseUrl = "https://dev.iwayplus.in/secured/indoor-path-network";
  String token = "";


  Future<List<PathModel>> fetchwaypoint({String? id=null}) async {
    
    final WayPointBox = WayPointModeBOX.getData();

    if(WayPointBox.containsKey(id??buildingAllApi.getStoredString())){
      print("WAYPOINT DATA FROM DATABASE");
      List<dynamic> responseBody = WayPointBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      List<PathModel> wayPointList = responseBody.map((data) => PathModel.fromJson(data as Map<dynamic, dynamic>)).toList();
      print("building ${wayPointList[0].buildingID}");
      return wayPointList;
    }
    
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
      print("WAYPOINT DATA FROM API");
      List<dynamic> jsonData = json.decode(response.body);
      List<PathModel> wayPointList = jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
      final wayPointData = WayPointModel(responseBody: jsonData);
      if(wayPointList.isNotEmpty){
        WayPointBox.put(wayPointList[0].buildingID, wayPointData);
        wayPointData.save();
      }
      return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
    } else {
      print("API Exception");
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}
