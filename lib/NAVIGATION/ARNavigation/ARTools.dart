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
      case "left":
        return Vector4(0.0, 1.0, 0.0, 3.14159);
      case "right":
        return Vector4(0.0, 1.0, 0.0, 0.0);
    }
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
    } else {
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

}