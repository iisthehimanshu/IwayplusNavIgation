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


  UserState({required this.floor, required this.coordX, required this.coordY, required this.lat, required this.lng, required this.theta, this.key = "", this.showcoordX = 0, this.showcoordY = 0, this.isnavigating = false});

  Future<void> move()async {
    List<int> transitionvalue = tools.eightcelltransition(this.theta);
    coordX = coordX + transitionvalue[0];
    coordY = coordY + transitionvalue[1];
    List<double> values = tools.localtoglobal(coordX, coordY);
    lat = values[0];
    lng = values[1];
    if(this.isnavigating && pathobj.path.isNotEmpty && pathobj.numCols != 0){
      showcoordX = path[pathobj.index++] % pathobj.numCols;
      showcoordY = path[pathobj.index++] ~/ pathobj.numCols;
    }else{
      showcoordX = coordX;
      showcoordY = coordY;
    }
  }

  Future<void> moveToStartofPath()async{
    List<int> transitionvalue = tools.eightcelltransition(this.theta);
    coordX = coordX + transitionvalue[0];
    coordY = coordY + transitionvalue[1];
    List<double> values = tools.localtoglobal(coordX, coordY);
    lat = values[0];
    lng = values[1];
    showcoordX = path[pathobj.index] % pathobj.numCols;
    showcoordY = path[pathobj.index] ~/ pathobj.numCols;
  }
}