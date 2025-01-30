
//AR Flutter Plugin
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_hittest_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iwaymaps/IWAYPLUS/Elements/HelperClass.dart';
import 'package:vector_math/vector_math_64.dart' as vv;

//Other custom imports
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

class ObjectGestures extends StatefulWidget {
  const ObjectGestures({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<ObjectGestures> createState() => _ObjectGesturesState();
}

class _ObjectGesturesState extends State<ObjectGestures> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  ARLocationManager arLocationManager = ARLocationManager();

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  int turnCount = 0;
  List<vv.Vector4> turnVectorCord = [Vector4(0.0, 1.0, 0.0, 0),Vector4(0.0, 1.0, 0.0, 3.14159),Vector4(0.0, 1.0, 0.0, 3.14159),Vector4(0.0, 1.0, 0.0, 1.5708)];


  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Object Transformation Gestures'),
        ),
        body: Container(
            child: Stack(children: [
              ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig: PlaneDetectionConfig.horizontal,
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: _placeObjectOnPlane,
                          child: Text("Add object")),
                      ElevatedButton(
                          onPressed: onRemoveEverything,
                          child: Text("Remove Everything")),
                    ]
                ),
              )
            ])));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
      handlePans: true,
      handleRotation: true,
    );
    this.arObjectManager!.onInitialize();
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
  }

  Future<void> onRemoveEverything() async {
    /*nodes.forEach((node) {
      this.arObjectManager.removeNode(node);
    });*/
    turnCount = 0;
    anchors.forEach((anchor) {
      this.arAnchorManager!.removeAnchor(anchor);
    });
    anchors = [];
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
            (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      double distance = singleHitTestResult.distance;  // The distance from the camera to the hit test result
      if(distance>2.0){
        var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
        bool? didAddAnchor = await this.arAnchorManager!.addAnchor(newAnchor);
        if (didAddAnchor!) {
          this.anchors.add(newAnchor);


          // Add note to anchor
          var newNode = ARNode(
              type: NodeType.webGLB,
              uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb", // Path to your model file
              scale: Vector3(0.2, 0.2, 0.2),
              position: Vector3(0.0, 0.0, 0.0),
              // rotation: Vector4(2.0, 0.0, 0.0, -1.5708)); ->right

              // rotation: Vector4(2.0, -15.0, 0.0, -1.5708)); heading direction |^

              // rotation: Vector4(2.0, 15.0, 0.0, 1)); slight right
              // rotation: Vector4(2, 15.0, 2.0, -1.5)); backward
              // rotation: Vector4(0.0, 1.0, 0.0, 3.14159) // left
              // rotation: Vector4(0.0, 1.0, 0.0, 0) // right
              // rotation: Vector4(0.0, 1.0, 0.0, -1.5708) // backward
              rotation: turnVectorCord[turnCount] // backward

          );
          bool? didAddNodeToAnchor = await this
              .arObjectManager!
              .addNode(newNode, planeAnchor: newAnchor);
          if (didAddNodeToAnchor!) {
            this.nodes.add(newNode);
            HelperClass.showToast("Object ${turnCount} added to the detected plane!");
            turnCount++;
          } else {
            AlertDialog(
              title: Text("Error"),
              content: Text("Adding Node to Anchor failed"),
            );
          }
        } else {
          AlertDialog(
            title: Text("Error"),
            content: Text("Adding Anchor failed"),
          );
        }
      }else{
        HelperClass.showToast("distance is less than 2m");
      }

    }
  }

  void _placeObjectOnPlane() async {
    // arSessionManager?.onPlaneDetected = (plane) {
    //   arSessionManager?.getCameraPose().then((cameraPose) async {
    //     // Calculate the position 3 meters in front of the camera
    //     if (cameraPose != null) {
    //       vv.Vector3 cameraPosition = cameraPose.;
    //       vv.Vector3 newPosition = vv.Vector3(
    //           cameraPosition.x, cameraPosition.y,
    //           cameraPosition.z - 1.0); // 3 meters in front
    //       if (arObjectManager != null) {
    //         ARNode objectNode = ARNode(
    //           type: NodeType.webGLB,
    //           uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
    //           // Path to your model file
    //           position: newPosition,
    //           scale: vv.Vector3(0.1, 0.1, 0.1), // Adjust the scale of the object
    //         );
    //
    //         bool? didAddNode = await arObjectManager!.addNode(objectNode);
    //         if (didAddNode != null && didAddNode) {
    //           HelperClass.showToast("Object added to the detected plane!");
    //         } else {
    //           HelperClass.showToast("Failed to add object.");
    //         }
    //       }
    //     }
    //   });
    // };

    arSessionManager?.getCameraPose().then((cameraPose) async {
      print("cameraPose");
      print(cameraPose);
      // Calculate the position 3 meters in front of the camera
      if (cameraPose != null) {
        vv.Vector3 cameraPosition = cameraPose.getTranslation();
        vv.Vector3 newPosition = vv.Vector3(cameraPosition.x, cameraPosition.y, cameraPosition.z - 3.0); // 3 meters in front
        if (arObjectManager != null) {
          ARNode objectNode = ARNode(
            type: NodeType.webGLB,
            uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
            // Path to your model file
            position: newPosition,
            scale: vv.Vector3(0.1, 0.1, 0.1), // Adjust the scale of the object
          );

          bool? didAddNode = await arObjectManager!.addNode(objectNode);
          if (didAddNode != null && didAddNode) {
            HelperClass.showToast("Object added to the detected plane!");
          } else {
            HelperClass.showToast("Failed to add object.");
          }
        }
      }
    });
  }

  onPanStarted(String nodeName) {
    print("Started panning node " + nodeName);
  }

  onPanChanged(String nodeName) {
    print("Continued panning node " + nodeName);
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    print("Ended panning node " + nodeName);
    final pannedNode =
    this.nodes.firstWhere((element) => element.name == nodeName);

    /*
    * Uncomment the following command if you want to keep the transformations of the Flutter representations of the nodes up to date
    * (e.g. if you intend to share the nodes through the cloud)
    */
    //pannedNode.transform = newTransform;
  }

  onRotationStarted(String nodeName) {
    print("Started rotating node " + nodeName);
  }

  onRotationChanged(String nodeName) {
    print("Continued rotating node " + nodeName);
  }

  onRotationEnded(String nodeName, Matrix4 newTransform) {
    print("Ended rotating node " + nodeName);
    final rotatedNode =
    this.nodes.firstWhere((element) => element.name == nodeName);

    /*
    * Uncomment the following command if you want to keep the transformations of the Flutter representations of the nodes up to date
    * (e.g. if you intend to share the nodes through the cloud)
    */
    //rotatedNode.transform = newTransform;
  }
}