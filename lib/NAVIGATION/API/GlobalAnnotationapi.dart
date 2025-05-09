import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/GlobalAnnotationModel.dart';
import '../config.dart';
import 'RefreshTokenAPI.dart';


class GlobalAnnotation {

  String baseUrl = "${AppConfig.baseUrl}/secured/get-global-annotation/";
  String token = "";
  static var signInBox = Hive.box('SignInDatabase');
  String accessToken = signInBox.get("accessToken");
  String refreshToken = signInBox.get("refreshToken");

  Future<GlobalModel> fetchGlobalAnnotationData(id, {String? newaccesstoken}) async {

    final response = await http.get(
      Uri.parse(baseUrl+id),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': newaccesstoken??accessToken
      },
    );
    print("globalannotation data ${response.body}");
    print("globalannotation data ${response.statusCode}");
    if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final completeData = GlobalModel.fromJson(jsonData);
        if(!kIsWeb && kDebugMode && Platform.isAndroid) {
          List<dynamic> JSONresponseBody = json.decode(response.body);
          String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
          HelperClass().saveJsonToAndroidDownloads("Global$id", formattedJson);
        }
        print("globalannotation data $jsonData");
        return completeData;

    }else if (response.statusCode == 403) {
      print("globalannotation data  IN 403");
      String newAccessToken = await RefreshTokenAPI.refresh();
      print('Refresh done');
      accessToken = newAccessToken;
      return fetchGlobalAnnotationData(id,newaccesstoken: newAccessToken);
    }else {
      if(kDebugMode) {
        HelperClass.showToast("MishorError in globalannotation data ");
      }
      print("API Exception ${response.body}");
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}