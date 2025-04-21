import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class WebSocketManager {
  WebSocket? _socket;
  Timer? _timer;

  final Map<String, dynamic> _message = {
    'appId': 'appID',
    "userId": "",
    "deviceInfo": {
      "sensors": {
        "BLE": false,
        "location": false,
        "activity": false,
        "compass": false
      },
      "permissions": {
        "BLE": false,
        "location": false,
        "activity": false,
        "compass": false
      },
      "deviceManufacturer": ""
    },
    "AppInitialization": {
      "BID": "",
      "buildingName": "",
      "bleScanResults": {},
      "nearByDevices": {},
      "localizedOn": ""
    },
    "userPosition": {
      "X": 0,
      "Y": 0,
      "floor": 0
    },
    "path": {
      "source": "",
      "destination": "",
      "didPathForm": false
    }
  };

  // ----- WebSocket handling -----
  Future<void> connect(String url) async {
    _socket = await WebSocket.connect(url);
    if (kDebugMode) {
      print('WebSocket connected');
    }

    _socket!.listen(
          (data) => _handleMessage(data),
      onDone: () => print('WebSocket closed'),
      onError: (error) => print('WebSocket error: $error'),
    );
  }

  void send(Map<String, dynamic> data) {
    if (_socket?.readyState == WebSocket.open) {
      _socket!.add(jsonEncode(data));
    }
  }

  void startAutoSend(int frequencyInSeconds) {
    stopAutoSend();
    _timer = Timer.periodic(Duration(seconds: frequencyInSeconds), (_) {
      send(_message);
    });
  }

  void stopAutoSend() {
    _timer?.cancel();
    _timer = null;
  }

  void disconnect() {
    stopAutoSend();
    _socket?.close();
    _socket = null;
  }

  void _handleMessage(dynamic data) {
    if (kDebugMode) {
      print('Received: $data');
    }
  }

  // ----- Sectional update methods -----

  void updateUserId(String userId) {
    _message["userId"] = userId;
  }

  void updateSensorStatus({
    bool? ble,
    bool? location,
    bool? activity,
    bool? compass,
  }) {
    final sensors = _message["deviceInfo"]["sensors"];
    if (ble != null) sensors["BLE"] = ble;
    if (location != null) sensors["location"] = location;
    if (activity != null) sensors["activity"] = activity;
    if (compass != null) sensors["compass"] = compass;
  }

  void updatePermissions({
    bool? ble,
    bool? location,
    bool? activity,
    bool? compass,
  }) {
    final permissions = _message["deviceInfo"]["permissions"];
    if (ble != null) permissions["BLE"] = ble;
    if (location != null) permissions["location"] = location;
    if (activity != null) permissions["activity"] = activity;
    if (compass != null) permissions["compass"] = compass;
  }

  void updateDeviceManufacturer(String manufacturer) {
    _message["deviceInfo"]["deviceManufacturer"] = manufacturer;
  }

  void updateInitialization({
    String? bid,
    String? buildingName,
    Map<String, dynamic>? bleScanResults,
    Map<String, dynamic>? nearByDevices,
    String? localizedOn,
  }) {
    final init = _message["AppInitialization"];
    if (bid != null) init["BID"] = bid;
    if (buildingName != null) init["buildingName"] = buildingName;
    if (bleScanResults != null) init["bleScanResults"] = bleScanResults;
    if (nearByDevices != null) init["nearByDevices"] = nearByDevices;
    if (localizedOn != null) init["localizedOn"] = localizedOn;
  }

  void updateUserPosition({required double x, required double y, required int floor}) {
    _message["userPosition"]["X"] = x;
    _message["userPosition"]["Y"] = y;
    _message["userPosition"]["floor"] = floor;
  }

  void updatePath({String? source, String? destination, bool? didPathForm}) {
    final path = _message["path"];
    if (source != null) path["source"] = source;
    if (destination != null) path["destination"] = destination;
    if (didPathForm != null) path["didPathForm"] = didPathForm;
  }

  // Optional: expose read-only message
  Map<String, dynamic> get currentMessage => Map.unmodifiable(_message);
}
