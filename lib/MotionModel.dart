import 'package:iwayplusnav/navigationTools.dart';

import 'UserState.dart';
import 'buildingState.dart';

class MotionModel{

  static bool isValidStep(UserState user, int cols, int rows, List<int> nonWalkable, Function reroute){
    List<int> transitionValue = user.Cellpath[user.pathobj.index+1].move(user.theta);
    int newX = user.coordX + transitionValue[0];
    int newY = user.coordY + transitionValue[1];
    print("$newX, $newY");



    if(newX<0 || newX >=cols || newY < 0 || newY >= rows){
      print("1");
      return false;
    }

    if(nonWalkable.contains((newY*cols)+newX)){
      print("${(newY*cols)+newX}");
      return false;
    }

    if(tools.calculateDistance([user.coordX,user.coordY], [user.showcoordX,user.showcoordY])>5){
      print("${user.coordX} ,${user.coordY} ,            ${user.showcoordX},${user.showcoordY}");
       reroute();
    }

    return true;
  }

  static bool reached(UserState state,int col){
    int x=0;
    int y=0;
    if(state.path.length>0){
      x=state.path[state.path.length-1]%col ;
      y=state.path[state.path.length-1]~/col;
    }

    if(state.showcoordX==x && state.showcoordY==y){
      print("true");
      return true;
    }
    print("falsse");
    return false;
  }


}