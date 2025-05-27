import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;
import 'package:iwaymaps/NAVIGATION/buildingState.dart';
import 'package:iwaymaps/NAVIGATION/singletonClass.dart';

import '../IWAYPLUS/API/buildingAllApi.dart';
import '../IWAYPLUS/API/slackApi.dart';
import 'API/ladmarkApi.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'Repository/RepositoryManager.dart';
import 'UserState.dart';
import 'navigationTools.dart';

class NavigationAPIController {
  Function createPatch = (patchDataModel value) {};
  Function createotherPatch = (String key, patchDataModel value) {};
  Function findCentroid = (List<Coordinates> vertices, String bid) {};
  Function createRooms = (polylinedata value, int floor){};
  Function createARPatch = (Map<int, geo.LatLng> coordinates){};
  Function createotherARPatch = (Map<int, geo.LatLng> coordinates, String bid){};
  Function createMarkers = (land landData, int floor, {String? bid}){};

  NavigationAPIController(
      {required this.createPatch,
      required this.createotherPatch,
      required this.findCentroid,
      required this.createRooms,
      required this.createARPatch,
      required this.createotherARPatch,
        required this.createMarkers
      });

  Future<void> patchAPIController(String id, bool selected) async {
    print("patch for $id");
    var patchData = await RepositoryManager().getPatchData(id) as patchDataModel;
    print("patchData print ${patchData.toJson()}");
    Building.buildingData ??= Map();
    Building.buildingData![patchData.patchData!.buildingID!] = patchData.patchData!.buildingName;
    SingletonFunctionController
        .building.patchData[patchData.patchData!.buildingID!] = patchData;
    if (selected) {
      createPatch(patchData);
    } else {
      createotherPatch(id, patchData);
    }
    findCentroid(patchData.patchData!.coordinates!, id);

    if (selected) {
      tools.globalData = patchData;
      tools.setBuildingAngle(patchData.patchData!.buildingAngle!);

      for (var i = 0; i < 4; i++) {
        tools.corners.add(math.Point(
            double.parse(patchData.patchData!.coordinates![i].globalRef!.lat!),
            double.parse(
                patchData.patchData!.coordinates![i].globalRef!.lng!)));
      }
    }

    var currentFloorDimensions = SingletonFunctionController
        .building.floorDimenssion[id] ??
        {};

    currentFloorDimensions[0] = [
      int.parse(patchData.patchData!.length!),
      int.parse(patchData.patchData!.breadth!)
    ];

    SingletonFunctionController.building.floorDimenssion[id] =
        currentFloorDimensions;

  }

  Future<void> landmarkAPIController(String id, bool selected) async {
    var landmarkData = await landmarkApi().fetchLandmarkData(id: id,outdoor: id==buildingAllApi.outdoorID);
    if(selected){
      SingletonFunctionController.building.landmarkdata = Future.value(landmarkData);
    }else{
      var otherLandmarkdata = await SingletonFunctionController.building.landmarkdata;
      otherLandmarkdata?.mergeLandmarks(landmarkData.landmarks);
    }

    var coordinates = <int, geo.LatLng>{};

    for (var landmark in landmarkData.landmarks!) {
      if (landmark.element!.subType == "AR"&&
          landmark.properties!.arName ==
              "P${int.parse(landmark.properties!.arValue!)}") {
        coordinates[int.parse(landmark.properties!.arValue!)] = geo.LatLng(
            double.parse(landmark.properties!.latitude!),
            double.parse(landmark.properties!.longitude!));
      }

      if (landmark.element!.type == "Floor") {
        var nonWalkableGrids = landmark.properties!.nonWalkableGrids!.join(',');
        var regExp = RegExp(r'\d+');
        var matches = regExp.allMatches(nonWalkableGrids);
        var allIntegers =
        matches.map((match) => int.parse(match.group(0)!)).toList();

        var currentNonWalkable = SingletonFunctionController
            .building.nonWalkable[landmark.buildingID!] ??
            {};
        currentNonWalkable[landmark.floor!] = allIntegers;

        SingletonFunctionController.building.nonWalkable[landmark.buildingID!] =
            currentNonWalkable;

        if(selected){
          UserState.nonWalkable = SingletonFunctionController.building.nonWalkable;
        }


        var currentFloorDimensions = SingletonFunctionController
            .building.floorDimenssion[id] ??
            {};
        currentFloorDimensions[landmark.floor!] = [
          landmark.properties!.floorLength!,
          landmark.properties!.floorBreadth!
        ];

        SingletonFunctionController
            .building.floorDimenssion[id] =
            currentFloorDimensions;
      }
    }
    if (SingletonFunctionController
        .building.floorDimenssion[id] ==
        null) {
      sendErrorToSlack(
          "Floor data is null for ${id}", null);
    }
    if(SingletonFunctionController.building.nonWalkable[landmarkData.landmarks!.first.buildingID!] == null){
      Map<int, List<int>> imaginedNonWalkable = {0:[]};
      SingletonFunctionController.building.nonWalkable[landmarkData.landmarks!.first.buildingID!] = imaginedNonWalkable;
    }
    createMarkers(landmarkData, 0, bid: id);
    ARPatch(id, selected, coordinates: coordinates);
  }

  Future<void> ARPatch(String id, bool selected, {Map<int, geo.LatLng>? coordinates}) async {
    if(coordinates == null){
      var landmarkData = await RepositoryManager().getLandmarkData(id) as land;
      coordinates = <int, geo.LatLng>{};
      for (var landmark in landmarkData.landmarks!) {
        if (landmark.element!.subType == "AR" &&
            landmark.properties!.arName ==
                "P${int.parse(landmark.properties!.arValue!)}") {
          coordinates[int.parse(landmark.properties!.arValue!)] = geo.LatLng(
              double.parse(landmark.properties!.latitude!),
              double.parse(landmark.properties!.longitude!));
        }
      }
    }

    if(selected){
      createARPatch(coordinates);
      if (SingletonFunctionController.building.ARCoordinates.containsKey(id) && coordinates.isNotEmpty) {
        SingletonFunctionController.building.ARCoordinates[id] = coordinates;
      }
    }else{
      createotherARPatch(coordinates, id);
    }
  }
  Future<polylinedata> polylineAPIController(String id, bool selected) async {
    var polylineData = await RepositoryManager().getPolylineData(id) as polylinedata;
    SingletonFunctionController.building
        .polylinedatamap[id] = polylineData;
    SingletonFunctionController
        .building.numberOfFloors[id] =
        polylineData.polyline!.floors!.length;
    Building.numberOfFloorsDelhi[id] =
        polylineData.polyline!.floors!.map((element) {
          return tools.alphabeticalToNumerical(element.floor!);
        }).toList();
    if(selected){
      SingletonFunctionController.building.polyLineData = polylineData;
    }
    print("createroomscalledfor${id} ${polylineData.polylineExist}");
    createRooms(polylineData, 0);
    SingletonFunctionController.building.floor[id] = 0;
    return polylineData;
  }
}
