import 'dart:collection';

import 'APIMODELS/landmark.dart';
import 'APIMODELS/polylinedata.dart';

class Building{
  int floor;
  int numberOfFloors;
  HashMap<int, List<int>> nonWalkable = HashMap();
  polylinedata? polyLineData = null;
  land? landmarkdata = null;
  Building({required this.floor,required this.numberOfFloors});

}