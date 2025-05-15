import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/NAVIGATION/VenueManager/BuildingStore.dart';
import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/landmark.dart';
import '../APIMODELS/patchDataModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../DatabaseManager/SwitchDataBase.dart';
import '../Repository/RepositoryManager.dart';
import '../navigationTools.dart';

class VenueManager extends BuildingStore{

  VenueManager._internal();

  // Single instance - lazily initialized
  static final VenueManager _instance = VenueManager._internal();

  // Factory constructor returns the same instance
  factory VenueManager() {
    return _instance;
  }

  String _venueName = "IIT Delhi";
  List<Buildingbyvenue> _buildings = [];

  String get venueName => _venueName;

  set venueName(String value) {
    _venueName = value;
  }

  List<Buildingbyvenue> get buildings => _buildings;

  set buildings(List<Buildingbyvenue> value) {
    _buildings = value;
  }

  void changeFocusedBuilding(CameraPosition position){
    String? bid;
    double minimumDistance = double.infinity;
    for (var building in _buildings) {
      double distance = tools.calculateAerialDist(position.target.latitude, position.target.longitude, building.coordinates![0], building.coordinates![1]);
      if(distance < minimumDistance){
        minimumDistance = distance;
        bid = building.sId;
      }
    }
    if(focusedBuilding != bid){
      focusedBuilding = bid;
      notifyListeners();
    }
  }

  Future<polylinedata?> getPolylinePolygonData(String buildingID) async {
      polylinedata? buildingData = await RepositoryManager().getPolylineDataNew(buildingID);
      return buildingData;
  }

  Future<List<polylinedata>?> getPolylinePolygonDataAllBuildings() async {
    print("polylinedata buildings $buildings");
    if(buildings.isEmpty) return null;
    List<polylinedata> data = [];
    for (var building in buildings) {
      polylinedata? buildingData = await getPolylinePolygonData(building.sId!);
      if(buildingData != null) {
        data.add(buildingData);
      }
    }
    processAvailableFloors(data);
    return data;
  }

  Future<patchDataModel?> getPatchData(String buildingID) async {
      patchDataModel? buildingData = await RepositoryManager().getPatchDataNew(buildingID);
      return buildingData;
  }

  Future<List<patchDataModel>?> getPatchDataAllBuildings() async {
    print("patchDataModel buildings $buildings");
    if(buildings.isEmpty) return null;
    List<patchDataModel> data = [];
    for (var building in buildings) {
      patchDataModel? buildingData = await getPatchData(building.sId!);
      if(buildingData != null){
        data.add(buildingData);
      }
    }
    return data;
  }

  Future<land?> getLandmarkData(String buildingID) async {
      land? buildingData = await RepositoryManager().getLandmarkDataNew(buildingID);
      return buildingData;
  }

  Future<List<land>?> getLandmarkDataAllBuildings() async {
    print("land buildings $buildings");
    if(buildings.isEmpty) return null;
    List<land> data = [];
    for (var building in buildings) {
      land? buildingData = await getLandmarkData(building.sId!);
      if(buildingData != null){
        data.add(buildingData);
      }
    }
    return data;
  }

  Future<void> startDataFechFromServerCycle() async {
    await runDataVersionCycle();
    if(SwitchDataBase().newDataFromServerDBShouldBeCreated){
      await updateNewDB().then((_){
        var switchBox = Hive.box('SwitchingDatabaseInfo');
        SwitchDataBase().switchGreenDataBase(!switchBox.get('greenDataBase'));
        SwitchDataBase().newDataFromServerDBShouldBeCreated = false;
      });
    }else{
      print("SwitchDataBase().newDataFromServerDBShouldBeCreated ${SwitchDataBase().newDataFromServerDBShouldBeCreated} NO CREATION OF DB2");
    }
  }

  Future<void> runDataVersionCycle() async {
    for (var building in buildings) {
      await RepositoryManager().runAPICallDataVersion(building.sId!);
    }
  }

  Future<void> updateNewDB() async {
    for (var building in VenueManager().buildings) {
      await RepositoryManager().runAPICallPatchData(building.sId!);
      await RepositoryManager().runAPICallPolylineData(building.sId!);
      await RepositoryManager().runAPICallLandmarkData(building.sId!);
      await RepositoryManager().runAPICallBeaconData(building.sId!);
      // Space optimization CODE for FUTURE
      // if(VersionInfo.buildingPatchDataVersionUpdate.containsKey(building.sId) && VersionInfo.buildingPatchDataVersionUpdate[building.sId]==true){
      //   RepositoryManager().savePatchDataForDB2(building.sId!);
      // }
      // if(VersionInfo.buildingPolylineDataVersionUpdate.containsKey(building.sId) && VersionInfo.buildingPolylineDataVersionUpdate[building.sId]==true){
      //   RepositoryManager().savePolylineDataForDB2(building.sId!);
      // }
      // if(VersionInfo.buildingLandmarkDataVersionUpdate.containsKey(building.sId) && VersionInfo.buildingLandmarkDataVersionUpdate[building.sId]==true){
      //   RepositoryManager().saveLandmarkDataForDB2(building.sId!);
      // }
    }
  }



}