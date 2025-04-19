import 'dart:convert';

import 'package:iwaymaps/NAVIGATION/config.dart';

class Encryptionservice{

   String get encryptionKey {
    if (AppConfig.baseUrl == 'https://dev.iwayplus.in') {
      return 'rtyHuAxNZPIyx1YMCXQJcx6dX1ev0/svf79IWd1teX0=';
    } else {
      return 'YuXmrhpu5ENd+erlQ6TXmijrtYO72Icpm6irw7f/a9E=';
    }
  }

   String get authorization {
    if (AppConfig.baseUrl == 'https://dev.iwayplus.in') {
      return 'd52f6110-c69a-11ef-aa4e-e7aa7912987a';
    } else {
      return '023357e0-cf4f-11ef-8c00-45832f202b2e';
    }
  }

  String decrypt(String input) {
    String key = encryptionKey;
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }

  String encrypt(Map<String, dynamic> data){
    const jsonEncoder = JsonEncoder();
    var finalData=jsonEncoder.convert(data);
    final encryptedData = decrypt(finalData);
    return json.encode({"encryptedData":encryptedData});
  }

}