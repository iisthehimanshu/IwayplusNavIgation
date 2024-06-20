import 'dart:ui';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
class wsocket{
  static final channel = io.io('https://dev.iwayplus.in', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  static Map message = {
    "userId": "665d551e1ae7caff923f053b",
    "deviceInfo": {
      "sensors": {
        "BLE": true,
        "location": true,
        "activity": true,
        "compass": true
      },
      "permissions": {
        "BLE": true,
        "location": true,
        "activity": true,
        "compass": true
      },
      "deviceManufacturer": "Google"
    },
    "AppInitialization": {
      "BID": "65d887a5db333f89457145f6",
      "buildingName": "Research Park main",
      "bleScanResults": {
        "IW122": -65,
        "IW123": -89
      },
      "localizedOn": "IW111"
    },
    "userPosition": {
      "X": 50,
      "Y": 90,
      "floor": 1
    },
    "path": {
      "source": "Main",
      "destination": "iway",
      "didPathForm": true
    }
  };


  wsocket(){
    channel.connect();

  }
  static void sendmessg() {
    channel.emit("user-log-socket", message);
  }
}