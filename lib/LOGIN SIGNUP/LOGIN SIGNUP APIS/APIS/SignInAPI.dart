import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';

class SignInAPI{

  final String baseUrl = "https://dev.iwayplus.in/auth/signin";

  Future<SignInAPIModel?> signIN(String username, String password) async {
    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    //Map<String, dynamic> responseBody = json.decode(response.body);
    print("Response body is ${response.statusCode}");
    if (response.statusCode == 200) {
      //print("Response body is $responseBody");
      try {
        Map<String, dynamic> responseBody = json.decode(response.body);

        // Now use the decoded data to create a SignInAPIModel instance
        SignInAPIModel signInResponse = SignInAPIModel.fromJson(responseBody);
        var signInBox = Hive.box('SignInDatabase');
        // Put data into the box
        signInBox.put('signInResponse', signInResponse);
        print("Sign in details saved to database");
        // Use signInResponse as needed
        print("Sign in successful: $signInResponse");

        return signInResponse;

      } catch (e) {
        print("Error occurred during data parsing: $e");
        throw Exception('Failed to parse data');
      }
    } else {
      print("Code is ${response.statusCode}");

      return null;
    }
  }
}