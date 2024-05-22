import 'APIMODELS/landmark.dart';

class direction{
  int? node;
  String? turnDirection;
  Landmarks? nearbyLandmark;
  double? distanceToPrevTurn;
  double? distanceToNextTurn;
  int? x;
  int? y;
  int?floor;
  String? Bid;
  int? numCols;

  direction(this.node, this.turnDirection, this.nearbyLandmark, this.distanceToNextTurn, this.distanceToPrevTurn,this.x,this.y,this.floor,this.Bid,{this.numCols});
}