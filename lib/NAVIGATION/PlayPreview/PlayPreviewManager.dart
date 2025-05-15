import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

import '../APIMODELS/polylinedata.dart';
import '../Cell.dart';
import '../UserState.dart';
import '../navigationTools.dart';
import '../singletonClass.dart';
// assuming your utils are here

class PlayPreviewManager {
  PlayPreviewManager._internal();
  static final PlayPreviewManager _instance = PlayPreviewManager._internal();
  factory PlayPreviewManager() => _instance;

  Map<String, Map<int, Set<gmap.Polyline>>> _pathCovered = {};
  bool _isPlaying = false;
  bool _isCancelled = false;
  bool _stopAnimation = false;
  static Function alignMapToPath = (List<double> A, List<double> B,{bool isTurn=false}) {};
  static Function findLift = (String floor, List<Floors> floorData) {};
  static Function findCommonLift = (List<PolyArray> list1, List<PolyArray> list2) {};
  Map<String, Map<int, Set<gmap.Polyline>>> get pathCovered => _pathCovered;

  void clearPreview() {
    _pathCovered.clear();
  }

  void cancel() {
    _isCancelled = true;
  }

  void stop() {
    _stopAnimation = true;
  }

  Future<void> playPreviewAnimation({required List<Cell> pathList}) async {
    if (_isPlaying || pathList.isEmpty) return;
    _isPlaying = true;
    _isCancelled = false;
    _stopAnimation = false;

    try {
      List<gmap.LatLng> currentCoordinates = [];
      List<int> turnPoints = tools.getTurnpoints(
        pathList.map((e) => e.node).toList(),
        pathList.first.numCols,
      );
      int lastFloorItterated = pathList.first.floor;
      String lastBidIterated = pathList.first.bid!;
      await alignFloor(pathList.first.floor, pathList.first.bid!);
      for (int i = 0; i < pathList.length - 2; i++) {
        if (_isCancelled || _stopAnimation) {
          print("🔴 Animation stopped manually.");
          return;
        }

        final current = pathList[i];
        final next = pathList[i + 2];

        int row = current.node % current.numCols;
        int col = current.node ~/ current.numCols;

        int row1 = next.node % next.numCols;
        int col1 = next.node ~/ next.numCols;

        final buildingId = current.bid!;
        final floorId = current.floor;

        if(floorId != lastFloorItterated || buildingId != lastBidIterated){
          await alignFloor(floorId, buildingId);
          lastFloorItterated = floorId;
          lastBidIterated = buildingId;
          currentCoordinates.clear();
        }

        List<double> value = tools.localtoglobal(
          row,
          col,
          SingletonFunctionController.building.patchData[current.bid],
        );

        List<double> value1 = tools.localtoglobal(
          row1,
          col1,
          SingletonFunctionController.building.patchData[current.bid],
        );

        final latLng = gmap.LatLng(value[0], value[1]);
        currentCoordinates.add(latLng);

        final polyline = gmap.Polyline(
          polylineId: gmap.PolylineId("preview_${floorId}_$i"),
          points: List.from(currentCoordinates),
          color: Colors.green,
          width: 8,
        );
        if (turnPoints.contains(current.node)) {
          await alignMapToPath([value[0], value[1]], [value1[0], value1[1]], isTurn: true);
        } else {
          await alignMapToPath([value[0], value[1]], [value1[0], value1[1]]);
        }

        // ✅ Accumulate instead of overwrite
        _pathCovered.putIfAbsent(buildingId, () => {});
        _pathCovered[buildingId]!.putIfAbsent(floorId, () => <gmap.Polyline>{});
        print("adding for floor $floorId");
        _pathCovered[buildingId]![floorId]!.add(polyline);

        await Future.delayed(const Duration(milliseconds: 50));
      }

      print("✅ Animation complete for ${pathList.first.bid} | Floor ${pathList.first.floor}");
      // _pathCovered.clear();
    } catch (e) {
      print("❌ Error in preview animation: $e");
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> alignFloor(int floor, String bid)async{
    if (floor != 0) {
      List<PolyArray> prevFloorLifts = findLift(
          tools.numericalToAlphabetical(0),
          SingletonFunctionController
              .building.polylinedatamap[bid]!.polyline!.floors!);
      List<PolyArray> currFloorLifts = findLift(
          tools.numericalToAlphabetical(floor),
          SingletonFunctionController
              .building.polylinedatamap[bid]!.polyline!.floors!);
      List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
      UserState.xdiff = dvalue[0];
      UserState.ydiff = dvalue[1];
    } else {
      UserState.xdiff = 0;
      UserState.ydiff = 0;
    }
    return;
  }


}
