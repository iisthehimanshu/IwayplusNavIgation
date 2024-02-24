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



  UserState({required this.floor, required this.coordX, required this.coordY, required this.lat, required this.lng, required this.theta, this.key = "", this.showcoordX = 0, this.showcoordY = 0, this.isnavigating = false});

  void move(){
    List<int> transitionvalue = tools.eightcelltransition(this.theta);
    coordX = coordX + transitionvalue[0];
    coordY = coordY + transitionvalue[1];
    List<double> values = tools.localtoglobal(coordX, coordY);
    lat = values[0];
    lng = values[1];

    if(this.isnavigating){

    }else{
      showcoordX = coordX;
      showcoordY = coordY;
    }
  }

  Future<void> move_show()async {
    if(this.isnavigating){

    }else{
      move();
    }
  }
}