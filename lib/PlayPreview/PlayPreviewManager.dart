import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'dart:ui' as ui;

import '../NAVIGATION/APIMODELS/polylinedata.dart';
import '../NAVIGATION/Cell.dart';
import '../NAVIGATION/UserState.dart';
import '../NAVIGATION/cutommarker.dart';
import '../NAVIGATION/navigationTools.dart';
import '../NAVIGATION/singletonClass.dart';
// assuming your utils are here

class PlayPreviewManager {
  PlayPreviewManager._internal();
  static final PlayPreviewManager _instance = PlayPreviewManager._internal();
  factory PlayPreviewManager() => _instance;

  Map<String, Map<int, Set<gmap.Polyline>>> _pathCovered = {};
  Map<String, Map<int, Set<gmap.Marker>>> _previewMarker = {};
  bool _isPlaying = false;
  bool _isCancelled = false;
  bool _stopAnimation = false;
  static Function alignMapToPath = (List<double> A, List<double> B,{bool isTurn=false}) {};
  static Function findLift = (String floor, List<Floors> floorData) {};
  static Function findCommonLift = (List<PolyArray> list1, List<PolyArray> list2) {};
  static Function createRooms=(polylinedata value, int floor){};
  Map<String, Map<int, Set<gmap.Polyline>>> get pathCovered => _pathCovered;
  Map<String, Map<int, Set<gmap.Marker>>> get previewMarker => _previewMarker;

  void clearPreview() {
    _pathCovered.clear();
    _previewMarker.clear();
  }

  void cancel() {
    _isCancelled = true;
  }

  void stop() {
    _stopAnimation = true;
  }

  Future<void> playPreviewAnimation({required List<Cell> pathList}) async {
    if (_isPlaying || pathList.isEmpty) return;
    Uint8List iconMarker = await getImagesFromMarker('assets/previewarrow.png', 80);
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

      gmap.Marker marker = gmap.Marker(
        markerId: gmap.MarkerId("preview_marker"),
        position: gmap.LatLng(pathList.first.lat, pathList.first.lng),
        icon: gmap.BitmapDescriptor.fromBytes(iconMarker),
        anchor: Offset(0.5, 0.5),
      );

      for (int i = 0; i < pathList.length; i++) {
        if (_isCancelled || _stopAnimation) {
          print("🔴 Animation stopped manually.");
          return;
        }

        Cell current = pathList[i];
        Cell next = pathList[i];
        if(i<pathList.length-1){
          next = pathList[i+1];
        }
        int row = current.node % current.numCols;
        int col = current.node ~/ current.numCols;

        int row1 = next.node % next.numCols;
        int col1 = next.node ~/ next.numCols;

        final buildingId = current.bid!;
        final nextBuildingId = next.bid!;
        final floorId = current.floor;
        final nextFloorId = next.floor;

        if((floorId != lastFloorItterated || buildingId != lastBidIterated) || (floorId != nextFloorId || buildingId != nextBuildingId)){

          await alignFloor(floorId, buildingId);
          lastFloorItterated = floorId;
          lastBidIterated = buildingId;
          createRooms(SingletonFunctionController.building.polylinedatamap[lastBidIterated],lastFloorItterated);
          currentCoordinates.clear();
          continue;
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

        final gStart = gmap.LatLng(value[0], value[1]);
        final gEnd = gmap.LatLng(value1[0], value1[1]);

        if(tools.calculateAerialDist(gStart.latitude, gStart.longitude, gEnd.latitude, gEnd.longitude)<0.5){
          await iterateFurther(gStart, buildingId, floorId, marker, value1, currentCoordinates);
        }else{
          final interpolatedPoints = interpolatePoints(gStart, gEnd, 0.6); // 2 feet = 0.6 m

          for(int j = 0; j<interpolatedPoints.length; j++){
            await iterateFurther(interpolatedPoints[j], buildingId, floorId, marker, value1, currentCoordinates);
          }
        }
      }

      print("✅ Animation complete for ${pathList.first.bid} | Floor ${pathList.first.floor}");
      // _pathCovered.clear();
    } catch (e) {
      print("❌ Error in preview animation: $e");
    } finally {
      _previewMarker.clear();
      _isPlaying = false;
    }
  }

  Future<void> iterateFurther(gmap.LatLng point, String buildingId, int floorId, gmap.Marker marker, List<double> value1, List<gmap.LatLng> currentCoordinates) async {
    currentCoordinates.add(point);

    final polyline = gmap.Polyline(
      polylineId: gmap.PolylineId("preview_${floorId}_${DateTime.now().microsecondsSinceEpoch}"),
      points: List.from(currentCoordinates),
      color: Colors.green,
      width: 8,
    );
    marker = customMarker.move(point, marker);
    if(point.latitude != value1[0] && point.longitude != value1[1]){
      double angle = tools.calculateBearing([point.latitude, point.longitude], [value1[0], value1[1]]);
      marker = customMarker.rotate(angle, marker);
    }



    // if (turnPoints.contains(current.node)) {
    //   await alignMapToPath([value[0], value[1]], [value1[0], value1[1]], isTurn: true);
    // } else {
    //   if(interpolatedPoints[j].latitude != value1[0] && interpolatedPoints[j].longitude != value1[1]){
    //     await alignMapToPath([interpolatedPoints[j].latitude, interpolatedPoints[j].longitude], [value1[0], value1[1]]);
    //   }
    // }

    // ✅ Accumulate instead of overwrite
    _pathCovered.putIfAbsent(buildingId, () => {});
    _pathCovered[buildingId]!.putIfAbsent(floorId, () => <gmap.Polyline>{});
    _pathCovered[buildingId]![floorId]!.add(polyline);

    _previewMarker.putIfAbsent(buildingId, () => {});
    _previewMarker[buildingId]!.putIfAbsent(floorId, () => <gmap.Marker>{});
    _previewMarker[buildingId]![floorId]?.clear();
    _previewMarker[buildingId]![floorId]!.add(marker);

    await Future.delayed(const Duration(milliseconds: 50));
  }


  List<gmap.LatLng> interpolatePoints(
      gmap.LatLng start, gmap.LatLng end, double intervalMeters) {
    const earthRadius = 6371000.0; // in meters
    final lat1 = start.latitude * pi / 180;
    final lng1 = start.longitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final lng2 = end.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLng = lng2 - lng1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final totalDistance = earthRadius * c;

    final steps = (totalDistance / intervalMeters).floor();

    List<gmap.LatLng> points = [];

    for (int i = 1; i <= steps; i++) {
      final fraction = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final lng = start.longitude + (end.longitude - start.longitude) * fraction;
      points.add(gmap.LatLng(lat, lng));
    }

    return points;
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

  Future<Uint8List> getImagesFromMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

}