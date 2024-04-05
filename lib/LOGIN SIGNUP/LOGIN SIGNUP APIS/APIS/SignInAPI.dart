import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';

import '../../../DATABASE/BOXES/SignINAPIModelBox.dart';

class SignInAPI{

  final String baseUrl = "https://dev.iwayplus.in/auth/signin";

  Future<SignInApiModel?> signIN(String username, String password) async {

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

    print("Response body is ${response.statusCode}");
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic>  responseBody = json.decode(response.body);
        
        
        SignInApiModel ss = new SignInApiModel();
        if(responseBody.containsKey("exist") && responseBody["exist"]==false){
          ss.accessToken = null;
          ss.refreshToken = null;
          ss.payload?.userId = null;
          ss.payload?.roles = null;
          return ss;
        }
        ss.accessToken = responseBody["accessToken"];
        ss.refreshToken = responseBody["refreshToken"];
        ss.payload?.userId = responseBody["payload"]["userId"];
        ss.payload?.roles = responseBody["payload"]["roles"];
        
        var signInBox = Hive.box('SignInDatabase');
        List<dynamic> roles = responseBody["payload"]["roles"];
        // Put data into the box
        signInBox.put("accessToken", responseBody["accessToken"]);
        signInBox.put("refreshToken", responseBody["accessToken"]);
        signInBox.put("userId", responseBody["payload"]["userId"]);
        signInBox.put("roles", roles);
        
        print("Sign in details saved to database");
        
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
  static Future<int> sendOtpForgetPassword(String user) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://dev.iwayplus.in/auth/otp/username'));
    request.body = json.encode({"username": "${user}"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return 1;
    } else {
      print("response.reasonPhrase");
      print(response.reasonPhrase);
      return 0;
    }
  }

  static Future<int> changePassword(String user, String pass, String otp) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://dev.iwayplus.in/auth/reset-password'));
    request.body = json.encode({
      "username": "$user",
      "password": "$pass",
      "otp": "$otp"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return 1;
    } else {
      print("response.reasonPhrase");
      print(response.reasonPhrase);
      return 0;
    }
  }

}