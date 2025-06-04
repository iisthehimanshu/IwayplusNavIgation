import 'package:flutter/services.dart';

class BluetoothServiceNew {
  static const platform = MethodChannel("com.example.bluetooth/scan");

  static Future<void> startScanBackground() async {
    try {
      await platform.invokeMethod('startScanBackground');
    } catch (e) {
      print('Failed to start scan: $e');
    }
  }

  static Future<void> stopScanBackground() async {
    try {
      await platform.invokeMethod('stopScanBackground');
    } catch (e) {
      print('Failed to stop scan: $e');
    }
  }
}
