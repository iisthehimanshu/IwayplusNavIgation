import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class InteractionManager {
  static final InteractionManager _instance = InteractionManager._internal();

  late Map<String, int> _logs;
  late Box _box;

  factory InteractionManager() {
    return _instance;
  }
  InteractionManager._internal() {
    _logs = {};
  }
  /// Initialize Hive and load logs
  Future<void> initialize() async {
    _box = await Hive.openBox('interactionLogs');
    _loadLogsFromHive();
  }

  /// Log an interaction
  void logInteraction(String elementName) {
    if (_logs.containsKey(elementName)) {
      _logs[elementName] = _logs[elementName]! + 1;
    } else {
      _logs[elementName] = 1;
    }
    _saveLogsToHive();
    print("Tapped on $elementName: ${_logs[elementName]} times");
  }
  /// Save logs to Hive
  void _saveLogsToHive() {
    _box.put('logs', _logs);
  }
  void printMap(){
    print("${_logs} times");
  }
  /// Load logs from Hive
  void _loadLogsFromHive() {
    final storedLogs = _box.get('logs') as Map<dynamic, dynamic>?;
    // Convert dynamic keys and values to a Map<String, int>
    _logs = storedLogs?.map((key, value) => MapEntry(key as String, value as int)) ?? {};
  }

  /// Sync logs to the server
  Future<void> syncLogsToServer(String apiUrl) async {
    var signInBox = Hive.box('SignInDatabase');
    String accessToken = signInBox.get("accessToken");
    accessToken = signInBox.get("accessToken");
    if (_logs.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse((kDebugMode)?"https://dev.iwayplus.in/secured/save-activity-logs":"https://maps.iwayplus.in/secured/save-activity-logs"),
        headers:{
      'Content-Type': 'application/json',
      'x-access-token': accessToken
      },
        body: jsonEncode(_logs),
      );
      if (response.statusCode == 200) {
        // Clear logs after successful sync
        print("responsebody ${response.body}");
        _logs.clear();
        _box.clear();
      } else {
        print('Failed to sync logs: ${response.body}');
      }
    } catch (e) {
      print('Error syncing logs: $e');
    }
  }
}
