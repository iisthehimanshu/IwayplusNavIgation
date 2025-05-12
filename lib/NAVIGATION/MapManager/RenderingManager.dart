import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/NAVIGATION/DatabaseManager/SwitchDataBase.dart';
import 'package:iwaymaps/NAVIGATION/Repository/RepositoryManager.dart';

import '../APIMODELS/landmark.dart';
import '../APIMODELS/patchDataModel.dart';
import '../APIMODELS/polylinedata.dart' as polyline_model;
import '../VenueManager/VenueManager.dart';
import '../VersioInfo.dart';
import 'InteractionManager.dart';
import 'RenderingElement/Marker.dart';
import 'RenderingElement/Polygon.dart';

class RenderingManager {

  Map<String,Set<Marker>> _lowPriorityMarkers = {};
  Map<String,Set<Marker>> _midPriorityMarkers = {};
  Map<String,Set<Marker>> _highPriorityMarkers = {};
  Map<String,Set<Polygon>> _buildingSpecificPolygons = Map();
  Set<Polygon> _patch = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};


  Set<Polyline> get polylines => _polylines;
  Set<Circle> get circles => _circles;
  Set<Marker> get markers {
    if (_zoomLevel >= 20) {
      Set<Marker> lowMarker = _lowPriorityMarkers.values.expand((set) => set).toSet();
      Set<Marker> midMarker = _midPriorityMarkers.values.expand((set) => set).toSet();
      Set<Marker> highMarker = _highPriorityMarkers.values.expand((set) => set).toSet();
      return lowMarker.union(midMarker).union(highMarker);
    } else if (_zoomLevel >= 19) {
      Set<Marker> midMarker = _midPriorityMarkers.values.expand((set) => set).toSet();
      Set<Marker> highMarker = _highPriorityMarkers.values.expand((set) => set).toSet();
      return midMarker.union(highMarker);
    } else if (_zoomLevel >= 17) {
      Set<Marker> highMarker = _highPriorityMarkers.values.expand((set) => set).toSet();
      return highMarker;
    } else {
      return {};
    }
  }
  Set<Polygon> get polygons {
    return _buildingSpecificPolygons.values.expand((set) => set).toSet().union(_patch);
  }

  VenueManager venueManager = VenueManager();
  Interactionmanager interactionmanager = Interactionmanager();
  ElementPolygons polygonController = ElementPolygons();
  ElementMarker markerController = ElementMarker();

  RenderingManager(){
    polygonController.polygonTap = interactionmanager.polygonTap;
  }



  double _zoomLevel = 17.0;

  void updateZoomLevel(double newZoom) {
    if ((newZoom - _zoomLevel).abs() >= 0.5) {
      _zoomLevel = newZoom;
    }
  }

  void clearAll() {
    _lowPriorityMarkers.clear();
    _midPriorityMarkers.clear();
    _highPriorityMarkers.clear();
    _polylines.clear();
    _buildingSpecificPolygons.clear();
    _circles.clear();
  }


  Future<void> createMap() async {
    clearAll();
    List<polyline_model.polylinedata>? polylineData = await venueManager.getPolylinePolygonDataAllBuildings();
    List<patchDataModel>? patchData = await venueManager.getPatchDataAllBuildings();
    List<land>? landmarkData = await venueManager.getLandmarkDataAllBuildings();

    print("createBuildings data $polylineData");
    if(polylineData == null) return;
    if(patchData == null) return;
    if(landmarkData == null) return;

    for(var buildingPatches in patchData){
      Set<Polygon>? patchCreated = polygonController.createPatch(buildingPatches);
      if(patchCreated != null){
        _patch.addAll(patchCreated);
      }
    }

    for (var buildingData in polylineData) {
      Set<Polygon>? polygonsCreated = polygonController.createRooms(buildingData, 0);
      venueManager.switchFloor(0,buildingID: buildingData.polyline!.buildingID);
      if(polygonsCreated != null){
        _buildingSpecificPolygons[buildingData.polyline!.buildingID!] = polygonsCreated;
      }
    }

    for (var buildingData in landmarkData) {
      Map<String,Set<Marker>>? markerMap = await markerController.createMarkers(buildingData, 0);
      if (markerMap != null) {
        _lowPriorityMarkers[buildingData.landmarks!.first.buildingID!] = markerMap["low"] ?? {};
        _midPriorityMarkers[buildingData.landmarks!.first.buildingID!] = markerMap["mid"] ?? {};
        _highPriorityMarkers[buildingData.landmarks!.first.buildingID!] = markerMap["high"] ?? {};
      }
    }
    return;
  }

  Future<void> startDataFechFromServerCycle() async {
    await venueManager.runDataVersionCycle();
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

  Future<void> changeFloorOfBuilding(String buildingID, int floor) async {
    polyline_model.polylinedata? polylineData = await venueManager.getPolylinePolygonData(buildingID);
    land? landmarkData = await venueManager.getLandmarkData(buildingID);
    if(polylineData == null) return;
    if(landmarkData == null) return;

    Set<Polygon>? polygonsCreated = polygonController.createRooms(polylineData, floor);
    venueManager.switchFloor(floor,buildingID: buildingID);
    if(polygonsCreated != null){
      _buildingSpecificPolygons[buildingID] = polygonsCreated;
    }

    Map<String,Set<Marker>>? markerMap = await markerController.createMarkers(landmarkData, floor);
    if (markerMap != null) {
      _lowPriorityMarkers[buildingID] = markerMap["low"] ??{};
      _midPriorityMarkers[buildingID] = markerMap["mid"] ?? {};
      _highPriorityMarkers[buildingID] = markerMap["high"] ?? {};
    }
    venueManager.switchFloor(floor);
  }
  
}
