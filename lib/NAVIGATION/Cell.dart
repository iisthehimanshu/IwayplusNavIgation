import 'GPSService.dart';

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

}