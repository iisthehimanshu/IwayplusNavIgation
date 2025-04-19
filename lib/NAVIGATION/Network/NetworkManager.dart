import 'dart:convert';

import 'package:iwaymaps/NAVIGATION/Encryption/EncryptionService.dart';
import 'package:http/http.dart' as http;

import 'APIDetails.dart';

class Networkmanager{
  Encryptionservice encryptionService = Encryptionservice();

  Future<dynamic> request(Detail apiDetail) async {
    final client = http.Client();

    try {
      http.Response response;
      dynamic finalBody;
      if(apiDetail.encryption && apiDetail.body != null){
        finalBody = encryptionService.encrypt(apiDetail.body!);
      }else{
        finalBody = apiDetail.body;
      }

      switch (apiDetail.method.toUpperCase()) {
        case 'POST':
          response = await client.post(
            Uri.parse(apiDetail.url),
            body: finalBody,
            headers: apiDetail.headers,
          );
          break;

        case 'GET':
          response = await client.get(Uri.parse(apiDetail.url), headers: apiDetail.headers);
          break;

        default:
          throw Exception('Unsupported HTTP method');
      }

      String responseBody = response.body;

      dynamic decryptedBody = encryptionService.decrypt(responseBody);
      apiDetail.conversionFunction!(decryptedBody);
      return jsonDecode(decryptedBody);
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }
}