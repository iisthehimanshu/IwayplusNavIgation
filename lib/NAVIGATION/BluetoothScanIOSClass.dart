import 'package:flutter/services.dart';
import 'package:iwaymaps/NAVIGATION/singletonClass.dart';

class BluetoothScanIOSClass {
  static const MethodChannel _channel = MethodChannel('ble_scanner');
  static const MethodChannel _IL_channel = MethodChannel('initialLocalization');


  static Future<List<String>> startScan() async {
    print("startScanTriggered");
    final List<dynamic> devices = await _channel.invokeMethod('startScan');
    return devices.cast<String>();
  }

  static Future<List<String>> getDeviceList() async {
    final List<dynamic> devices = await _channel.invokeMethod('startScan');
    return devices.cast<String>();
  }

  static Future<String> getBestDevice() async {
    final String devices = await _channel.invokeMethod('getBestDevice');
    return devices;
  }

  static Future<String> getInitialLocalizedDevice() async {
    print("getInitialLocalizedDevice call");
    String initialLocalizedBeacon = await _channel.invokeMethod('initialLocalization');
    print("initialLocalizedBeacon");
    print(initialLocalizedBeacon);
    SingletonFunctionController.SC_LOCALIZED_BEACON = initialLocalizedBeacon;

    print(" SingletonFunctionController.SC_LOCALIZED_BEACON ${ SingletonFunctionController.SC_LOCALIZED_BEACON}");
    return initialLocalizedBeacon;
  }



  static Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
  }

  // static Future<dynamic> initialLocalization() async {
  //   try {
  //     final result = await _channel.invokeMethod('initialLocalization');
  //     print('Result from iOS: $result');
  //     return result;
  //   } catch (e) {
  //     print('Error: $e');
  //     return "";
  //   }
  // }

}

class IOSBluetoothDevice{
  String NAME;
  String RSSI;
  IOSBluetoothDevice({required this.NAME,required this.RSSI});
}