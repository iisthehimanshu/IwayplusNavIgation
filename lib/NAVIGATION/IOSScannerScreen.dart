import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/BluetoothScanIOSClass.dart';
import 'dart:async';  // Import for Timer


class IOSScannerScreen extends StatefulWidget {
  @override
  _IOSScannerScreenState createState() => _IOSScannerScreenState();
}

class _IOSScannerScreenState extends State<IOSScannerScreen> {
  List<String> devices = [];
  late Timer _timer;  // Declare the timer
  late Timer Device_timer;
  dynamic initialLocalization = "";

  String bestDevice = "No device found";


  @override
  void initState() {
    super.initState();
    startPeriodicCheck();
  }


  void startScan() async {
    // try {
    //   initialLocalization = await BluetoothScanIOSClass.initialLocalization();
    //   setState(() {
    //
    //   });
    // } catch (e) {
    //   print('Error during localization: $e');
    // }

    final scannedDevices = await BluetoothScanIOSClass.startScan();

    // getDevicesList();
    // setState(() {
    //   devices = scannedDevices;
    // });
  }

  void getDevicesList() {
    _timer = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      final scannedDevices = await BluetoothScanIOSClass.getDeviceList();
      print("FlutterNewLength ${scannedDevices}");
      setState(() {
        devices.addAll(scannedDevices);  // Update the device list
      });
    });
  }

  void stopScan() {
    BluetoothScanIOSClass.stopScan();
  }


  void startPeriodicCheck() {
    Device_timer = Timer.periodic(Duration(milliseconds: 2500), (timer) async {
      try {
        bestDevice = await BluetoothScanIOSClass.getBestDevice();
        setState(() {

        });
        print("scannedDevices ${bestDevice}");
      } catch (e) {
        print("Error getting best device: $e");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    Device_timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLE Scanner')),
      body: Column(
        children: [
          Text("${bestDevice}"),
          ElevatedButton(onPressed: (){
            startScan();

          }, child: Text('Start Scan')),
          ElevatedButton(onPressed: stopScan, child: Text('Stop Scan')),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) => ListTile(
                title: Text("${devices[index]}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}