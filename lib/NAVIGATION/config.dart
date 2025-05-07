import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return 'https://dev.iwayplus.in';
    } else {
      return 'https://maps.iwayplus.in';
    }
  }

  static String playStore = "com.iwayplus.navigation";
  static String appStore = "iwaymaps/id6478580371";
  static String appID = "com.iwayplus.navigation";
}


