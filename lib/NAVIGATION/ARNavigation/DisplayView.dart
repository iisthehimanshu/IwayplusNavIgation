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
import '../UserState.dart';
import '../pathState.dart';
import 'ARTools.dart';

class DisplayARObjects extends StatefulWidget {
  UserState user;
  pathState PathState;

  DisplayARObjects({required this.user,required this.PathState});
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

  List<int> directionLengthList = [5,2,8,20,8];
  List<String> directionList = ["right","right","left","left","left"];

  vv.Vector3? initialPosition;
  vv.Vector3 currentPosition = vv.Vector3.zero();
  double totalDistanceMoved = 0.0;
  String totalDistanceMovedstring = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("DisplayARObjects");
    print(widget.PathState.sourcePolyID);
    print(widget.PathState.destinationPolyID);


  }


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

  Future<void> onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;

    // Initialize the AR session without planes or anchors
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: true, // Optional: Useful for debugging
    );

    arSessionManager.getCameraPose().then((pose) {
      if (pose != null) {
        initialPosition = vv.Vector3(pose.row3.x, pose.row3.y, pose.row3.z);
        print("✅ Initial Position Captured: $initialPosition");
      } else {
        print("❌ Failed to capture initial position");
      }
    });
    check();

    if((widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "c7b082-725b-a34-085d-062884b523ac") || (widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "7c8e88a-78ca-3cb1-c4aa-75efde7eae0")){
      addDirectionalObjects();//iwp to pantry
    }else if((widget.PathState.sourcePolyID == "c7b082-725b-a34-085d-062884b523ac" && widget.PathState.destinationPolyID == "c2ba564-24f-a8e2-c7-4cfc00cdff") || (widget.PathState.sourcePolyID == "c7b082-725b-a34-085d-062884b523ac" && widget.PathState.destinationPolyID == "8b7c1-46a0-2f3-ad2a-030024c0016b") || (widget.PathState.sourcePolyID == "c7b082-725b-a34-085d-062884b523ac" && widget.PathState.destinationPolyID == "846c0d-b27b-c037-ebb8-b55131efbe86")){
      addDirectionalObjects2(); //pantry to lift 2 front landmark
    }else if((widget.PathState.sourcePolyID == "ec2325b-0dbb-73b5-67d-4218d76853f4" && widget.PathState.destinationPolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0") ||
        (widget.PathState.sourcePolyID == "ec2325b-0dbb-73b5-67d-4218d76853f4" && widget.PathState.destinationPolyID == "707dd03-13c5-28ab-48c-b84460a3c")||
        (widget.PathState.sourcePolyID == "ec2325b-0dbb-73b5-67d-4218d76853f4" && widget.PathState.destinationPolyID == "257615-7b2e-4e2-287a-d1b120c110f7")||
        (widget.PathState.sourcePolyID == "ec2325b-0dbb-73b5-67d-4218d76853f4" && widget.PathState.destinationPolyID == "c0113d-d324-5a77-3e1-22c3fd237")){
      addDirectionalObjects3(); //lift2 to iwp
    }else if((widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "0c32010-b523-6c0-7ed6-4d3bd6204dc6") ||
        (widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "13ae3e2-6388-d70d-216b-cb35b821a7") ){
      addDirectionalObjects4(); //iwp to dark stairs +side 1
    }else if((widget.PathState.sourcePolyID == "c7b082-725b-a34-085d-062884b523ac" && widget.PathState.destinationPolyID == "fddee8-11ba-05d7-fa28-25fa6363c53d") || (widget.PathState.sourcePolyID == "c7b082-725b-a34-085d-062884b523ac" && widget.PathState.destinationPolyID == "175e6a3-7ecf-b0dc-ab7e-3f52e3bd52")) {
      addDirectionalObjects5();
    } else if((widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "ebedc38-33f6-f43e-2168-d6a8ef1acb55") || (widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "d3446-340f-ff3-f203-dac575c3565")){
      addDirectionalObjects6();
    }else if((widget.PathState.sourcePolyID == "ec2325b-0dbb-73b5-67d-4218d76853f4" && widget.PathState.destinationPolyID == "224d500-4823-f2ef-42aa-7f67804c6000") || (widget.PathState.sourcePolyID == "ec2325b-0dbb-73b5-67d-4218d76853f4" && widget.PathState.destinationPolyID == "bb4a73-bdaa-f3ae-1dca-7c1aef761363") || (widget.PathState.sourcePolyID == "ec2325b-0dbb-73b5-67d-4218d76853f4" && widget.PathState.destinationPolyID == "458af70-dbd-ab2-f064-38f30a762c3")){
      addDirectionalObjects7();
    }else if((widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "c2ba564-24f-a8e2-c7-4cfc00cdff") || (widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "8b7c1-46a0-2f3-ad2a-030024c0016b") || (widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "846c0d-b27b-c037-ebb8-b55131efbe86")){
      addDirectionalObject8();
    }else if((widget.PathState.sourcePolyID == "0a8bdc2-b0b2-662a-ae5-bff7bff350c0" && widget.PathState.destinationPolyID == "724f73b-00c-f850-eb-bb3433fde60")){
      addDirectionalObject9();
    }
    //



    // 0a8bdc2-b0b2-662a-ae5-bff7bff350c0
    // I/flutter (29969): 0c32010-b523-6c0-7ed6-4d3bd6204dc6
    // addFloatingObject();
    // trackUserMovement();
    // addDirectionalObjects();

    // vv.Vector3 referencePosition = vv.Vector3(0, 0, -5);
    //
    // // Calculate new positions
    // vv.Vector3 leftPosition = referencePosition + vv.Vector3(-3, 0, 0);   // (-3, 0, -5)
    // vv.Vector3 newleftPosition = leftPosition + vv.Vector3(-3, 0, 0);   // (-3, 0, -5)
    // vv.Vector3 rightPosition = referencePosition + vv.Vector3(3, 0, 0);   // (3, 0, -5)
    // vv.Vector3 frontPosition = referencePosition + vv.Vector3(0, 0, -3);  // (0, 0, -8)
    //
    // // Add objects
    // await add3DObject(arObjectManager, referencePosition); // Reference point (0,0,-5)
    // await add3DObject(arObjectManager, leftPosition);      // Left (-3,0,-5)
    // await add3DObject(arObjectManager, rightPosition);     // Right (3,0,-5)
    // await add3DObject(arObjectManager, frontPosition);     // Front (0,0,-8)
    // await add3DObject(arObjectManager, newleftPosition);     // Front (0,0,-8)
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
  double fixedCoordinatedY = -1;
  Future<void> addDirectionalObject9() async {
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

    var newNode6 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-7, fixedCoordinatedY, 6),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("front") // left
    );
    await arObjectManager.addNode(newNode6);

    var newNode3 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-3, fixedCoordinatedY, 6),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode3);
  }


  Future<void> addDirectionalObject8() async {
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
    var newNode6 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-7, fixedCoordinatedY, -1),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("front") // left
    );
    await arObjectManager.addNode(newNode6);
    var newNode3 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-25, fixedCoordinatedY, -1),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode3);
    var newNode4 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-25, fixedCoordinatedY, -5),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode4);
    var newNode5 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-30, fixedCoordinatedY, -5),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode5);
  }

  void addDirectionalObjects3() async {
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: currentPosition,
      scale: vv.Vector3(0.2, 0.2, 0.2),
      rotation: ARTools.getObjectRotation("front"),
    );
    await arObjectManager.addNode(newNode);
    var newNode1 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(0, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode1);
    var newNode2 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(25, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("front") // left
    );
    await arObjectManager.addNode(newNode2);
    var newNode3 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(25, fixedCoordinatedY, -11),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode3);
    var newNode4 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(30, fixedCoordinatedY, -11),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode4);
    var newNode5 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(30, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode5);
  }

  void addDirectionalObjects6() async {
    var newNode1 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        //                x,   y,                 z
        position: vv.Vector3(0, fixedCoordinatedY, -15),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode1);
  }

  void addDirectionalObjects4() async {
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
        position: vv.Vector3(-7, fixedCoordinatedY, -12),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode3);
  }

  void addDirectionalObjects5() async {
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: currentPosition,
      scale: vv.Vector3(0.2, 0.2, 0.2),
      rotation: ARTools.getObjectRotation("front"),
    );
    await arObjectManager.addNode(newNode);

    var newNode1 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(0, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode1);
    var newNode2 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-5, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("front") // left
    );
    await arObjectManager.addNode(newNode2);
  }
  void addDirectionalObjects7() async{
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: currentPosition,
      scale: vv.Vector3(0.2, 0.2, 0.2),
      rotation: ARTools.getObjectRotation("front"),
    );
    await arObjectManager.addNode(newNode);

    var newNode1 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(0, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode1);
    var newNode2 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-14, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode2);
    var newNode3 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-14, fixedCoordinatedY, 25),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager.addNode(newNode3);
    var newNode4 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(-25, fixedCoordinatedY, 25),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("front") // left
    );
    await arObjectManager.addNode(newNode4);
  }


    void addDirectionalObjects2() async{
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: currentPosition,
      scale: vv.Vector3(0.2, 0.2, 0.2),
      rotation: ARTools.getObjectRotation("front"),
    );
    await arObjectManager.addNode(newNode);

    var newNode1 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(0, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode1);
    var newNode2 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(15, fixedCoordinatedY, -7),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("front") // left
    );
    await arObjectManager.addNode(newNode2);
    var newNode3 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(15, fixedCoordinatedY, -25),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode3);
    var newNode4 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(20, fixedCoordinatedY, -25),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode4);
    var newNode5 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: vv.Vector3(20, fixedCoordinatedY, -30),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("front") // left
    );
    await arObjectManager.addNode(newNode5);

  }
  List<int> testingDirection(double angle) {
    //angle 45
    if(angle==180){
      return [0,1];
    }else if(angle==90){
      return [-1,0];
    }else if(angle == 0){
      return [0,-1];
    }else if(angle == 45){
      return [0,-1]; //
    }else if(angle == 135){
      return [-1,0];
    }else if(angle == 225){
      //++
      return [1,0];
    }else if(angle == 315){
      //
      return [1,0];
    }else{
      return [1,0];
    }
  }
  late int x;
  late int z;

  Future<void> check() async {
    List<int> result = testingDirection(225);

    print('result $result');
    int distance = 5;
    // if(result[0]!=0 && result[1]!=0){
    //   if(result[0]>0){
    //     x = result[0];
    //     z = result[1]*3;
    //   }else {
    //     x = result[0] * 3;
    //     z = result[1];
    //   }
    // }

    if(result[0] != 0){
      x = result[0]*distance;
      z = -1;
    }else{
      z = result[1]*distance;
      x = -1;
    }
    print("${x} ${z}");
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: vv.Vector3(0, fixedCoordinatedY, 0),
      scale: vv.Vector3(0.5, 0.5, 0.5),
      rotation: ARTools.getObjectRotation("front"),

    );
    await arObjectManager.addNode(newNode);
    var newNode1 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        //                x,   y,                 z
        position: vv.Vector3(x.toDouble(), fixedCoordinatedY, z.toDouble()),
        scale: vv.Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("left") // left
    );
    await arObjectManager.addNode(newNode1);
  }



  void addDirectionalObjects() async {
    List<int> directionLengthList = [5, 8, 20, 8];
    List<String> directionList = ["front", "left", "left", "left"];

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
    var newNode4 = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: vv.Vector3(0, fixedCoordinatedY, 15),
      scale: vv.Vector3(0.5, 0.5, 0.5),
      rotation: ARTools.getObjectRotation("front"),
    );
    await arObjectManager.addNode(newNode4);

  }

  // void addDirectionalObjects() async {
  //   List<int> directionLengthList = [5, 2, 8, 20, 8];
  //   List<String> directionList = ["front","right", "left", "left", "left"];
  //   double fixedY = -1; // Fixed Y-coordinate
  //
  //   // Initial position and direction (facing front)
  //   vv.Vector3 currentPosition = vv.Vector3(0, fixedY, 0);
  //   vv.Vector3 currentDirection = vv.Vector3(0, 0, -1); // Initially facing forward
  //
  //   for (int i = 0; i < directionList.length; i++) {
  //     // Add an object at the current position
  //     // await add3DObject(currentPosition, getRotation(directionList[i]));
  //
  //     // Move in the current direction by the given length
  //     print("currentDirection ${currentDirection}");
  //     print("currentPosition ${currentPosition}");
  //
  //     currentPosition += currentDirection * directionLengthList[i].toDouble();
  //
  //     // Update direction based on movement
  //     currentDirection = getNewDirection(currentDirection, directionList[i]);
  //
  //   }
  // }

// Function to add 3D object
//   Future<void> add3DObject(vv.Vector3 position, vv.Vector4 rotation) async {
//     var newNode = ARNode(
//       type: NodeType.webGLB,
//       uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
//       position: position,
//       scale: vv.Vector3(0.5, 0.5, 0.5),
//       rotation: rotation,
//     );
//     await arObjectManager.addNode(newNode);
//   }

  Future<void> add3DObject(ARObjectManager arObjectManager, vv.Vector3 position) async {
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: position,
      scale: vv.Vector3(0.5, 0.5, 0.5),
      rotation: vv.Vector4(0, 1, 0, 0), // No rotation
    );
    await arObjectManager.addNode(newNode);
  }

// Function to get rotation for direction
  vv.Vector4 getRotation(String direction) {
    switch (direction) {
      case "left":
        return vv.Vector4(0.0, 1.0, 0.0, -1.5708); // -90° rotation
      case "right":
        return vv.Vector4(0.0, 1.0, 0.0, 1.5708); // +90° rotation
      case "back":
        return vv.Vector4(0.0, 1.0, 0.0, 3.1416); // 180° rotation
      default:
        return vv.Vector4(0.0, 1.0, 0.0, 0.0); // No rotation (front)
    }
  }

// Function to update direction based on movement
  vv.Vector3 getNewDirection(vv.Vector3 currentDirection, String turn) {
    if (turn == "left") {
      return vv.Vector3(currentDirection.z, 0, -currentDirection.x); // Rotate 90° left
    } else if (turn == "right") {
      return vv.Vector3(-currentDirection.z, 0, currentDirection.x); // Rotate 90° right
    } else if (turn == "back") {
      return -currentDirection; // Reverse direction (180°)
    }
    return currentDirection; // Continue in the same direction
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

//
// var newNode = ARNode(
//   type: NodeType.webGLB,
//   uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
//   position: currentPosition,
//   scale: vv.Vector3(0.5, 0.5, 0.5),
//   rotation: ARTools.getObjectRotation("front"),
//
// );
// await arObjectManager.addNode(newNode);
//
// var newNode1 = ARNode(
// type: NodeType.webGLB,
// uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
// position: vv.Vector3(0, fixedCoordinatedY, -5),
// scale: vv.Vector3(0.5, 0.5, 0.5),
// rotation: ARTools.getObjectRotation("left") // left
// );
// await arObjectManager.addNode(newNode1);
//
// var newNode2 = ARNode(
// type: NodeType.webGLB,
// uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
// position: vv.Vector3(-7, fixedCoordinatedY, -5),
// scale: vv.Vector3(0.5, 0.5, 0.5),
// rotation: vv.Vector4(0.0, 1.0, 0.0, -1.5708) // left
//
// );
// await arObjectManager.addNode(newNode2);
//
// var newNode3 = ARNode(
// type: NodeType.webGLB,
// uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
// position: vv.Vector3(-7, fixedCoordinatedY, 15),
// scale: vv.Vector3(0.5, 0.5, 0.5),
// rotation: vv.Vector4(0.0, 1.0, 0.0, 0.0) // left
// );
// await arObjectManager.addNode(newNode3);
//
// var newNode4 = ARNode(
// type: NodeType.webGLB,
// uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
// position: vv.Vector3(0, fixedCoordinatedY, 15),
// scale: vv.Vector3(0.5, 0.5, 0.5),
// rotation: ARTools.getObjectRotation("front"),
// );
// await arObjectManager.addNode(newNode4);
