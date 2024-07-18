import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iwaymaps/DATABASE/BOXES/BuildingAPIModelBox.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/Elements/locales.dart';

import 'package:iwaymaps/navigationTools.dart';
import 'package:translator/translator.dart';
import 'package:vibration/vibration.dart';

import '../Cell.dart';
import '../UserState.dart';
import '../bluetooth_scanning.dart';
import '../buildingState.dart';
import '../directionClass.dart';
import '../directionClass.dart' as dc;
import '../directionClass.dart';
import '../Navigation.dart';

class DirectionHeader extends StatefulWidget {
  String direction;
  int distance;
  bool isRelocalize;
  UserState user;
  String getSemanticValue;
  BuildContext context;
  final Function(String nearestBeacon, {bool render}) paint;
  final Function(String nearestBeacon) repaint;
  final Function() reroute;
  final Function() moveUser;
  final Function() closeNavigation;
  final Function(dc.direction turn) focusOnTurn;
  final Function() clearFocusTurnArrow;

  DirectionHeader(
      {this.distance = 0,
      required this.user,
      this.direction = "",
      required this.paint,
      required this.repaint,
      required this.reroute,
      required this.moveUser,
      required this.closeNavigation,
      required this.isRelocalize,
      this.getSemanticValue = '',
      required this.focusOnTurn,
      required this.clearFocusTurnArrow,
      required this.context}) {
    try {
      double angle = tools.calculateAngleBWUserandCellPath(
          user.Cellpath[0],
          user.Cellpath[1],
          user.pathobj.numCols![user.Bid]![user.floor]!,
          user.theta);
      direction = tools.angleToClocks(angle, context);
      if (direction == "Straight") {
        direction = "Go Straight";
      } else {
        direction = "Turn ${direction}, and Go Straight";
      }
    } catch (e) {}
  }

  @override
  State<DirectionHeader> createState() => _DirectionHeaderState();
}

class _DirectionHeaderState extends State<DirectionHeader> {
  List<int> turnPoints = [];
  BLueToothClass btadapter = new BLueToothClass();
  late Timer _timer;
  String turnDirection = "";
  List<Widget> DirectionWidgetList = [];

  Map<String, double> ShowsumMap = Map();
  int DirectionIndex = 1;
  int nextTurnIndex = 0;
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale = '';

  @override
  void initState() {
    super.initState();

    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;

    for (int i = 0; i < widget.user.pathobj.directions.length; i++) {
      direction element = widget.user.pathobj.directions[i];
      //DirectionWidgetList.add(scrollableDirection("${element.turnDirection == "Straight"?"Go Straight":"Turn ${element.turnDirection??""}, and Go Straight"}", '${((element.distanceToNextTurn??1)/UserState.stepSize).ceil()} steps', getCustomIcon(element.turnDirection!)));
    }

    btadapter.emptyBin();
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }
    // btadapter.startScanning(Building.apibeaconmap);
    // _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
    //   //print("Pathposition");
    //   //print(widget.user.path);
    //
    //
    //   // //print("listen to bin :${listenToBin()}");
    //
    //   // HelperClass.showToast("Bin cleared");
    //   if(widget.user.pathobj.index>3) {
    //     listenToBin();
    //   }
    //
    //
    //
    // });

    btadapter.numberOfSample.clear();
    btadapter.rs.clear();
    Building.thresh = "";

    widget.getSemanticValue = "";
    // if(widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor] != null){
    //   turnPoints = tools.getTurnpointsForMultiBuilding(widget.user.ListofPaths);
    //
    //   (widget.user.path.length%2==0)? turnPoints.add(widget.user.path[widget.user.path.length-2]):turnPoints.add(widget.user.path[widget.user.path.length-1]);
    //   btadapter.startScanning(Building.apibeaconmap);
    //   _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
    //     print("WilsonCalled");
    //
    //     listenToBin();
    //
    //   });
    if (!widget.user.isInRealWorld) {
      List<Cell> path = widget.user.ListofPaths[widget.user.buildingNumber];

      List<int> v = tools.eightcelltransition(widget.user.theta);
      double a = 0;
      if (widget.user.pathobj.index + 1 == path.length) {
        a = tools.calculateAnglefifthForMultiBuilding(
            path[widget.user.pathobj.index - 1],
            [widget.user.showcoordX + v[0], widget.user.showcoordY + v[1]],
            path[widget.user.pathobj.index]);
      } else {
        a = tools.calculateAnglefifthForMultiBuilding(
            path[widget.user.pathobj.index],
            [widget.user.showcoordX + v[0], widget.user.showcoordY + v[1]],
            path[widget.user.pathobj.index + 1]);
      }
      widget.direction = tools.angleToClocks(a, widget.context);
      List<Cell> remainingPath = path.sublist(widget.user.pathobj.index);
      if (remainingPath.isEmpty) {
        remainingPath.add(path.last);
      }
      Cell nextTurn = findNextTurn(remainingPath);
      widget.distance = tools.distancebetweennodes(
          nextTurn, path[widget.user.pathobj.index], path);
    }

    //print("angleeeeee $angle")  ;
    setState(() {
      if (widget.direction == "Straight") {
        widget.direction = "Go Straight";

        speak(
            "${LocaleData.getProperty6('Go Straight', widget.context)} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}",
            _currentLocale);
      } else {
        speak(
            convertTolng(
                "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}, and ${LocaleData.getProperty6('Go Straight', widget.context)} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}",
                _currentLocale,
                "",
                Cell(0, 0, 0, (angle, {currPointer, totalCells}) => null, 0.0,
                    0.0, "",0),
                ""),
            _currentLocale);
        widget.getSemanticValue =
            "Turn ${widget.direction}, and Go Straight ${(widget.distance / UserState.stepSize).ceil()} steps";
      }
    });
    //
    // }
  }

  @override
  void dispose() {
    flutterTts.cancelHandler;
    _timer.cancel();
    super.dispose();
  }

  String getgetSemanticValue() {
    return widget.getSemanticValue;
  }

  String debuglastNearestbeacon = "";
  String debuglNearestbeacon = "";
  Map<String, double> sortedsumMap = {};
  Map<String, double> sumMap = {};
  Map<String, double> sumMapAvg = {};

  var newMap = <String, double>{};

  bool listenToBin() {
    double highestweight = 0;
    String nearestBeacon = "";
    sumMap.clear();
    sumMap = btadapter.calculateAverage();
    sortedsumMap.clear();
    //print("sortedsumMapcleared $sortedsumMap");

    sumMap.forEach((key, value) {
      if (highestweight < value) {
        nearestBeacon = key;
        highestweight = value;
      }
    });

    setState(() {
      ShowsumMap = HelperClass().sortMapByValue(sumMap);
    });

    btadapter.stopScanning();
    btadapter.startScanning(Building.apibeaconmap);

    // sortedsumMap.entries.forEach((element) {
    //   if(Building.apibeaconmap[element.key]!.floor == widget.user.pathobj.destinationFloor && element.value >= 0.05){
    //     nearestBeacon = element.key;
    //     highestweight = element.value;
    //   }
    // });
    // //print("-90---   ${sumMap.length}");
    // //print("checkingavgmap   ${sumMap}");

    // for (int i = 0; i < btadapter.BIN.length; i++) {
    //   if (btadapter.BIN[i]!.isNotEmpty) {
    //
    //     btadapter.BIN[i]!.forEach((key, value) {
    //       //print("Wilsonchecker");
    //       //print(value.toString());
    //       //print(key);
    //
    //       setState(() {
    //             widget.direction = "${widget.direction}$key   $value\n";
    //           });
    //
    //       //print("-90-   $key   $value");
    //
    //       if (value > highestweight) {
    //         highestweight = value;
    //         //nearestBeacon = key;
    //       }
    //     });
    //     break;
    //   }
    // }

    // btadapter.emptyBin();
    //

    // sortedsumMap.forEach((key, value) {
    //
    //   setState(() {
    //     widget.direction = "${widget.direction}$key   $value\n";
    //   });
    //
    //   //print("-90-   $key   $value");
    //
    //   if(value>highestweight){
    //     highestweight =  value;
    //     nearestBeacon = key;
    //   }
    // });
    setState(() {
      debuglNearestbeacon = nearestBeacon;
      if (debuglastNearestbeacon != nearestBeacon) {
        debuglastNearestbeacon = nearestBeacon;
      }
    });

    ////print("$nearestBeacon   $highestweight");

    // print("nearest${nearestBeacon}");
    if (nearestBeacon != "") {
      print("WilsonInsideCall");

      if (widget
              .user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] !=
          null) {
        print("WilsonInsideCall2");
        print(widget.user.key);
        print(Building.apibeaconmap[nearestBeacon]!.sId);
        if (widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId) {
          print("WilsonInsideCall3");

          //widget.user.pathobj.destinationFloor
          if (widget.user.floor !=
              Building.apibeaconmap[nearestBeacon]!.floor) {
            print("workingg 5");
            widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
            speak(
                convertTolng(
                    "You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor",
                    _currentLocale,
                    "",
                    Cell(0, 0, 0, (angle, {currPointer, totalCells}) => null,
                        0.0, 0.0, "",0),
                    nearestBeacon),
                _currentLocale);
            //need to render on beacon for aiims jammu
            widget.paint(nearestBeacon, render: false);
            return true;
          }

          // else if(widget.user.floor != Building.apibeaconmap[nearestBeacon]!.floor &&  highestweight >= 1.1){
          //   widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
          //   speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor");
          //   widget.paint(nearestBeacon,render: false);
          //   return true;
          // }

          else if (widget.user.floor ==
                  Building.apibeaconmap[nearestBeacon]!.floor &&
              highestweight >= 1.3) {
            //print("workingg user floor ${widget.user.floor}");
            List<int> beaconcoord = [
              Building.apibeaconmap[nearestBeacon]!.coordinateX!,
              Building.apibeaconmap[nearestBeacon]!.coordinateY!
            ];
            Building.apibeaconmap[nearestBeacon]!.sId;
            var dataBox = BuildingAPIModelBox.getData();
            dataBox.keys;
            dataBox.values;
            for (var keys in dataBox.keys) {}

            List<int> usercoord = [
              widget.user.showcoordX,
              widget.user.showcoordY
            ];
            double d = tools.calculateDistance(beaconcoord, usercoord);
            if (d < 5) {
              print("workingg 1");
              //near to user so nothing to do
              return true;
            } else {
              //print("workingg 2");
              int distanceFromPath = 100000000;
              int? indexOnPath = null;
              int numCols = widget
                  .user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!;
              widget.user.ListofPaths[widget.user.buildingNumber]
                  .forEach((node) {
                List<int> pathcoord = [node.x, node.y];
                double d1 = tools.calculateDistance(beaconcoord, pathcoord);
                if (d1 < distanceFromPath) {
                  distanceFromPath = d1.toInt();
                  //print("node on path $node");
                  //print("distanceFromPath $distanceFromPath");
                  indexOnPath = widget
                      .user.ListofPaths[widget.user.buildingNumber]
                      .indexOf(node);
                  //print(indexOnPath);
                }
              });

              if (distanceFromPath > 10) {
                print("workingg 3");
                _timer.cancel();
                widget.repaint(nearestBeacon);
                widget.reroute;
                return false; //away from path
              } else {
                print("workingg 4");
                widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
                speak(
                    "${widget.direction} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}",
                    _currentLocale);
                widget.user.moveToPointOnPath(indexOnPath!);
                widget.moveUser();
                return true; //moved on path
              }
            }

            //print("d $d");
            //print("widget.user.key ${widget.user.key}");
            //print("beaconcoord ${beaconcoord}");
            //print("usercoord ${usercoord}");
            //print(nearestBeacon);
          }
        }
      } else {
        print("WilsonInsideCall4");

        print("workingg 6");
        //print("listening");
        //print("inelese");

        //print(nearestBeacon);
        _timer.cancel();
        widget.repaint(nearestBeacon);
        widget.reroute;
        return false;
      }
    }

    // btadapter.emptyBin();

    return false;
  }

  FlutterTts flutterTts = FlutterTts();
  var translationn = GoogleTranslator();
  Future<void> speak(String msg, String lngcode) async {
    var translation =
        await translationn.translate(msg, from: 'en', to: lngcode);
    print("transalation");
    print(translation);
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  String convertTolng(String msg, String lngcode, String direc, Cell nextTurn,
      String nearestBeacon) {
    if (msg == "Turn ${widget.direction}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${widget.direction} मुड़ें";
      }
    } else if (widget.user.pathobj.associateTurnWithLandmark[nextTurn]!=null && msg ==
        "You are approaching ${direc} turn from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!} से ${direc} मोड़ के करीब पहुंच रहे हैं।";
      }
    } else if (msg == "You are approaching ${direc} turn") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${direc} मोड़ के करीब पहुंच रहे हैं";
      }
    } else if (msg ==
        "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}, and ${LocaleData.getProperty6('Go Straight', widget.context)} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(widget.direction, widget.context)} और सीधे ${(widget.distance / UserState.stepSize).ceil()} कदम चलें";
      }
    } else if (msg ==
        "You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} मंजिल पर पहुंच गए हैं";
      }
    }
    return "";
  }

  Cell findNextTurn(List<Cell> path) {
    for (int i = 1; i < path.length - 2; i++) {
      int currPos = path[i].node;

      int x1 = path[i].x;
      int y1 = path[i].y;

      int x2 = path[i + 1].x;
      int y2 = path[i + 1].y;

      int x3 = path[i - 1].x;
      int y3 = path[i - 1].y;

      int prevDeltaX = x1 - x3;
      int prevDeltaY = y1 - y3;
      int nextDeltaX = x2 - x1;
      int nextDeltaY = y2 - y1;

      if ((prevDeltaX != nextDeltaX) || (prevDeltaY != nextDeltaY)) {
        if (prevDeltaX == 0 && nextDeltaX == 0) {
        } else if (prevDeltaY == 0 && nextDeltaY == 0) {
        } else {
          return path[i];
        }
      }
    }
    return path.last;
  }

  @override
  void didUpdateWidget(DirectionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.user.isInRealWorld) {
      double di = tools.calculateDistance([widget.user.showcoordX,widget.user.showcoordY], [widget.user.pathobj.connections[widget.user.Bid]![widget.user.floor]! % UserState.cols, widget.user.pathobj.connections[widget.user.Bid]![widget.user.floor]! ~/ UserState.cols]);
      List<Cell> path = widget.user.ListofPaths[widget.user.buildingNumber];

      List<int> v = tools.eightcelltransition(widget.user.theta);
      double a = 0;
      if (widget.user.pathobj.index + 1 == path.length) {
        a = tools.calculateAnglefifthForMultiBuilding(
            path[widget.user.pathobj.index - 1],
            [widget.user.showcoordX + v[0], widget.user.showcoordY + v[1]],
            path[widget.user.pathobj.index]);
      } else {
        a = tools.calculateAnglefifthForMultiBuilding(
            path[widget.user.pathobj.index],
            [widget.user.showcoordX + v[0], widget.user.showcoordY + v[1]],
            path[widget.user.pathobj.index + 1]);
      }
      widget.direction = tools.angleToClocks(a, widget.context);
      List<Cell> remainingPath = path.sublist(widget.user.pathobj.index);
      if (remainingPath.isEmpty) {
        remainingPath.add(path.last);
      }
      Cell nextTurn = findNextTurn(remainingPath);
      widget.distance = tools.distancebetweennodes(
          nextTurn, path[widget.user.pathobj.index], path);
      print("distance ${widget.distance}");

      // isko uncomment kr lena agar direction header mein instruction dikhaani hai yeh vaali
      // if (widget.user.floor != widget.user.pathobj.destinationFloor &&
      //     di < 3 ) {
      //   widget.direction = "Use this lift and go to ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} floor";
      // }


      if (oldWidget.direction != widget.direction) {
        if (oldWidget.direction == "Straight") {
          Vibration.vibrate();

          // if(nextTurn == turnPoints.last){
          //   speak("${widget.direction} ${widget.distance} meter then you will reach ${widget.user.pathobj.destinationName}");
          // }else{
          //   speak("${widget.direction} ${widget.distance} meter");
          // }

          speak(
              convertTolng("Turn ${widget.direction}", _currentLocale, "", Cell(0, 0, 0, (angle, {currPointer, totalCells}) => null, 0.0,
                      0.0, "",0),""),
              _currentLocale);
          //speak("Turn ${widget.direction}, and Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");

        } else if (widget.direction == LocaleData.straight.getString(widget.context)) {

          Vibration.vibrate();

          speak(
              "${LocaleData.getProperty6('Go Straight', context)} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}",
              _currentLocale);
        }
      }

      try {
        if ((widget.distance / UserState.stepSize).ceil() == 7) {
          if (widget.user.pathobj.associateTurnWithLandmark[nextTurn] != null) {
            int index = path.indexWhere((element) => element == nextTurn);
            String direc = tools.angleToClocks(
                tools.calculateAnglefifthForMultiBuilding(path[index],
                    [path[index - 1].x, path[index - 1].y], path[index + 1]),
                widget.context);
            print("direc mila $direc");
            print("index mila $index");

            speak(
                convertTolng(
                    "You are approaching ${direc} turn from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}",
                    _currentLocale,
                    direc,
                    nextTurn,""),
                _currentLocale);
            //widget.user.pathobj.associateTurnWithLandmark.remove(nextTurn);
          } else {
            int index = path.indexWhere((element) => element == nextTurn);
            print("index mila $index");
            String direc = tools.angleToClocks(
                tools.calculateAnglefifthForMultiBuilding(path[index],
                    [path[index + 1].x, path[index + 1].y], path[index - 1]),
                widget.context);
            print("direc mila $direc");
            speak(
                convertTolng("You are approaching ${direc} turn",
                    _currentLocale, direc, nextTurn,""),
                _currentLocale);
            widget.user.move(widget.context);
          }
        }
      } catch (e) {
        print("approaching turn issue");
      }
    } else {
      widget.distance = tools
              .calculateDistanceBetweenLatLng(widget.user.lat, widget.user.lng,
                  widget.user.p[0], widget.user.p[1],
                  inFeet: true)
              .ceil() -
          UserState.stepSize.toInt();
      double a = tools.calculateAngleBetweenVectors(
          widget.user.lat,
          widget.user.lng,
          widget.user.p[0],
          widget.user.p[1],
          widget.user.theta);
      widget.direction = tools.angleToClocks(a, widget.context);
      if (oldWidget.direction != widget.direction) {
        if (oldWidget.direction == "Straight") {
          Vibration.vibrate();

          // if(nextTurn == turnPoints.last){
          //   speak("${widget.direction} ${widget.distance} meter then you will reach ${widget.user.pathobj.destinationName}");
          // }else{
          //   speak("${widget.direction} ${widget.distance} meter");
          // }

          speak("Turn ${LocaleData.getProperty5(widget.direction, context)}",
              _currentLocale);
          //speak("Turn ${widget.direction}, and Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");
        } else if (widget.direction == "Straight") {
          Vibration.vibrate();

          speak(
              "${LocaleData.getProperty6('Go Straight', context)} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}",
              _currentLocale);
        }
      }
    }
  }

  // @override
  // void didUpdateWidget(DirectionHeader oldWidget){
  //   super.didUpdateWidget(oldWidget);
  //
  //   if(widget.user.floor == widget.user.pathobj.sourceFloor && widget.user.pathobj.connections.isNotEmpty && widget.user.showcoordY*UserState.cols + widget.user.showcoordX  == widget.user.pathobj.connections[widget.user.Bid]![widget.user.pathobj.sourceFloor]){
  //
  //   }else{
  //
  //     if(widget.user.path[widget.user.pathobj.index] == turnPoints.last){
  //
  //       speak("You have reached ${widget.user.pathobj.destinationName}");
  //       widget.closeNavigation();
  //     }else{
  //       widget.user.pathobj.connections.forEach((key, value) {
  //         value.forEach((inkey, invalue) {
  //           if(widget.user.path[widget.user.pathobj.index] == invalue){
  //             widget.direction = "You have reached ";
  //           }
  //         });
  //       });
  //
  //
  //
  //
  //       List<int> remainingPath = widget.user.path.sublist(widget.user.pathobj.index+1);
  //       int nextTurn = findNextTurn(turnPoints, remainingPath);
  //       print(nextTurn);
  //       print(remainingPath);
  //       nextTurnIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == nextTurn);
  //
  //       if(turnPoints.contains(widget.user.path[widget.user.pathobj.index])){
  //         if(DirectionIndex + 1 < widget.user.pathobj.directions.length)
  //           DirectionIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == widget.user.path[widget.user.pathobj.index])+1;
  //       }
  //       widget.distance = tools.distancebetweennodes(nextTurn, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
  //
  //       double angle = tools.calculateAngleBWUserandCellPath(widget.user.Cellpath[widget.user.pathobj.index], widget.user.Cellpath[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!,widget.user.theta);
  //       widget.direction = tools.angleToClocks(angle,context) == "None"?oldWidget.direction:tools.angleToClocks(angle,context);
  //       int index = widget.user.path.indexOf(nextTurn);
  //       //print("index $index");
  //       double a =0;
  //       if(index+1 == widget.user.path.length){
  //         a = tools.calculateAnglefifth(widget.user.path[index-2], widget.user.path[index-1], widget.user.path[index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
  //       }else{
  //         a = tools.calculateAnglefifth(widget.user.path[index-1], widget.user.path[index], widget.user.path[index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
  //       }
  //
  //       String direc = tools.angleToClocks(a);
  //       turnDirection = direc;
  //       if(nextTurn == turnPoints.last && widget.distance == 7){
  //         double angle = tools.calculateAngleThird([widget.user.pathobj.destinationX,widget.user.pathobj.destinationY], widget.user.path[widget.user.pathobj.index+1], widget.user.path[widget.user.pathobj.index+2], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
  //         speak("${widget.direction} ${widget.distance} steps. ${widget.user.pathobj.destinationName} will be ${tools.angleToClocks2(angle)}");
  //       }else if(nextTurn != turnPoints.last && (widget.distance/UserState.stepSize).ceil() == 7){
  //         if(!direc.contains("slight")){
  //
  //           if(widget.user.pathobj.associateTurnWithLandmark[nextTurn] != null){
  //             speak("Approaching ${direc} turn from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}");
  //             //widget.user.pathobj.associateTurnWithLandmark.remove(nextTurn);
  //           }else{
  //             speak("Approaching ${direc} turn");
  //             widget.user.move();
  //           }
  //         }
  //       }
  //
  //
  //       if(oldWidget.direction != widget.direction){
  //
  //         if(oldWidget.direction == "Straight"){
  //
  //           Vibration.vibrate();
  //
  //
  //           // if(nextTurn == turnPoints.last){
  //           //   speak("${widget.direction} ${widget.distance} meter then you will reach ${widget.user.pathobj.destinationName}");
  //           // }else{
  //           //   speak("${widget.direction} ${widget.distance} meter");
  //           // }
  //
  //           speak("Turn ${widget.direction}");
  //           //speak("Turn ${widget.direction}, and Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");
  //
  //
  //         }else if(widget.direction == "Straight"){
  //
  //
  //
  //           Vibration.vibrate();
  //
  //           speak("Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");
  //         }
  //       }
  //     }
  //   }
  // }

  static Icon getCustomIcon(String direction) {
    if (direction.toLowerCase().contains("lift")) {
      return Icon(
        Icons.elevator,
        color: Colors.white,
        size: 40,
      );
    }else if (direction == "Straight") {
      return Icon(
        Icons.straight,
        color: Colors.white,
        size: 40,
      );
    } else if (direction == "Slight Right") {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.white,
        size: 40,
      );
    } else if (direction == "Right") {
      return Icon(
        Icons.turn_right,
        color: Colors.white,
        size: 40,
      );
    } else if (direction == "Sharp Right") {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.white,
        size: 40,
      );
    } else if (direction == "U Turn") {
      return Icon(
        Icons.u_turn_right,
        color: Colors.white,
        size: 40,
      );
    } else if (direction == "Sharp Left") {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.white,
        size: 40,
      );
    } else if (direction == "Left") {
      return Icon(
        Icons.turn_left,
        color: Colors.white,
        size: 40,
      );
    } else if (direction == "Slight Left") {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.white,
        size: 40,
      );
    } else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.white,
        size: 40,
      );
    }
  }

  Icon getNextCustomIcon(String direction) {
    if (direction == "Straight") {
      return Icon(
        Icons.straight,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Slight Right") {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Right") {
      return Icon(
        Icons.turn_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Sharp Right") {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "U Turn") {
      return Icon(
        Icons.u_turn_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Sharp Left") {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Left") {
      return Icon(
        Icons.turn_left,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Slight Left") {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.white,
        size: 23,
      );
    } else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.white,
        size: 23,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Semantics(
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
              color: Color(0xff01544F),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Container(
                //   width: 44,
                //   height: 44,
                //   child: IconButton(
                //       onPressed: () {
                //         //   setState(() {
                //         //   if(DirectionIndex - 1 >=1){
                //         //     DirectionIndex--;
                //         //     widget.focusOnTurn(widget.user.pathobj.directions[DirectionIndex]);
                //         //     if(DirectionIndex == nextTurnIndex){
                //         //       widget.clearFocusTurnArrow();
                //         //     }
                //         //   }
                //         // });
                //       },
                //       icon: Icon(
                //         Icons.arrow_back_ios_new,
                //         color: DirectionIndex - 1 >= 1
                //             ? Colors.white
                //             : Colors.grey,
                //       )),
                // ),
                const SizedBox(
                  width: 8,
                ),
                scrollableDirection(
                    "${widget.direction}",
                    '${(widget.distance / UserState.stepSize).ceil()}',
                    getCustomIcon(widget.direction),
                    DirectionIndex,
                    nextTurnIndex,
                    widget.user.pathobj.directions,
                    widget.user,
                    widget.context),
                const SizedBox(
                  width: 8,
                ),
                // Container(
                //   width: 44,
                //   height: 44,
                //   child: IconButton(
                //       onPressed: () {
                //         //   setState(() {
                //         //   if(DirectionIndex + 1 < widget.user.pathobj.directions.length){
                //         //     DirectionIndex++;
                //         //     widget.focusOnTurn(widget.user.pathobj.directions[DirectionIndex]);
                //         //     if(widget.user.pathobj.directions.length-DirectionIndex == 2 && widget.user.pathobj.directions[DirectionIndex].distanceToNextTurn != null && widget.user.pathobj.directions[DirectionIndex].distanceToNextTurn!<=5 && DirectionIndex + 1 < widget.user.pathobj.directions.length){
                //         //       DirectionIndex++;
                //         //     }
                //         //     if(DirectionIndex == nextTurnIndex){
                //         //       widget.clearFocusTurnArrow();
                //         //     }
                //         //   }
                //         // });
                //       },
                //       icon: Icon(
                //         Icons.arrow_forward_ios_outlined,
                //         color: DirectionIndex + 1 <
                //                 widget.user.pathobj.directions.length
                //             ? Colors.white
                //             : Colors.grey,
                //         size: 24,
                //       )),
                // )
              ],
            ),
          ),
          DirectionIndex == nextTurnIndex
              ? Container(
                  width: 98,
                  height: 39,
                  margin: EdgeInsets.only(left: 9, top: 5),
                  padding: EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: Color(0xff013633),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Then",
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffFFFFFF),
                          height: 25 / 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      // Text(DirectionIndex.toString()),
                      // Text(nextTurnIndex.toString())
                      getNextCustomIcon(turnDirection)
                    ],
                  ),
                )
              : Container(),
          Container(
            width: 300,
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(ShowsumMap.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class scrollableDirection extends StatelessWidget {
  String Direction;
  String steps;
  Icon i;
  int DirectionIndex;
  int nextTurnIndex;
  List<direction> listOfDirections;
  UserState user;
  BuildContext context;

  scrollableDirection(this.Direction, this.steps, this.i, this.DirectionIndex,
      this.nextTurnIndex, this.listOfDirections, this.user, this.context);

  String chooseDirection(context) {
    if (listOfDirections[DirectionIndex].isDestination) {
      double? angle;
      if (user.pathobj.singleCellListPath.isNotEmpty) {
        int l = user.pathobj.singleCellListPath.length;
        angle = tools.calculateAngle([
          user.pathobj.singleCellListPath[l - 2].x,
          user.pathobj.singleCellListPath[l - 2].y
        ], [
          user.pathobj.singleCellListPath[l - 1].x,
          user.pathobj.singleCellListPath[l - 1].y
        ], [
          user.pathobj.destinationX,
          user.pathobj.destinationY
        ]);
      }
      return angle != null
          ? "${listOfDirections[DirectionIndex].turnDirection} will be ${tools.angleToClocks3(angle, context)}"
          : "${listOfDirections[DirectionIndex].turnDirection} will be on your front";
    } else if (DirectionIndex == nextTurnIndex) {
      return "${Direction == "Straight" ? "Go Straight" : "Turn ${Direction}, and Go Straight"}";
    } else {
      if (DirectionIndex < listOfDirections.length) {
        return "${listOfDirections[DirectionIndex].turnDirection == "Straight" ? "Go Straight" : "Turn ${listOfDirections[DirectionIndex].turnDirection}, and Go Straight"}";
      } else {
        return "${listOfDirections[DirectionIndex - 1].turnDirection == "Straight" ? "Go Straight" : "Turn ${listOfDirections[DirectionIndex - 1].turnDirection}, and Go Straight"}";
      }
    }
  }

  String chooseSteps() {
    if (listOfDirections[DirectionIndex].isDestination) {
      return "";
    } else if (DirectionIndex == nextTurnIndex) {
      return '$steps Steps';
    } else {
      return '${((listOfDirections[DirectionIndex].distanceToNextTurn ?? 1) / UserState.stepSize).ceil()} Steps';
    }
  }

  Icon chooseIcon() {
    if (listOfDirections[DirectionIndex].isDestination) {
      return Icon(
        Icons.place_rounded,
        color: Colors.white,
        size: 40,
      );
    } else if (DirectionIndex == nextTurnIndex) {
      return i;
    } else {
      return _DirectionHeaderState.getCustomIcon(
          listOfDirections[DirectionIndex].turnDirection!);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "${Direction == "Straight" ? "${LocaleData.gostraight.getString(context)}" : LocaleData.getProperty(Direction, context)}",
                style: const TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 30 / 24,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Container(
            width: 75,
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Direction.toLowerCase().contains("lift")?Container():Text(
                  steps,
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 26 / 16,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  height: 40,
                  width: 40,
                  child: chooseIcon(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
