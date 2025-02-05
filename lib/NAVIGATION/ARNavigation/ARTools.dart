import 'package:vector_math/vector_math_64.dart';

class ARTools{
  static Vector4? getObjectRotation(String direction){
    switch(direction){
      case "front":
        return Vector4(0.0, 1.0, 0.0, 1.5708);
      case "back":
        return Vector4(0.0, 1.0, 0.0, -3.14159);
      case "left":
        return Vector4(0.0, 1.0, 0.0, 3.14159);
      case "right":
        return Vector4(0.0, 1.0, 0.0, 0.0);
    }
  }
}