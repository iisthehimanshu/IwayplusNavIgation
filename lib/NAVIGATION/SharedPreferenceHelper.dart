import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static SharedPreferenceHelper? _instance;
  static SharedPreferences? _prefs;

  // Private constructor
  SharedPreferenceHelper._internal();

  // Singleton instance
  static Future<SharedPreferenceHelper> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferenceHelper._internal();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Save a Map<String, dynamic> as a JSON string
  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    String jsonString = jsonEncode(value); // Convert Map to JSON String
    await _prefs?.setString(key, jsonString);
    print("saved ${ _prefs?.getString(key)}");
  }

  // Get a Map<String, dynamic> from a JSON string
  Map<String, dynamic>? getMap(String key) {
    String? jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString); // Convert JSON String back to Map
    }
    return null;
  }

  // Other existing methods remain the same
  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  Future<void> removeKey(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
