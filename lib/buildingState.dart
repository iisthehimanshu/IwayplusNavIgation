import 'dart:collection';

import 'APIMODELS/beaconData.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/polylinedata.dart';

class Building{
  int floor;
  int numberOfFloors;
  HashMap<int, List<int>> nonWalkable = HashMap();
  Map<int,List<int>> floorDimenssion = Map();
  polylinedata? polyLineData = null;
  Future<land>? landmarkdata = null;
  List<beacon>? beacondata = null;
  String? selectedLandmarkID = null;
  Building({required this.floor,required this.numberOfFloors});

}