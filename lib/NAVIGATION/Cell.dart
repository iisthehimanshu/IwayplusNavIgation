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
  Position? position;

  Cell(this.node, this.x, this.y, this.move, this.lat, this.lng,this.bid, this.floor, this.numCols, {this.ttsEnabled = true, this.imaginedCell = false, this.imaginedIndex, this.position});

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