import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/DATABASE/BOXES/OutDoorModelBOX.dart';
import '../APIMODELS/guestloginmodel.dart';
import '../APIMODELS/outdoormodel.dart';
import '../DATABASE/DATABASEMODEL/OutDoorModel.dart';
import 'guestloginapi.dart';

class outBuilding {

  Future<outdoormodel?> outbuilding(List<String> ids) async {

    final String baseUrl = "https://dev.iwayplus.in/secured/outdoor";

    String token = "";

    final OutBuildingBox = OutDoorModeBOX.getData();


    await guestApi().guestlogin().then((value){
      if(value.accessToken != null){
        token = value.accessToken!;
      }
    });


    final Map<String, dynamic> data = {
      "buildingIds": ids
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
      final outBuildingData = OutDoorModel(responseBody: responseBody);
      OutBuildingBox.put(outdoormodel.fromJson(responseBody).data!.campusId, outBuildingData);
      outBuildingData.save();

      return outdoormodel.fromJson(responseBody);

    } else {
      print(ids);
      print(json.decode(response.body));
      print("outdoor api error");
    }
  }
}
