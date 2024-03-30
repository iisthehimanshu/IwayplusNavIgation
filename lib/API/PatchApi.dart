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

  void checkForUpdate({String? id=null}) async{
    final PatchBox = PatchAPIModelBox.getData();
    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString()
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      String APITime = responseBody['patchData']['updatedAt']!;
      final patchData = PatchAPIModel(responseBody: responseBody);
      if(!PatchBox.containsKey(buildingAllApi.getStoredString())) {
        PatchBox.put(buildingAllApi.getStoredString(),patchData);
        patchData.save();
        print("PATCHDATA UPDATE BOX EMPTY AND SAVED IN THE DATABASE");
      }else{
        Map<String, dynamic> databaseresponseBody = PatchBox.get(buildingAllApi.getStoredString())!.responseBody;
        String LastUpdatedTime = databaseresponseBody['patchData']['updatedAt'];
        print("APITime");
        if(APITime!=LastUpdatedTime){
          print("PATCHDATA UPDATE API DATA FROM DATABASE AND UPDATED");
          print("Current Time: ${APITime} Lastupdated Time: ${LastUpdatedTime}");
          PatchBox.put(buildingAllApi.getStoredString(),patchData);
          patchData.save();
        }
      }
    } else {
      print(Exception);
      throw Exception('Failed to load data');
    }
  }

  Future<patchDataModel> fetchPatchData({String? id = null}) async {
    print("patch");
    final PatchBox = PatchAPIModelBox.getData();
    if(PatchBox.containsKey(id??buildingAllApi.getStoredString())){
      print("PATCH API DATA FROM DATABASE");
      print(PatchBox.get(buildingAllApi.getStoredString())!.responseBody);
      Map<String, dynamic> responseBody = PatchBox.get(id??buildingAllApi.getStoredString())!.responseBody;
      return patchDataModel.fromJson(responseBody);
    }

    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });

    final Map<String, dynamic> data = {
      "id": id??buildingAllApi.getStoredString()
    };

    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': token
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      final patchData = PatchAPIModel(responseBody: responseBody);
      PatchBox.put(buildingAllApi.getStoredString(),patchData);
      patchData.save();
      print("PATCH API DATA FROM API");
      return patchDataModel.fromJson(responseBody);

    } else {
      print(Exception);
      throw Exception('Failed to load data');
    }
  }
}
