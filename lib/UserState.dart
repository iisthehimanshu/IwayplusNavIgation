import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/MotionModel.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:iwaymaps/websocket/UserLog.dart';
import 'buildingState.dart' as b;

import 'Cell.dart';
import 'Elements/locales.dart';
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
  bool onConnection = false;
  bool temporaryExit = false;
  static double geoLat = 0.0;
  static double geoLng = 0.0;
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
  static Map<String, Map<int, List<int>>> nonWalkable = {};
  static Function reroute = () {};
  static Function closeNavigation = () {};
  static Function speak = (String lngcode) {};
  static Function alignMapToPath = () {};
  static Function changeBuilding = () {};
  static Function startOnPath = () {};
  static Function paintMarker = (geo.LatLng location) {};
  static Function createCircle = (double lat, double lng) {};

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

  Future<void> move(BuildContext context) async {
    List<Cell> turnPoints = [];
    try {
      turnPoints = tools.getCellTurnpoints(cellPath);
    } catch (_) {}

    moveOneStep(context, turnPoints);

    for (int i = 1; i < stepSize.toInt(); i++) {
      print("moveal ${isMovementAllowed(turnPoints)}");
      if (!isMovementAllowed(turnPoints)) {
        return;
      }
      moveOneStep(context, turnPoints);
    }
  }

  bool isMovementAllowed(List<Cell> turnPoints) {
    bool movementAllowed = MotionModel.isValidStep(
        this, cols, rows, nonWalkable[bid]![floor]!, reroute);

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

  Future<void> moveOneStep(context, List<Cell> turnPoints) async {
    userLogData();

    if (isnavigating) {
      checkForMerge();
      pathobj.index = pathobj.index + 1;

      if (isInOutdoor()) {
        //destination check
        if (shouldTerminateNavigation()) {
          createCircle(lat, lng);
          closeNavigation();
          return;
        }

        Cell previousPoint = tools.findingprevpoint(cellPath, pathobj.index);
        double angleToNextCell = tools.calculateBearing([lat, lng],
            [cellPath[pathobj.index].lat, cellPath[pathobj.index].lng]);

        updateCoordinatesAndPath(previousPoint, angleToNextCell);

        if (calculateOffPathDistance() > 0) {
          offPathDistance.add(calculateOffPathDistance());
        }
        return;
      }

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
    bool isSameFloorAndBuilding =
        floor == pathobj.destinationFloor && bid == pathobj.destinationBid;

    bool isNearLastTurnPoint = tools.calculateDistance(
            [turnPoints.last.x, turnPoints.last.y],
            [pathobj.destinationX, pathobj.destinationY]) <
        10;

    bool isAtLastTurnPoint =
        showcoordX == turnPoints.last.x && showcoordY == turnPoints.last.y;

    bool isNearDestination = tools.calculateDistance([showcoordX, showcoordY],
            [pathobj.destinationX, pathobj.destinationY]) <
        6;

    return (isSameFloorAndBuilding &&
        ((isNearLastTurnPoint && isAtLastTurnPoint) || isNearDestination));
  }

  void updateCoordinatesAndPath(Cell previousPoint, double angle) {
    Map<String, double> lineData = tools.findslopeandintercept(previousPoint.x,
        previousPoint.y, cellPath[pathobj.index].x, cellPath[pathobj.index].y);

    List<int> nextTransition = tools.findpoint(showcoordX, showcoordY,
        cellPath[pathobj.index].x, cellPath[pathobj.index].y, lineData);

    List<int>? correctedTransition = getCorrectedTransition(angle);

    // Update main coordinates and display coordinates
    showcoordX = nextTransition[0];
    showcoordY = nextTransition[1];
    coordX = correctedTransition[0];
    coordY = correctedTransition[1];

    List<double> newLatLng = tools.moveLatLng([lat, lng], angle, 1);
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
    List<int> transitionvalue = cellPath[pathobj.index].move(theta);
    pathState.nearbyLandmarks.retainWhere((element) {
      if (element.element!.subType == "room door" &&
          element.properties!.polygonExist != true) {
        if (tools.calculateDistance([
              showcoordX,
              showcoordY
            ], [
              element.doorX ?? element.coordinateX!,
              element.doorY ?? element.coordinateY!
            ]) <=
            3) {
          if (!UserState.ttsOnlyTurns) {
            speak(
                convertTolng("Passing by ${element.name}", element.name, 0.0,
                    context, 0.0, "", ""),
                lngCode);
          }
          return false;
        }
      } else if (tools.calculateDistance([
            showcoordX,
            showcoordY
          ], [
            element.doorX ?? element.coordinateX!,
            element.doorY ?? element.coordinateY!
          ]) <=
          6) {
        double angle = tools.calculateAngle2(
            [showcoordX, showcoordY],
            [showcoordX + transitionvalue[0], showcoordY + transitionvalue[1]],
            [element.coordinateX!, element.coordinateY!]);
        if (!UserState.ttsOnlyTurns) {
          speak(
              convertTolng(
                  "${element.name} is on your ${LocaleData.getProperty5(tools.angleToClocks(angle, context), context)}",
                  element.name!,
                  0.0,
                  context,
                  0.0,
                  "",
                  ""),
              lngCode);
        }
        return false;
      }
      return true;
    });
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
        b.Building.buildingData?[cellPath[pathobj.index - 1].bid];
    String? nextBuildingName = b.Building.buildingData?[pathobj.destinationBid];

    if (previousBuildingName != null && nextBuildingName != null) {
      if (cellPath[pathobj.index - 1].bid == pathobj.sourceBid) {
        speakExitDirection(context, previousBuildingName, nextBuildingName);
      } else if (cellPath[pathobj.index].bid == pathobj.destinationBid) {
        speakEntryDirection(context, nextBuildingName);
      }
    }

    changeBuilding(
        cellPath[pathobj.index - 1].bid, cellPath[pathobj.index].bid);
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
    }
    return "";
  }

  Future<void> checkForMerge() async {
    if (offPathDistance.length == 3) {
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

  Future<void> moveToPointOnPath(int index, {bool onTurn = false}) async {
    if (onTurn) {
      int? turnIndex = await findTurnPointAround();
      if (turnIndex != null) {
        index = turnIndex;
      }
    }
    if (index > path.length - 1) {
      index = path.length - 9;
    }
    showcoordX = path[index] % pathobj.numCols![bid]![floor]!;
    showcoordY = path[index] ~/ pathobj.numCols![bid]![floor]!;
    coordX = showcoordX;
    coordY = showcoordY;
    pathobj.index = index + 1;
    List<double> values =
        tools.localtoglobal(coordX, coordY, building!.patchData[bid]);
    lat = values[0];
    lng = values[1];
    createCircle(values[0], values[1]);
    alignMapToPath([values[0], values[1]], values);
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

  Future<void> moveToStartofPath() async {
    int i = await moveToNearestPoint();
    await moveToNearestTurn(i);
    floor = pathobj.sourceFloor;
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
