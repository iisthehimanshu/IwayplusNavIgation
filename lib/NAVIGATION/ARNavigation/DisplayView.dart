import 'dart:async';

import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vv;

import 'ARTools.dart';



class DisplayARObjects extends StatefulWidget {
  @override
  _DisplayARObjectsState createState() => _DisplayARObjectsState();
}

class _DisplayARObjectsState extends State<DisplayARObjects> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;
  Timer? cameraPoseTimer;
  String _cameraPoseText = "Waiting for camera pose...";

  List<int> directionLengthList = [5,8,20,8];
  List<String> directionList = ["front","left","left","left"];

  vv.Vector3? initialPosition;
  vv.Vector3 currentPosition = vv.Vector3.zero();
  double totalDistanceMoved = 0.0;
  String totalDistanceMovedstring = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.none,
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black54,
                  child: Text(
                    totalDistanceMoved.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black54,
                  child: Text(
                    totalDistanceMovedstring,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;

    // Initialize the AR session without planes or anchors
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false, // Optional: Useful for debugging
    );

    arSessionManager.getCameraPose().then((pose) {
      if (pose != null) {
        initialPosition = vv.Vector3(pose.row3.x, pose.row3.y, pose.row3.z);
        print("✅ Initial Position Captured: $initialPosition");
      } else {
        print("❌ Failed to capture initial position");
      }
    });
    // addFloatingObject();
    trackUserMovement();
    addDirectionalObjects();
  }

  void trackUserMovement() {
    // Run every 500ms (adjust as needed)
    print("trackUserMovement");
    Timer.periodic(Duration(milliseconds: 500), (timer) async {
      var pose = await arSessionManager.getCameraPose();

      if (pose != null && initialPosition != null) {
        // Update current position
        currentPosition = vv.Vector3(pose.row3.x, pose.row3.y, pose.row3.z);

        // Calculate distance from origin
        double distance = (currentPosition - initialPosition!).length;

        // Update total distance moved
        totalDistanceMoved = distance;
        totalDistanceMovedstring = currentPosition.toString();

        print("Current Position: $currentPosition");
        print("Distance Moved from Origin: ${totalDistanceMoved.toStringAsFixed(2)} meters");
      }
    });
  }

  void addDirectionalObjects() async {
    List<int> directionLengthList = [5, 8, 20, 8];
    List<String> directionList = ["front", "left", "left", "left"];
    double fixedCoordinatedY = -1;



    vv.Vector3 currentPosition = vv.Vector3(0, fixedCoordinatedY, 0); // Start at (0, -0.5, 0)
    vv.Vector3 currentDirection = vv.Vector3(0, 0, -1); // Initially facing forward
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: currentPosition,
      scale: vv.Vector3(0.5, 0.5, 0.5),
      rotation: ARTools.getObjectRotation("front"),

    );
    await arObjectManager.addNode(newNode);

    var newNode1 = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        //                x,   y,                 z
      position: vv.Vector3(0, fixedCoordinatedY, -5),
      scale: vv.Vector3(0.5, 0.5, 0.5),
      rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode1);

    var newNode2 = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: vv.Vector3(-7, fixedCoordinatedY, -5),
      scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: vv.Vector4(0.0, 1.0, 0.0, -1.5708) // left

    );
    await arObjectManager.addNode(newNode2);

    var newNode3 = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: vv.Vector3(-7, fixedCoordinatedY, 15),
      scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: vv.Vector4(0.0, 1.0, 0.0, 0.0) // left
    );
    await arObjectManager.addNode(newNode3);


    // for (int i = 0; i < directionList.length; i++) {
    //   // Move in current direction
    //   currentPosition += currentDirection * directionLengthList[i].toDouble();
    //
    //   // Add the model at the calculated position
    //   var newNode = ARNode(
    //     type: NodeType.webGLB,
    //     uri: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/earth.glb",
    //     position: currentPosition,
    //     scale: vv.Vector3(0.5, 0.5, 0.5),
    //   );
    //   await arObjectManager.addNode(newNode);
    //
    //   // Rotate the direction vector based on "left" or "right" (90-degree turns)
    //   if (directionList[i] == "left") {
    //     currentDirection = vv.Vector3(currentDirection.z, 0, -currentDirection.x); // Rotate 90° left
    //   } else if (directionList[i] == "right") {
    //     currentDirection = vv.Vector3(-currentDirection.z, 0, currentDirection.x); // Rotate 90° right
    //   }
    // }
  }

  void addFloatingObject() async {
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/earth.glb",
      position: vv.Vector3(0, -1, -1),
      rotation: vv.Vector4(0.0,1.0,0.0,1.570),
      scale: vv.Vector3(0.5, 0.5, 0.5),
    );
    await arObjectManager.addNode(newNode);
    var againnewNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/earth.glb",
      position: vv.Vector3(0, -0.5, -2),
      scale: vv.Vector3(0.5, 0.5, 0.5),
    );
    await arObjectManager.addNode(againnewNode);
    var againnewNode1 = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/earth.glb",
      position: vv.Vector3(0, 0, -3),
      scale: vv.Vector3(0.5, 0.5, 0.5),
    );
    await arObjectManager.addNode(againnewNode1);
  }

  @override
  void dispose() {
    arSessionManager.dispose(); // Clean up AR session
    cameraPoseTimer?.cancel();
    super.dispose();
  }
}