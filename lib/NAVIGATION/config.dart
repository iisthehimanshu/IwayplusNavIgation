import 'dart:convert';

import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return 'https://maps.iwayplus.in';
    } else {
      return 'https://maps.iwayplus.in';
    }
  }

  static String get encryptionKey {
    if (baseUrl == 'https://dev.iwayplus.in') {
      return 'rtyHuAxNZPIyx1YMCXQJcx6dX1ev0/svf79IWd1teX0=';
    } else {
      return 'YuXmrhpu5ENd+erlQ6TXmijrtYO72Icpm6irw7f/a9E=';
    }
  }

  static String get Authorization {
    if (baseUrl == 'https://dev.iwayplus.in') {
      return 'd52f6110-c69a-11ef-aa4e-e7aa7912987a';
    } else {
      return '023357e0-cf4f-11ef-8c00-45832f202b2e';
    }
  }
}

String encryptDecrypt(String input) {
  String key = AppConfig.encryptionKey;
  StringBuffer result = StringBuffer();
  for (int i = 0; i < input.length; i++) {
// XOR each character of the input with the corresponding character of the key
    result.writeCharCode(input.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
  }
  return result.toString();
}

String EncryptedbodyForApi(Map<String, dynamic> data){
  final jsonEncoder = JsonEncoder();
  var finalData=jsonEncoder.convert(data);
  final encryptedData = encryptDecrypt(finalData);
  return json.encode({"encryptedData":encryptedData});
}

