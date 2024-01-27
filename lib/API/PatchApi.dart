import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/APIMODELS/patchDataModel.dart';

import 'guestloginapi.dart';

class patchAPI {

  String token = "";
  final String baseUrl = "https://dev.iwayplus.in/secured/patch/get";


  Future<patchDataModel> fetchPatchData() async {

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": "659001bce6c204e1eec04c0f"
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
       return patchDataModel.fromJson(responseBody);
    } else {
      print(Exception);
      throw Exception('Failed to load data');
    }
  }
}
