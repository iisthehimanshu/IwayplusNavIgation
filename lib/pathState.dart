import 'package:iwayplusnav/Cell.dart';

import 'APIMODELS/landmark.dart';

class pathState {
  String sourcePolyID = "";
  String destinationPolyID = "";
  String sourceName = "";
  String destinationName = "";
  int sourceX = 0;
  int sourceY = 0;
  int destinationX = 0;
  int destinationY = 0;
  int sourceFloor = 0;
  int destinationFloor = 0;
  Map<int, List<int>> path = {};
  Map<int, List<Cell>> Cellpath = {};
  List<int> singleListPath = [];
  List<Cell> singleCellListPath = [];
  List<Cell> CellTurnPoints = [];
  List<Map<String, int>> directions = [];
  Map<String,Map<int,int>>? numCols = Map();
  int index = 0;
  String sourceBid = "";
  String destinationBid = "";
  Map<String,Map<int,int>> connections = {};
  List<int> beaconCords = [];
  List<Landmarks> turnLandmarks = [];
  Map<int,Landmarks> associateTurnWithLandmark = Map();

  // Default constructor without arguments
  pathState();

  // Additional constructor with named parameters for creating instances with specific values
  pathState.withValues(
      this.sourceX, this.sourceY, this.sourceFloor, this.destinationX, this.destinationY, this.destinationFloor, this.numCols, this.index);


  void clear(){
    path.clear();
    Cellpath.clear();
    singleListPath.clear();
    CellTurnPoints.clear();
    directions.clear();
    connections.clear();
    turnLandmarks.clear();
    associateTurnWithLandmark.clear();
    index = 0;
    beaconCords.clear();
  }

  void swap() {
    // Swap source and destination information
    String tempPolyID = sourcePolyID;
    sourcePolyID = destinationPolyID;
    destinationPolyID = tempPolyID;

    String tempsourceBid = sourceBid;
    sourceBid = destinationBid;
    destinationBid = tempsourceBid;

    String tempName = sourceName;
    sourceName = destinationName;
    destinationName = tempName;

    int tempX = sourceX;
    sourceX = destinationX;
    destinationX = tempX;

    int tempY = sourceY;
    sourceY = destinationY;
    destinationY = tempY;

    int tempFloor = sourceFloor;
    sourceFloor = destinationFloor;
    destinationFloor = tempFloor;

    path.forEach((key, value) {
      path[key] = value.reversed.toList();
    });
  }
}