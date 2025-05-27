import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config.dart';

class WebSocketManager {
  late IO.Socket socket;
  Timer? _timer;

  final Map<String, dynamic> _message = {
    'appId': AppConfig.appID,
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

  Map<String, dynamic> _lastSentMessage = {};

  void init() {
    socket = IO.io(AppConfig.baseUrl, {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('Socket connected');
      startAutoSend();
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      stopAutoSend();
    });

    socket.on('message', (data) {
      print('Received: $data');
    });
  }

  void connect() {
    socket.connect();
  }

  void disconnect() {
    stopAutoSend();
    socket.disconnect();
  }

  void startAutoSend() {
    stopAutoSend(); // avoid duplicates
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      send(_message);
    });
  }

  void stopAutoSend() {
    _timer?.cancel();
    _timer = null;
  }

  void send(Map<String, dynamic> data) {
    final dataString = _deepSortAndStringify(data);
    final lastString = _deepSortAndStringify(_lastSentMessage);

    if (socket.connected && dataString != lastString) {
      socket.emit('user-log-socket', data);
      _lastSentMessage = _cloneDeep(data);
      // print("socket data $data");
    }
  }

  Map<String, dynamic> get currentMessage => Map.unmodifiable(_message);

  // --- Utility Methods ---
  String _deepSortAndStringify(Map<String, dynamic> data) {
    return _sortAndConvert(data).toString();
  }

  dynamic _sortAndConvert(dynamic value) {
    if (value is Map) {
      final sorted = Map.fromEntries(value.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      return sorted.map((k, v) => MapEntry(k, _sortAndConvert(v)));
    } else if (value is List) {
      return value.map(_sortAndConvert).toList();
    }
    return value;
  }

  Map<String, dynamic> _cloneDeep(Map<String, dynamic> original) {
    return Map<String, dynamic>.from(_sortAndConvert(original));
  }

  // --- Update Methods ---
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
    MapEntry<String, dynamic>? bleScanResults,
    MapEntry<String, dynamic>? nearByDevices,
    String? localizedOn,
  }) {
    final init = _message["AppInitialization"];
    if (bid != null) init["BID"] = bid;
    if (buildingName != null) init["buildingName"] = buildingName;
    if (bleScanResults != null) init["bleScanResults"][bleScanResults.key] = bleScanResults.value;
    if (nearByDevices != null) init["nearByDevices"][nearByDevices.key] = nearByDevices.value;
    if (localizedOn != null) init["localizedOn"] = localizedOn;
  }

  void updateUserPosition({required int x, required int y, required int floor}) {
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

}
