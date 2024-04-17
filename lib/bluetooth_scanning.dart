import 'dart:async';
import 'dart:collection';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'APIMODELS/beaconData.dart';

class BT {
  HashMap<int, HashMap<String, double>> BIN = HashMap();
  HashMap<int, double> weight = HashMap();
  HashMap<String, int> beacondetail = HashMap();
  StreamController<HashMap<int, HashMap<String, double>>> _binController = StreamController.broadcast();

  void startbin() {
    BIN[0] = HashMap<String, double>();
    BIN[1] = HashMap<String, double>();
    BIN[2] = HashMap<String, double>();
    BIN[3] = HashMap<String, double>();
    BIN[4] = HashMap<String, double>();
    BIN[5] = HashMap<String, double>();
    BIN[6] = HashMap<String, double>();

    weight[0] = 8.0;
    weight[1] = 4.0;
    weight[2] = 2.0;
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
        String MacId = "${result.device.remoteId}";
        int Rssi = result.rssi;
        if (apibeaconmap.containsKey(MacId)) {
          beacondetail[MacId] = Rssi * -1;
          addtoBin(MacId, Rssi);
          _binController.add(BIN); // Emitting event when BIN changes
        }
      }
    });
  }

  void stopScanning() {
    FlutterBluePlus.stopScan();
    emptyBin();
  }

  void emptyBin() {
    for (int i = 0; i < BIN.length; i++) {
      BIN[i]!.clear();
    }
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
  }

  void printbin() {
    print(BIN);
  }

  void dispose() {
    _binController.close();
  }
}
