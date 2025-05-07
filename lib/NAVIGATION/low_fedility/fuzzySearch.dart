import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:iwaymaps/NAVIGATION/low_fedility/searchResult.dart';

import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../API/ladmarkApi.dart';
import '../APIMODELS/landmark.dart';
import '../navigationTools.dart';
import '../singletonClass.dart';
import 'homepage.dart';

Future<List<Widget>> fuzzySearch(String query) async {
  if(landmarkList.isEmpty){
    print("fetching");
    await fetchlist();
  }
  print("landmarkList $landmarkList");
  List<Widget> searchResults = [];
  List<Landmarks> Ammenities = [];
  List<Landmarks> Facilities = [];
  final fuse = Fuzzy(
    landmarkList,
    options: FuzzyOptions(
      findAllMatches: true,
      threshold: 0.3, // Lower values = stricter matches
    ),
  );

  final result = fuse.search(query);

  result.sort((a, b) => b.score.compareTo(a.score));
  for (var fuseResult in result) {
    if(searchResults.length > 15){
      print("returning");
      return searchResults;
    }
    if(fuseResult.score <=0.5){
      List<Landmarks>? resultantLandmarks = landmarkData.landmarks?.where((landmark)=>normalizeText(landmark.name??"")==fuseResult.item).toList();
      print("result ${fuseResult.item}");
      if(resultantLandmarks != null && resultantLandmarks.isNotEmpty){
        for (var landmark in resultantLandmarks) {
          if(isFacility(landmark)){
            Facilities.add(landmark);
          }else if(isAmmenity(landmark)){
            Ammenities.add(landmark);
          }else{
            searchResults.add(SearchresultWithAddress(null, Location: landmark));
          }
        }
      }
    }
  }
  searchResults.insertAll(0, handleAmenities(Ammenities));
  searchResults.insertAll(0, handleFacility(Facilities));
  return searchResults;
}

List<Widget> handleAmenities(List<Landmarks> Ammenities) {
  Map<String, List<Landmarks>> amenity = {};
  List<Widget> AmenityWidgets = [];

  for (var landmark in Ammenities) {
    amenity.putIfAbsent(landmark.element!.subType!, () => []);
    amenity[landmark.element!.subType!]!.add(landmark);
  }

  amenity.forEach((key,value){
    AmenityWidgets.add(AmmenityResult(null, Location: value));
  });

  return AmenityWidgets;
}

List<Widget> handleFacility(List<Landmarks> Facilities) {
  Facilities.removeWhere((landmark)=>(landmark.buildingID!=Homepage.detectedLocation!.buildingID || landmark.floor != Homepage.detectedLocation!.floor));
  double d = double.infinity;
  Map<String, List<Landmarks>> facilityMap = {};
  List<Widget> FacilityWidgets = [];

  if (Homepage.detectedLocation == null) {
    for (var facility in Facilities) {
      FacilityWidgets.add(SearchresultWithAddress(null, Location: facility));
    }
    return FacilityWidgets;
  } else {
    for (var landmark in Facilities) {
      facilityMap.putIfAbsent(landmark.element!.subType!, () => []);
      facilityMap[landmark.element!.subType!]!.add(landmark);
    }

    facilityMap.forEach((key, value) {
      if (value.isNotEmpty) {
        Landmarks select = value.first;
        for (var facility in value) {
          double distance = tools.calculateDistance(
            [facility.coordinateX!, facility.coordinateY!],
            [Homepage.detectedLocation!.coordinateX!, Homepage.detectedLocation!.coordinateY!],
          );
          if (distance < d) {
            select = facility;
            d = distance;
          }
        }
        FacilityWidgets.add(SearchresultWithAddress(null, Location: select));
      }
    });
  }

  return FacilityWidgets; // Ensure a return statement at the end
}


String normalizeText(String text) {
  return text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
}


land landmarkData = land();
List<String> landmarkList = [];
Future<void> fetchlist() async {
  land? singletonData = await SingletonFunctionController.building.landmarkdata;

  if (singletonData != null) {
    landmarkData = singletonData;
    landmarkList = landmarkData.landmarksMap!.values
        .where(
            (value) => value.name != null && value.element!.subType != "beacon")
        .map((value) => normalizeText(value.name!))
        .toList();
    return;
  }

  buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
    await landmarkApi().fetchLandmarkData(id: key).then((value) {
      landmarkData.mergeLandmarks(value.landmarks);
    });
  });

  landmarkList = landmarkData.landmarksMap!.values
      .where(
          (value) => value.name != null && value.element!.subType != "beacon")
      .map((value) => normalizeText(value.name!))
      .toList();
}

bool isAmmenity(Landmarks landmark){
  String? value = landmark.element!.subType;
  if(value == null || landmark.properties!.polyId == null){
    return false;
  }
  if(value == "restRoom" ||
      value == "Cafeteria" ||
      value == "main entry" ||
      value == "Help Desk | Reception" ||
      value == "ATM"
      ){
    print('got amenity');
    return true;
  }
  return false;
}
bool isFacility(Landmarks landmark){
  String? value = landmark.element!.subType;
  if(value == null || landmark.properties!.polyId == null){
    return false;
  }
  if(value == "restRodom" ||
      value == "lift" ||
      value == "Drinking Water"){
    return true;
  }
  return false;
}

