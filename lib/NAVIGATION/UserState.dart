import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;
import 'package:iwaymaps/NAVIGATION/pathState.dart';
import 'package:iwaymaps/NAVIGATION/path_snapper.dart';
import 'package:ml_linalg/matrix.dart';

import '../IWAYPLUS/API/buildingAllApi.dart';
import '../IWAYPLUS/Elements/locales.dart';
import 'Cell.dart';
import 'GPSService.dart';
import 'GPSStreamHandler.dart';
import 'MotionModel.dart';
import 'Network/NetworkManager.dart';
import 'buildingState.dart' as b;
import 'navigationTools.dart';


class UserState {
  NetworkManager networkManager = NetworkManager();
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
  List<Cell> Cellpath = [];
  bool initialallyLocalised = false;
  String Bid;
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
  static Function recenter=(){};
  static Function speak = (String lngcode) {};
  static Function AlignMapToPath = () {};
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
        this.Bid = "",
        this.showcoordX = 0,
        this.showcoordY = 0,
        this.isnavigating = false,
        this.coordXf = 0.0,
        this.coordYf = 0.0});

  Future<void> move(context) async {
    List<Cell> turnPoints = [];
    try {
      turnPoints =
          tools.getCellTurnpoints(Cellpath);
    }catch(_){}
    moveOneStep(context);
    print("stepSize $stepSize");
    for (int i = 1; i < stepSize.toInt(); i++) {
      bool movementAllowed = true;

      if (!MotionModel.isValidStep(
          this, cols, rows, nonWalkable[Bid]![floor]!, reroute)) {

        movementAllowed = false;
      }

      if (isnavigating) {
        int prevX = Cellpath[pathobj.index - 1].x;
        int prevY = Cellpath[pathobj.index - 1].y;
        int nextX = Cellpath[pathobj.index + 1].x;
        int nextY = Cellpath[pathobj.index + 1].y;
        //non Walkable Check

        //destination check
        if (Cellpath.length - pathobj.index < 6) {

          movementAllowed = false;
        }

        //turn check
        try{
          if(Bid == buildingAllApi.outdoorID){
            for(var c in turnPoints){
              if(c.Bid == Bid && c.x == showcoordX && c.y == showcoordY){
                movementAllowed = false;
              }
            }
          }else{
            if (tools
                .isTurn([prevX, prevY], [showcoordX, showcoordY], [nextX, nextY])) {

              movementAllowed = false;
            }
          }}catch(_){}


        //lift check

        if (pathobj.connections[Bid]?[floor] ==
            showcoordY * cols + showcoordX) {

          movementAllowed = false;
        }
      }

      if (movementAllowed) {
        moveOneStep(context);
      } else if (!movementAllowed) {
        return;
      }
    }

    if (stepSize.toInt() != stepSize) {}
  }
  bool isMovementAllowed(List<Cell> turnPoints, BuildContext context) {
    bool movementAllowed = MotionModel.isValidStep(this, cols, rows, nonWalkable[Bid]![floor]!, reroute);
    if (!movementAllowed || !isnavigating) return movementAllowed;
    int prevX = Cellpath[pathobj.index - 1].x;
    int prevY = Cellpath[pathobj.index - 1].y;
    int nextX = Cellpath[pathobj.index + 1].x;
    int nextY = Cellpath[pathobj.index + 1].y;
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
    if (Bid == buildingAllApi.outdoorID) {
      for (var c in turnPoints) {
        if (c.Bid == Bid && c.x == showcoordX && c.y == showcoordY) {
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
    if (pathobj.connections[Bid]?[floor] == showcoordY * cols + showcoordX) {
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
      print("userBid is $Bid ${Bid == buildingAllApi.outdoorID} ${buildingAllApi.outdoorID}");
      if(isnavigating && Bid == buildingAllApi.outdoorID){
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
          var kalmanCell = snapper.snapToPathKalman(lastPosition!,X_pred[0][0],X_pred[1][0], pathobj.index, Cellpath);
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
              List<Cell>? points = tools.findSegmentContainingPoint(Cellpath, pathobj.index);
              List<Cell> allPointsofSegment = tools.findAllPointsOfSegment(Cellpath, points!);
              allPointsofSegment.add(cell);
              List<Cell> sorted = tools.sortCollinearPoints(allPointsofSegment);
              int index = sorted.indexWhere((node)=>node.x == cell.x && node.y == cell.y);
              index = index + Cellpath.indexWhere((node)=>node.x == points[0].x && node.y == points[0].y);
              path.insert(index, (cell.y*cell.numCols)+cell.x);
              Cellpath.insert(index, cell);
              moveToPointOnPath(index);
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

  Future<void> moveOneStep(context) async {
    userLogData();

    if (isnavigating) {
      checkForMerge();
      pathobj.index = pathobj.index + 1;
      if((Bid == buildingAllApi.outdoorID && Cellpath[pathobj.index].Bid == buildingAllApi.outdoorID) && tools.calculateDistance([showcoordX, showcoordY], [Cellpath[pathobj.index].x,Cellpath[pathobj.index].y])>=3){
        //destination check
        List<Cell> turnPoints =
        tools.getCellTurnpoints(Cellpath);
        print("angleeeeeeeee ${(tools.calculateDistance([showcoordX, showcoordY],
            [pathobj.destinationX, pathobj.destinationY]) <
            6)}");
        bool isSameFloorAndBuilding = floor == pathobj.destinationFloor &&
            Bid == pathobj.destinationBid;

        bool isNearLastTurnPoint = tools.calculateDistance(
            [turnPoints.last.x, turnPoints.last.y],
            [pathobj.destinationX, pathobj.destinationY]) < 10;

        bool isAtLastTurnPoint = showcoordX == turnPoints.last.x &&
            showcoordY == turnPoints.last.y;

        bool isNearDestination = tools.calculateDistance(
            [showcoordX, showcoordY],
            [pathobj.destinationX, pathobj.destinationY]) < 6;

        if (isSameFloorAndBuilding &&
            ((isNearLastTurnPoint && isAtLastTurnPoint) || isNearDestination)) {
          createCircle(lat, lng);
          closeNavigation();
        }


        Cell point = tools.findingprevpoint(Cellpath,pathobj.index);
        double angle = tools.calculateBearing([lat,lng], [Cellpath[pathobj.index].lat, Cellpath[pathobj.index].lng]);
        Map<String, double> data = tools.findslopeandintercept(point.x, point.y, Cellpath[pathobj.index].x, Cellpath[pathobj.index].y);
        List<int> transitionvalue = tools.findPoint(showcoordX,showcoordY, Cellpath[pathobj.index].x, Cellpath[pathobj.index].y, data);
        List<int>? trans ;
        if(angle-(theta<0?theta+360 : theta) <= 45  && angle-(theta<0?theta+360 : theta) >= -45){
          List<int> tv = tools.eightcelltransition(angle);
          trans = [tv[0]+coordX , tv[1]+coordY];
        }else{
          List<int> tv = tools.eightcelltransition(theta);
          trans = [tv[0]+coordX , tv[1]+coordY];
        }
        showcoordX = transitionvalue[0];
        showcoordY = transitionvalue[1];
        print("himanshu check $trans");
        coordX = trans[0];
        coordY = trans[1];
        List<double> values = tools.moveLatLng([lat,lng], angle, 1);
        lat = values[0];
        lng = values[1];
        path.insert(pathobj.index, (showcoordY*cols)+showcoordX);
        Cellpath.insert(pathobj.index, Cell((showcoordY*cols)+showcoordX, showcoordX, showcoordY, tools.eightcelltransition, lat, lng, buildingAllApi.outdoorID, floor, cols,imaginedCell: true));
        int d = tools
            .calculateDistance([coordX, coordY], [showcoordX, showcoordY]).toInt();
        if (d > 0) {
          offPathDistance.add(d);
        }
        return;
      }

      if(Cellpath[pathobj.index].Bid != null && Bid != Cellpath[pathobj.index].Bid) {
        Bid = Cellpath[pathobj.index].Bid!;
        cols = building!.floorDimenssion[Bid]![floor]![0];
        rows = building!.floorDimenssion[Bid]![floor]![1];
      }
      List<int> p = tools.analyzeCell(Cellpath, Cellpath[pathobj.index]);
      List<int> transitionvalue = Cellpath[pathobj.index]
          .move(this.theta, currPointer: p[1], totalCells: p[0]);
      coordX = coordX+transitionvalue[0];
      coordY = coordY+transitionvalue[1];
      List<double> values =
      tools.localtoglobal(showcoordX, showcoordY, building!.patchData[Cellpath[pathobj.index].Bid]);
      lat = values[0];
      lng = values[1];

      // if(coordXf == 0.0){
      //   coordXf = transitionvalue[0]*(stepSize-stepSize.toInt());
      // }else{
      //   coordX = coordX + transitionvalue[0];
      //   coordXf = 0.0;
      // }
      //
      //
      // if(coordYf == 0.0){
      //   coordYf = transitionvalue[1]*(stepSize-stepSize.toInt());
      // }else{
      //   coordY = coordY + transitionvalue[1];
      //   coordYf = 0.0;
      // }
      if (this.isnavigating &&
          pathobj.Cellpath.isNotEmpty &&
          pathobj.numCols != 0) {
        showcoordX = Cellpath[pathobj.index].x;
        showcoordY = Cellpath[pathobj.index].y;
        List<double> values =
        tools.localtoglobal(showcoordX, showcoordY, building!.patchData[Cellpath[pathobj.index].Bid]);
        lat = values[0];
        lng = values[1];
        if(Cellpath[pathobj.index-1].Bid != Cellpath[pathobj.index].Bid){

          coordX = showcoordX;
          coordY = showcoordY;
          values =
              tools.localtoglobal(coordX, coordY, building!.patchData[Cellpath[pathobj.index].Bid]);
          lat = values[0];
          lng = values[1];
          String? previousBuildingName = b.Building.buildingData?[Cellpath[pathobj.index - 1].Bid];
          String? nextBuildingName = b.Building.buildingData?[pathobj.destinationBid];

          if (previousBuildingName != null && nextBuildingName != null) {
            if(Cellpath[pathobj.index - 1].Bid == pathobj.sourceBid){
              speak(convertTolng("Exiting $previousBuildingName. Continue along the path towards $nextBuildingName.", "", 0.0, context, 0.0,nextBuildingName,previousBuildingName),lngCode);
            }else if(Cellpath[pathobj.index].Bid == pathobj.destinationBid){

              if(pathobj.destinationBid == buildingAllApi.outdoorID){
                speak(convertTolng("Continue ahead towards ${pathobj.destinationName}.", "", 0.0, context, 0.0, "", "",destname:pathobj.destinationName ) ,lngCode);
              }else{
                speak(convertTolng("Entering ${nextBuildingName}. Continue ahead.", "", 0.0, context, 0.0,nextBuildingName,""),lngCode);
              }
            }

          } changeBuilding(Cellpath[pathobj.index-1].Bid, Cellpath[pathobj.index].Bid);
        }
      } else {
        showcoordX = coordX;
        showcoordY = coordY;
        values =
            tools.localtoglobal(coordX, coordY, building!.patchData[Cellpath[pathobj.index].Bid]);
        lat = values[0];
        lng = values[1];
      }


      int prevX = Cellpath[pathobj.index - 1].x;
      int prevY = Cellpath[pathobj.index - 1].y;
      int nextX = Cellpath[pathobj.index + 1].x;
      int nextY = Cellpath[pathobj.index + 1].y;
      //non Walkable Check

      //destination check
      List<Cell> turnPoints =
      tools.getCellTurnpoints(Cellpath);
      print("angleeeeeeeee ${(tools.calculateDistance([showcoordX, showcoordY],
          [pathobj.destinationX, pathobj.destinationY]) <
          6)}");
      bool isSameFloorAndBuilding = floor == pathobj.destinationFloor &&
          Bid == pathobj.destinationBid;

      bool isNearLastTurnPoint = tools.calculateDistance(
          [turnPoints.last.x, turnPoints.last.y],
          [pathobj.destinationX, pathobj.destinationY]) < 10;

      bool isAtLastTurnPoint = showcoordX == turnPoints.last.x &&
          showcoordY == turnPoints.last.y;

      bool isNearDestination = tools.calculateDistance(
          [showcoordX, showcoordY],
          [pathobj.destinationX, pathobj.destinationY]) < 6;

      if (isSameFloorAndBuilding &&
          ((isNearLastTurnPoint && isAtLastTurnPoint) || isNearDestination)) {
        createCircle(lat, lng);
        closeNavigation();
      }
      // if (floor == pathobj.destinationFloor &&
      //     Bid == pathobj.destinationBid &&
      //     showcoordX == turnPoints[turnPoints.length - 1].x &&
      //     showcoordY == turnPoints[turnPoints.length - 1].y &&
      //     tools.calculateDistance([showcoordX, showcoordY],
      //             [pathobj.destinationX, pathobj.destinationY]) <
      //         6) {
      //
      // }

      //turn check
      if (tools
          .isTurn([prevX, prevY], [showcoordX, showcoordY], [nextX, nextY])) {

        UserState.isTurn=true;
        print("qpalzm turn detected ${[prevX, prevY]}, ${[
          showcoordX,
          showcoordY
        ]}, ${[nextX, nextY]}");
        if(Cellpath[pathobj.index+1].Bid == Cellpath[pathobj.index].Bid){
          print("value at turnsss");
          print([lat, lng]);
          print(tools.localtoglobal(nextX, nextY, building!.patchData[Bid]));
          AlignMapToPath([lat, lng],
              tools.localtoglobal(nextX, nextY, building!.patchData[Bid]));
        }
      }

      //lift check
      List<int> liftCoordinates = [(pathobj.connections[Bid]?[pathobj.sourceFloor]??1)%cols, (pathobj.connections[Bid]?[pathobj.sourceFloor]??1)~/cols];
      print("liftCoordinates $liftCoordinates");

      if(floor != pathobj.destinationFloor && pathobj.connections[Bid]?[floor] == showcoordY * cols + showcoordX){
        // UserState.reachedLift=true;
        onConnection = true;
        createCircle(lat, lng);


        speak(
            convertTolng(
                "Use this ${pathobj.accessiblePath} and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor",
                "",
                0.0,
                context,
                0.0,"",""),
            lngCode,
            prevpause: true);
      }

      if (0 < pathobj.index &&
          pathobj.index < Cellpath.length - 1 &&
          pathState.nearbyLandmarks.isNotEmpty &&
          !tools.isCellTurn(Cellpath[pathobj.index - 1],
              Cellpath[pathobj.index], Cellpath[pathobj.index + 1])) {
        pathState.nearbyLandmarks.retainWhere((element) {
          if ((element.element!.subType == "room door" ||
              element.element!.subType == "Entrance Only") &&
              element.properties!.polygonExist != true) {
            print(element.name);
            if (tools.calculateDistance([
              showcoordX,
              showcoordY
            ], [
              element.doorX ?? element.coordinateX!,
              element.doorY ?? element.coordinateY!
            ]) <=
                3) {
              if(!UserState.ttsOnlyTurns){
                speak(
                    convertTolng("Passing by ${element.name}", element.name, 0.0,
                        context, 0.0,"",""),
                    lngCode);
              }

              return false; // Remove this element
            }
          } else {
            if (tools.calculateDistance([
              showcoordX,
              showcoordY
            ], [
              element.doorX ?? element.coordinateX!,
              element.doorY ?? element.coordinateY!
            ]) <=
                6) {
              double agl = tools.calculateAngle2([
                showcoordX,
                showcoordY
              ], [
                showcoordX + transitionvalue[0],
                showcoordY + transitionvalue[1]
              ], [
                element.coordinateX!,
                element.coordinateY!
              ]);
              if(!UserState.ttsOnlyTurns){
                speak(
                    convertTolng(
                        "${element.name} is on your ${tools.angleToClocks(agl, context)}",
                        element.name!,
                        agl,
                        context,
                        0.0,"",""),
                    lngCode);
              }

              return false; // Remove this element
            }
          }
          return true; // Keep this element
        });
      }
    } else {
      pathobj.index = pathobj.index + 1;

      List<int> transitionvalue = tools.eightcelltransition(this.theta);
      coordX = coordX + transitionvalue[0];
      coordY = coordY + transitionvalue[1];
      List<double> values =
      tools.localtoglobal(coordX, coordY, building!.patchData[Bid]);
      lat = values[0];
      lng = values[1];
      if (this.isnavigating &&
          pathobj.path.isNotEmpty &&
          pathobj.numCols != 0) {
        showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
        showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
      } else {
        showcoordX = coordX;
        showcoordY = coordY;
      }
    }

    int d = tools
        .calculateDistance([coordX, coordY], [showcoordX, showcoordY]).toInt();
    if (d > 0) {
      offPathDistance.add(d);
    }
  }
  
  void userLogData() {
    networkManager.ws.updateUserPosition(x: coordX, y: coordY, floor: floor);
  }

  bool shouldTerminateNavigation() {
    List<Cell> turnPoints = tools.getCellTurnpoints(Cellpath);
    bool isSameFloorAndBuilding = Bid == buildingAllApi.outdoorID || (floor == pathobj.destinationFloor && Bid == pathobj.destinationBid);


    bool isNearLastTurnPoint = tools.calculateDistance(
        [turnPoints.last.x, turnPoints.last.y],
        [pathobj.destinationX, pathobj.destinationY]) <
        10;

    bool isAtLastTurnPoint =
        showcoordX == turnPoints.last.x && showcoordY == turnPoints.last.y;

    // print("destination is ${tools.calculateAerialDist(lat,lng, pathobj.destinationLat, pathobj.destinationLng)} m away");
    bool isNearDestination = tools.calculateAerialDist(
        lat, lng, pathobj.destinationLat, pathobj.destinationLng) <
        ((Bid == buildingAllApi.outdoorID) ? 5 : 2);

    return (isSameFloorAndBuilding && ((isNearLastTurnPoint && isAtLastTurnPoint) || isNearDestination));
  }

  void initializeStepsArray(int index, List<int> array){
    // print("array changed to $array");
    stepsArray = {"index":[index], "array":array};
  }

  void incrementSteps(){
    // print("index was ${stepsArray["index"]}");
    int i = stepsArray["index"]!.first;
    stepsArray["index"] = [i+1];
    if(stepsArray["index"]!.first == stepsArray["array"]!.length){
      stepsArray["index"]!.first = 0;
    }
    stepSize = stepsArray["array"]![stepsArray["index"]!.first].toDouble();
    // print("changed step size to $stepSize on index ${stepsArray["index"]} and should have been ${stepsArray["array"]![stepsArray["index"]!.first].toDouble()}");
  }

  void updateCoordinatesAndPath(Cell previousPoint, double angle, {bool isFlying = false}) {

    Map<String, double> lineData = tools.findslopeandintercept(previousPoint.x,
        previousPoint.y, Cellpath[pathobj.index].x, Cellpath[pathobj.index].y);

    if(!isFlying){
      try{
        int stepsRequired = tools.stepsToReachTarget(previousPoint.x, previousPoint.y, Cellpath[pathobj.index].x, Cellpath[pathobj.index].y, lineData);
        double d = tools.calculateDistance([previousPoint.x, previousPoint.y], [Cellpath[pathobj.index].x, Cellpath[pathobj.index].y]);
        // print("stepsRequired $stepsRequired d $d");
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
        Cellpath[pathobj.index].x, Cellpath[pathobj.index].y, lineData);

    // print("nextTransition $nextTransition");

    List<int>? correctedTransition = isFlying?nextTransition:getCorrectedTransition(angle);

    // Update main coordinates and display coordinates
    showcoordX = nextTransition[0];
    showcoordY = nextTransition[1];
    coordX = correctedTransition[0];
    coordY = correctedTransition[1];

    List<double> newLatLng = tools.localtoglobal(showcoordX, showcoordY, building!.patchData[Bid]);
    lat = newLatLng[0];
    lng = newLatLng[1];

    path.insert(pathobj.index, (showcoordY * cols) + showcoordX);
    Cellpath.insert(
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
      List<Cell>? nextSegment = tools.findNextSegment(Cellpath, pathobj.index);
      if(nextSegment == null){
        // print("calculateNextSegmentDistance nextSegment is null");
        return null;
      }
      double distance = tools.perpendicularDistance(nextSegment[0], nextSegment[1], [coordX, coordY]);
      if(distance == double.infinity || distance > 33){
        // print("calculateNextSegmentDistance distance for $coordX,$coordY is $distance for segment ${nextSegment[0].x},${nextSegment[0].y}   <>   ${nextSegment[1].x},${nextSegment[1].y}");
        return null;
      }
      // print("calculateNextSegmentDistance distance is $distance");
      return distance;
    }else{
      // print("calculateNextSegmentDistance offPathDistance is 0");
      return null;
    }
  }

  bool isInOutdoor() {
    return (Bid == buildingAllApi.outdoorID &&
        Cellpath[pathobj.index].Bid == buildingAllApi.outdoorID) &&
        tools.calculateDistance([showcoordX, showcoordY],
            [Cellpath[pathobj.index].x, Cellpath[pathobj.index].y]) >=
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
    List<int> transitionValue = Cellpath[pathobj.index].move(theta);

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
    showcoordX = Cellpath[pathobj.index].x;
    showcoordY = Cellpath[pathobj.index].y;

    List<double> globalCoords = tools.localtoglobal(showcoordX, showcoordY,
        building!.patchData[Cellpath[pathobj.index].Bid]);
    lat = globalCoords[0];
    lng = globalCoords[1];
  }

  bool hasChangedBuilding() {
    return Cellpath[pathobj.index - 1].Bid != Cellpath[pathobj.index].Bid;
  }

  void handleBuildingTransition(BuildContext context) {
    coordX = showcoordX;
    coordY = showcoordY;
    updateGlobalCoordinates();

    String? previousBuildingName =
    b.Building.buildingData?[Cellpath[pathobj.index==0?0:pathobj.index - 1].Bid];
    String? nextBuildingName = b.Building.buildingData?[pathobj.destinationBid];

    if (previousBuildingName != null && nextBuildingName != null) {
      if (Cellpath[pathobj.index==0?0:pathobj.index - 1].Bid == pathobj.sourceBid) {
        speakExitDirection(context, previousBuildingName, nextBuildingName);
      } else if (Cellpath[pathobj.index].Bid == pathobj.destinationBid) {
        speakEntryDirection(context, nextBuildingName);
      }
    }

    changeBuilding(
        Cellpath[pathobj.index==0?0:pathobj.index - 1].Bid, Cellpath[pathobj.index].Bid);
  }

  void updateGlobalCoordinates() {
    List<double> globalCoords = tools.localtoglobal(
        coordX, coordY, building!.patchData[Cellpath[pathobj.index].Bid]);
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
    tools.localtoglobal(coordX, coordY, building!.patchData[Bid]);
    lat = values[0];
    lng = values[1];
    if (isnavigating && pathobj.path.isNotEmpty && pathobj.numCols![Bid]![floor] != 0) {
      showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
      showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
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
    } else if (name != null && msg == "${name} is on your ${tools.angleToClocks(agl, context)}") {
      if (lngCode == 'en') {
        return msg;
      } else {
        return "${name} आपके ${LocaleData.getProperty5(tools.angleToClocks(agl, context), context)} ओर है";
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
    }else if(msg=="Passing by ${name}")
      {
        if(lngCode=='en'){
          return msg;
        }else{
          return "${name} से गुजरते हुए";
        }
      }

    else{
      return msg;
    }
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
      List<double> values = tools.localtoglobal(coordX, coordY, building!.patchData[Bid]);
      lat = values[0];
      lng = values[1];
      showcoordX = coordX;
      showcoordY = coordY;
      pathobj.index = path.indexOf(pathobj.Cellpath[fl]![0].node);
      paintMarker(geo.LatLng(lat, lng));
    }
  }

  Future<void> moveToPointOnPath(int index, {bool onTurn = false}) async {
    if(onTurn){
      int? turnIndex = await findTurnPointAround();
      if (turnIndex != null) {
        index = turnIndex;
      }
    }
    if (index > path.length - 1) {
      index = path.length - 9;
    }
    showcoordX = path[index] % pathobj.numCols![Bid]![floor]!;
    showcoordY = path[index] ~/ pathobj.numCols![Bid]![floor]!;
    coordX = showcoordX;
    coordY = showcoordY;
    pathobj.index = index + 1;
    List<double> values =
    tools.localtoglobal(coordX, coordY, building!.patchData[Bid]);
    lat = values[0];
    lng = values[1];
    createCircle(values[0], values[1]);
    AlignMapToPath([values[0],values[1]],values);

    Future.delayed(Duration(milliseconds:1500)).then((onValue){
      recenter();
    });
  }


  Future<int> moveToNearestPoint() async {
    if (coordX == 0 && coordY == 0) {
      return pathobj.index;
    }

    double minDistance = double.infinity;
    int nearestIndex = pathobj.index;

    for (var cell in Cellpath) {
      if (cell.floor == floor && cell.Bid == Bid) {
        double distance = tools.calculateDistance([coordX, coordY], [cell.x, cell.y]);
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = Cellpath.indexOf(cell);
        }
      }
    }

    pathobj.index = nearestIndex;
    return pathobj.index;
  }


  Future<void> moveToNearestTurn(int index) async {
    List<Cell> turnPoints = tools.getCellTurnpoints(Cellpath);
    for (int i = index; i < Cellpath.length; i++) {
      for (int j = 0; j < turnPoints.length; j++) {
        if (Cellpath[i] == turnPoints[j]) {
          if (tools.calculateDistance(
              [Cellpath[pathobj.index].x, Cellpath[pathobj.index].y],
              [turnPoints[j].x, turnPoints[j].y]) <=
              10) {
            pathobj.index = Cellpath.indexOf(turnPoints[j]);
          }
          return;
        }
      }
    }
  }

  Future<int?> findTurnPointAround() async {
    List<Cell> turnPoints = tools.getCellTurnpoints(Cellpath);
    double d = 11;
    int? ind;
    for (int j = 0; j < turnPoints.length; j++) {
      double distance = tools.calculateDistance(
          [showcoordX, showcoordY], [turnPoints[j].x, turnPoints[j].y]);
      if (distance < d) {
        d = distance;
        ind = Cellpath.indexOf(turnPoints[j]);
      }
    }
    return ind;
  }

  int? changeBuildingIfNear(BuildContext context){
    int distance = 5;
    for(int i = 1; i<=distance; i++){
      if(Cellpath[i].Bid == Cellpath[i-1].Bid && Cellpath[i].Bid == buildingAllApi.outdoorID){
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
      print("moveToStartofPath $index [${Cellpath[pathobj.index].x},${Cellpath[pathobj.index].y}] <> ${Cellpath[pathobj.index].Bid} <> ${Cellpath[pathobj.index].floor}");
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
    Bid = Cellpath[pathobj.index].Bid??Bid;
    showcoordX = Cellpath[pathobj.index].x;
    showcoordY = Cellpath[pathobj.index].y;
    coordX = showcoordX;
    coordY = showcoordY;
    List<double> values = tools.localtoglobal(showcoordX, showcoordY, building!.patchData[Bid]);
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
  Map<String, dynamic> toJson() => {
    'floor': floor,
    'coordX': coordX,
    'coordY': coordY,
    'coordXf': coordXf,
    'coordYf': coordYf,
    'lat': lat,
    'lng': lng,
    'theta': theta,
    'key': key,
    'locationName': locationName,
    'isnavigating': isnavigating,
    'showcoordX': showcoordX,
    'showcoordY': showcoordY,
    'initialallyLocalised': initialallyLocalised,
    'Bid': Bid,
    'path': path,
    'offPathDistance': offPathDistance,
    'outdoorNextSegmentDistance': outdoorNextSegmentDistance,
    'onConnection': onConnection,
    'temporaryExit': temporaryExit,
    'stepsArray': stepsArray,
    // Do NOT include functions or complex custom objects unless they have their own toJson()
  };


}