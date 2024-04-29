import 'dart:async';
import 'dart:collection';
import '../buildingState.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'APIMODELS/beaconData.dart';

class BT {
  HashMap<int, HashMap<String, double>> BIN = HashMap();
  HashMap<String,int> numberOfSample = HashMap();
  HashMap<String,List<int>> rs = HashMap();
  HashMap<int, double> weight = HashMap();
  HashMap<String, int> beacondetail = HashMap();
  StreamController<HashMap<int, HashMap<String, double>>> _binController = StreamController.broadcast();
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;


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
    weight[6] = 0.075;
  }

  Stream<HashMap<int, HashMap<String, double>>> get binStream =>
      _binController.stream;

  void startScanning(HashMap<String, beacon> apibeaconmap) {

    startbin();
    FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        String MacId = "${result.device.platformName}";
        int Rssi = result.rssi;
        // print("mac $result    rssi $Rssi");
        if (apibeaconmap.containsKey(MacId)) {
          beacondetail[MacId] = Rssi * -1;

          addtoBin(MacId, Rssi);
          _binController.add(BIN); // Emitting event when BIN changes
        }
      }
    });
  }


  void getDevicesList()async{
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
      //print("system devices $_systemDevices");



    } catch (e) {
      print("System Devices Error: $e");
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print("System Devices Error: $e");
    }




    // _connectionStateSubscription = widget.result.device.connectionState.listen((state) {
    //   _connectionState = state;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }


  void strtScanningIos(HashMap<String, beacon> apibeaconmap){

   // print(apibeaconmap);

    startbin();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
    //  print("scanneed results $_scanResults");



      getDevicesList();




      for (ScanResult result in _scanResults) {
        String MacId = "${result.device.platformName}";
        int Rssi = result.rssi;
        // print(result);
        // print("mac $MacId   rssi $Rssi");

        if (apibeaconmap.containsKey(MacId)) {
          beacondetail[MacId] = Rssi * -1;

          addtoBin(MacId, Rssi);
          _binController.add(BIN); // Emitting event when BIN changes
        }
      }




     // Future.delayed(Duration(seconds: 3));

   //   getDevicesList();


    }, onError: (e) {
      print("Scan Error:, $e");
    });
  }




  void stopScanning() async{
    await FlutterBluePlus.stopScan();
    //_scanResultsSubscription.cancel();
    _scanResults.clear();
    _systemDevices.clear();
    emptyBin();

  }

  void emptyBin() {
    for (int i = 0; i < BIN.length; i++) {
      BIN[i]!.clear();
    }
    numberOfSample.clear();
    rs.clear();
  }

  void addtoBin(String MacId, int rssi) {

    int binnumber = 0;
    int Rssi = rssi * -1;
    if(numberOfSample[MacId] == null){
      numberOfSample[MacId] = 1;
      rs[MacId] = [];
    }
    numberOfSample[MacId] = numberOfSample[MacId]! + 1;
    rs[MacId]!.add(rssi);


    //print("of beacon ${rs}");

    if (Rssi <= 60) {
      binnumber = 0;
    } else if (Rssi <= 65) {
      binnumber = 1;
    } else if (Rssi <= 70) {
      binnumber = 2;
    } else if (Rssi <= 75) {
      binnumber = 3;
    } else if (Rssi <= 80) {
      binnumber = 4;
    } else if (Rssi <= 85) {
      binnumber = 5;
    } else {
      binnumber = 6;
    }

    if (BIN[binnumber]!.containsKey(MacId)) {
      BIN[binnumber]![MacId] = BIN[binnumber]![MacId]! + weight[binnumber]!;
    } else {
      BIN[binnumber]![MacId] = 1 * weight[binnumber]!;
    }

    //print("number of sample---${numberOfSample[MacId]}");

  }
  Map<String, double> calculateAverage(){
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
class BT2 {
  HashMap<int, HashMap<String, double>> BIN = HashMap();
  HashMap<String,int> numberOfSample = HashMap();
  HashMap<String,List<int>> rs = HashMap();
  HashMap<int, double> weight = HashMap();
  HashMap<String, int> beacondetail = HashMap();
  StreamController<HashMap<int, HashMap<String, double>>> _binController = StreamController.broadcast();
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;


  void startbin() {
    BIN[0] = HashMap<String, double>();
    BIN[1] = HashMap<String, double>();
    BIN[2] = HashMap<String, double>();
    BIN[3] = HashMap<String, double>();
    BIN[4] = HashMap<String, double>();
    BIN[5] = HashMap<String, double>();
    BIN[6] = HashMap<String, double>();

    weight[0] = 12.0;
    weight[1] = 5.0;
    weight[2] = 4.0;
    weight[3] = 0.5;
    weight[4] = 0.25;
    weight[5] = 0.15;
    weight[6] = 0.075;

  }

  Stream<HashMap<int, HashMap<String, double>>> get binStream =>
      _binController.stream;

  void startScanning(HashMap<String, beacon> apibeaconmap) {
    startbin();
    FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        String MacId = "${result.device.platformName}";
        int Rssi = result.rssi;
        print("${result.device.remoteId}     $Rssi");
        if (apibeaconmap.containsKey(MacId)) {
          beacondetail[MacId] = Rssi * -1;

          addtoBin(MacId, Rssi);
          _binController.add(BIN); // Emitting event when BIN changes
        }
      }
    });
  }

  Map<String, double> calculateAverage(){
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

    return sumMap;
  }


  // void stopScanning() {
  //   _scanResultsSubscription.cancel();
  //   _scanResults.clear();
  //   _systemDevices.clear();
  //   FlutterBluePlus.stopScan();
  //   emptyBin();
  // }

  void emptyBin() {
    for (int i = 0; i < BIN.length; i++) {
      BIN[i]!.clear();
    }
    numberOfSample.clear();
    rs.clear();
    Building.thresh = "";
  }

  void getDevicesList()async{
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
      //print("system devices $_systemDevices");



    } catch (e) {
      print("System Devices Error: $e");
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print("System Devices Error: $e");
    }




    // _connectionStateSubscription = widget.result.device.connectionState.listen((state) {
    //   _connectionState = state;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  void addtoBin(String MacId, int rssi) {

    int binnumber = 0;
    int Rssi = rssi * -1;


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
      BIN[binnumber]![MacId] = BIN[binnumber]![MacId]! + weight[binnumber]!;
    } else {
      BIN[binnumber]![MacId] = 1 * weight[binnumber]!;
    }

    if(numberOfSample[MacId] == null){
      numberOfSample[MacId] = 1;
    }else{
      numberOfSample[MacId] = numberOfSample[MacId]! + 1;
    }


    if(binnumber == 0 || binnumber == 1 || binnumber == 3){
      Building.thresh = Building.thresh + "\n" + "$binnumber ------- $MacId, ${BIN[binnumber]![MacId]}";
      //print("$binnumber ------- $MacId, ${BIN[binnumber]![MacId]}");
    }
  }

  void printbin() {
    print(BIN);
  }

  void strtScanningIos(HashMap<String, beacon> apibeaconmap){

    print(apibeaconmap);

    startbin();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      //  print("scanneed results $_scanResults");



      getDevicesList();




      for (ScanResult result in _scanResults) {
        String MacId = "${result.device.platformName}";
        int Rssi = result.rssi;
        if (apibeaconmap.containsKey(MacId)) {
          //  print("mac $MacId   rssi $Rssi");
          beacondetail[MacId] = Rssi * -1;

          addtoBin(MacId, Rssi);
          _binController.add(BIN); // Emitting event when BIN changes
        }
      }




      // Future.delayed(Duration(seconds: 3));

      //   getDevicesList();


    }, onError: (e) {
      print("Scan Error:, $e");
    });
  }

  void dispose() {
    _binController.close();
  }
}
