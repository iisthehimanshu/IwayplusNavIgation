import 'dart:collection';

import 'APIMODELS/beaconData.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';

class Building{
  int floor;
  int numberOfFloors;
  Map<String,Map<int, List<int>>> nonWalkable = Map();

  Map<String,Map<int,List<int>>> floorDimenssion = Map();

  polylinedata? polyLineData = null;
  Map<String,polylinedata> polylinedatamap = Map();
  Future<land>? landmarkdata = null;
  List<beacon>? beacondata = null;
  String? selectedLandmarkID = null;
  Map<String,patchDataModel> patchData = Map();
  bool updateMarkers = true;
  List<String> ignoredMarker = [];
  static HashMap<String, beacon> apibeaconmap = HashMap();
  Building({required this.floor,required this.numberOfFloors});

}
