import 'dart:ui';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
class wsocket{
  static final channel = io.io('https://dev.iwayplus.in', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
//message ["userId"]=123456;
  static Map message = {
    "userId": null,
    "deviceInfo": {
      "sensors": {
        "BLE": null,
        "location": null,
        "activity": null,
        "compass": null
      },
      "permissions": {
        "BLE": null,
        "location": null,
        "activity": null,
        "compass": null
      },
      "deviceManufacturer": null
    },
    "AppInitialization": {
      "BID": null,
      "buildingName": null,
      "bleScanResults": {
        "IW122": null,
        "IW123": null
      },
      "localizedOn": null
    },
    "userPosition": {
      "X": null,
      "Y": null,
      "floor": null
    },
    "path": {
      "source":null,
      "destination": null,
      "didPathForm": null
    }
  };


  wsocket(){
    channel.connect();

  }
  static void sendmessg() {
    channel.emit("user-log-socket", message);
  }
}