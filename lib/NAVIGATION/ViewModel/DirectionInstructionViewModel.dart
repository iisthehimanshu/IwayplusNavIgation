import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:iwaymaps/NAVIGATION/UserState.dart';

import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/Elements/locales.dart';
import '../directionClass.dart';
import '../navigationTools.dart';

class DirectionInstructionViewModel extends ChangeNotifier {
  final List<direction> directionList;
  Map<String,String?>? buildingData;
  BuildContext context;

  String sourceBID;
  String sourceName;
  int sourceFloor;
  String sourceBuildingName="";
  String sourceLiftIndexString = "";
  List<direction> _sourceDirection = [];
  bool _sourceMultiFloor = false;
  double _sourceUPHeight = 0;
  double _sourceDownHeight = 0;
  String sourceLiftString = "";
  int totalSourceTurns = 0;
  double totalSourceDistance = 0;

  String destinationBID;
  String destinationName;
  int destionationFloor;
  String destinationBuildingName="";
  String destinationLiftIndexString = "";
  List<direction> _destinationDirection = [];
  bool _destinationMultiFloor = false;
  double _destinationUpHeight = 0;
  double _destinationDownHeight = 0;
  String destinationLiftString = "";
  int totalDestinationTurns = 0;
  double totalDestinationDistance = 0;
  List<direction> _outdoorDirection = [];
  double _outdoorWidgetHeight = 1.1;
  double totalOutdoorLength = 0.0;
  bool _MultiBuilding = false;
  List<direction> get sourceDirection => _sourceDirection;
  List<direction> get destinationDirection => _destinationDirection;
  List<direction> get outdoorDirection => _outdoorDirection;
  double get sourceUPHeight => _sourceUPHeight;
  double get sourceDownHeight => _sourceDownHeight;
  double get destinationUpHeight => _destinationUpHeight;
  double get destinationDownHeight => _destinationDownHeight;
  bool get isSourceMultiFloor => _sourceMultiFloor;
  bool get isDestinationMultiFloor => _destinationMultiFloor;
  bool get isMultiBuilding => _MultiBuilding;
  double get outdoorWidgetHeight => _outdoorWidgetHeight;


  DirectionInstructionViewModel(this.directionList, this.sourceBID, this.sourceName, this.sourceFloor, this.destinationBID,this.destinationName,this.destionationFloor,this.buildingData, this.context) {
    _makeList();
  }

  void _makeList() {
    buildingData?.forEach((k,v){
      if(k==sourceBID){
        sourceBuildingName = v!;
      }else if(k==destinationBID){
        destinationBuildingName = v!;
      }
    });
    if(sourceBID != destinationBID){
      _MultiBuilding = true;
    }else{
      _MultiBuilding = false;
    }

    List<direction> stemp = directionList.where((e) => e.Bid == sourceBID).toList();
    _sourceDirection = parseDirections(stemp, context);
    List<direction> dtemp = directionList.where((e) => e.Bid == destinationBID).toList();
    _destinationDirection = parseDirections(dtemp, context);
    List<direction> otemp =  directionList.where((e) => e.Bid == buildingAllApi.outdoorID).toList();
    _outdoorDirection = parseDirections(otemp, context);
    checkMultiFloor();
    _calculateHeight();
    UserState.mapPathGuide= tools.processInstructions(_sourceDirection);
    notifyListeners();
  }

  bool toggleForLiftFoundS = false;
  bool toggleForLiftFoundD = false;

  void _calculateHeight() {
    for (var dir in _sourceDirection) {
      if (dir.turnDirection!.split(' ').first.toLowerCase() == "take") {
        toggleForLiftFoundS = true;
        sourceLiftString = dir.turnDirection.toString();
      }
      if(toggleForLiftFoundS){
        _sourceDownHeight+=50;
      }else{
        _sourceUPHeight+=68;
      }
      totalSourceTurns++;
      if(dir.distanceToNextTurnInFeet != null) {
        totalSourceDistance += dir.distanceToNextTurnInFeet!;
      }
    }
    if(_MultiBuilding){
      for (var dir in _destinationDirection) {
        if (dir.turnDirection!.split(' ').first.toLowerCase() == "take") {
          toggleForLiftFoundD = true;
          destinationLiftString = dir.turnDirection.toString();
        }
        if(toggleForLiftFoundD){
          _destinationDownHeight+=50;
        }else{
          _destinationUpHeight+=50;
        }
        totalDestinationTurns++;
        if(dir.distanceToNextTurnInFeet != null) {
          totalDestinationDistance += dir.distanceToNextTurnInFeet!;
        }
      }

      _outdoorWidgetHeight = 50 * _outdoorDirection.length.toDouble();
      for (var dir in _outdoorDirection) {
        if(dir.distanceToNextTurnInFeet != null) {
          totalOutdoorLength += dir.distanceToNextTurnInFeet!;
        }
      }
    }
  }


  void checkMultiFloor(){
    if(_MultiBuilding){
      for (var dir in _sourceDirection) {
        if (dir.turnDirection!.split(' ').first.toLowerCase() == "take") {
          _sourceMultiFloor = true;
        }
      }
      for (var dir in _destinationDirection) {
        if (dir.turnDirection!.split(' ').first.toLowerCase() == "take") {
          _destinationMultiFloor = true;
        }
      }
    }else{
      for (var dir in _sourceDirection) {
          if (dir.turnDirection!.split(' ').first.toLowerCase() == "take") {
            _sourceMultiFloor = true;
          }
      }
    }
  }



  String turnToWidgetString (direction input){
    String output = "";
    if(input.turnDirection != null && input.turnDirection!.split(' ').first.toLowerCase() != "go" && input.turnDirection!.split(' ').first.toLowerCase() != "turn" && input.turnDirection!.split(' ').first.toLowerCase() != "take"){
      if(input.nearbyLandmark != null){
        output = input.changeDirection(
            input.turnDirection == "Straight"
                ? '${LocaleData.gostraight.getString(context)}'
                : "${LocaleData.turn.getString(context)} ${LocaleData.getProperty3(input.turnDirection!, context)} ${LocaleData.from.getString(context)} ${input.nearbyLandmark!.name!} ${LocaleData.getProperty2(input.turnDirection!, context)} ${LocaleData.and.getString(context)} ${LocaleData.gostraight.getString(context)}"
        ).turnDirection.toString();
        print("output");
        print(output);

      }else{
        output = input.changeDirection(
            input.turnDirection == "Straight"
                ? '${LocaleData.gostraight.getString(context)}'
                : "${LocaleData.turn.getString(context)} ${LocaleData.getProperty4(input.turnDirection!, context)}, ${LocaleData.and.getString(context)} ${LocaleData.gostraight.getString(context)}"
        ).turnDirection.toString();
      }

    }

    return output;
  }

  List<direction> parseDirections(List<direction> directionList, BuildContext context){

    List<direction> parsedList = [];
    for(var direction in directionList){
      if(direction.turnDirection != null && direction.turnDirection!.split(' ').first.toLowerCase() != "go" && direction.turnDirection!.split(' ').first.toLowerCase() != "turn" && direction.turnDirection!.split(' ').first.toLowerCase() != "take"){
        if(direction.nearbyLandmark != null){
          print("found landmark ${direction.nearbyLandmark}");
          parsedList.add(direction.changeDirection(
              direction.turnDirection == "Straight"
                  ? '${LocaleData.gostraight.getString(context)}'
                  : "${LocaleData.turn.getString(context)} ${LocaleData.getProperty3(direction.turnDirection!, context)} ${LocaleData.from.getString(context)} ${direction.nearbyLandmark!.name!} ${LocaleData.getProperty2(direction.turnDirection!, context)}\n ${LocaleData.and.getString(context)} ${LocaleData.gostraight.getString(context)}"
          ));
        }else{
          parsedList.add(direction.changeDirection(
              direction.turnDirection == "Straight"
                  ? '${LocaleData.gostraight.getString(context)}'
                  : "${LocaleData.turn.getString(context)} ${LocaleData.getProperty4(direction.turnDirection!, context)}, ${LocaleData.and.getString(context)} ${LocaleData.gostraight.getString(context)}"
          ));
        }

      }

    }






    return directionList;
  }
}
