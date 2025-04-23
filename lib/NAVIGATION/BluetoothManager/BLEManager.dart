import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';
import '../APIMODELS/beaconData.dart';
import '../ELEMENTS/BluetoothDevice.dart';
import '../Repository/RepositoryManager.dart';

class BLEManager{

  static const methodChannel = MethodChannel('com.example.bluetooth/scan');
  static const eventChannel = EventChannel('com.example.bluetooth/scanUpdates');
  RepositoryManager networkManager = RepositoryManager();
  final StreamController<Map<String, dynamic>> _bufferedDeviceStreamController =
  StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get bufferedDeviceStream => _bufferedDeviceStreamController.stream;
  static StreamSubscription? _scanSubscription;

  Timer? _bufferEmitTimer;
  Timer? _manualStopTimer;

  Map<String,Map<DateTime,String>> buffer = Map();


  void startScanning({
    required int bufferSize,
    required int streamFrequency,
    int? duration,
  }) {
    stopScanning(); // cancel previous

    // networkManager.getBeaconData(bID)
    //
    // listenToScanUpdates(apibeaconmap);

    // Start emitting data to stream every [streamFrequency] seconds
    startBufferedEmission(bufferSizeInSeconds: streamFrequency);

    if (duration != null) {
      _manualStopTimer = Timer(Duration(seconds: duration), () {
        stopScanning();
      });
    }
  }


  void startBufferedEmission({required int bufferSizeInSeconds}) {
    _bufferEmitTimer?.cancel(); // cancel previous if any
    _bufferEmitTimer = Timer.periodic(Duration(seconds: bufferSizeInSeconds), (_) {
      final dataToSend = _prepareBufferedData();
      _bufferedDeviceStreamController.add(dataToSend);
    });
  }

  Map<String, dynamic> _prepareBufferedData() {
    final Map<String, dynamic> output = {};

    // for (var entry in rssiValues.entries) {
    //   final address = entry.key;
    //   final rssiList = entry.value;
    //
    //   if (rssiList.isNotEmpty) {
    //     final avg = rssiList.reduce((a, b) => a + b) / rssiList.length;
    //     output[address] = {
    //       "name": deviceNames[address] ?? "Unknown",
    //       "averageRssi": avg.toStringAsFixed(1),
    //       "lastSeen": lastSeenTimestamps[address]?.toIso8601String()
    //     };
    //   }
    // }
    return output;
  }



  Future<void> startScan() async {
    try{
      await methodChannel.invokeMethod('startScan');
      // isScanning = true;
    } on PlatformException catch(e){
      print("Failed to start scan: ${e.message}");
    }
  }

  Future<void> stopScanning() async {
    try {
      await methodChannel.invokeMethod('stopScan');
      // isScanning = false;
      // cleanupTimer.cancel();
    } on PlatformException catch (e) {
      print("Failed to stop scan: ${e.message}");
    }
  }

  void listenToScanUpdates(HashMap<String, beacon> apibeaconmap) {
    startScan();
    // startCleanupTimer();
    print("listenToScanUpdates");


    String deviceMacId = "";
    // Start listening to the stream continuously
    _scanSubscription = eventChannel.receiveBroadcastStream().listen((deviceDetail) {
      print("deviceDetail----- $deviceDetail");
      // BluetoothDevice deviceDetails = parseDeviceDetails(deviceDetail);
      // // String dataaa = parseLog(deviceDetail);
      // networkManager.ws.updateInitialization(nearByDevices: MapEntry(deviceDetails.rawData, deviceDetails.DeviceRssi));
      // print("dataaa- $dataaa");

      // if(apibeaconmap.containsKey(deviceDetails.DeviceName)) {
      //   DateTime currentTime = DateTime.now();
      //   //wsocket.message["AppInitialization"]["bleScanResults"][deviceDetails.DeviceName] = deviceDetails.DeviceRssi;
      //   deviceMacId = deviceDetails.DeviceAddress;
      //   print("iffffff");
      //   print(deviceDetails.DeviceName);
      //
      //
      //   slidingScan.putIfAbsent(deviceDetails.DeviceName, () => <String, DateTime>{});
      //   slidingScan[deviceDetails.DeviceName]![deviceDetails.DeviceRssi] = currentTime;
      //
      //   deviceNames[deviceDetails.DeviceAddress] = deviceDetails.DeviceName;
      //   lastSeenTimestamps[deviceDetails.DeviceAddress] = currentTime;
      //
      //   rssiValues.putIfAbsent(deviceDetails.DeviceAddress, () => []);
      //   rssiWeight.putIfAbsent(deviceDetails.DeviceAddress, () => []);
      //
      //
      //   rssiValues[deviceDetails.DeviceAddress]!.add(int.parse(deviceDetails.DeviceRssi));
      //   print("deviceDetails.DeviceRssi");
      //   print(deviceDetails.DeviceRssi);
      //
      //   rssiWeight[deviceDetails.DeviceAddress]!.add(getWeight(getBinNumber(int.parse(deviceDetails.DeviceRssi).abs())));
      //
      //   if (rssiValues[deviceDetails.DeviceAddress]!.length > 7) {
      //     rssiValues[deviceDetails.DeviceAddress]!.removeAt(0);
      //   }
      //
      //   if(rssiWeight[deviceDetails.DeviceAddress]!.length > 7){
      //     rssiWeight[deviceDetails.DeviceAddress]!.removeAt(0);
      //   }
      // }
    }, onError: (error) {
      print('Error receiving device updates: $error');
    });
  }
}