import 'dart:math';

import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';


// Yaw (θ) – Rotation Around the Y-Axis
// Definition: Rotates the camera left or right (like turning your head left/right).

// Pitch (φ) – Rotation Around the X-Axis
// Definition: Rotates the camera up or down (like nodding your head).

// Roll (ψ) – Rotation Around the Z-Axis
// Definition: Rotates the camera by tilting left or right (like tilting your head sideways).


class ARTools{
  static Vector4? getObjectRotation(String direction){
    switch(direction){
      case "front":
        return Vector4(0.0, 1.0, 0.0, 1.5708);
      case "back":
        return Vector4(0.0, 1.0, 0.0, -3.14159);
      case "Turn Left, and Go Straight":
        return Vector4(0.0, 1.0, 0.0, 3.14159);
      case "Turn Right, and Go Straight":
        return Vector4(0.0, 1.0, 0.0, 0.0);
    }
  }
  static List<int> getQuadrant(List<int> initial, String direction){
    if(initial[0]==0 && initial[1]==0){
      if(direction=="Turn Left, and Go Straight"){
        return [-1,0];
      }else if(direction == "Go Straight"){
        return [0,-1];
      }else if(direction == "Turn Right, and Go Straight"){
        return [0,-1];
      }else{
        return [0,0];
      }
    }else if(initial[0]==1 && initial[1]==1){
      if(direction=="Turn Left, and Go Straight"){
        return [-1,1];
      }else if(direction=="Turn Right, and Go Straight"){
        return [1,1];
      }else if(direction=="Go Straight"){
        return [1,1];
      }else{
        return [1,-1];
      }
    }else if(initial[0]==1 && initial[1]==-1){
      if(direction=="Turn Left, and Go Straight"){
        return [-1,-1];
      }else if(direction=="Turn Right, and Go Straight"){
        return [1,-1];
      }else if(direction=="Go Straight"){
        return [1,-1];
      }else{
        return [1,1];
      }
    }else if(initial[0]==-1 && initial[1]==-1){
      if(direction=="Turn Left, and Go Straight"){
        return [-1,1];
      }else if(direction=="Turn Right, and Go Straight"){
        return [-1,-1];
      }else if(direction=="Go Straight"){
        return [-1,-1];
      }else{
        return [1,-1];
      }
    }else if(initial[0]==-1 && initial[1]==1){
      if(direction=="Turn Left, and Go Straight"){
        return [1,1];
      }else if(direction=="Turn Right, and Go Straight"){
        return [-1,1];
      }else if(direction=="Go Straight"){
        return [-1,1];
      }else{
        return [-1,-1];
      }
    }else if(initial[0]==0 && initial[1]==-1){  //on origin x=0 , z=-something
      if(direction=="Turn Left, and Go Straight"){
        return [-1,-1];
      }else if(direction=="Turn Right, and Go Straight"){
        return [1,-1];
      }else if(direction=="Go Straight"){
        return [0,-1];
      }else{
        return [0,1];
      }
    }else{
      return [];
    }
  }


  static Vector3 matrixToEuler(Matrix3 rotationMatrix) {
    double sy = sqrt(rotationMatrix.entry(0, 0) * rotationMatrix.entry(0, 0) +
        rotationMatrix.entry(1, 0) * rotationMatrix.entry(1, 0));

    bool singular = sy < 1e-6;

    double x, y, z;

    // if (!singular) {
    //   x = atan2(rotationMatrix.entry(2, 1), rotationMatrix.entry(2, 2)); // Roll
    //   y = atan2(-rotationMatrix.entry(2, 0), sy); // Pitch
    //   z = atan2(rotationMatrix.entry(1, 0), rotationMatrix.entry(0, 0)); // Yaw (Heading)
    // }else {
    //   x = atan2(-rotationMatrix.entry(1, 2), rotationMatrix.entry(1, 1));
    //   y = atan2(-rotationMatrix.entry(2, 0), sy);
    //   z = 0; // Yaw is 0 in singular case
    // }

    if(singular){
      x = atan2(-rotationMatrix.entry(1,1),rotationMatrix.entry(1, 1));
      y = atan2(-rotationMatrix.entry(2, 0), sy);
      z = 0;
    }else{
      x = atan2(rotationMatrix.entry(2, 1), rotationMatrix.entry(2, 2));
      y = atan2(-rotationMatrix.entry(2, 0), sy);
      z = atan2(rotationMatrix.entry(1, 0), rotationMatrix.entry(0, 0));
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

  static List<int> findFirstTurnCoord(Vector3 cameraPosition){
    print("findFirstTurnCoord");
    List<int> firstTurnCoords = [];
    if(cameraPosition.z<0){
      if(cameraPosition.x < 0){
        firstTurnCoords = [-1,-1];
      }else if(cameraPosition.x > 0){
        firstTurnCoords = [1,-1];
      }else {
        firstTurnCoords = [0, -1];
      }
    }else if (cameraPosition.z>0){
      if(cameraPosition.x < 0){
        firstTurnCoords = [-1,1];
      }else if(cameraPosition.x > 0){
        firstTurnCoords = [1,1];
      }else {
        firstTurnCoords = [0,1];
      }
    }else{
      if (cameraPosition.x < 0) {
        firstTurnCoords = [-1,0];
      }else if(cameraPosition.x > 0){
        firstTurnCoords = [1,0];
      }
    }
    return firstTurnCoords;
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
  static List<int> getCoordN2(double theta){
    if(theta >= 0 && theta < 90){
      print("0 90");
      return [-1,1];
    }else if(theta >= 90 && theta < 180){
      print("90 180");
      return [-1,-1];
    }else if(theta >=180 && theta < 270){
      print("180 270");
      return [1,-1];
    }else if(theta>=270 && theta<360){
      print("270 360");
      return [1,1];
    }else{
      print("ERROR getCoordNinelse");
      return [0,0];
    }
  }

  Vector3 _getForwardVector(Quaternion rotation) {
    double x = rotation.x, y = rotation.y, z = rotation.z, w = rotation.w;
    return Vector3(1.5 * (x * z + w * y), 1, 1.5 * (w * w + x * x) - 1,).normalized();
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