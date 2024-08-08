import 'dart:collection';

class VersionInfo{

  static HashMap<String,bool> buildingPolylineDataVersionUpdate = HashMap();
  static HashMap<String,bool> buildingBuildingDataVersionUpdate = HashMap();
  static HashMap<String,bool> buildingPatchDataVersionUpdate = HashMap();
  static HashMap<String,bool> buildingLandmarkDataVersionUpdate = HashMap();

  static int polylineDataVersion=0;
  static int buildingDataVersion=0;
  static int patchDataVersion=0;
  static int landmarksDataVersion=0;
  static bool polylineDataVersionUpdate =false;
  static bool buildingDataVersionUpdate =false;
  static bool patchDataVersionUpdate =false;
  static bool landmarksDataVersionUpdate =false;

}
