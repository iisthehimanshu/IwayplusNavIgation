import 'package:iwayplusnav/pathState.dart';

import 'navigationTools.dart';


class UserState{
  int floor;
  int coordX;
  int coordY;
  double lat;
  double lng;
  String key;
  double theta;
  bool isnavigating;
  int showcoordX;
  int showcoordY;
  pathState pathobj = pathState();
  List<int> path = [];
  bool initialallyLocalised = false;
  String Bid ;
  static int xdiff = 0;
  static int ydiff = 0;
  static bool isRelocalizeAroundLift=false;

  UserState({required this.floor, required this.coordX, required this.coordY, required this.lat, required this.lng, required this.theta, this.key = "", this.Bid = "", this.showcoordX = 0, this.showcoordY = 0, this.isnavigating = false});

  Future<void> move()async {
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