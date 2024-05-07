import 'package:iwayplusnav/pathState.dart';

import 'Cell.dart';
import 'navigationTools.dart';


class UserState{
  int floor;
  int coordX ;
  int coordY ;
  double lat;
  double lng;
  String key;
  double theta;
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

  UserState({required this.floor, required this.coordX, required this.coordY, required this.lat, required this.lng, required this.theta, this.key = "", this.Bid = "", this.showcoordX = 0, this.showcoordY = 0, this.isnavigating = false});

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
    if(isnavigating){
      checkForMerge();
      pathobj.index = pathobj.index + 1;
      print("theta ${this.theta}");
      List<int> transitionvalue = Cellpath[pathobj.index].move(this.theta);
      print("movefunction $transitionvalue");
      coordX = coordX + transitionvalue[0];
      coordY = coordY + transitionvalue[1];
      List<double> values = tools.localtoglobal(coordX, coordY);
      lat = values[0];
      lng = values[1];
      print("ch ${pathobj.Cellpath.isNotEmpty}");
      print("ch1 ${pathobj.numCols}");
      if(this.isnavigating && pathobj.Cellpath.isNotEmpty && pathobj.numCols != 0){
        print("first");
        showcoordX = Cellpath[pathobj.index].x;
        showcoordY = Cellpath[pathobj.index].y;
      }else{
        print("second");
        showcoordX = coordX;
        showcoordY = coordY;
      }

      print("curr----- tv $transitionvalue");
      print("curr----- coord $coordX,$coordY");
      print("curr----- show $showcoordX,$showcoordY");
    }else{
      print("prev----- coord $coordX,$coordY");
      print("prev----- show $showcoordX,$showcoordY");
      print("prev----- index ${pathobj.index}");
      pathobj.index = pathobj.index + 1;
      print("prev----- index ${pathobj.index}");

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

      print("curr----- coord $coordX,$coordY");
      print("curr----- show $showcoordX,$showcoordY");
      print("curr----- index ${pathobj.index}");
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
    showcoordX = path[pathobj.index] % pathobj.numCols![Bid]![floor]!;
    showcoordY = path[pathobj.index] ~/ pathobj.numCols![Bid]![floor]!;
    coordX = showcoordX;
    coordY = showcoordY;
    List<double> values = tools.localtoglobal(coordX, coordY);
    lat = values[0];
    lng = values[1];
    print("path $path");
    print("index ${[pathobj.index]}");
    print("object ${path[pathobj.index]}");
    print("cols ${pathobj.numCols![Bid]![floor]!}");
    print("x $showcoordX");
    print("y $showcoordY");
  }

  Future<void> reset()async{
    showcoordX = coordX;
    showcoordY = coordY;
    isnavigating = false;
    pathobj = pathState();
    path = [];

  }
}