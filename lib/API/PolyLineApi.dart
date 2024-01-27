import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/polylinedata.dart';
import 'guestloginapi.dart';

class PolyLineApi {
  final String baseUrl = "https://dev.iwayplus.in/secured/polyline";
  String token = "";

  Future<polylinedata> fetchPolyData() async {

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": "659001bce6c204e1eec04c0f",
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
      return polylinedata.fromJson(responseBody);
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}

