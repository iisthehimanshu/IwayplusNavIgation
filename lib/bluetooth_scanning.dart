import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';

import '../buildingState.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'APIMODELS/beaconData.dart';
import 'Elements/HelperClass.dart';
import 'package:iwaymaps/websocket/UserLog.dart';

class BLueToothClass {
  HashMap<int, HashMap<String, double>> BIN = HashMap();
  HashMap<String,int> numberOfSample = HashMap();
  HashMap<String,List<int>> rs = HashMap();
  HashMap<int, double> weight = HashMap();
  HashMap<String, int> beacondetail = HashMap();
  StreamController<HashMap<int, HashMap<String, double>>> _binController = StreamController.broadcast();
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;


  PriorityQueue<MapEntry<String, double>> priorityQueue = PriorityQueue((a, b) => a.value.compareTo(b.value));

  PriorityQueue<MapEntry<String, double>> returnPQ (){
    return priorityQueue;
  }


  BLueToothClass(){
    try {
      FlutterBluePlus.systemDevices;
    } catch (e) {

    }
    try {
      FlutterBluePlus.startScan();
    } catch (e) {

    }
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
    weight[5] = 0.0;
    weight[6] = 0.0;
  }

  Stream<HashMap<int, HashMap<String, double>>> get binStream =>
      _binController.stream;

  void startScanning(HashMap<String, beacon> apibeaconmap) {

   // print("himanshu 1");

    startbin();
   // print("himanshu 2");
    FlutterBluePlus.startScan();
  //  print("himanshu 3");
    FlutterBluePlus.scanResults.listen((results) async {
     // print("himanshu 4");
      for (ScanResult result in results) {
        if(result.device.platformName.length > 2){
          //print("himanshu 5 ${result}");
          String MacId = "${result.device.platformName}";
          int Rssi = result.rssi;
          //print("mac $MacId    rssi $Rssi");
          wsocket.message["AppInitialization"]["bleScanResults"][MacId]=Rssi;
          if (apibeaconmap.containsKey(MacId)) {
            //print(MacId);
            beacondetail[MacId] = Rssi * -1;
            addtoBin(MacId, Rssi);
            _binController.add(BIN); // Emitting event when BIN changes
          }
        }
      }
    });

    calculateAverage();
  }



  // void getDevicesList()async{
  //   try {
  //     _systemDevices = await FlutterBluePlus.systemDevices;
  //     //print("system devices $_systemDevices");
  //
  //
  //
  //   } catch (e) {
  //     print("System Devices Error: $e");
  //   }
  //   try {
  //     await FlutterBluePlus.startScan();
  //   } catch (e) {
  //     print("System Devices Error: $e");
  //   }
  //
  //
  //
  //
  //   // _connectionStateSubscription = widget.result.device.connectionState.listen((state) {
  //   //   _connectionState = state;
  //   //   if (mounted) {
  //   //     setState(() {});
  //   //   }
  //   // });
  // }



  // void strtScanningIos(HashMap<String, beacon> apibeaconmap){
  //   print("scanning for IOS called");
  //
  //  // print(apibeaconmap);
  //
  //   startbin();
  //   _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
  //
  //     _scanResults = results;
  //     for (ScanResult result in _scanResults) {
  //       String MacId = "${result.device.platformName}";
  //       int Rssi = result.rssi;
  //       // print(result);
  //       print("mac $MacId   rssi $Rssi");
  //
  //       if (apibeaconmap.containsKey(MacId)) {
  //         beacondetail[MacId] = Rssi * -1;
  //
  //         addtoBin(MacId, Rssi);
  //         _binController.add(BIN); // Emitting event when BIN changes
  //       }
  //     }
  //    // print("scanneed results $_scanResults");
  //    // getDevicesList(_scanResults,apibeaconmap);
  //    // Future.delayed(Duration(seconds: 3));
  //
  //  //   getDevicesList();
  //
  //
  //   }, onError: (e) {
  //     print("Scan Error:, $e");
  //   });
  // }

  int c = 0;

  Future<void> startScanningIOS(HashMap<String, beacon> apibeaconmap) async {
    startbin();

    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {

    }
    try {
      await FlutterBluePlus.startScan();
    } catch (e) {

    }

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      print("mac $results");
      for (ScanResult result in _scanResults) {
        String MacId = "${result.device.platformName}";
        int Rssi = result.rssi;
        // print(result);
        print("mac $MacId   rssi $Rssi");

        if (apibeaconmap.containsKey(MacId)) {
          beacondetail[MacId] = Rssi * -1;

          addtoBin(MacId, Rssi);
          _binController.add(BIN); // Emitting event when BIN changes
        }
      }
    }, onError: (e) {

    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
    });




  }






  void stopScanning() async{
    await FlutterBluePlus.stopScan();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
    _systemDevices.clear();
    emptyBin();
    priorityQueue.clear();
  }

  void emptyBin() {
    for (int i = 0; i < BIN.length; i++) {
      BIN[i]!.clear();
    }
    //HelperClass.showToast(BIN.toString());
    numberOfSample.clear();
    rs.clear();
  }

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

    if (BIN[binnumber]!.containsKey(MacId)) {
      // print(BIN[binnumber]![MacId]! + weight[binnumber]!);
      BIN[binnumber]![MacId] = BIN[binnumber]![MacId]! + weight[binnumber]!;
    } else {
      BIN[binnumber]![MacId] = 1 * weight[binnumber]!;
    }


    //print("number of sample---${numberOfSample[MacId]}");

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



  void printbin() {
    print("BIN");
    print(BIN);
  }

  void dispose() {
    _binController.close();
  }
}
