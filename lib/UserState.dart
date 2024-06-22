import 'package:geodesy/geodesy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/MotionModel.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:iwaymaps/websocket/UserLog.dart';

import 'Cell.dart';
import 'navigationTools.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:iwaymaps/websocket/UserLog.dart';


class UserState{
  int floor;
  int coordX ;
  double coordXf;
  int coordY ;
  double coordYf;
  double lat;
  double lng;
  String key;
  double theta;
  String? locationName;
  bool isnavigating;
  int showcoordX;
  int showcoordY;
  pathState pathobj = pathState();
  List<int> path = [];
  List<Cell> Cellpath = [];
  bool initialallyLocalised = false;
  String Bid ;
  List<int> offPathDistance = [];
  static int xdiff = 0;
  static int ydiff = 0;
  static bool isRelocalizeAroundLift=false;
  static int UserHeight  = 195;
  static double stepSize = 2;


  static int cols = 0;
  static int rows = 0;
  static Map<int, List<int>> nonWalkable = Map();
  static Function reroute = (){};
  static Function closeNavigation = (){};
  static Function speak = (){};
  static Function AlignMapToPath = (){};
  static Function startOnPath = (){};
  static Function paintMarker = (geo.LatLng Location){};

  UserState({required this.floor, required this.coordX, required this.coordY, required this.lat, required this.lng, required this.theta, this.key = "", this.Bid = "", this.showcoordX = 0, this.showcoordY = 0, this.isnavigating = false, this.coordXf = 0.0, this.coordYf = 0.0});

  // Future<void> move()async {
  //   print("prev----- coord $coordX,$coordY");
  //   print("prev----- show $showcoordX,$showcoordY");
  //   print("prev----- index ${pathobj.index}");
  //   pathobj.index = pathobj.index + 1;
  //   print("prev----- index ${pathobj.index}");
  //
  //   List<int> transitionvalue = tools.eightcelltransition(this.theta);
  //   coordX = coordX + transitionvalue[0];
  //   coordY = coordY + transitionvalue[1];
  //   List<double> values = tools.localtoglobal(coordX, coordY);
  //   lat = values[0];
  //   lng = values[1];
  //
  //
  //   if(this.isnavigating && pathobj.path.isNotEmpty && pathobj.numCols != 0){
  //     showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
  //     showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
  //   }else{
  //     showcoordX = coordX;
  //     showcoordY = coordY;
  //   }
  //
  //   print("curr----- coord $coordX,$coordY");
  //   print("curr----- show $showcoordX,$showcoordY");
  //   print("curr----- index ${pathobj.index}");
  //
  // }

  Future<void> move()async{


    moveOneStep();



    for(int i=1;i<stepSize.toInt() ; i++){
      bool movementAllowed = true;


      if(!MotionModel.isValidStep(this, cols, rows, nonWalkable[floor]!, reroute)){
        movementAllowed = false;
      }

      if(isnavigating){
        int prevX = Cellpath[pathobj.index-1].x;
        int prevY = Cellpath[pathobj.index-1].y;
        int nextX = Cellpath[pathobj.index+1].x;
        int nextY = Cellpath[pathobj.index+1].y;
        //non Walkable Check


        //destination check
        if(Cellpath.length - pathobj.index <6 ){
          movementAllowed = false;
        }

        //turn check
        if(tools.isTurn([prevX,prevY], [showcoordX,showcoordY], [nextX,nextY])){
          movementAllowed = false;
        }

        //lift check

        if(pathobj.connections[Bid]?[floor] == showcoordY*cols + showcoordX){
          movementAllowed = false;
        }
      }



      if(movementAllowed){
        moveOneStep();
      }else if(!movementAllowed){
        return;
      }
    }

    if(stepSize.toInt() != stepSize){

    }
  }

  Future<void> moveOneStep()async{

    wsocket.message["userPosition"]["X"]=coordX;
    wsocket.message["userPosition"]["Y"]=coordY;
    wsocket.message["userPosition"]["floor"]=floor;

    if(isnavigating){
      checkForMerge();
      pathobj.index = pathobj.index + 1;
      List<int> p = tools.analyzeCell(Cellpath, Cellpath[pathobj.index]);
      List<int> transitionvalue = Cellpath[pathobj.index].move(this.theta,currPointer:p[1],totalCells:p[0]);
      coordX = coordX + transitionvalue[0];
      coordY = coordY + transitionvalue[1];
      List<double> values = tools.localtoglobal(coordX, coordY);
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

      if(this.isnavigating && pathobj.Cellpath.isNotEmpty && pathobj.numCols != 0){
        showcoordX = Cellpath[pathobj.index].x;
        showcoordY = Cellpath[pathobj.index].y;
      }else{
        showcoordX = coordX;
        showcoordY = coordY;
      }




      int prevX = Cellpath[pathobj.index-1].x;
      int prevY = Cellpath[pathobj.index-1].y;
      int nextX = Cellpath[pathobj.index+1].x;
      int nextY = Cellpath[pathobj.index+1].y;
      //non Walkable Check


      //destination check
      if(Cellpath.length - pathobj.index <6 ){
        speak("You have reached ${pathobj.destinationName}");
        closeNavigation();
      }

      //turn check
      if(tools.isTurn([prevX,prevY], [showcoordX,showcoordY], [nextX,nextY])){
        print("qpalzm turn detected ${[prevX,prevY]}, ${[showcoordX,showcoordY]}, ${[nextX,nextY]}");
        AlignMapToPath([lat,lng],tools.localtoglobal(nextX, nextY));
      }

      //lift check
      print("iwiwiwi ${pathobj.connections[Bid]?[floor]}");
      print("iwwwwi ${showcoordY*cols + showcoordX}");

      if(floor!=pathobj.destinationFloor &&  pathobj.connections[Bid]?[floor] == (showcoordY*cols + showcoordX)){
        speak("Use this lift and go to ${tools.numericalToAlphabetical(pathobj.destinationFloor)} floor");
      }

      if(pathState.nearbyLandmarks.isNotEmpty){
        pathState.nearbyLandmarks.forEach((element) {
          if(element.element!.subType == "room door" && element.properties!.polygonExist != true){
            if(tools.calculateDistance([showcoordX,showcoordY], [element.doorX??element.coordinateX!,element.doorY??element.coordinateY!]) <=3){
              speak("Passing by ${element.name}");
              pathState.nearbyLandmarks.remove(element);
            }
          }else{
            if(tools.calculateDistance([showcoordX,showcoordY], [element.doorX??element.coordinateX!,element.doorY??element.coordinateY!]) <=6){
              double agl = tools.calculateAngle2([showcoordX,showcoordY], [showcoordX+transitionvalue[0],showcoordY+transitionvalue[1]], [element.coordinateX!,element.coordinateY!]);
              speak("${element.name} is on your ${tools.angleToClocks(agl)}");
              pathState.nearbyLandmarks.remove(element);
            }
          }
        });
      }

    }else{
      pathobj.index = pathobj.index + 1;

      List<int> transitionvalue = tools.eightcelltransition(this.theta);
      coordX = coordX + transitionvalue[0];
      coordY = coordY + transitionvalue[1];
      List<double> values = tools.localtoglobal(coordX, coordY);
      lat = values[0];
      lng = values[1];
      if(this.isnavigating && pathobj.path.isNotEmpty && pathobj.numCols != 0){
        showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
        showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
      }else{
        showcoordX = coordX;
        showcoordY = coordY;
      }
    }

    int d = tools.calculateDistance([coordX,coordY], [showcoordX,showcoordY]).toInt();
    if(d>0){
      offPathDistance.add(d);
    }
  }




  Future<void> checkForMerge()async{
    if(offPathDistance.length==3){
      if(tools.allElementsAreSame(offPathDistance)){
        offPathDistance.clear();
        coordX = showcoordX;
        coordY = showcoordY;
      }else{
        offPathDistance.removeAt(0);
      }
    }
  }


  Future<void> moveToFloor(int fl)async{
    floor = fl;
    if(pathobj.Cellpath[fl] != null){
      coordX = pathobj.Cellpath[fl]![0].x;
      coordY = pathobj.Cellpath[fl]![0].y;
      List<double> values = tools.localtoglobal(coordX, coordY);
      lat = values[0];
      lng = values[1];
      showcoordX = coordX;
      showcoordY = coordY;
      pathobj.index = path.indexOf(pathobj.Cellpath[fl]![0].node);
      paintMarker(geo.LatLng(lat, lng));
    }
  }


  Future<void> moveToPointOnPath(int index)async{
    showcoordX = path[index] % pathobj.numCols![Bid]![floor]!;
    showcoordY = path[index] ~/ pathobj.numCols![Bid]![floor]!;
    coordX = showcoordX;
    coordY = showcoordY;
    pathobj.index = index + 1;
    List<double> values = tools.localtoglobal(coordX, coordY);
    lat = values[0];
    lng = values[1];
  }

  Future<void> moveToStartofPath()async{
    List<Cell> turnPoints = tools.getCellTurnpoints(Cellpath, pathobj.numCols![Bid]![floor]!);
    if(tools.calculateDistance([Cellpath[0].x,Cellpath[0].y], [turnPoints[0].x,turnPoints[0].y])<5){
      pathobj.index = Cellpath.indexOf(turnPoints[0]);
    }
    floor = pathobj.sourceFloor;
    showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
    showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
    coordX = showcoordX;
    coordY = showcoordY;
    List<double> values = tools.localtoglobal(coordX, coordY);
    lat = values[0];
    lng = values[1];

    print("moveToStartofPath [$coordX,$coordY] === [$showcoordX,$showcoordY]");
  }

  Future<void> reset()async{
    showcoordX = coordX;
    showcoordY = coordY;
    isnavigating = false;
    pathobj = pathState();
    path = [];

  }
}