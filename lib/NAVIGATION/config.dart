import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return 'https://dev.iwayplus.in';
    } else {

      return 'https://maps.iwayplus.in';
    }
  }
  static String get xaccesstoken {
  if (kDebugMode) {
  return '0eef5040-b6e7-11ef-8f89-1f3bdf8a8f2e';
  } else {
  return 'e44f4020-b6f0-11ef-8392-afa70ad2e6a2';
  }
}
}
