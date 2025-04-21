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
}


