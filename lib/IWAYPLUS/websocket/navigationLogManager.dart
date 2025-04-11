import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'navigationLogModel.dart';

import 'package:http/http.dart' as http;

class NavigationLogManager {
  static final NavigationLogManager _instance = NavigationLogManager._internal();
  late List<NavigationLog> _logs;
  late Box _box;
  factory NavigationLogManager() {
    return _instance;
  }
  NavigationLogManager._internal() {
    _logs = [];
  }
  /// Initialize Hive and load logs
  Future<void> initialize() async {
    _box = await Hive.openBox('navigationLogs');
    _loadLogsFromHive();
  }
  /// Log a navigation event
  void logNavigation(NavigationLog log){
    _logs.add(log);
    _saveLogsToHive();
    print("Navigation Log Added: ${log.toJson()}");
  }
  /// Save logs to Hive
  void _saveLogsToHive(){
    List<String> encodedLogs = _logs.map((log) => jsonEncode(log.toJson())).toList();
    _box.put('logs', encodedLogs);
  }
  /// Load logs from Hive
  void _loadLogsFromHive(){
    final storedLogs = _box.get('logs') as List<dynamic>?;
    if (storedLogs != null){
      _logs = storedLogs.map((log) => NavigationLog.fromJson(jsonDecode(log))).toList();
    }
  }
  /// Sync logs to the server
  Future<void> syncLogsToServer() async{
    var signInBox = Hive.box('SignInDatabase');
    String accessToken = signInBox.get("accessToken");
    if (_logs.isEmpty) return;
    try{
      print("navigation logs::${_logs}");
      final response = await http.post(
        Uri.parse(kDebugMode
            ? "https://dev.iwayplus.in/secured/save-navigation-logs"
            : "https://maps.iwayplus.in/secured/save-navigation-logs"),
        headers:{
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
        },
        body: jsonEncode(_logs.map((log) => log.toJson()).toList()),
      );
      if (response.statusCode == 200){
        print("Navigation Logs Synced: ${response.body}");
        _logs.clear();
        _box.clear();
      }else{
        print('Failed to sync navigation logs: ${response.body}');
      }
    }catch (e){
      print('Error syncing navigation logs: $e');
    }
  }
}