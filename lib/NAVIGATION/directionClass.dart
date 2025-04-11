import 'APIMODELS/landmark.dart';

class direction{
  int? node;
  String? turnDirection;
  Landmarks? nearbyLandmark;
  double? distanceToPrevTurn;
  double? distanceToNextTurnInFeet;
  int? x;
  int? y;
  int?floor;
  String? Bid;
  int? numCols;
  bool isDestination;
  int? liftDestinationFloor;

  direction(this.node, this.turnDirection, this.nearbyLandmark, this.distanceToNextTurnInFeet, this.distanceToPrevTurn,this.x,this.y,this.floor,this.Bid,{this.isDestination = false,this.numCols ,this.liftDestinationFloor});

  direction changeDirection(String direction){
    turnDirection = direction;
    return this;
  }
}