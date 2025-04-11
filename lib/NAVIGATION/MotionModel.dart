import 'package:flutter/cupertino.dart';
import '../IWAYPLUS/API/buildingAllApi.dart';
import 'UserState.dart';
import 'navigationTools.dart';

class MotionModel{
  static int stuckCount = 0;
  static bool isValidStep(UserState user, int cols, int rows, List<int> nonWalkable, Function reroute, BuildContext context){
    if(user.pathobj.index+1 > user.cellPath.length-1){
      UserState.closeNavigation();
    }
    if(user.onConnection || user.temporaryExit){
      print("isValid false due to lift");
      return false;
    }
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    if(user.isnavigating){
      transitionValue = user.cellPath[user.pathobj.index+1].move(user.theta);
    }
    int newX = user.coordX + transitionValue[0];
    int newY = user.coordY + transitionValue[1];
    print("newxnewy $newX,$newY");
    if(newX<0 || newX >=cols || newY < 0 || newY >= rows){
      print("isValid false due to building boundary");
      return false;
    }
    if(nonWalkable.contains((newY*cols)+newX)){
      print("motionmodel $newY $newX $cols ${(newY*cols)+newX}");
      stuckCount++;
      if(stuckCount==5){
        //if the pointer gets stuck in the non walkable during navigation.
        if(user.bid == buildingAllApi.outdoorID){
          user.moveToPointOnPathOnPath(context, ((stuckCount*UserState.stepSize)-1).toInt());
        }else{
          user.moveToPointOnPath((user.pathobj.index+(stuckCount*UserState.stepSize)-1).toInt(), context);
        }

        stuckCount = 0;
      }
      print("isValid false due to stuck in nonWalkable $stuckCount");
      return false;
    }
    try{
      print("motion model ${[user.coordX,user.coordY]} <> ${[user.showcoordX,user.showcoordY]}");
      if(user.cellPath[user.pathobj.index+1].move == tools.twocelltransitionhorizontal || user.cellPath[user.pathobj.index+1].move == tools.twocelltransitionvertical){
        if(tools.calculateDistance([user.coordX,user.coordY], [user.showcoordX,user.showcoordY])>(user.bid==buildingAllApi.outdoorID?40:20)){
          reroute();
        }
      }else{
        if(tools.calculateDistance([user.coordX,user.coordY], [user.showcoordX,user.showcoordY])>(user.bid==buildingAllApi.outdoorID?40:20)){
          reroute();
        }
      }
    }catch(e){}
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