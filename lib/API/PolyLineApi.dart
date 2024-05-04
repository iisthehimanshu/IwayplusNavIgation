import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/API/RefreshTokenAPI.dart';
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
  var signInBox = Hive.box('SignInDatabase');


  void checkForUpdate({String? id = null}) async {
    final PolyLineBox = PolylineAPIModelBOX.getData();

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString(),
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
        polyLineData.save();
        print("POLYLINE UPDATE BOX EMPTY AND SAVED IN THE DATABASE");
      }else{
        Map<String, dynamic> databaseresponseBody = PolyLineBox.get(buildingAllApi.getStoredString())!.responseBody;
        String LastStoredTime = databaseresponseBody['polyline']!['updatedAt'];
        print("${APITime} ${LastStoredTime}");
        if(APITime!=LastStoredTime){
          print("POLYLINE UPDATE API DATA FROM DATABASE AND UPDATED");
          final polyLineData = PolyLineAPIModel(responseBody: responseBody);
          PolyLineBox.put(buildingAllApi.getStoredString(),polyLineData);
          polyLineData.save();
        }
      }
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('UPDATE Failed to load data');
    }
  }



  Future<polylinedata> fetchPolyData({String? id = null}) async {
    print("polyline");
    final PolyLineBox = PolylineAPIModelBOX.getData();
    token = signInBox.get("accessToken");

    if(PolyLineBox.containsKey(id??buildingAllApi.getStoredString())){
      print("POLYLINE API DATA FROM DATABASE");
      print(buildingAllApi.getStoredString());
      Map<String, dynamic> responseBody = PolyLineBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      return polylinedata.fromJson(responseBody);
    }



    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString(),
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

      print("POLYLINE API DATA FROM API");
      PolyLineBox.put(polylinedata.fromJson(responseBody).polyline!.buildingID,polyLineData);
      polyLineData.save();
      return polylinedata.fromJson(responseBody);
    } else {
      if (response.statusCode == 403) {
        RefreshTokenAPI.fetchPatchData();
        return PolyLineApi().fetchPolyData();
      }
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}