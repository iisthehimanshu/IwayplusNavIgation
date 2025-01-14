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


  void startScan() async {
    final scannedDevices = await BluetoothScanIOSClass.startScan();

    //getDevicesList();
    setState(() {
      devices = scannedDevices;
    });
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





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLE Scanner')),
      body: Column(
        children: [
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