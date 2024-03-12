import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/APIMODELS/patchDataModel.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/PatchAPIModel.dart';


import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import 'guestloginapi.dart';

class patchAPI {

  String token = "";
  final String baseUrl = "https://dev.iwayplus.in/secured/patch/get";


  Future<patchDataModel> fetchPatchData() async {

    final PatchBox = PatchAPIModelBox.getData();
    print(buildingAllApi.getStoredString());

    if(PatchBox.containsKey(buildingAllApi.getStoredString())){
      print("PATCH API DATA FROM DATABASE");
      print(PatchBox.get(buildingAllApi.getStoredString())!.responseBody);
      Map<String, dynamic> responseBody = PatchBox.get(buildingAllApi.getStoredString())!.responseBody;
      return patchDataModel.fromJson(responseBody);
    }

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": buildingAllApi.getStoredString()
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
      String APITime = responseBody['patchData']['updatedAt']!;

      if(!PatchBox.containsKey(buildingAllApi.getStoredString())) {
        final patchData = PatchAPIModel(responseBody: responseBody);
        PatchBox.put(buildingAllApi.getStoredString(),patchData);
        print("PATCH API DATA FROM API");
        return patchDataModel.fromJson(responseBody);
      }else{
        Map<String, dynamic> databaseresponseBody = PatchBox.get(buildingAllApi.getStoredString())!.responseBody;
        String LastUpdatedTime = databaseresponseBody['patchData']!['updatedAt'];
        print("${APITime} ${LastUpdatedTime}");
        if(APITime==LastUpdatedTime){
          print("POLYLINE API DATA FROM DATABASE");
          return patchDataModel.fromJson(databaseresponseBody);
        }else{
          print("POLYLINE API DATA FROM DATABASE AND UPDATED");
          final patchData = PatchAPIModel(responseBody: responseBody);
          PatchBox.put(buildingAllApi.getStoredString(),patchData);
          return patchDataModel.fromJson(responseBody);
        }

        return patchDataModel.fromJson(responseBody);
      }




    } else {
      print(Exception);
      throw Exception('Failed to load data');
    }
  }
}
