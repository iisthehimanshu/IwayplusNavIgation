import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class NavigationLog {
  final String userId;
  final String source;
  final String destination;
  final DateTime startTime;
  DateTime? endTime;
  bool isSuccess;
  String reason; // e.g., "Exited manually", "Reached destination"
  int rerouteCount; // Number of times rerouting happened

  NavigationLog({
    required this.userId,
    required this.source,
    required this.destination,
    required this.startTime,
    this.endTime,
    this.isSuccess = false,
    this.reason = '',
    this.rerouteCount = 0,
  });
  void markSuccessful() {
    isSuccess = true;
    reason = "Successfully reached destination";
    endTime = DateTime.now();
  }
  void markUnsuccessful(String exitReason) {
    isSuccess = false;
    reason = exitReason;
    endTime = DateTime.now();
  }

  void incrementReroute() {
    rerouteCount += 1;
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "source": source,
      "destination": destination,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime?.toIso8601String(),
      "isSuccess": isSuccess,
      "reason": reason,
      "rerouteCount": rerouteCount,
    };
  }
  factory NavigationLog.fromJson(Map<String, dynamic> json) {
    return NavigationLog(
      userId: json["userId"],
      source: json["source"],
      destination: json["destination"],
      startTime: DateTime.parse(json["startTime"]),
      endTime: json["endTime"] != null ? DateTime.parse(json["endTime"]) : null,
      isSuccess: json["isSuccess"],
      reason: json["reason"],
      rerouteCount: json["rerouteCount"],
    );
  }
}
