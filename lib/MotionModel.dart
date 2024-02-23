import 'package:iwayplusnav/navigationTools.dart';

import 'UserState.dart';
import 'buildingState.dart';

class MotionModel{

  static bool isValidStep(UserState user, int cols, int rows, List<int> nonWalkable){
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    int newX = user.coordX + transitionValue[0];
    int newY = user.coordY + transitionValue[1];
    print("$newX, $newY");
    if(newX<0 || newX >=cols || newY < 0 || newY >= rows){
      print("1");
      return true;
    }

    if(nonWalkable.contains((newY*cols)+newX)){
      print("${(newY*cols)+newX}");
      return true;
    }

    return true;
  }

}