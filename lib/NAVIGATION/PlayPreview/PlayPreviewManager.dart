import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

import '../Cell.dart';
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

  Future<void> playPreviewAnimation({
    required List<Cell> pathList,
  }) async {
    if (_isPlaying || pathList.isEmpty) return;
    _isPlaying = true;
    _isCancelled = false;
    _stopAnimation = false;

    try {
      List<gmap.LatLng> currentCoordinates = [];
      List<int> turnPoints = tools.getTurnpoints(pathList.map((e) => e.node).toList(), pathList.first.numCols);

      for (int i = 0; i < pathList.length - 2; i++) {
        if (_isCancelled || _stopAnimation) {
          print("🔴 Animation stopped manually.");
          return;
        }

        final current = pathList[i];
        final next = pathList[i + 2];

        final latLng = gmap.LatLng(current.lat, current.lng);
        currentCoordinates.add(latLng);

        final buildingId = current.bid!;
        final floorId = current.floor;

        final polyline = gmap.Polyline(
          polylineId: gmap.PolylineId("preview_${floorId}_$i"),
          points: List.from(currentCoordinates),
          color: Colors.green,
          width: 8,
        );

        // Populate the pathCovered structure
        _pathCovered.putIfAbsent(buildingId, () => {});
        _pathCovered[buildingId]!.putIfAbsent(floorId, () => {});

          _pathCovered[buildingId]![floorId]={polyline};
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print("✅ Animation complete for ${pathList.first.bid} | Floor ${pathList.first.floor}");
    } catch (e) {
      print("❌ Error in preview animation: $e");
    } finally {
      _isPlaying = false;
    }
  }

}
