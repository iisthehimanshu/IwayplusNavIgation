import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../APIMODELS/guestloginmodel.dart';

class guestApi {

  final String baseUrl = kDebugMode? "https://dev.iwayplus.in/auth/guest?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edf" : "https://maps.iwayplus.in/auth/guest?API_KEY=be349f00-b6cb-11ee-b352-d74b1ab1edf";

  Future<guestloginmodel> guestlogin() async {
    print("guest");
    final response = await http.get(
      Uri.parse(baseUrl),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      return guestloginmodel.fromJson(responseBody);
    } else {
      print("API Exception");
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }
}
