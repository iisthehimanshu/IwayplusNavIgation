import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'APIMODELS/Building.dart';
import 'ELEMENTS/BluetoothDevice.dart';

class BluetoothScanAndroid extends StatefulWidget {
  @override
  _BluetoothScanAndroidState createState() => _BluetoothScanAndroidState();
}

class _BluetoothScanAndroidState extends State<BluetoothScanAndroid> {

  static const methodChannel = MethodChannel('com.example.bluetooth/scan');
  static const eventChannel = EventChannel('com.example.bluetooth/scanUpdates');
  List<BluetoothDevice> devices = [];
  bool isScanning = false;


  Map<String, String> deviceNames = {};
  Map<String, List<int>> rssiValues = {};
  Map<String, double> distances = {};
  Map<String, List<double>> rssiWeight = {};
  Map<String, double> rssiAverage = {};
  Map<String, List<double>> newList = {};
  static StreamSubscription? _scanSubscription; // Variable to hold the subscription
  String closestRSSI = "";
  Map<String, double> sumMapCallBack = {};
  String closestDeviceDetails = "";




  @override
  void initState() {
    super.initState();
    print("BluetoothScanAndroidStateinitstate");
    _startScan();
    _listenToScanUpdates();
  }
  Future<void> _startScan() async {
    try{
      await methodChannel.invokeMethod('startScan');
      setState(() {
        isScanning = true;
      });
    } on PlatformException catch(e){
      print("Failed to start scan: ${e.message}");
    }
  }
  Future<void> _stopScan() async {
    setState(() {
      isScanning = false;
    });
    try {
      await methodChannel.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      print("Failed to stop scan: ${e.message}");
    }
  }


  BluetoothDevice parseDeviceDetails(String response) {
    final deviceRegex = RegExp(
      r'Device Name: (.+?)\n.*?Address: (.+?)\n.*?RSSI: (-?\d+).*?Raw Data: ([0-9A-Fa-f\-]+)',
      dotAll: true,
    );

    final match = deviceRegex.firstMatch(response);

    if (match != null) {
      final deviceName = match.group(1) ?? 'Unknown';
      final deviceAddress = match.group(2) ?? 'Unknown';
      final deviceRssi = match.group(3) ?? '0';
      final rawData = match.group(4) ?? '';

      return BluetoothDevice(
        DeviceName: deviceName,
        DeviceAddress: deviceAddress,
        DeviceRssi: deviceRssi,
        rawData: rawData,
      );
    } else {
      throw Exception('Invalid device details string');
    }
  }


  void _listenToScanUpdates() {
    isScanning = true;
    setState(() {

    });
    String deviceMacId = "";
    // Start listening to the stream continuously
    _scanSubscription = eventChannel.receiveBroadcastStream().listen((deviceDetail) {
      BluetoothDevice deviceDetails = parseDeviceDetails(deviceDetail);
      if(deviceDetails.DeviceName.contains("IW")) {
        deviceMacId = deviceDetails.DeviceAddress;
        print("iffffff");
        print(deviceDetails.DeviceName);
        deviceNames[deviceDetails.DeviceAddress] = deviceDetails.DeviceName;

        rssiValues.putIfAbsent(deviceDetails.DeviceAddress, () => []);
        rssiWeight.putIfAbsent(deviceDetails.DeviceAddress, () => []);

        rssiValues[deviceDetails.DeviceAddress]!.add(int.parse(deviceDetails.DeviceRssi));
        print("deviceDetails.DeviceRssi");
        print(deviceDetails.DeviceRssi);

        rssiWeight[deviceDetails.DeviceAddress]!.add(getWeight(int.parse(deviceDetails.DeviceRssi).abs()));

        if (rssiValues[deviceDetails.DeviceAddress]!.length > 7) {
          rssiValues[deviceDetails.DeviceAddress]!.removeAt(0);
        }

        if(rssiWeight[deviceDetails.DeviceAddress]!.length > 7){
          rssiWeight[deviceDetails.DeviceAddress]!.removeAt(0);
        }


        rssiAverage = calculateAverageFromRssi(rssiValues,deviceNames,rssiWeight);

        print("rssiAverage");
        print(rssiAverage);

        closestDeviceDetails = findLowestRssiDevice(rssiAverage);
        setState(() {

        });

      }else{

      }
    }, onError: (error) {
      print('Error receiving device updates: $error');
    });

    if(isScanning) {
      Timer.periodic(Duration(seconds: 2), (timer) {
        if (rssiValues.isNotEmpty) {
          rssiValues.forEach((key, value) {
            if (deviceMacId != key) {
              if(value.length>0)
              value.removeAt(0);
            }else{
              print("deviceMacId--");
            }
          });
        }

        if (rssiWeight.isNotEmpty) {
          rssiWeight.forEach((key, value) {
            if (deviceMacId != key) {
              if(value.length>0)
              value.removeAt(0);
            }
          });
        }
        setState(() {

        });
      });
    }else{
      print("ELsecase");
    }
  }

  String findLowestRssiDevice(Map<String, double> rssiAverage) {
    String? lowestKey;
    double? lowestValue;

    rssiAverage.forEach((key, value) {
      if (lowestValue == null || value > lowestValue!) {
        lowestValue = value;
        lowestKey = key;
      }
    });
    closestRSSI = lowestValue.toString();
    print("findLowestRssiDevice");
    print(lowestValue);

    return lowestKey ?? "No devices found";
  }


  double getWeight(int num){
    switch(num) {
      case <=65:
        return 12.0;
      case <=75:
        return 6.0;
      case <=80:
        return 4.0;
      case <=85:
        return 0.5;
      case <= 90:
        return 0.25;
      case <= 95:
        return 0.15;
      default:
        return 0.0;
    }
  }

  Map<String, double> calculateAverageFromRssi(
      Map<String, List<int>> rssiValues,
      Map<String, String> deviceList,
      Map<String, List<double>> rssiWeight) {
    Map<String, double> averagedRssiValues = {};

    rssiWeight.forEach((address, rssiList) {

      if (rssiList.isNotEmpty) {
        // Calculate average if the list is not empty
        double average = rssiList.reduce((a, b) => a + b) / rssiList.length;

        // Update the newList for debugging or other purposes
        newList[deviceList[address]!] = rssiList;

        print("deviceList[address]");
        print(average);
        print(newList);

        // Add the average to the map
        averagedRssiValues[deviceList[address]!] = double.parse(average.toStringAsFixed(3));;
      } else {
        print("Warning: RSSI list for $address is empty.");
      }
    });

    // Sort by the average RSSI values in descending order
    var sortedEntries = averagedRssiValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return the sorted map
    return Map.fromEntries(sortedEntries);
  }

  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort(
              (a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }

  HashMap<int, HashMap<String, double>> BIN = HashMap();
  HashMap<String,int> numberOfSample = HashMap();
  HashMap<String,List<int>> rs = HashMap();
  HashMap<int, double> weight = HashMap();

  @override
  void dispose() {
    _stopScan(); // Stop scanning when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(closestDeviceDetails, style: TextStyle(fontSize: 12)),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.stop : Icons.play_arrow),
            onPressed: isScanning ? _stopScan : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rssiValues.length,
              itemBuilder: (context, index) {
                String deviceName = rssiValues.keys.elementAt(index);
                String deviceShowName = deviceNames[rssiValues.keys.elementAt(index)]??"";
                List<double> weightReading = rssiWeight[deviceName]??[];
                List<int> readings = rssiValues[deviceName]??[];
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceShowName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Column(
                        children: readings.map((rssi) =>
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text('$rssi'),
                            )
                        ).toList(),
                      ),
                      Divider(),
                      Column(
                        children: weightReading.map((rssi) =>
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text('$rssi'),
                            )
                        ).toList(),
                      ),
                      Divider(height: 3,color: Colors.black,),
                    ],
                  ),
                );
              },
            ),
          ),
          Text(rssiAverage.toString()),
        ],
      )
    );
  }
}