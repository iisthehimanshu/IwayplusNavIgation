import 'dart:convert';
import 'GPSService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;

class Cell{
  int node;
  int x;
  int y;
  double lat;
  double lng;
  final Function(double angle, {int? currPointer,int? totalCells}) move;
  bool ttsEnabled;
  String? bid;
  int floor;
  int numCols;
  bool imaginedCell;
  int? imaginedIndex;
  Location? position;

  Cell(this.node, this.x, this.y, this.move, this.lat, this.lng,this.bid, this.floor, this.numCols, {this.ttsEnabled = true, this.imaginedCell = false, this.imaginedIndex, this.position});


  Map<String, dynamic> toJson() => {
    'node': node,
    'x': x,
    'y': y,
    'lat': lat,
    'lng': lng,
    'ttsEnabled': ttsEnabled,
    'bid': bid,
    'floor': floor,
    'numCols': numCols,
    'imaginedCell': imaginedCell,
    'imaginedIndex': imaginedIndex,
    'position': position != null ? {
      'latitude': position!.latitude,
      'longitude': position!.longitude,
      'accuracy': position!.accuracy,
      'timeStamp': position!.timeStamp.toIso8601String(),
    } : null,
  };

  factory Cell.fromJson(
      Map<String, dynamic> json,
      Function(double angle, {int? currPointer, int? totalCells}) move,
      ) {
    Location? position;
    if (json['position'] != null) {
      position = Location(
        latitude: json['position']['latitude'],
        longitude: json['position']['longitude'],
        accuracy: json['position']['accuracy'],
        timeStamp: DateTime.parse(json['position']['timeStamp']),
      );
    }

    return Cell(
      json['node'],
      json['x'],
      json['y'],
      move,
      json['lat'],
      json['lng'],
      json['bid'],
      json['floor'],
      json['numCols'],
      ttsEnabled: json['ttsEnabled'] ?? true,
      imaginedCell: json['imaginedCell'] ?? false,
      imaginedIndex: json['imaginedIndex'],
      position: position,
    );
  }

  @override
  String toString() => jsonEncode(toJson());




}

class ClosestPointResult {
  final geo.LatLng latLngPoint;
  final IntPoint intPoint;

  ClosestPointResult(this.latLngPoint, this.intPoint);
}
class IntPoint {
  int x;
  int y;

  IntPoint(this.x, this.y);

}