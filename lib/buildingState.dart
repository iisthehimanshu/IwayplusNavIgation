import 'dart:collection';

import 'package:geodesy/geodesy.dart';
import 'package:iwaymaps/waypoint.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/buildingAll.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'APIMODELS/polylinedata.dart' as poly;

class Building{
  bool qrOpened = false;
  bool destinationQr=false;
  Map<String,int> floor;
  Map<String,int> numberOfFloors;
  static Map<String,List<int>> numberOfFloorsDelhi = Map();
  Map<String,Map<int, List<int>>> nonWalkable = Map();
  Map<String,Map<int,List<int>>> floorDimenssion = Map();
  //Map<int,List<poly.Nodes>> wayPoints = {};
  polylinedata? polyLineData = null;
  Map<String,polylinedata> polylinedatamap = Map();
  Future<land>? landmarkdata = null;
  List<beacon>? beacondata = null;
  String? selectedLandmarkID = null;
  Map<String,patchDataModel> patchData = Map();
  bool updateMarkers = true;
  List<String> ignoredMarker = [];
  static Map<String,String?>? buildingData ;
  static HashMap<String, beacon> apibeaconmap = HashMap();
  static String thresh = "";
  static Map<String,List<PathModel>> waypoint = {};
  static Map<String,g.LatLng> allBuildingID = {
  };
  Map<String,Map<int, g.LatLng>> ARCoordinates = {};
  Building({required this.floor,required this.numberOfFloors});

}
