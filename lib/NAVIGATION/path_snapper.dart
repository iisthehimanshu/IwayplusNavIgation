import 'dart:async';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;

import 'Cell.dart';
import 'GPS.dart';
import 'GPSService.dart';
import 'navigationTools.dart';

class KalmanFilter {
  double? latitudeEstimate;
  double? longitudeEstimate;
  double variance;
  final double processNoise;
  final double measurementNoise;

  KalmanFilter({this.variance = 1, this.processNoise = 0.05, this.measurementNoise = 0.5});

  void applyFilter(double lat, double lng){
    print("got latlng $lat,$lng");
    if (latitudeEstimate == null || longitudeEstimate == null) {
      latitudeEstimate = lat;
      longitudeEstimate = lng;
      return;
    }

    double kalmanGain = variance / (variance + measurementNoise);
    latitudeEstimate = latitudeEstimate! + kalmanGain * (lat - latitudeEstimate!);
    variance = (1 - kalmanGain) * variance + processNoise;

    kalmanGain = variance / (variance + measurementNoise);
    longitudeEstimate = longitudeEstimate! + kalmanGain * (lng - longitudeEstimate!);
    variance = (1 - kalmanGain) * variance + processNoise;
    double d = tools.calculateAerialDist(lat, lng, latitudeEstimate!, longitudeEstimate!);
    print("made latlng $latitudeEstimate,$longitudeEstimate with distance $d");
  }
}

class PathSnapper {
  late List<Cell> path;
  final KalmanFilter _kalmanFilter = KalmanFilter();

  void setPath(List<Cell> singleCellListPath) {
    path = singleCellListPath;
  }

  final _snappedCellController = StreamController<Map<String,dynamic>>();
  // GPS gps = GPS();

  PathSnapper();

  // Stream of snapped cells
  Stream<Map<String,dynamic>> get snappedCellStream => _snappedCellController.stream;

  // Start listening to GPS updates
  Future<void> startGpsUpdates() async {

    await GPSService.checkLocationPermissions();
    GPSService.locationStream.listen((location) {
      print("path_snapper recieved gps location");
      processGpsData(location);
    }, onError: (error) {
      print("Error receiving GPS data: $error");
    });

    // await gps.startGpsUpdates();
    // gps.positionStream.listen((position) {
    //   print("got gps position");
    //   processGpsData(position);
    // });
  }

  // Stop listening to GPS updates
  void stopGpsUpdates() {
    // gps.stopGpsUpdates();
    // gps.dispose();
  }

  // Process GPS data
  void processGpsData(Location position) {
    //_kalmanFilter.applyFilter(lat, lng);
    // var snapped = _snapToPath(
    //     _kalmanFilter.latitudeEstimate ?? lat,
    //     _kalmanFilter.longitudeEstimate ?? lng);
    var snapped = _snapToPath(position);
      print("_snapToPath distance second $snapped");
      _snappedCellController.add(snapped);

  }

  // Close the stream controller
  void dispose() {
    _snappedCellController.close();
    stopGpsUpdates();
  }

  // Snap to the nearest point on the path
  Map<String,dynamic> _snapToPath(Location position) {
    print("_snapToPath");
    double minDistance = double.infinity;
    Cell? nearestCell;

    for (int i = 0; i < path.length - 1; i++) {
      var start = path[i];
      var end = path[i + 1];
      if(start.x == end.x && start.y == end.y){
        continue;
      }
      // Find the projection on the segment
      var projection = projectPointOnSegment(position.latitude, position.longitude, start, end);
      if (projection != null) {
        double projectionLat = projection.latitude ?? 0.0;
        double projectionLng = projection.longitude ?? 0.0;

        double distance = _haversineDistance(position.latitude, position.longitude, projectionLat, projectionLng);


        if (distance < minDistance) {
          print("_snapToPath with distance $distance");
          minDistance = distance;
          nearestCell = Cell(
              (projection.y * start.numCols) + projection.x,
              projection.x,
              projection.y,
              start.move,
              projectionLat,
              projectionLng,
              start.bid,
              start.floor,
              start.numCols,
              imaginedIndex: path.indexOf(start) + 1,
              imaginedCell: true,
              position: position
          );
        }
      }
    }
    return {"cell":nearestCell,
    "position": position};
  }

  Cell? snapToPathKalman(Location position,double latitude, double longitude, int index, List<Cell> path) {
    print("snapToPathKalman ${position.latitude},${position.longitude}");
    double minDistance = double.infinity;
    Cell? nearestCell;

    List<Cell>? points = tools.findSegmentContainingPoint(path, index);
    if(points == null){
      return null;
    }
    int d1 = tools.calculateAerialDist(path[index].lat, path[index].lng, points[0].lat, points[0].lng).ceil();
    int d2 = tools.calculateAerialDist(path[index].lat, path[index].lng, points[1].lat, points[1].lng).ceil();
    print("d1 is $d1 and d2 is $d2");
    if(d1<3 || d2<3){
      return null;
    }
    Cell start = points[0];
    Cell end = points[1];

    // Find the projection on the segment
    var projection = projectPointOnSegment(latitude, longitude, start, end);
    if (projection != null) {
      double projectionLat = projection.latitude ?? 0.0;
      double projectionLng = projection.longitude ?? 0.0;

      double distance = _haversineDistance(latitude, longitude, projectionLat, projectionLng);

      if (distance < minDistance) {
        minDistance = distance;
        nearestCell = convertToCell(projection, start, position);
      }
    }
    if(nearestCell != null){
      // path.insert(nearestCell.imaginedIndex!, nearestCell);
    }else{
      // HelperClass.showToast("old gps position identified");
      return null;
    }
    return nearestCell;
  }

  Cell convertToCell(navPoints projection, Cell start, Location? position){
    return Cell(
        (projection.y * start.numCols) + projection.x,
        projection.x,
        projection.y,
        start.move,
        projection.latitude,
        projection.longitude,
        start.bid,
        start.floor,
        start.numCols,
        imaginedIndex: path.indexOf(start),
        imaginedCell: true,
        position: position
    ) ;
  }

  // Project point onto a segment
  navPoints? projectPointOnSegment(double px, double py, Cell a, Cell b) {

    geo.LatLng? projectLatLngIfWithinSegment(geo.LatLng user, geo.LatLng start, geo.LatLng end) {
      double ax = user.latitude - start.latitude;
      double ay = user.longitude - start.longitude;
      double bx = end.latitude - start.latitude;
      double by = end.longitude - start.longitude;

      double t = (ax * bx + ay * by) / (bx * bx + by * by);

      // Check if the projection lies within the segment
      if (t < 0 || t > 1) {
        return null; // Outside the segment
      }
      if((start.latitude + t * bx).isNaN || (start.longitude + t * by).isNaN){
        return null;
      }
      return geo.LatLng(start.latitude + t * bx, start.longitude + t * by);
    }

    geo.LatLng? projectedLatLng = projectLatLngIfWithinSegment(
        geo.LatLng(px, py), geo.LatLng(a.lat, a.lng), geo.LatLng(b.lat, b.lng));
    navPoints? closestIntPoint;

    if (projectedLatLng != null) {
      double projectedX = projectedLatLng.latitude;
      double projectedY = projectedLatLng.longitude;
      navPoints X = navPoints(a.lat, a.lng, a.x, a.y);
      navPoints Y = navPoints(b.lat, b.lng, b.x, b.y);
      navPoints Z = navPoints(projectedX, projectedY, 0, 0);
      print(X.toString());
      print(Y.toString());
      print(Z.toString());
      closestIntPoint = tools.findCartesianCoordinates(X, Y, Z);

    }
    return closestIntPoint;
  }

  // Haversine formula to calculate distance between two lat/lng points
  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371000; // Earth's radius in meters
    double dLat = _degToRad(lat2 - lat1);
    double dLng = _degToRad(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * pi / 180;
}