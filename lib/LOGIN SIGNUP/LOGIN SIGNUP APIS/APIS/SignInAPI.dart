import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';


import '../../../API/RefreshTokenAPI.dart';
import '../../../DATABASE/BOXES/SignINAPIModelBox.dart';
import '../../../Elements/UserCredential.dart';

class SignInAPI{

  final String baseUrl = "https://dev.iwayplus.in/auth/signin";

  Future<SignInApiModel?> signIN(String username, String password) async {
    //final signindataBox = FavouriteDataBaseModelBox.getData();
    // final SigninBox = SignINAPIModelBox.getData();

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
        print("response body--");
        print(responseBody);
        SignInApiModel ss = new SignInApiModel();
        ss.accessToken = responseBody["accessToken"];
        ss.refreshToken = responseBody["refreshToken"];
        ss.payload?.userId = responseBody["payload"]["userId"];
        ss.payload?.roles = responseBody["payload"]["roles"];
        // print("printing box length ${SigninBox.length}");

        var signInBox = Hive.box('SignInDatabase');
        signInBox.put("accessToken", responseBody["accessToken"]);
        signInBox.put("refreshToken", responseBody["refreshToken"]);
        signInBox.put("userId", responseBody["payload"]["userId"]);
        List<dynamic> roles = responseBody["payload"]["roles"];
        print(responseBody["payload"]["roles"].runtimeType);
        signInBox.put("roles", roles);

        //------STORING USER CREDENTIALS FROM DATABASE----------
        // UserCredentials.setAccessToken(signInBox.get("accessToken"));
        // UserCredentials.setRefreshToken(signInBox.get("refreshToken"));
        // List<dynamic> rolesList = signInBox.get("roles");
        // UserCredentials.setRoles(rolesList);
        // UserCredentials.setUserId(signInBox.get("userId"));

        //--------------------------------------------------------

        print("Sign in details saved to database");
        // Use signInResponse as needed

        return ss;
      } catch (e) {
        print("Error occurred during data parsing: $e");
        throw Exception('Failed to parse data');
      }
    } else {
      if (response.statusCode == 403) {
        print("In response.statusCode == 403");
        RefreshTokenAPI.fetchPatchData();
        return SignInAPI().signIN(username,password);
      }
      print("Code is ${response.statusCode}");
      return null;
    }
  }
  static Future<int> sendOtpForgetPassword(String user) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://dev.iwayplus.in/auth/otp/username'));
    request.body = json.encode({"username": "${user}", "digits":4,});
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