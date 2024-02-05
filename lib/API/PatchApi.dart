import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/APIMODELS/patchDataModel.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/PatchAPIModel.dart';


import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import 'guestloginapi.dart';

class patchAPI {

  String token = "";
  final String baseUrl = "https://dev.iwayplus.in/secured/patch/get";


  Future<patchDataModel> fetchPatchData() async {
    final PatchBox = PatchAPIModelBox.getData();

    if(PatchBox.length!=0){
      //print("PATCH API DATA FROM DATABASE");
      Map<String, dynamic> responseBody = PatchBox.getAt(0)!.responseBody;
      return patchDataModel.fromJson(responseBody);
    }

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
      print("running");
      Map<String, dynamic> responseBody = json.decode(response.body);
       final patchData = PatchAPIModel(responseBody: responseBody);
       PatchBox.add(patchData);
      //print("PATCH API DATA FROM API");

      return patchDataModel.fromJson(responseBody);

    } else {
      print(Exception);
      throw Exception('Failed to load data');
    }
  }
}
