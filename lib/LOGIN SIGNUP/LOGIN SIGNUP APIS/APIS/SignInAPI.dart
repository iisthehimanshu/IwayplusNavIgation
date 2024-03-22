import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';

class SignInAPI{

  final String baseUrl = "https://dev.iwayplus.in/auth/signin";

  Future<SignInAPIModel?> signIN(String username, String password) async {
    //final signindataBox = FavouriteDataBaseModelBox.getData();

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
        Map<String, dynamic>  responseBody = json.decode(response.body);
        SignInAPIModel ss = new SignInAPIModel();
        ss.accessToken = responseBody["accessToken"];
        ss.refreshToken = responseBody["refreshToken"];
        ss.payload?.userId = responseBody["payload"]["userId"];
        ss.payload?.roles = responseBody["payload"]["roles"];

        FavouriteDataBaseModel signInResponse = FavouriteDataBaseModel(signInAPIModel: ss);
        // Now use the decoded data to create a SignInAPIModel instance
        // signindataBox.add(signInResponse);
        // signInResponse.save();


        var signInBox = Hive.box('SignInDatabase');
        List<dynamic> roles = responseBody["payload"]["roles"];
        // Put data into the box
        signInBox.put("accessToken", responseBody["accessToken"]);
        signInBox.put("refreshToken", responseBody["accessToken"]);
        signInBox.put("userId", responseBody["payload"]["userId"]);
        signInBox.put("roles", roles);
        // print(signInBox.values);
        // print(signInBox.get("roles"));
        // if(signInBox.get("roles")=="user"){
        //   print("True");
        // }

        //signInResponse.save();
        print("Sign in details saved to database");
        // Use signInResponse as needed
        print("Sign in successful: $signInResponse");

        return ss;

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