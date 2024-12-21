
import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/services.dart';

import 'APIMODELS/beaconData.dart';
import 'ELEMENTS/BlurtoothDevice.dart';

class BluetoothScanAndroidClass{
  static const methodChannel = MethodChannel('com.example.bluetooth/scan');
  static const eventChannel = EventChannel('com.example.bluetooth/scanUpdates');
  List<BluetoothDevice> devices = [];
  bool isScanning = false;


  Map<String, String> deviceNames = {};
  Map<String, List<int>> rssiValues = {};
  Map<String, double> distances = {};
  String closestDeviceDetails = "";
  Map<String, double> sumMapCallBack = {};





  Future<void> startScan() async {
    try{
      await methodChannel.invokeMethod('startScan');
      isScanning = false;
    } on PlatformException catch(e){
      print("Failed to start scan: ${e.message}");
    }
  }
  Future<void> stopScan() async {
    try {
      await methodChannel.invokeMethod('stopScan');
      isScanning = false;
    } on PlatformException catch (e) {
      print("Failed to stop scan: ${e.message}");
    }
  }


  BluetoothDevice parseDeviceDetails(String response) {
    final deviceRegex = RegExp(
      r'Device Name: (.+?)\n.*?Address: (.+?)\n.*?RSSI: (-?\d+)',
      dotAll: true,
    );

    final match = deviceRegex.firstMatch(response);

    if (match != null) {
      final deviceName = match.group(1) ?? 'Unknown';
      final deviceAddress = match.group(2) ?? 'Unknown';
      final deviceRssi = match.group(3) ?? '0';

      return BluetoothDevice(
        DeviceName: deviceName,
        DeviceAddress: deviceAddress,
        DeviceRssi: deviceRssi,
      );
    } else {
      throw Exception('Invalid device details string');
    }
  }
  String listenToScanUpdates(HashMap<String, beacon> apibeaconmap) {
    startScan();
    print("listenToScanUpdates");
    // startbin();
    // eventChannel.receiveBroadcastStream().listen((deviceDetail) {
    //   print("deviceDetails");
    //   print(deviceDetail);
    //
    //
    //
    //   BluetoothDevice deviceDetails = parseDeviceDetails(deviceDetail);
    //   deviceNames[deviceDetails.DeviceAddress] = deviceDetails.DeviceName;
    //   setState(() {
    //     devices.add(deviceDetails);
    //   });
    //
    //   addtoBin(deviceDetails.DeviceAddress, int.parse(deviceDetails.DeviceRssi));
    //
    //
    //
    //   //
    //
    //   //
    //   // rssiValues.putIfAbsent(deviceDetails.DeviceAddress, () => []);
    //   // if (rssiValues[deviceDetails.DeviceAddress]!.length >= 5) {
    //   //   rssiValues[deviceDetails.DeviceAddress]!.removeAt(0);
    //   // }
    //   // rssiValues[deviceDetails.DeviceAddress]!.add(int.parse(deviceDetails.DeviceRssi));
    //   //
    //   // double averagedRssi = rssiValues[deviceDetails.DeviceAddress]!.reduce((a, b) => a + b) /
    //   //     rssiValues[deviceDetails.DeviceAddress]!.length;
    //   //
    //   // distances[deviceDetails.DeviceAddress] = averagedRssi;
    //   // print("checkrsssi");
    //   // print("${distances[deviceDetails.DeviceAddress]} ${averagedRssi}");
    //   // if (distances.isNotEmpty) {
    //   //   Map<String, double> sortedsumMap = sortMapByValue(distances);
    //   //
    //   //
    //   //   final closestDeviceId = distances.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    //   //   closestDeviceDetails = "Device Name: ${deviceNames[sortedsumMap.entries.first.key]}";
    //   // }
    //   // print("closestDeviceDetails");
    //   // print(closestDeviceDetails);
    //   //
    //   //
    //   //
    //
    //
    //
    //
    //
    // }, onError: (error) {
    //   print('Error receiving device updates: $error');
    // });
// Map to store devices and their RSSI values for processing
    Map<String, List<int>> rssiValues = {};

    // Start listening to the stream continuously
    eventChannel.receiveBroadcastStream().listen((deviceDetail) {
      BluetoothDevice deviceDetails = parseDeviceDetails(deviceDetail);
      if(apibeaconmap.containsKey(deviceDetails.DeviceName)) {
        print("iffffff");
        print(deviceDetails.DeviceName);
        // Update device names
        deviceNames[deviceDetails.DeviceAddress] = deviceDetails.DeviceName;

        // Add RSSI value to the list for the corresponding device
        rssiValues.putIfAbsent(deviceDetails.DeviceAddress, () => []);
        rssiValues[deviceDetails.DeviceAddress]!.add(
            int.parse(deviceDetails.DeviceRssi));

        // Keep only the latest RSSI values (optional, for better averaging)
        if (rssiValues[deviceDetails.DeviceAddress]!.length > 5) {
          rssiValues[deviceDetails.DeviceAddress]!.removeAt(0);
        }

        // Add to bin
        addtoBin(deviceDetails.DeviceAddress, int.parse(deviceDetails.DeviceRssi));
      }else{

      }
    }, onError: (error) {
      print('Error receiving device updates: $error');
    });

    // Process the collected data every 5 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      // Calculate average RSSI values
      Map<String, double> sumMap = calculateAverage();

      // Sort the map by value (e.g., strongest signal first)
      Map<String, double> sortedSumMap = sortMapByValue(sumMap);

      sumMapCallBack = sortedSumMap;

      // Log the sorted mapcccc
      print("SortedSumMap: $sortedSumMap");

      // Update closest device details if available
      if (sortedSumMap.isNotEmpty) {
        closestDeviceDetails = "${deviceNames[sortedSumMap.entries.first.key]}";
      }
      print("closestDeviceDetails");
      print(closestDeviceDetails);
    });

    emptyBin();


    return closestDeviceDetails;
  }

  Map<String, double> giveSumMapCallBack(){
    return sumMapCallBack;
  }

  String giveClosestDeviceCallBAck(){
    return closestDeviceDetails;
  }

  Map<String, double> calculateAverageFromRssi(Map<String, List<int>> rssiValues) {
    return rssiValues.map((address, rssiList) {
      double average = rssiList.reduce((a, b) => a + b) / rssiList.length;
      return MapEntry(address, average);
    });
  }

  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort(
              (a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }

  Map<String, double> calculateAverage(){
    //HelperClass.showToast("Bin ${BIN} \n number $numberOfSample");
    Map<String, double> sumMap = {};
    // Iterate over each inner map and accumulate the values for each string key
    BIN.values.forEach((innerMap) {
      innerMap.forEach((key, value) {
        sumMap[key] = (sumMap[key] ?? 0.0) + value;
      });
    });
    // Divide the sum by the number of values for each string key
    sumMap.forEach((key, sum) {
      int count = numberOfSample[key]!;
      sumMap[key] = sum / count;
    });

    BIN = HashMap();
    numberOfSample.clear();
    startbin();

    return sumMap;
  }


  double calculateDistance(double rssi) {
    const int txPower = -64; // Adjust based on the reference RSSI at 1 meter
    const double environmentalFactor = 1; // Adjust based on your environment
    return pow(10, (txPower - rssi) / (10 * environmentalFactor))
        .toDouble(); // Cast to double
  }

  HashMap<int, HashMap<String, double>> BIN = HashMap();
  HashMap<String,int> numberOfSample = HashMap();
  HashMap<String,List<int>> rs = HashMap();
  HashMap<int, double> weight = HashMap();

  void addtoBin(String MacId, int rssi) {

    int binnumber = 0;
    int Rssi = rssi * -1;
    if(numberOfSample[MacId] == null){
      numberOfSample[MacId] = 0;
      rs[MacId] = [];
    }
    numberOfSample[MacId] = numberOfSample[MacId]! + 1;
    rs[MacId]!.add(rssi);



    //print("of beacon ${rs}");


    if (Rssi <= 65) {
      binnumber = 0;
    } else if (Rssi <= 70) {
      binnumber = 1;
    } else if (Rssi <= 75) {
      binnumber = 2;
    } else if (Rssi <= 80) {
      binnumber = 3;
    } else if (Rssi <= 85) {
      binnumber = 4;
    } else if (Rssi <= 90) {
      binnumber = 5;
    } else {
      binnumber = 6;
    }

    if(BIN[binnumber]==null){
      startbin();
    }

    if (BIN[binnumber]!.containsKey(MacId)) {
      BIN[binnumber]![MacId] = BIN[binnumber]![MacId]! + weight[binnumber]!;
    } else {
      BIN[binnumber]![MacId] = 1 * weight[binnumber]!;
    }
    //print("number of sample---${numberOfSample[MacId]}");
  }

  void startbin() {
    BIN[0] = HashMap<String, double>();
    BIN[1] = HashMap<String, double>();
    BIN[2] = HashMap<String, double>();
    BIN[3] = HashMap<String, double>();
    BIN[4] = HashMap<String, double>();
    BIN[5] = HashMap<String, double>();
    BIN[6] = HashMap<String, double>();

    weight[0] = 12.0;
    weight[1] = 6.0;
    weight[2] = 4.0;
    weight[3] = 0.5;
    weight[4] = 0.25;
    weight[5] = 0.15;
    weight[6] = 0.1;
  }

  void emptyBin() {
    for (int i = 0; i < BIN.length; i++) {
      BIN[i]!.clear();
    }
    numberOfSample.clear();
    rs.clear();
  }
}