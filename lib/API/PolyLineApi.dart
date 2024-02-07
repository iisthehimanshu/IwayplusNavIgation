import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/DATABASE/BOXES/PolyLineAPIModelBOX.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'guestloginapi.dart';

class PolyLineApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/polyline";
  String token = "";
  String buildingID="";
  final BuildingAllBox = BuildingAllAPIModelBOX.getData();


  Future<polylinedata> fetchPolyData() async {
    final PolyLineBox = PolylineAPIModelBOX.getData();

    if(PolyLineBox.containsKey(buildingAllApi.getStoredString())){
      print("POLYLINE API DATA FROM DATABASE");
      print(buildingAllApi.getStoredString());
      Map<String, dynamic> responseBody = PolyLineBox.get(buildingAllApi.getStoredString())!.responseBody;
      return polylinedata.fromJson(responseBody);
    }


    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": buildingAllApi.getStoredString(),
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
      Map<String, dynamic> responseBody = json.decode(response.body);
      final polyLineData = PolyLineAPIModel(responseBody: responseBody);
      PolyLineBox.put(buildingAllApi.getStoredString(),polyLineData);
      print("POLYLINE API DATA FROM API");
      return polylinedata.fromJson(responseBody);
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}

