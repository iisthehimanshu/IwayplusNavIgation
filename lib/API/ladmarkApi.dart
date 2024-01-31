import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/landmark.dart';
import 'guestloginapi.dart';

class landmarkApi {
  final String baseUrl = "https://maps.iwayplus.in/secured/landmarks";
  String token = "";

  Future<land> fetchLandmarkData() async {

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": "659001bce6c204e1eec04c0f",
    };
    print("inside land");
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );
    print("response code in land is ${response.statusCode}");
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      return land.fromJson(responseBody);
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}

