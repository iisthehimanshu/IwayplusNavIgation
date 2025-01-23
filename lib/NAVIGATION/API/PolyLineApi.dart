import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/NAVIGATION/API/RefreshTokenAPI.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/PolyLineAPIModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '/NAVIGATION/APIMODELS/polylinedata.dart';
import '../VersioInfo.dart';

class PolyLineApi {
  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/secured/polyline" : "https://maps.iwayplus.in/secured/polyline";
  String buildingID="";
  final BuildingAllBox = BuildingAllAPIModelBOX.getData();
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  String encryptDecrypt(String input, String key){
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      // XOR each character of the input with the corresponding character of the key
      result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }
  String getDecryptedData(String encryptedData){
    Map<String, dynamic> encryptedResponseBody = json.decode(encryptedData);
    String newResponse=encryptDecrypt(encryptedResponseBody['encryptedData'], "xX7/kWYt6cjSDMwB4wJPOBI+/AwC+Lfbd610sWfwywU=");
    //print("new response ${newResponse}");
    Map<String,dynamic> originalList = jsonDecode(newResponse);
    // Wrap in landmarks header
    Map<String, dynamic> wrappedResponse = {
      "polyline": originalList
    };
    return jsonEncode(wrappedResponse);
  }

  Future<polylinedata> fetchPolyData({String? id = null, bool outdoor = false}) async {
    print("polyline");
    final PolyLineBox = PolylineAPIModelBOX.getData();
    accessToken = signInBox.get("accessToken");

    if(PolyLineBox.containsKey(id??buildingAllApi.getStoredString()) && VersionInfo.buildingPolylineDataVersionUpdate.containsKey(id??buildingAllApi.getStoredString()) && VersionInfo.buildingPolylineDataVersionUpdate[id??buildingAllApi.getStoredString()]! == false){
      print("POLYLINE API DATA FROM DATABASE");
      print(buildingAllApi.getStoredString());
      Map<String, dynamic> responseBody = PolyLineBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      return polylinedata.fromJson(responseBody);
    }



    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString(),
      "outdoor": outdoor
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken,
        'Authorization': 'e28cdb80-c69a-11ef-aa4e-e7aa7912987a'
      },
    );
    if (response.statusCode == 200) {
      try{
        Map<String, dynamic> responseBody = json.decode(response.body);
        final polyLineData = PolyLineAPIModel(responseBody: responseBody);
        print("POLYLINE API DATA FROM API");
        PolyLineBox.put(polylinedata.fromJson(responseBody).polyline!.buildingID,polyLineData);
        polyLineData.save();
        return polylinedata.fromJson(responseBody);
      }catch(e){
        String finalResponse=getDecryptedData(response.body);
        Map<String, dynamic> responseBody = json.decode(finalResponse);
        final polyLineData = PolyLineAPIModel(responseBody: responseBody);
        print("POLYLINE API DATA FROM API");
        PolyLineBox.put(polylinedata.fromJson(responseBody).polyline!.buildingID,polyLineData);
        polyLineData.save();
        return polylinedata.fromJson(responseBody);
      }
    }
    else if (response.statusCode == 403) {
      print("POLYLINE API in error 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        final polyLineData = PolyLineAPIModel(responseBody: responseBody);

        print("POLYLINE API DATA FROM API AFTER 403");
        PolyLineBox.put(polylinedata.fromJson(responseBody).polyline!.buildingID,polyLineData);
        polyLineData.save();
        return polylinedata.fromJson(responseBody);
      }else{
        print("POLYLINE API EMPTY DATA FROM API AFTER 403");
        polylinedata polyData = polylinedata();
        return polyData;
      }
    }
    else {
      HelperClass.showToast("MishorError in POLYLINE API");
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}