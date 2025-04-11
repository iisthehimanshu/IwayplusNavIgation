import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'BluetoothScanIOSClass.dart';


class BLEScreen extends StatefulWidget {
  @override
  _BLEScreenState createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  static const platform = MethodChannel('com.example/ble_manager');
  String bestDevice = "No device found";
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startPeriodicCheck();
  }

  void startPeriodicCheck() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        String scannedDevices = await BluetoothScanIOSClass.getBestDevice();
        print("scannedDevices");
        print(scannedDevices);
      } catch (e) {
        print("Error getting best device: $e");
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLE Best Device')),
      body: Center(
        child: Text('Best Device: $bestDevice'),
      ),
    );
  }
}