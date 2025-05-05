import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../IWAYPLUS/API/buildingAllApi.dart';
import 'BluetoothScanAndroidClass.dart';
import 'BluetoothScanIOSClass.dart';
import 'buildingState.dart';

import 'API/beaconapi.dart';

import 'APIMODELS/beaconData.dart';
import 'VersioInfo.dart';
import 'bluetooth_scanning.dart';

class SingletonFunctionController {
  bool _isRunning = false;
  Completer<void>? _completer;
  static BLueToothClass btadapter = new BLueToothClass();
  static HashMap<String, beacon> apibeaconmap = HashMap();
  static Building building = Building(floor: Map(), numberOfFloors: Map());
  static Future<void>? timer;
  static String currentBeacon = "";
  static String SC_LOCALIZED_BEACON = "";
  BluetoothScanAndroidClass bluetoothScanAndroidClass = BluetoothScanAndroidClass();
  static Map<String, double> SC_IL_RSSI_AVERAGE = {};
  BluetoothScanIOSClass bluetoothScanIOSClass = BluetoothScanIOSClass();
  bool isBinEmpty() {
    for (int i = 0; i < SingletonFunctionController.btadapter.BIN.length; i++) {
      if (SingletonFunctionController.btadapter.BIN[i] != null &&
          SingletonFunctionController.btadapter.BIN[i]!.isNotEmpty) {
        // If any bin is not empty, return false
        return false;
      }
    }
    // If all bins are empty, return true
    return true;
  }
  Future<void> executeFunction(Map<String,LatLng> allBuildingID) async {
    if (_isRunning) {
      // Wait for the currently running instance to finish
      return _completer?.future;
    }

    // Mark the function as running and create a new Completer
    _isRunning = true;
    _completer = Completer<void>();


    print("building.beacondata.length");
    try {
      // Perform your task here
      print("Function is running...");
      building.qrOpened=false;
      building.destinationQr=false;
      await Future.wait(allBuildingID.entries.map((entry) async {
        print("entry$entry");
        var key = entry.key;
        var beaconData = await beaconapi().fetchBeaconData(key);
        print("keydata${beaconData.length}");
        if (building.beacondata == null) {
          print("entryprintifstate${key}");
          building.beacondata = beaconData;
          print("entryprintifstate${building.beacondata!.length}");
        } else {
          print("entryprint${building.beacondata!.length}");
          building.beacondata = List.from(building.beacondata!)..addAll(beaconData);
          print("entryprint${building.beacondata!.length}");
        }
        for (var beacon in beaconData) {
          if (beacon.name != null) {
            apibeaconmap[beacon.name!] = beacon;
          }
        }
        Building.apibeaconmap = apibeaconmap;
        print(buildingAllApi.allBuildingID);
        print(apibeaconmap);
      })).then((value) async {
        //-------------
        // print("blue statusssss");
        // print(await FlutterBluePlus.isOn);
        // if(Platform.isAndroid){
        //   // print("apibeaconmap");
        //   // print(apibeaconmap);
        //   // blueToothAndroid.listenToScanUpdates(apibeaconmap);
        //
        //   await bluetoothScanAndroidClass.listenToScanInitialLocalization(Building.apibeaconmap).then((value) {
        //     SC_LOCALIZED_BEACON = value;
        //     if(kDebugMode){
        //       showToast("SC_LOCALIZED_BEACON:${value}");
        //     }
        //     print("SC_LOCALIZED_BEACON $SC_LOCALIZED_BEACON");
        //   });
        //
        //   // bluetoothScanAndroidClass.stopScan();
        //   // btadapter.startScanning(apibeaconmap);
        //
        // }else if(Platform.isIOS){
        //   print("isIOS");
        //   String resp = await BluetoothScanIOSClass.getInitialLocalizedDevice();
        //
        //   //await btadapter.startScanningIOS(apibeaconmap);
        // }
        //-------------
        if(!kIsWeb){
          if(Platform.isAndroid){
            btadapter.startScanning(apibeaconmap);
          }else{
            btadapter.startScanning(apibeaconmap);
          }
        }
        timer= Future.delayed((await FlutterBluePlus.isOn==true)?Duration(seconds:9):Duration(seconds:0));
        //timer= Future.delayed((await FlutterBluePlus.isOn==true)?Duration(seconds:9):Duration(seconds:0));
      });

      // Simulate a long-running task
      print("Function completed.");
    } finally {
      // Mark the function as complete
      _isRunning = false;
      _completer?.complete();

    }
  }

  beacon? getlocalizedBeacon(){
    double highestweight = 0;
    String nearestBeacon = "";
    // if(isBinEmpty() == false){
    // }

    return (SingletonFunctionController.currentBeacon!="")?Building.apibeaconmap[SingletonFunctionController.currentBeacon]:null;
  }
}

void showToast(String mssg) {
  Fluttertoast.showToast(
    msg: mssg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}