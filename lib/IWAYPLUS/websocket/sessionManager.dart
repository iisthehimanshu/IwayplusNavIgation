import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  late DateTime? _sessionStart;
  late Map<String, dynamic> sessionLogs;
  late Box _box;
  factory SessionManager() {
    return _instance;
  }
  SessionManager._internal();
  /// Initialize Hive and load session data
  Future<void> initialize() async {
    _box = await Hive.openBox('sessionLogs');
  }
  /// Start a new session
  void startSession() {
    _sessionStart = DateTime.now();
    print("Session started at $_sessionStart");
  }
  /// End the current session and log the duration
  Future<void> endSession() async {
    if (_sessionStart == null) return;
    final sessionEnd = DateTime.now();
    final sessionDuration = sessionEnd.difference(_sessionStart!).inSeconds;
    _logSession(_sessionStart!, sessionEnd, sessionDuration);
    await syncLogsToServer("");
    _sessionStart = null; // Reset the session start time
    print("Session ended. Duration: $sessionDuration seconds");
    printMap();
  }
  /// Log session details into Hive
  void _logSession(DateTime start, DateTime end, int duration) {
    sessionLogs={
      'start': DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
      'end': DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
      'duration': duration, // Duration in seconds
    };
    _box.put('sessions', sessionLogs);
  }
  /// Retrieve all session logs
  Map<String, dynamic> getSessionLogs(){
    final sessionLogs = _box.get('sessions', defaultValue: <Map<String, dynamic>>[]);
    return Map<String, dynamic>.from(sessionLogs);
  }
  void printMap(){
    print("${getSessionLogs} times");
  }

  Future<void> syncLogsToServer(String apiUrl) async {
    var signInBox = Hive.box('SignInDatabase');
    String accessToken = signInBox.get("accessToken");
    accessToken = signInBox.get("accessToken");
    if (sessionLogs.isEmpty) return;
    try{
      print("session logs:${sessionLogs}");
      final response = await http.post(
        Uri.parse((kDebugMode)?"https://dev.iwayplus.in/secured/save-session-log":"https://maps.iwayplus.in/secured/save-session-log"),
        headers:{
          'Content-Type': 'application/json',
          'x-access-token': accessToken
        },
        body: jsonEncode(sessionLogs),
      );
      if (response.statusCode == 200) {
        // Clear logs after successful sync
        print("responsebody ${response.body}");
        sessionLogs.clear();
        _box.clear();
      } else {
        print('Failed to sync logs: ${response.body}');
      }
    } catch (e) {
      print('Error syncing logs: $e');
    }
  }
  /// Clear session logs (Optional)
  void clearLogs() {
    _box.delete('sessions');
    print("Session logs cleared.");
  }
}
