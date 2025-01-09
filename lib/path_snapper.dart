import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;
import 'GPS.dart';
import 'NAVIGATION/Cell.dart';
import 'NAVIGATION/navigationTools.dart';

class KalmanFilter {
  double? latitudeEstimate;
  double? longitudeEstimate;
  double variance;
  final double processNoise;
  final double measurementNoise;

  KalmanFilter({this.variance = 1, this.processNoise = 0.05, this.measurementNoise = 0.5});

  void applyFilter(double lat, double lng) {
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
  late final List<Cell> path;
  final KalmanFilter _kalmanFilter = KalmanFilter();
  double? accuracy;

  void setPath(List<Cell> singleCellListPath) {
    path = singleCellListPath;
  }

  final _snappedCellController = StreamController<Cell>();
  GPS gps = GPS();

  PathSnapper();

  // Stream of snapped cells
  Stream<Cell> get snappedCellStream => _snappedCellController.stream;

  // Start listening to GPS updates
  Future<void> startGpsUpdates() async {

    await gps.startGpsUpdates();
    gps.positionStream.listen((position) {
      processGpsData(position);
      accuracy = position.accuracy;
    });
  }

  // Stop listening to GPS updates
  void stopGpsUpdates() {
    gps.stopGpsUpdates();
    gps.dispose();
  }

  // Process GPS data
  void processGpsData(Position position) {
    //_kalmanFilter.applyFilter(lat, lng);
    // var snapped = _snapToPath(
    //     _kalmanFilter.latitudeEstimate ?? lat,
    //     _kalmanFilter.longitudeEstimate ?? lng);
    var snapped = _snapToPath(position);
    if (snapped != null) {
      _snappedCellController.add(snapped);
    }
  }

  // Close the stream controller
  void dispose() {
    _snappedCellController.close();
    stopGpsUpdates();
  }

  // Snap to the nearest point on the path
  Cell? _snapToPath(Position position) {
    double minDistance = double.infinity;
    Cell? nearestCell;

    for (int i = 0; i < path.length - 1; i++) {
      var start = path[i];
      var end = path[i + 1];
      if(start.x == end.x && start.y == end.y){
        continue;
      }
      // Find the projection on the segment
      var projection = _projectPointOnSegment(position.latitude, position.longitude, start, end);
      if (projection != null) {
        double projectionLat = projection.latitude ?? 0.0;
        double projectionLng = projection.longitude ?? 0.0;

        double distance = _haversineDistance(position.latitude, position.longitude, projectionLat, projectionLng);

        if (distance < minDistance) {
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
    if(nearestCell != null){
      // path.insert(nearestCell.imaginedIndex!, nearestCell);
    }
    return nearestCell;
  }

  // Project point onto a segment
  navPoints? _projectPointOnSegment(double px, double py, Cell a, Cell b) {

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