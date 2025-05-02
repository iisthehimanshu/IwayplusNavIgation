import 'package:flutter/cupertino.dart';
import 'package:iwaymaps/NAVIGATION/navigationTools.dart';
import '../APIMODELS/polylinedata.dart';

class BuildingStore extends ChangeNotifier {
  final Map<String, List<int>> availableFloorsInAllBuildings = {};
  String? focusedBuilding;
  Map<String, int> currentFloorOfBuilding = {};

  List<int> get focusedBuildingFloors {
    return availableFloorsInAllBuildings[focusedBuilding]??[];
  }

  int get focusedBuildingCurrentFloor {
    return currentFloorOfBuilding[focusedBuilding]??0;
  }

  void switchFloor(int floor, {String? buildingID}){
    if(buildingID == null && focusedBuilding == null){
      return;
    }
    currentFloorOfBuilding[buildingID??focusedBuilding!] = floor;
    notifyListeners();
  }

  void processAvailableFloors(List<polylinedata> buildings) {
    for (final building in buildings) {
      final polyline = building.polyline;
      final buildingID = polyline?.buildingID;
      final floors = polyline?.floors;

      if (buildingID == null || floors == null) continue;

      availableFloorsInAllBuildings[buildingID] = [];

      final floorNumbers = floors
          .where((floor) => floor.floor != null)
          .map((floor) => tools.alphabeticalToNumerical(floor.floor!))
          .toList();

      availableFloorsInAllBuildings[buildingID]!.addAll(floorNumbers);
    }
    notifyListeners();
  }

}
