import 'dart:math';

import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:iwaymaps/NAVIGATION/ARNavigation/Class/ARPathInfo.dart';
import 'package:vector_math/vector_math_64.dart';

import '../Cell.dart';


// Yaw (θ) – Rotation Around the Y-Axis
// Definition: Rotates the camera left or right (like turning your head left/right).

// Pitch (φ) – Rotation Around the X-Axis
// Definition: Rotates the camera up or down (like nodding your head).

// Roll (ψ) – Rotation Around the Z-Axis
// Definition: Rotates the camera by tilting left or right (like tilting your head sideways).


class ARTools{
  double objectDegree = 0.0;

  static Vector4? getObjectRotation(String direction){
    switch(direction){
      case "front":
        return Vector4(0.0, 1.0, 0.0, 1.5708);
      case "back":
        return Vector4(0.0, 1.0, 0.0, -1.5708);
      case "left":
        return Vector4(0.0, 1.0, 0.0, 3.14159);
      case "right":
        return Vector4(0.0, 1.0, 0.0, 0.0);
    }
  }
  static Vector4? getObjectRotation2(double rotationValueZ2,double rotationValueZ1,double rotationValueX2 ,double rotationValueX1){
    double rotationValue = 0.0;

    if(rotationValueZ2> rotationValueZ1){
      rotationValue = -1.5708;
    }else if(rotationValueZ2 < rotationValueZ1){
      rotationValue = 1.5708;
    }else{
      if(rotationValueX2 > rotationValueX1){
        rotationValue = 0.0;
      }else if(rotationValueX2 < rotationValueX1){
        rotationValue = 3.14159;
      }
    }

    switch(rotationValue){
      case 1.5708:
        return Vector4(0.0, 1.0, 0.0, 1.5708);
      case -3.14159:
        return Vector4(0.0, 1.0, 0.0, -3.14159);
      case 3.14159:
        return Vector4(0.0, 1.0, 0.0, 3.14159);
      case 0.0:
        return Vector4(0.0, 1.0, 0.0, 0.0);
    }
  }

  // 1.5708 //front
  // 3.14159 left
  // 0.0 right
  // --1.5708
  static double? giveRotationDouble(int rotationValueZ2,int rotationValueZ1,int rotationValueX2 ,int rotationValueX1){
    if(rotationValueZ2 > rotationValueZ1){
      return -1.5708;
    }else if(rotationValueZ2 < rotationValueZ1){
      return 1.5708;
    }else{
      if(rotationValueX2 > rotationValueX1){
        return 0.0;
      }else if(rotationValueX2 < rotationValueX1){
        return 3.14159;
      }
    }
  }



  static List<List<int>> absoluteARPathCoordinates(List<Cell> turnPoints,List<int> userABScrd){
    List<List<int>> processedCRDList = [];
    for(int i=0 ; i<turnPoints.length ; i++){
      int xC = (((turnPoints[i].y - userABScrd[1])/3.2)*-1).toInt();
      int zC = ((turnPoints[i].x - userABScrd[0])/3.2).toInt();
      processedCRDList.add([xC,zC]);
    }
    return processedCRDList;
  }

  static List<List<int>> generatePath(List<List<int>> path) {
    List<List<int>> modifiedPath = [];
    Map<int,List<List<int>>> indexPath = Map();

    for (int i = 0; i < path.length - 1; i++) {
      List<List<int>> indexList = [];
      int x1 = path[i][0], y1 = path[i][1];
      int x2 = path[i + 1][0], y2 = path[i + 1][1];

      if (x1 == x2) {
        // Vertical movement
        int step = y1 < y2 ? 1 : -1;
        for (int y = y1; y != y2; y += step) {
          modifiedPath.add([x1, y]);
          indexList.add([x1, y]);
        }
      } else if (y1 == y2) {
        // Horizontal movement
        int step = x1 < x2 ? 1 : -1;
        for (int x = x1; x != x2; x += step) {
          modifiedPath.add([x, y1]);
          indexList.add([x,y1]);
        }
      }
      indexPath[i] = indexList;
    }
    // Add the last point
    modifiedPath.add(path.last);
    ARPathinfo.arIndexPath = indexPath;
    print("ARPathinfo().modifiedPath ${ARPathinfo.arIndexPath}");

    return modifiedPath;
  }

  static List<List<double>> realWorldARPathCoordinates(List<List<int>> absPathCRD,List<int> userCRD,double marginAngle){
    List<List<double>> realWorldPath = [];
    for(int i=0 ; i<absPathCRD.length ; i++){
      int xC = absPathCRD[i][0];
      int zC = absPathCRD[i][1];

      double newX = xC * cos(marginAngle) + zC * sin(marginAngle);
      double newZ = -xC * sin(marginAngle) + zC * cos(marginAngle);

      realWorldPath.add([newX, newZ]);
    }
    return realWorldPath;
  }

  static List<List<double>> singleRealWorldARPathCoordinates(List<List<int>> absPathCRD,double marginAngle){
    List<List<double>> realWorldPath = [];
    for(int i=0 ; i<absPathCRD.length ; i++){
      int xC = absPathCRD[i][0];
      int zC = absPathCRD[i][1];

      double newX = xC * cos(marginAngle) + zC * sin(marginAngle);
      double newZ = -xC * sin(marginAngle) + zC * cos(marginAngle);

      realWorldPath.add([newX, newZ]);
    }
    return realWorldPath;

  }




  static List<double> generateRotationARValues(List<List<int>> absoluteARPathCoordinates) {
    List<double> rotationARValueList = [];
    for (int i = 0; i < absoluteARPathCoordinates.length - 1; i++) {
      rotationARValueList.add(ARTools.giveRotationDouble(
        absoluteARPathCoordinates[i + 1][1].toInt(),
        absoluteARPathCoordinates[i][1].toInt(),
        absoluteARPathCoordinates[i + 1][0].toInt(),
        absoluteARPathCoordinates[i][0].toInt(),
      )!);
    }
    return rotationARValueList;
  }







  static Vector3 matrixToEuler(Matrix3 rotationMatrix) {
    double sy = sqrt(rotationMatrix.entry(0, 0) * rotationMatrix.entry(0, 0) +
        rotationMatrix.entry(1, 0) * rotationMatrix.entry(1, 0));

    bool singular = sy < 1e-6;

    double x, y, z;

    if (!singular) {
      x = atan2(rotationMatrix.entry(2, 1), rotationMatrix.entry(2, 2)); // Roll
      y = atan2(-rotationMatrix.entry(2, 0), sy); // Pitch
      z = atan2(rotationMatrix.entry(1, 0), rotationMatrix.entry(0, 0)); // Yaw (Heading)
    }else {
      x = atan2(-rotationMatrix.entry(1, 2), rotationMatrix.entry(1, 1));
      y = atan2(-rotationMatrix.entry(2, 0), sy);
      z = 0; // Yaw is 0 in singular case
    }

    return Vector3(radians(x), radians(y),radians(z));
  }

  static ARNode returnARNode(Vector3 position){
    var arNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: position,
      scale: Vector3(0.2, 0.2, 0.2),
      rotation: getObjectRotation("right"),
    );
    return arNode;
  }

  static Vector3 getTranslation(Matrix4 matrix) {
    return Vector3(matrix.entry(0, 3), matrix.entry(1, 3), matrix.entry(2, 3));
  }

  static List<int> getCoordN(double theta){
    if(theta >= 0 && theta < 90){
      print("0 90");
      return [1,-1];
    }else if(theta >= 90 && theta < 180){
      print("90 180");
      return [1,1];
    }else if(theta >=180 && theta < 270){
      print("180 270");
      return [-1,1];
    }else if(theta>=270 && theta<360){
      print("270 360");
      return [-1,-1];
    }else{
      print("getCoordNinelse");
      return [0,0];
    }
  }

  Vector3 _getForwardVector(Quaternion rotation) {
    double x = rotation.x, y = rotation.y, z = rotation.z, w = rotation.w;
    return Vector3(1.5 * (x * z + w * y), 1, 1.5 * (w * w + x * x) - 1,).normalized();
  }

  Vector3 quaternionToEuler(Quaternion q) {
    double ysqr = q.y * q.y;

    // Compute pitch (X-axis rotation)
    double t0 = 2.0 * (q.w * q.x + q.y * q.z);
    double t1 = 1.0 - 2.0 * (q.x * q.x + ysqr);
    double pitch = atan2(t0, t1);

    // Compute yaw (Y-axis rotation)
    double t2 = 2.0 * (q.w * q.y - q.z * q.x);
    t2 = t2.clamp(-1.0, 1.0);
    double yaw = asin(t2);

    // Compute roll (Z-axis rotation)
    double t3 = 2.0 * (q.w * q.z + q.x * q.y);
    double t4 = 1.0 - 2.0 * (ysqr + q.z * q.z);
    double roll = atan2(t3, t4);

    return Vector3(pitch, yaw, roll); // In radians
  }


  void printEulerAngles(Quaternion q) {
    Vector3 eulerAngles = quaternionToEuler(q);

    print("Euler Angles:");
    print("Pitch (X-axis): ${degrees(eulerAngles.x)}°");
    objectDegree = degrees(eulerAngles.x);
    print("Yaw (Y-axis): ${degrees(eulerAngles.y)}°");
    print("Roll (Z-axis): ${degrees(eulerAngles.z)}°");
  }

  // Extracts rotation as a quaternion from a transformation matrix
  Quaternion _extractRotation(Matrix4 matrix) {
    Vector3 scale = Vector3.zero();
    Vector3 translation = Vector3.zero();
    Quaternion rotation = Quaternion.identity();

    matrix.decompose(scale, rotation, translation);
    return rotation;
  }

  static double calculateOpposite(double angleInDegrees, double hypotenuse) {
    double angleInRadians = angleInDegrees * (pi / 180); // Convert degrees to radians
    return hypotenuse * sin(angleInDegrees);
  }

  static double calculateAdjacent(double angleInDegrees, double hypotenuse) {
    double angleInRadians = angleInDegrees * (pi / 180); // Convert degrees to radians
    return hypotenuse * cos(angleInDegrees);
  }





}