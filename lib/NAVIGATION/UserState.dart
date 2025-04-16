import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;
import 'package:iwaymaps/NAVIGATION/pathState.dart';
import 'package:iwaymaps/NAVIGATION/path_snapper.dart';
import 'package:ml_linalg/matrix.dart';
import '../IWAYPLUS/API/buildingAllApi.dart';
import '../IWAYPLUS/Elements/locales.dart';
import '../IWAYPLUS/websocket/UserLog.dart';
import 'DebugToggle.dart';
import 'GPSService.dart';
import 'GPSStreamHandler.dart';
import 'MotionModel.dart';
import 'buildingState.dart' as b;

import 'Cell.dart';
import 'navigationTools.dart';


class UserState {
  int floor;
  int coordX;
  double coordXf;
  int coordY;
  double coordYf;
  double lat;
  double lng;
  String key;
  double theta;
  String? locationName;
  bool isnavigating;
  int showcoordX;
  int showcoordY;
  static bool isTurn = false;
  static bool lowCompassAccuracy = false;
  pathState pathobj = pathState();
  List<int> path = [];
  List<Cell> cellPath = [];
  bool initialallyLocalised = false;
  String bid;
  List<int> offPathDistance = [];
  List<double> outdoorNextSegmentDistance = [];
  bool onConnection = false;
  bool temporaryExit = false;
  Map<String,List<int>> stepsArray = {"index":[0], "array":[2]};
  GPSStreamHandler gpsStreamHandler = GPSStreamHandler();
  static double? geoLat ;
  static double? geoLng ;
  static Function autoRecenter=() {};
  static bool ttsAllStop = false;
  static bool ttsOnlyTurns = false;
  b.Building? building;
  static int xdiff = 0;
  static int ydiff = 0;
  static bool isRelocalizeAroundLift = false;
  static bool reachedLift = false;
  static int userHeight = 195;
  static double stepSize = 2;
  static String lngCode = 'en';
  static int cols = 0;
  static int rows = 0;
  static List<Map<String, dynamic>> mapPathGuide=[];
  static Map<String, Map<int, List<int>>> nonWalkable = {};
  static Function reroute = () {};
  static Function closeNavigation = () {};
  static Function speak = (String lngcode) {};
  static Function alignMapToPath = () {};
  static Function changeBuilding = () {};
  static Function startOnPath = () {};
  static Function renderHere = () {};
  static Function paintMarker = (geo.LatLng location) {};
  static Function createCircle = (double lat, double lng) {};
  static Function addDebugMarkers = (geo.LatLng point, {double? hue,int? id}){};
  PathSnapper snapper = PathSnapper();


  UserState(
      {required this.floor,
        required this.coordX,
        required this.coordY,
        required this.lat,
        required this.lng,
        required this.theta,
        this.key = "",
        this.bid = "",
        this.showcoordX = 0,
        this.showcoordY = 0,
        this.isnavigating = false,
        this.coordXf = 0.0,
        this.coordYf = 0.0});

  Future<void> move(BuildContext context, {int? steps, bool isFlying = false}) async {
    List<Cell> turnPoints = [];
    try {
      turnPoints = tools.getCellTurnpoints(cellPath);
    } catch (_) {}
    moveOneStep(context, turnPoints, isFlying: steps == null?false:isFlying);
    for (int i = 1; i < (steps??stepSize.toInt()); i++) {
      print("moveal ${isMovementAllowed(turnPoints, context)}");
      if (!isMovementAllowed(turnPoints, context)) {
        return;
      }
      moveOneStep(context, turnPoints, isFlying: steps == null?false:isFlying);
    }
    incrementSteps();
  }

  bool isMovementAllowed(List<Cell> turnPoints, BuildContext context) {
    bool movementAllowed = MotionModel.isValidStep(this, cols, rows, nonWalkable[bid]![floor]!, reroute, context);
    if (!movementAllowed || !isnavigating) return movementAllowed;
    int prevX = cellPath[pathobj.index - 1].x;
    int prevY = cellPath[pathobj.index - 1].y;
    int nextX = cellPath[pathobj.index + 1].x;
    int nextY = cellPath[pathobj.index + 1].y;
    if (shouldTerminateNavigation()) {
      print('Destination reached.');
      return false;
    }
    if (isTurnCheck(prevX, prevY, nextX, nextY, turnPoints) || isLiftCheck()) {
      print("turn and lift.");
      return false;
    }
    return true;
  }

  bool isTurnCheck(
      int prevX, int prevY, int nextX, int nextY, List<Cell> turnPoints) {
    if (bid == buildingAllApi.outdoorID) {
      for (var c in turnPoints) {
        if (c.bid == bid && c.x == showcoordX && c.y == showcoordY) {
          print('Turn check true.');
          return true;
        }
      }
    } else if (tools
        .isTurn([prevX, prevY], [showcoordX, showcoordY], [nextX, nextY])) {
      print('Indoor turn check true.');
      return true;
    }
    return false;
  }
  bool isLiftCheck() {
    if (pathobj.connections[bid]?[floor] == showcoordY * cols + showcoordX) {
      print("Lift check true.");
      return true;
    }
    return false;
  }

  Location? lastPosition;
  void handleGPS(BuildContext context){
    DateTime startTime = DateTime.now();
    // Process noise covariance
    Matrix Q = Matrix.fromList([
      [0.5, 0, 0, 0],
      [0, 0.5, 0, 0],
      [0, 0, 0.05, 0],
      [0, 0, 0, 0.05],
    ]);
    // State transition matrix (constant velocity model)

    // Observation matrix (GPS provides only x, y position)
    Matrix H = Matrix.fromList([
      [1, 0, 0, 0],
      [0, 1, 0, 0],
    ]);
    // Measurement noise covariance (GPS noise)
    Matrix R = Matrix.fromList([
      [0.15, 0],
      [0, 0.15],
    ]);
    Matrix P = Matrix.identity(4)*70;

    //Prediction Step



    print("handleGPS invoked");
    snapper.snappedCellStream.listen((snapped) {
      var cell = snapped["cell"];
      var pos = snapped["position"];
      print("userbid is $bid ${bid == buildingAllApi.outdoorID} ${buildingAllApi.outdoorID}");
      if(isnavigating && bid == buildingAllApi.outdoorID){
        Matrix X_pred = Matrix.fromList([
          [lat], [lng], [0], [0]
        ]);
        int dt = 0;
        if(lastPosition != null){
          dt = pos.timeStamp.difference(lastPosition!.timeStamp).inSeconds;
        }
        lastPosition = pos;
        Matrix F = Matrix.fromList([
          [1, 0, dt.toDouble(), 0],
          [0, 1, 0, dt.toDouble()],
          [0, 0, 1, 0],
          [0, 0, 0, 1],
        ]);
        Matrix P_pred = F * P * F.transpose() + Q;
        // Kalman gain
        Matrix K = P_pred * H.transpose() *
            (H * P_pred * H.transpose() + R).inverse();
        // Update step
        Matrix Z = Matrix.fromList([[pos.latitude], [pos.longitude]]);
        X_pred = X_pred + K * (Z - H * X_pred);
        P = (Matrix.identity(4) - K * H) * P_pred;
        if(lastPosition != null){
          var kalmanCell = snapper.snapToPathKalman(lastPosition!,X_pred[0][0],X_pred[1][0], pathobj.index, cellPath);
          if(kalmanCell != null){
            snapped["cell"] = kalmanCell;
            cell = kalmanCell;
            double d = tools.calculateDistance([cell.x, cell.y], [showcoordX, showcoordY]);
            // HelperClass.showToast("kalman position identified with distance ${d.toStringAsFixed(2)} meters and accuracy is ${pos.accuracy}");
            print("kalman position identified with distance $d meters");

            if(DateTime.now().difference(startTime).inSeconds >10 && cell?.imaginedIndex != null && d>=20){
              // if(DateTime.now().difference(startTime).inSeconds >10 && snapped.imaginedIndex != null){
              // if(DebugToggle.kalman){

              if(d>26){
              addDebugMarkers(geo.LatLng(cell.lat,cell.lng));
              List<Cell>? points = tools.findSegmentContainingPoint(cellPath, pathobj.index);
              List<Cell> allPointsofSegment = tools.findAllPointsOfSegment(cellPath, points!);
              allPointsofSegment.add(cell);
              List<Cell> sorted = tools.sortCollinearPoints(allPointsofSegment);
              int index = sorted.indexWhere((node)=>node.x == cell.x && node.y == cell.y);
              index = index + cellPath.indexWhere((node)=>node.x == points[0].x && node.y == points[0].y);
              path.insert(index, (cell.y*cell.numCols)+cell.x);
              cellPath.insert(index, cell);
              moveToPointOnPath(index, context);
              pathobj.index = index;
              renderHere();
              }

              // }

            }
          }
        }
      }
    });
  }

  Future<void> moveOneStep(context, List<Cell> turnPoints, {bool isFlying = false}) async {
    userLogData();

    if (isnavigating) {
      checkForMerge(context);
      pathobj.index = pathobj.index + 1;
      print("making ${pathobj.index}");
      if (isInOutdoor()) {
        //destination check
        if (shouldTerminateNavigation()) {
          createCircle(lat, lng);
          closeNavigation();
          return;
        }

        if (!gpsStreamHandler.isStreamActive()) {
          //gpsHandler();
        }

        Cell previousPoint = tools.findingprevpoint(cellPath, pathobj.index);
        print("next cell ${cellPath[pathobj.index].x},${cellPath[pathobj.index].y}");
        double angleToNextCell = tools.calculateBearing([lat, lng],
            [cellPath[pathobj.index].lat, cellPath[pathobj.index].lng]);
        updateCoordinatesAndPath(previousPoint, angleToNextCell, isFlying: isFlying);

        double? NextSegmentDistance = calculateNextSegmentDistance();
        if (NextSegmentDistance != null && NextSegmentDistance > 0) {
          print("adding NextSegmentDistance");
          outdoorNextSegmentDistance.add(NextSegmentDistance);
        }
        if (calculateOffPathDistance() > 0) {
          offPathDistance.add(calculateOffPathDistance());
        }
        return;
      }
      print("inside else condition movement");
      if(gpsStreamHandler.isStreamActive()){
        gpsStreamHandler.stopStream();
      }

      initializeStepsArray(0, [2]);
      if (cellPath[pathobj.index].bid != null &&
          bid != cellPath[pathobj.index].bid) {
        bid = cellPath[pathobj.index].bid!;
        cols = building!.floorDimenssion[bid]![floor]![0];
        rows = building!.floorDimenssion[bid]![floor]![1];
      }

      List<int> cellAnalysis =
      tools.analyzeCell(cellPath, cellPath[pathobj.index]);
      List<int> transition = cellPath[pathobj.index].move(theta,
          currPointer: cellAnalysis[1], totalCells: cellAnalysis[0]);

      coordX += transition[0];
      coordY += transition[1];

      // Convert local coordinates to global lat/lng
      List<double> globalCoords = tools.localtoglobal(showcoordX, showcoordY,
          building!.patchData[cellPath[pathobj.index].bid]);
      lat = globalCoords[0];
      lng = globalCoords[1];

      if (isnavigating && pathobj.Cellpath.isNotEmpty && pathobj.numCols![bid]![floor] != 0) {
        updateDisplayCoordinates();
        if (hasChangedBuilding()) {
          handleBuildingTransition(context);
        }
      } else {
        showcoordX = coordX;
        showcoordY = coordY;
        updateGlobalCoordinates();
      }

      //destination check
      if (shouldTerminateNavigation()) {
        createCircle(lat, lng);
        closeNavigation();
        return;
      }

      //turn check
      int prevX = cellPath[pathobj.index - 1].x;
      int prevY = cellPath[pathobj.index - 1].y;
      int nextX = cellPath[pathobj.index + 1].x;
      int nextY = cellPath[pathobj.index + 1].y;
      if (isTurnCheck(prevX, prevY, nextX, nextY, turnPoints)) {
        UserState.isTurn = true;
        if (cellPath[pathobj.index + 1].bid == cellPath[pathobj.index].bid) {
          alignMapToPath([lat, lng],
              tools.localtoglobal(nextX, nextY, building!.patchData[bid]));
        }
      }

      //lift check
      if (isLiftCheck() && floor != pathobj.destinationFloor) {
        announceLiftUsage(context);
      }

      //nearby Landmarks
      if (0 < pathobj.index &&
          pathobj.index < cellPath.length - 1 &&
          pathState.nearbyLandmarks.isNotEmpty &&
          !tools.isCellTurn(cellPath[pathobj.index - 1],
              cellPath[pathobj.index], cellPath[pathobj.index + 1])) {
        handleNearbyLandmarks(context);
      }
    } else {
      proceedWithoutNavigation();
    }

    if (calculateOffPathDistance() > 0) {
      offPathDistance.add(calculateOffPathDistance());
    }
  }

  void userLogData() {
    wsocket.message["userPosition"]["X"] = coordX;
    wsocket.message["userPosition"]["Y"] = coordY;
    wsocket.message["userPosition"]["floor"] = floor;
  }

  bool shouldTerminateNavigation() {
    List<Cell> turnPoints = tools.getCellTurnpoints(cellPath);
    bool isSameFloorAndBuilding = bid == buildingAllApi.outdoorID || (floor == pathobj.destinationFloor && bid == pathobj.destinationBid);


    bool isNearLastTurnPoint = tools.calculateDistance(
        [turnPoints.last.x, turnPoints.last.y],
        [pathobj.destinationX, pathobj.destinationY]) <
        10;

    bool isAtLastTurnPoint =
        showcoordX == turnPoints.last.x && showcoordY == turnPoints.last.y;

    print("destination is ${tools.calculateAerialDist(lat,lng, pathobj.destinationLat, pathobj.destinationLng)} m away");
    bool isNearDestination = tools.calculateAerialDist(
        lat, lng, pathobj.destinationLat, pathobj.destinationLng) <
        ((bid == buildingAllApi.outdoorID) ? 5 : 2);

    return (isSameFloorAndBuilding && ((isNearLastTurnPoint && isAtLastTurnPoint) || isNearDestination));
  }

  void initializeStepsArray(int index, List<int> array){
    print("array changed to $array");
    stepsArray = {"index":[index], "array":array};
  }

  void incrementSteps(){
    print("index was ${stepsArray["index"]}");
    int i = stepsArray["index"]!.first;
    stepsArray["index"] = [i+1];
    if(stepsArray["index"]!.first == stepsArray["array"]!.length){
      stepsArray["index"]!.first = 0;
    }
    stepSize = stepsArray["array"]![stepsArray["index"]!.first].toDouble();
    print("changed step size to $stepSize on index ${stepsArray["index"]} and should have been ${stepsArray["array"]![stepsArray["index"]!.first].toDouble()}");
  }

  void updateCoordinatesAndPath(Cell previousPoint, double angle, {bool isFlying = false}) {

    Map<String, double> lineData = tools.findslopeandintercept(previousPoint.x,
        previousPoint.y, cellPath[pathobj.index].x, cellPath[pathobj.index].y);

    if(!isFlying){
      try{
        int stepsRequired = tools.stepsToReachTarget(previousPoint.x, previousPoint.y, cellPath[pathobj.index].x, cellPath[pathobj.index].y, lineData);
        double d = tools.calculateDistance([previousPoint.x, previousPoint.y], [cellPath[pathobj.index].x, cellPath[pathobj.index].y]);
        print("stepsRequired $stepsRequired d $d");
        List<int> Array = tools.findIntegersWithMean((stepsRequired/d)*2);
        print("length of array ${stepsArray["array"]!.length}  ${Array.length}  ${ListEquality().equals(stepsArray["array"], Array)}");
        if(!const ListEquality().equals(stepsArray["array"], Array)){
          initializeStepsArray(0, Array);
        }
      }catch(e){
        print("error in stepsArray $e");
        initializeStepsArray(0, [2]);
      }
    }




    List<int> nextTransition = tools.findPoint(showcoordX, showcoordY,
        cellPath[pathobj.index].x, cellPath[pathobj.index].y, lineData);

    print("nextTransition $nextTransition");

    List<int>? correctedTransition = isFlying?nextTransition:getCorrectedTransition(angle);

    // Update main coordinates and display coordinates
    showcoordX = nextTransition[0];
    showcoordY = nextTransition[1];
    coordX = correctedTransition[0];
    coordY = correctedTransition[1];

    List<double> newLatLng = tools.localtoglobal(showcoordX, showcoordY, building!.patchData[bid]);
    lat = newLatLng[0];
    lng = newLatLng[1];

    path.insert(pathobj.index, (showcoordY * cols) + showcoordX);
    cellPath.insert(
        pathobj.index,
        Cell(
            (showcoordY * cols) + showcoordX,
            showcoordX,
            showcoordY,
            tools.eightcelltransition,
            lat,
            lng,
            buildingAllApi.outdoorID,
            floor,
            cols,
            imaginedCell: true));
  }

  List<int> getCorrectedTransition(double angle) {
    List<int> transitionValues;

    if ((angle - (theta < 0 ? theta + 360 : theta)).abs() <= 45) {
      transitionValues = tools.eightcelltransition(angle);
    } else {
      transitionValues = tools.eightcelltransition(theta);
    }

    return [transitionValues[0] + coordX, transitionValues[1] + coordY];
  }

  int calculateOffPathDistance() {
    return tools
        .calculateDistance([coordX, coordY], [showcoordX, showcoordY]).toInt();
  }

  double? calculateNextSegmentDistance() {
    if(calculateOffPathDistance() >2){
      List<Cell>? nextSegment = tools.findNextSegment(cellPath, pathobj.index);
      if(nextSegment == null){
        print("calculateNextSegmentDistance nextSegment is null");
        return null;
      }
      double distance = tools.perpendicularDistance(nextSegment[0], nextSegment[1], [coordX, coordY]);
      if(distance == double.infinity || distance > 33){
        print("calculateNextSegmentDistance distance for $coordX,$coordY is $distance for segment ${nextSegment[0].x},${nextSegment[0].y}   <>   ${nextSegment[1].x},${nextSegment[1].y}");
        return null;
      }
      print("calculateNextSegmentDistance distance is $distance");
      return distance;
    }else{
      print("calculateNextSegmentDistance offPathDistance is 0");
      return null;
    }
  }

  bool isInOutdoor() {
    return (bid == buildingAllApi.outdoorID &&
        cellPath[pathobj.index].bid == buildingAllApi.outdoorID) &&
        tools.calculateDistance([showcoordX, showcoordY],
            [cellPath[pathobj.index].x, cellPath[pathobj.index].y]) >=
            3;
  }

  void announceLiftUsage(BuildContext context) {
    onConnection = true;
    createCircle(lat, lng);
    speak(
        convertTolng(
            "Use this ${pathobj.accessiblePath} and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor",
            "",
            0.0,
            context,
            0.0,
            "",
            ""),
        lngCode,
        prevpause: true);
  }

  void handleNearbyLandmarks(BuildContext context) {
    List<int> transitionValue = cellPath[pathobj.index].move(theta);

    pathState.nearbyLandmarks.retainWhere((element) {
      double distance = tools.calculateDistance([
        showcoordX,
        showcoordY
      ], [
        element.doorX ?? element.coordinateX!,
        element.doorY ?? element.coordinateY!
      ]);

      if (element.element!.subType == "room door" && element.properties!.polygonExist != true) {
        if (distance <= 5) {
          _speakPassingBy(context, element.name);
          return false;
        } else if (distance <= 10) {
          _speakDoorAheadOrDirection(context, element, transitionValue);
          return false;
        }
      } else if(element.element!.subType == "Alert" && element.properties != null && element.properties!.alertName != null && element.properties!.alertName!.isNotEmpty){
        if(distance<=6){
          _speakAlert(context, element.properties!.alertName);
          return false;
        }
      } else if (distance <= 6) {
        _speakElementDirection(context, element, transitionValue);
        return false;
      }

      return true;
    });
  }

  void _speakPassingBy(BuildContext context, String? name) {
    if (!UserState.ttsOnlyTurns) {
      speak(
          convertTolng("Passing by $name", name, 0.0, context, 0.0, "", ""),
          lngCode
      );
    }
  }

  void _speakDoorAheadOrDirection(BuildContext context, dynamic element, List<int> transitionValue) {
    double angle = tools.calculateAngle2(
        [showcoordX, showcoordY],
        [showcoordX + transitionValue[0], showcoordY + transitionValue[1]],
        [element.coordinateX!, element.coordinateY!]
    );

    if (!UserState.ttsOnlyTurns) {
      String direction = tools.angleToClocks(angle, context);
      if (direction == "Straight") {
        speak("${element.name} door ahead", lngCode);
      } else {
        speak(
            "${element.name} door is on your ${LocaleData.getProperty5(direction, context)}",
            lngCode
        );
      }
    }
  }

  void _speakAlert(BuildContext context, String? name) {
    if (!UserState.ttsOnlyTurns) {
      speak(
          convertTolng("Alert, $name ahead ", name, 0.0, context, 0.0, "", ""),
          lngCode
      );
    }
  }

  void _speakElementDirection(BuildContext context, dynamic element, List<int> transitionValue) {
    double angle = tools.calculateAngle2(
        [showcoordX, showcoordY],
        [showcoordX + transitionValue[0], showcoordY + transitionValue[1]],
        [element.coordinateX!, element.coordinateY!]
    );

    if (!UserState.ttsOnlyTurns) {
      speak(
          convertTolng(
              "${element.name} is on your ${LocaleData.getProperty5(tools.angleToClocks(angle, context), context)}",
              element.name!,
              0.0,
              context,
              0.0,
              "",
              ""
          ),
          lngCode
      );
    }
  }




  void updateDisplayCoordinates() {
    showcoordX = cellPath[pathobj.index].x;
    showcoordY = cellPath[pathobj.index].y;

    List<double> globalCoords = tools.localtoglobal(showcoordX, showcoordY,
        building!.patchData[cellPath[pathobj.index].bid]);
    lat = globalCoords[0];
    lng = globalCoords[1];
  }

  bool hasChangedBuilding() {
    return cellPath[pathobj.index - 1].bid != cellPath[pathobj.index].bid;
  }

  void handleBuildingTransition(BuildContext context) {
    coordX = showcoordX;
    coordY = showcoordY;
    updateGlobalCoordinates();

    String? previousBuildingName =
    b.Building.buildingData?[cellPath[pathobj.index==0?0:pathobj.index - 1].bid];
    String? nextBuildingName = b.Building.buildingData?[pathobj.destinationBid];

    if (previousBuildingName != null && nextBuildingName != null) {
      if (cellPath[pathobj.index==0?0:pathobj.index - 1].bid == pathobj.sourceBid) {
        speakExitDirection(context, previousBuildingName, nextBuildingName);
      } else if (cellPath[pathobj.index].bid == pathobj.destinationBid) {
        speakEntryDirection(context, nextBuildingName);
      }
    }

    changeBuilding(
        cellPath[pathobj.index==0?0:pathobj.index - 1].bid, cellPath[pathobj.index].bid);
  }

  void updateGlobalCoordinates() {
    List<double> globalCoords = tools.localtoglobal(
        coordX, coordY, building!.patchData[cellPath[pathobj.index].bid]);
    lat = globalCoords[0];
    lng = globalCoords[1];
  }

  void speakExitDirection(
      BuildContext context, String previousBuilding, String nextBuilding) {
    speak(
        convertTolng(
            "Exiting $previousBuilding. Continue along the path towards $nextBuilding.",
            "",
            0.0,
            context,
            0.0,
            nextBuilding,
            previousBuilding),
        lngCode);
  }

  void speakEntryDirection(BuildContext context, String nextBuildingName) {
    if (pathobj.destinationBid == buildingAllApi.outdoorID) {
      speak(
          convertTolng("Continue ahead towards ${pathobj.destinationName}.", "",
              0.0, context, 0.0, "", "",
              destname: pathobj.destinationName),
          lngCode);
    } else {
      speak(
          convertTolng("Entering $nextBuildingName. Continue ahead.", "", 0.0,
              context, 0.0, nextBuildingName, ""),
          lngCode);
    }
  }

  void proceedWithoutNavigation() {
    pathobj.index = pathobj.index + 1;

    List<int> transitionvalue = tools.eightcelltransition(theta);
    coordX = coordX + transitionvalue[0];
    coordY = coordY + transitionvalue[1];
    List<double> values =
    tools.localtoglobal(coordX, coordY, building!.patchData[bid]);
    lat = values[0];
    lng = values[1];
    if (isnavigating && pathobj.path.isNotEmpty && pathobj.numCols![bid]![floor] != 0) {
      showcoordX = path[pathobj.index] % pathobj.numCols![bid]![floor]!;
      showcoordY = path[pathobj.index] ~/ pathobj.numCols![bid]![floor]!;
    } else {
      showcoordX = coordX;
      showcoordY = coordY;
    }
  }

  String convertTolng(
      String msg,
      String? name,
      double agl,
      BuildContext context,
      double a,
      String nextBuildingName,
      String currentBuildingName,
      {String destname = ""}) {
    if (msg ==
        "You have reached $destname. It is ${tools.angleToClocks3(a, context)}") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "आप $destname पर पहुँच गए हैं। वह ${LocaleData.getProperty(tools.angleToClocks3(a, context), context)}";
      }
    } else if (msg ==
        "Use this Lifts and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor") {
      if (lngCode == 'en') {
        return "Use this Lift and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor";
      } else {
        return "इस लिफ़्ट का उपयोग करें और ${tools.numericalToAlphabetical(pathobj.destinationFloor)} मंज़िल पर जाएँ";
      }
    } else if (msg ==
        "Use this Stairs and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor") {
      if (lngCode == 'en') {
        return "Use this Stair and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor";
      } else {
        return "इन सीढ़ियों का उपयोग करें और ${tools.numericalToAlphabetical(pathobj.destinationFloor)} मंज़िल पर जाएँ";
      }
    } else if (name != null && msg == "Passing by $name") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "$name से गुज़रते हुए";
      }
    } else if (name != null &&
        msg ==
            "$name is on your ${(
            tools.angleToClocks(agl, context),
            context
            )}") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "$name आपके ${LocaleData.getProperty5(tools.angleToClocks(agl, context), context)} पर है";
      }
    } else if (nextBuildingName != "" &&
        currentBuildingName != "" &&
        msg ==
            "Exiting $currentBuildingName. Continue along the path towards $nextBuildingName.") {
      if (lngCode == 'en') {
        return msg;
      } else {
        print("entereddddd");
        print(msg);
        return "$currentBuildingName से बाहर निकलते हुए। $nextBuildingName की ओर चलते रहें";
      }
    } else if (nextBuildingName != "" &&
        msg == "Entering $nextBuildingName. Continue ahead.") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "$nextBuildingName में प्रवेश कर रहे हैं। आगे बढ़ते रहें।";
      }
    } else if (destname != "" && msg == "Continue ahead towards $destname") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "$destname की ओर आगे बढ़ते रहें";
      }
    }else{
      return msg;
    }
  }

  Future<void> checkForMerge(BuildContext context) async {
    if(bid == buildingAllApi.outdoorID){
     if(outdoorNextSegmentDistance.length >= 15){
       if (tools.allElementsAreSame(outdoorNextSegmentDistance)) {
         int steps = outdoorNextSegmentDistance.length;
         outdoorNextSegmentDistance.clear();
         List<Cell>? nextSegment = tools.findNextSegment(cellPath, pathobj.index);
         if(nextSegment == null){
           return ;
         }
         await moveToPointOnPath(cellPath.indexOf(nextSegment[0]), context, flying: true);
         // await Future.delayed(Duration(seconds: 2));
        moveToPointOnPathOnPath(context, steps);
       } else {
         outdoorNextSegmentDistance.removeAt(0);
       }
     }
    }
    if (offPathDistance.length >= 3) {
      if (tools.allElementsAreSame(offPathDistance)) {
        offPathDistance.clear();
        coordX = showcoordX;
        coordY = showcoordY;
      } else {
        offPathDistance.removeAt(0);
      }
    }

  }

  Future<void> moveToFloor(int fl) async {
    floor = fl;
    if (pathobj.Cellpath[fl] != null) {
      coordX = pathobj.Cellpath[fl]![0].x;
      coordY = pathobj.Cellpath[fl]![0].y;
      List<double> values = tools.localtoglobal(coordX, coordY, building!.patchData[bid]);
      lat = values[0];
      lng = values[1];
      showcoordX = coordX;
      showcoordY = coordY;
      pathobj.index = path.indexOf(pathobj.Cellpath[fl]![0].node);
      paintMarker(geo.LatLng(lat, lng));
    }
  }

  Future<void> moveToPointOnPath(int index, BuildContext context, {bool onTurn = false, bool flying = false}) async {
    print("moveToPointOnPath called");
    if(!flying){
      if(isLiftCheck()){
        announceLiftUsage(context);
      }else if (onTurn) {
        int? turnIndex = await findTurnPointAround();
        if (turnIndex != null) {
          index = turnIndex;
        }
      }
    }
    if (index > cellPath.length - 1) {
      index = cellPath.length - 9;
    }
    floor = cellPath[index].floor;
    bid = cellPath[index].bid??bid;
    showcoordX = cellPath[index].x;
    showcoordY = cellPath[index].y;
    coordX = showcoordX;
    coordY = showcoordY;
    pathobj.index = index + 1;
    lat = cellPath[index].lat;
    lng = cellPath[index].lng;
    createCircle(lat, lng);
    alignMapToPath([lat, lng], [lat, lng]);
    print("moveToPointOnPath $index");
    Future.delayed(Duration(seconds: 1)).then((onValue){
      autoRecenter();
    });
  }

  Future<void> moveToPointOnPathOnPath(BuildContext context, int steps) async {
    print("moveToPointOnPathOnPath called for $steps steps");
    await move(context, steps: steps, isFlying: true);
    Future.delayed(Duration(seconds: 1)).then((onValue){
      autoRecenter();
    });
  }

  Future<int> moveToNearestPoint() async {
    if (coordX == 0 && coordY == 0) {
      return pathobj.index;
    }

    double minDistance = double.infinity;
    int nearestIndex = pathobj.index;

    for (var cell in cellPath) {
      if (cell.floor == floor && cell.bid == bid) {
        double distance = tools.calculateDistance([coordX, coordY], [cell.x, cell.y]);
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = cellPath.indexOf(cell);
        }
      }
    }

    pathobj.index = nearestIndex;
    return pathobj.index;
  }


  Future<void> moveToNearestTurn(int index) async {
    List<Cell> turnPoints = tools.getCellTurnpoints(cellPath);
    for (int i = index; i < cellPath.length; i++) {
      for (int j = 0; j < turnPoints.length; j++) {
        if (cellPath[i] == turnPoints[j]) {
          if (tools.calculateDistance(
              [cellPath[pathobj.index].x, cellPath[pathobj.index].y],
              [turnPoints[j].x, turnPoints[j].y]) <=
              10) {
            pathobj.index = cellPath.indexOf(turnPoints[j]);
          }
          return;
        }
      }
    }
  }

  Future<int?> findTurnPointAround() async {
    List<Cell> turnPoints = tools.getCellTurnpoints(cellPath);
    double d = 11;
    int? ind;
    for (int j = 0; j < turnPoints.length; j++) {
      double distance = tools.calculateDistance(
          [showcoordX, showcoordY], [turnPoints[j].x, turnPoints[j].y]);
      if (distance < d) {
        d = distance;
        ind = cellPath.indexOf(turnPoints[j]);
      }
    }
    return ind;
  }

  int? changeBuildingIfNear(BuildContext context){
    int distance = 5;
    for(int i = 1; i<=distance; i++){
      if(cellPath[i].bid == cellPath[i-1].bid && cellPath[i].bid == buildingAllApi.outdoorID){
        pathobj.index = i-1;
        handleBuildingTransition(context);
        renderHere();
        return i-1;
      }
    }
    return null;
  }

  Future<void> moveToStartofPath(BuildContext context) async {
    int i = 0;
    if(pathobj.sourceBid != pathobj.destinationBid){
      int? index = changeBuildingIfNear(context);
      print("moveToStartofPath $index [${cellPath[pathobj.index].x},${cellPath[pathobj.index].y}] <> ${cellPath[pathobj.index].bid} <> ${cellPath[pathobj.index].floor}");
      if(index != null){
        i = index;
      }else{
        i = await moveToNearestPoint();
        await moveToNearestTurn(i);
      }
    }else if(isLiftCheck()){
      i = 0;
      announceLiftUsage(context);
    }else{
      i = await moveToNearestPoint();
      await moveToNearestTurn(i);
    }
    floor = pathobj.sourceFloor;
    bid = cellPath[pathobj.index].bid??bid;
    showcoordX = cellPath[pathobj.index].x;
    showcoordY = cellPath[pathobj.index].y;
    coordX = showcoordX;
    coordY = showcoordY;
    List<double> values = tools.localtoglobal(showcoordX, showcoordY, building!.patchData[bid]);
    lat = values[0];
    lng = values[1];
  }

  Future<void> reset() async {
    showcoordX = coordX;
    showcoordY = coordY;
    isnavigating = false;
    pathobj = pathState();
    path = [];
  }
}