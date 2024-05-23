import 'dart:collection';

import 'APIMODELS/beaconData.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';

class Building{
  Map<String,int> floor;
  Map<String,int> numberOfFloors;
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
  static String thresh = "";
  Building({required this.floor,required this.numberOfFloors});

}
