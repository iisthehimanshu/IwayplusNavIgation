import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/APIMODELS/patchDataModel.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/PatchAPIModel.dart';


import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import 'guestloginapi.dart';

class RefreshTokenAPI {

  static String refreshToken = "";
  static String baseUrl = "https://dev.iwayplus.in/api/refreshToken?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edff";

  static void fetchPatchData() async {
    var signInBox = Hive.box('SignInDatabase');
    refreshToken = signInBox.get("refreshToken");
    // print("refreshToken");
    // print(refreshToken);

    final Map<String, dynamic> data = {
      "refreshToken": refreshToken
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("in refreshTOken");
      Map<String, dynamic> responseBody = json.decode(response.body);

      String updatedAccessToken = responseBody["accessToken"];
      signInBox.put('accessToken', updatedAccessToken);

      print(responseBody);
      return;
    } else {
      print(Exception);
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}
