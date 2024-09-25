import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/buildingState.dart';

import 'API/beaconapi.dart';
import 'API/buildingAllApi.dart';

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
  Future<void> executeFunction(Map<String,LatLng> allBuildingID) async {
    if (_isRunning) {
      // Wait for the currently running instance to finish
      return _completer?.future;
    }

    // Mark the function as running and create a new Completer
    _isRunning = true;
    _completer = Completer<void>();
    

    var beaconData = await beaconapi().fetchBeaconData("65d9cacfdb333f8945861f0f");
    building.beacondata = beaconData;
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
        print("blue statusssss");
        print(await FlutterBluePlus.isOn);
        if(Platform.isAndroid){

          btadapter.startScanning(apibeaconmap);
        }else{
          btadapter.startScanningIOS(apibeaconmap);
        }
        timer= Future.delayed((await FlutterBluePlus.isOn==true)?Duration(seconds:9):Duration(seconds:0));
      });

      // Simulate a long-running task
      print("Function completed.");
    } finally {
      // Mark the function as complete
      _isRunning = false;
      _completer?.complete();

    }
  }
}