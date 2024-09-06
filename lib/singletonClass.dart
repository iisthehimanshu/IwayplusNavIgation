import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/buildingState.dart';

import 'API/beaconapi.dart';
import 'API/buildingAllApi.dart';

import 'APIMODELS/beaconData.dart';
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

    try {
      // Perform your task here
      print("Function is running...");
      print(buildingAllApi.allBuildingID);
      await Future.wait(allBuildingID.entries.map((entry) async {
        var key = entry.key;

        var beaconData = await beaconapi().fetchBeaconData(key);
        if (building.beacondata == null) {
          building.beacondata = List.from(beaconData);
        } else {
          building.beacondata = List.from(building.beacondata!)..addAll(beaconData);
        }

        for (var beacon in beaconData) {
          if (beacon.name != null) {
            apibeaconmap[beacon.name!] = beacon;
          }
        }
        Building.apibeaconmap = apibeaconmap;

      })).then((value){
        if(Platform.isAndroid){
          btadapter.startScanning(apibeaconmap);
        }else{
          btadapter.startScanningIOS(apibeaconmap);
        }
        timer= Future.delayed(Duration(seconds:9));
      });

      // Simulate a long-running task
      print("Function completed.");
    } finally {
      // Mark the function as complete
      _isRunning = false;
      _completer?.complete();
      building.qrOpened=false;
      building.destinationQr=false;
    }
  }
}