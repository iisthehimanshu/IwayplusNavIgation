import 'APIMODELS/landmark.dart';

class direction{
  int node;
  String turnDirection;
  Landmarks? nearbyLandmark;
  double? distanceToPrevTurn;
  double? distanceToNextTurn;

  direction(this.node, this.turnDirection, this.nearbyLandmark, this.distanceToNextTurn, this.distanceToPrevTurn);
}