import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/NAVIGATION/API/RefreshTokenAPI.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/OutDoorModelBOX.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../config.dart';
import '/NAVIGATION/APIMODELS/outdoormodel.dart';
import '../DATABASE/DATABASEMODEL/OutDoorModel.dart';

class outBuilding {
  final String baseUrl = "${AppConfig.baseUrl}/secured/outdoor";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");

  Future<outdoormodel?> outbuilding(List<String> ids) async {

    final OutBuildingBox = OutDoorModeBOX.getData();

    for(var id in ids){
      if(OutBuildingBox.containsKey(id)){
        Map<String, dynamic> responseBody = OutBuildingBox.get(id)!.responseBody;
        print("OUTBUILDING DATA FORM DATABASE $responseBody");
        return outdoormodel.fromJson(responseBody);
      }
    }

    final Map<String, dynamic> data = {
      "buildingIds": ids
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': accessToken
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      final outBuildingData = OutDoorModel(responseBody: responseBody);
      print("OUTBUILDING DATA FORM API $responseBody");

      OutBuildingBox.put(ids[0], outBuildingData);
      outBuildingData.save();

      if(!kIsWeb && kDebugMode && Platform.isAndroid) {
        List<dynamic> JSONresponseBody = json.decode(response.body);
        String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
        HelperClass().saveJsonToAndroidDownloads("Outbuilding${ids.toString()}", formattedJson);
      }

      return outdoormodel.fromJson(responseBody);

    }else if(response.statusCode == 403){
      print("OUTBUILDING DATA API IN ERROR 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      final Map<String, dynamic> data = {
        "buildingIds": ids
      };

      final response = await http.post(
        Uri.parse(baseUrl), body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        final outBuildingData = OutDoorModel(responseBody: responseBody);
        print("OUTBUILDING DATA FORM API");
        if(!kIsWeb && kDebugMode && Platform.isAndroid) {
          List<dynamic> JSONresponseBody = json.decode(response.body);
          String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
          HelperClass().saveJsonToAndroidDownloads("Outbuilding${ids.toString()}", formattedJson);
        }

        OutBuildingBox.put(ids[0], outBuildingData);
        outBuildingData.save();

        return outdoormodel.fromJson(responseBody);

      }else{
        print('OUTBUILDING DATA EMPTY FROM API AFTER 403');
        outdoormodel outBuild = outdoormodel();
        return outBuild;
      }

    } else {
      print(ids);
      print(json.decode(response.body));
      print("outdoor api error");
    }
  }
}
