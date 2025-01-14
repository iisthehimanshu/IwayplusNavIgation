import 'package:flutter/services.dart';

class BluetoothScanIOSClass {
  static const MethodChannel _channel = MethodChannel('ble_scanner');

  static Future<List<String>> startScan() async {
    print("startScanTriggered");

    final List<dynamic> devices = await _channel.invokeMethod('startScan');
    return devices.cast<String>();
  }

  static Future<List<String>> getDeviceList() async {
    final List<dynamic> devices = await _channel.invokeMethod('startScan');
    return devices.cast<String>();
  }

  static Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
  }
}

class IOSBluetoothDevice{
  String NAME;
  String RSSI;
  IOSBluetoothDevice({required this.NAME,required this.RSSI});
}