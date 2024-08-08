import 'package:iwaymaps/navigationTools.dart';

import 'UserState.dart';
import 'buildingState.dart';

class MotionModel{

  static int stuckCount = 0;

  static bool isValidStep(UserState user, int cols, int rows, List<int> nonWalkable, Function reroute){
    if(user.pathobj.index+1 > user.Cellpath.length-1){
      UserState.closeNavigation();
    }
    if(user.onConnection || user.temporaryExit){
      return false;
    }
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    if(user.isnavigating){
      transitionValue = user.Cellpath[user.pathobj.index+1].move(user.theta);
    }
    int newX = user.coordX + transitionValue[0];
    int newY = user.coordY + transitionValue[1];

    print("newxnewy $newX,$newY");



    if(newX<0 || newX >=cols || newY < 0 || newY >= rows){
      return false;
    }

    if(nonWalkable.contains((newY*cols)+newX)){
      stuckCount++;
      if(stuckCount==5){
        user.moveToPointOnPath((user.pathobj.index+(stuckCount*UserState.stepSize)-1).toInt());
        stuckCount = 0;
      }
      return false;
    }

    try{
      if(user.Cellpath[user.pathobj.index+1].move == tools.twocelltransitionhorizontal || user.Cellpath[user.pathobj.index+1].move == tools.twocelltransitionvertical){
        if(tools.calculateDistance([user.coordX,user.coordY], [user.showcoordX,user.showcoordY])>20){
          reroute();
        }
      }else{
        if(tools.calculateDistance([user.coordX,user.coordY], [user.showcoordX,user.showcoordY])>20){
          reroute();
        }
      }
    }catch(e){

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
      return true;
    }
    return false;
  }


}