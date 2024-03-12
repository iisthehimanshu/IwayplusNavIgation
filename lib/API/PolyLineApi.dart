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

    // if(PolyLineBox.containsKey(buildingAllApi.getStoredString())){
    //   print("POLYLINE API DATA FROM DATABASE");
    //   print(buildingAllApi.getStoredString());
    //   Map<String, dynamic> responseBody = PolyLineBox.get(buildingAllApi.getStoredString())!.responseBody;
    //   String LastStoredTime = responseBody['polyline']!['createdAt'];
    //   print(LastStoredTime);
    //   return polylinedata.fromJson(responseBody);
    // }


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
      responseBody['polyline']!=null? print("contain--") : print("not--");
      var getting = responseBody['polyline'];
      print(getting['createdAt']!);
      String APITime = getting['updatedAt']!;

      if(!PolyLineBox.containsKey(buildingAllApi.getStoredString())){ // WHEN NO DATA IN DATABASE
        final polyLineData = PolyLineAPIModel(responseBody: responseBody);
        PolyLineBox.put(buildingAllApi.getStoredString(),polyLineData);
        print("POLYLINE API DATA FROM API");
        return polylinedata.fromJson(responseBody);
        //2024-03-07T07:06:53.829Z 2024-03-11T13:01:08.640Z
      }else{
        Map<String, dynamic> databaseresponseBody = PolyLineBox.get(buildingAllApi.getStoredString())!.responseBody;
        String LastStoredTime = databaseresponseBody['polyline']!['updatedAt'];
        print("${APITime} ${LastStoredTime}");
        if(APITime==LastStoredTime){
          print("POLYLINE API DATA FROM DATABASE");
          return polylinedata.fromJson(databaseresponseBody);
        }else{
          print("POLYLINE API DATA FROM DATABASE AND UPDATED");
          final polyLineData = PolyLineAPIModel(responseBody: responseBody);
          PolyLineBox.put(buildingAllApi.getStoredString(),polyLineData);
          return polylinedata.fromJson(responseBody);
        }
      }

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

