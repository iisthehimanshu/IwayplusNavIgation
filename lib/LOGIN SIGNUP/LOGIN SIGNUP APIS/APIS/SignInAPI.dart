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
    //final signindataBox = FavouriteDataBaseModelBox.getData();
    final SigninBox = SignINAPIModelBox.getData();
    final box = SignINAPIModelBox.getData();

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


        // final landmarkData = LandMarkApiModel(responseBody: responseBody);
        //
        //       print('LANDMARK DATA FROM API');
        //       print(responseBody.containsValue("polylineExist"));
        //       // print(LandMarkBox.length);
        //       //LandMarkApiModel? demoresponseBody = LandMarkBox.getAt(0);
        //       //print(demoresponseBody?.responseBody);
        //       LandMarkBox.put(buildingAllApi.getStoredString(),landmarkData);
        //
        //       // print(LandMarkBox.length);
        //       // print('TESTING LANDMARK API DATABASE OVER');
        //       landmarkData.save();
        // final signData = Si(responsebody:responseBody);
        // SignInApiModel gettingSigninData = new SignInApiModel();
        // gettingSigninData.payload?.roles = responseBody["payload"]["roles"];
        // gettingSigninData.payload?.userId = responseBody["payload"]["userId"];
        // gettingSigninData.refreshToken = responseBody["refreshToken"];
        // gettingSigninData.accessToken = responseBody["accessToken"];
        //
        // final signDat = SignINAPIModel(signIndata: gettingSigninData);
        // SigninBox.add(signDat);
        // signDat.save();
        SignInApiModel signInData = SignInApiModel(
          payload: Payload(userId: '123', roles: ['admin']),
          accessToken: 'accessToken',
          refreshToken: 'refreshToken',
        );

        // Create an instance of SignINAPIModel
        SignINAPIModel signInAPIModel = SignINAPIModel(signIndata: signInData);

        // Get the Hive box


        // Write data to the box
        box.add(signInAPIModel);

        print('Data saved successfully.');
        print('Data saved successfully.${box.length}');
        print("wilsoncheckeer");
        print(SigninBox.get("signindata"));
        print(SigninBox.keys);
        print(SigninBox.values);


        SignInApiModel ss = new SignInApiModel();
        ss.accessToken = responseBody["accessToken"];
        ss.refreshToken = responseBody["refreshToken"];
        // ss.payload?.userId = responseBody["payload"]["userId"];
        // ss.payload?.roles = responseBody["payload"]["roles"];
        // print("Wilsonchecker");
        // print(responseBody["accessToken"]);
        // print(responseBody["refreshToken"]);
        // print(responseBody["payload"]);
        Payload payload = new Payload();
        // payload.roles = responseBody["payload"]["roles"];
        // payload.userId = responseBody["payload"]["userId"];

        // final signinData = SignInApiModel(accessToken:responseBody["accessToken"],refreshToken: responseBody["refreshToken"],payload: payload);
        // SigninBox.add(signinData);

        print("printing box length ${SigninBox.length}");

        var signInBox = Hive.box('SignInDatabase');
        // Put data into the box
        signInBox.put("accessToken", responseBody["accessToken"]);
        signInBox.put("refreshToken", responseBody["accessToken"]);
        //signInBox.put("userId", responseBody["payload"]["userId"]);

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
}