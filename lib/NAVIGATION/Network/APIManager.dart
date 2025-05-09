import 'dart:convert';

import 'package:iwaymaps/NAVIGATION/Encryption/EncryptionService.dart';
import 'package:http/http.dart' as http;

import '../API/response.dart';
import '../DatabaseManager/DataBaseManager.dart';
import 'APIDetails.dart';

class Apimanager{
  Encryptionservice encryptionService = Encryptionservice();

  Future<dynamic> request(Detail apiDetail, {String? newAccessToken}) async {
    final client = http.Client();
    if(newAccessToken != null){
      apiDetail.updateAccessToken(newAccessToken);
    }
    try {
      http.Response response;

      switch (apiDetail.method.toUpperCase()) {
        case 'POST':
          response = await client.post(
            Uri.parse(apiDetail.url),
            body: jsonEncode(apiDetail.body),
            headers: apiDetail.headers,
          );
          break;

        case 'GET':
          response = await client.get(Uri.parse(apiDetail.url), headers: apiDetail.headers);
          break;

        default:
          throw Exception('Unsupported HTTP method');
      }
      if(response.statusCode == 200){
        String responseBody = response.body;
        dynamic decryptedBody = json.decode(responseBody);
        if(apiDetail.encryption){
          decryptedBody = encryptionService.decrypt(decryptedBody['encryptedData']);
          decryptedBody = json.decode(decryptedBody);
        }
        Response responseObject = Response(response.statusCode, decryptedBody);

        return responseObject;
      }else if(response.statusCode == 403){
        Response refreshResponse = await request(Apidetails.refreshToken());
        apiDetail.updateAccessToken(Apidetails.refreshToken().conversionFunction(refreshResponse.data).accessToken);
        DataBaseManager().updateAccessToken(Apidetails.refreshToken().conversionFunction(refreshResponse.data).accessToken);
        DataBaseManager().updateRefreshToken(Apidetails.refreshToken().conversionFunction(refreshResponse.data).refreshToken);
        return await request(apiDetail);
      }


    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }
}