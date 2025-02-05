import 'dart:async';
import 'dart:math';

import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:iwaymaps/IWAYPLUS/Elements/HelperClass.dart';
import 'package:vector_math/vector_math_64.dart' as vv;

import '../Navigation.dart';
import '../UserState.dart';
import '../navigationTools.dart';
import 'ARTools.dart';

class CombinedScreen extends StatefulWidget {
  UserState user;

  CombinedScreen({required this.user});


  @override
  _CombinedScreenState createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> {
  OverlayEntry? _overlayEntry;

  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;
  vv.Vector3? initialPosition;
  vv.Vector3 currentPosition = vv.Vector3.zero();

  double height = 200;
  Timer? alignmentTimer; // Timer reference
  bool isAligned = false;

  List<int> directionLengthList = [5,8,20,8];
  List<String> directionList = ["front","left","left","left"];


  @override
  void initState() {
    super.initState();

  }
  late vv.Vector3 forwardd;
  late vv.Vector3 startdirection;
  late double x ;
  late double y ;
  late double z;

  vv.Vector3? cameraPosition;
  vv.Quaternion? cameraRotation;

  vv.Vector3 getTranslation(Matrix4 matrix) {
    return vv.Vector3(matrix.entry(0, 3), matrix.entry(1, 3), matrix.entry(2, 3));
  }

  Future<void> startAlignmentCheck() async {

    int col = widget.user.pathobj.numCols![widget.user.bid]![widget.user.floor]!;

    List<int> a = [widget.user.showcoordX, widget.user.showcoordY];
    List<int> tval = tools.eightcelltransition(widget.user.theta);
    List<int> b = [widget.user.showcoordX + tval[0], widget.user.showcoordY + tval[1]];

    int index = widget.user.path.indexOf((widget.user.showcoordY * col) + widget.user.showcoordX);
    if (index + 1 >= widget.user.path.length) return; // Prevent out-of-bounds error

    int node = widget.user.path[index + 1];
    List<int> c = [node % col, node ~/ col];

    int val = tools.calculateAngleSecond(a, b, c).toInt();
    var pose = await arSessionManager.getCameraPose();

    // If already running, do nothing
    if (alignmentTimer != null && alignmentTimer!.isActive) return;

    alignmentTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
 
      print("Checking alignment...");

      if ((widget.user.theta.abs())>val-5 && (widget.user.theta.abs()<val+5)) {

        var pose = await arSessionManager.getCameraPose();
        if (pose != null) {

          print("pose.matrixEulerAngles");
          print("${pose.matrixEulerAngles}");
          print("${pose.getRotation()}");
          print("${pose.getRotation().getRow(0)}");
          setState(() {
            cameraPosition = pose.forward;
          });

          vv.Matrix3 rotationMatrix = pose.getRotation();
          vv.Vector3 eulerAngles = matrixToEuler(rotationMatrix);

          double yawDegrees = vv.degrees(eulerAngles.z); // Convert radians to degrees
          print("Heading Direction (Yaw): $yawDegrees°");
          double distance = 0.0; // Distance to place the object in meters
          double headingRadians = eulerAngles.z;

          double offsetX = distance * cos(headingRadians);
          double offsetZ = distance * sin(headingRadians);
          vv.Vector3 cameraPosition2 = getTranslation(pose);


          vv.Vector3 objectPosition = vv.Vector3(cameraPosition2.x + offsetX,
              cameraPosition2.y,
              cameraPosition2.z + offsetZ);




          // var newNode = ARNode(
          //   type: NodeType.webGLB,
          //   uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
          //   position: cameraPosition,
          //   scale: vv.Vector3(0.2, 0.2, 0.2),
          //   rotation: ARTools.getObjectRotation("front"),
          // );
          // await arObjectManager.addNode(newNode);


          var newNodeagain = ARNode(
            type: NodeType.webGLB,
            uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
            position: objectPosition,
            scale: vv.Vector3(0.2, 0.2, 0.2),
            rotation: ARTools.getObjectRotation("right"),
          );
          await arObjectManager.addNode(newNodeagain);

          double newoffsetX = 5 * cos(headingRadians);
          double newoffsetZ = 5 * sin(headingRadians);

          vv.Vector3 newPosition = vv.Vector3(cameraPosition2.x + newoffsetX,
              cameraPosition2.y,
              cameraPosition2.z + newoffsetZ);
          var newNodeagain2 = ARNode(
            type: NodeType.webGLB,
            uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
            position: newPosition,
            scale: vv.Vector3(0.2, 0.2, 0.2),
            rotation: ARTools.getObjectRotation("front"),
          );
          await arObjectManager.addNode(newNodeagain2);

          alignmentTimer?.cancel();
          //addDirectionalObjects();

          HelperClass.showToast("Camera Position: ${cameraPosition}");
        }
      }



      // vv.Vector3 currentCameraPosition = vv.Vector3(pose!.row3.x, pose!.row3.y-1, pose!.row3.z);
      //
      // print("val");
      // print(val);
      // print(val-20);
      // print(val+20);
      // print(widget.user.theta.abs());
      // print(widget.user.theta.abs());
      //
      // forwardd = pose!.forward;
      // //print(forwardd);
      //
      // x = forwardd.x;
      // y = forwardd.y;
      // z = forwardd.z;
      // startdirection = vv.Vector3(x,y-1,-z);
      //
      // if ((widget.user.theta.abs())>val-5 && (widget.user.theta.abs()<val+5)) {
      //   isAligned = true;
      //   print("User Aligned");
      //   print(currentCameraPosition);
      //
      //   print("x: $x, y: $y, z: $z");
      //
      //   HelperClass.showToast("User Aligned }");
      //   setState(() {});
      //   addDirectionalObjects();
      //   timer.cancel();
      // } else {
      //   print("Not Aligned");
      //   print(currentCameraPosition);
      //   //print(forwardd);
      //   HelperClass.showToast("Not Aligned }");
      // }
    });
  }

  vv.Vector3 matrixToEuler(vv.Matrix3 rotationMatrix) {
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

    return vv.Vector3(vv.radians(x), vv.radians(y), vv.radians(z));
  }

  void _showNavigationOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // right: 5.0,
        // left: 5,
        bottom: 2.0,
        child: Material(
          elevation: 4.0,
          color: Colors.transparent, // Ensure transparency for shadow
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(200.0),
            topRight: Radius.circular(200.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(200.0),
              topRight: Radius.circular(200.0),
            ),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height -200,
              color: Colors.white,
              child: Navigation(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // void addDirectionalObjects() async {
  //   print("addDirectionalObjects");
  //   List<int> directionLengthList = [5, 8, 20, 8];
  //   List<String> directionList = ["front", "left", "left", "left"];
  //   double fixedCoordinatedY = -1;
  //
  //
  //
  //   vv.Vector3 currentPosition = vv.Vector3(0, fixedCoordinatedY, 0); // Start at (0, -0.5, 0)
  //   vv.Vector3 currentDirection = vv.Vector3(0, 0, -1); // Initially facing forward
  //   var newNode = ARNode(
  //     type: NodeType.webGLB,
  //     uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
  //     position: currentPosition,
  //     scale: vv.Vector3(0.5, 0.5, 0.5),
  //     rotation: ARTools.getObjectRotation("front"),
  //
  //   );
  //   await arObjectManager.addNode(newNode);
  //
  //   var newNode1 = ARNode(
  //       type: NodeType.webGLB,
  //       uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
  //       position: vv.Vector3(0, fixedCoordinatedY, -5),
  //       scale: vv.Vector3(0.5, 0.5, 0.5),
  //       rotation: ARTools.getObjectRotation("left") // left
  //   );
  //   await arObjectManager.addNode(newNode1);
  //
  //   var newNode2 = ARNode(
  //       type: NodeType.webGLB,
  //       uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
  //       position: vv.Vector3(-7, fixedCoordinatedY, -5),
  //       scale: vv.Vector3(0.5, 0.5, 0.5),
  //       rotation: vv.Vector4(0.0, 1.0, 0.0, -1.5708) // left
  //
  //   );
  //   await arObjectManager.addNode(newNode2);
  //
  //   var newNode3 = ARNode(
  //       type: NodeType.webGLB,
  //       uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
  //       position: vv.Vector3(-7, fixedCoordinatedY, 15),
  //       scale: vv.Vector3(0.5, 0.5, 0.5),
  //       rotation: vv.Vector4(0.0, 1.0, 0.0, 0.0) // left
  //   );
  //   await arObjectManager.addNode(newNode3);
  //
  //
  //   // for (int i = 0; i < directionList.length; i++) {
  //   //   // Move in current direction
  //   //   currentPosition += currentDirection * directionLengthList[i].toDouble();
  //   //
  //   //   // Add the model at the calculated position
  //   //   var newNode = ARNode(
  //   //     type: NodeType.webGLB,
  //   //     uri: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/earth.glb",
  //   //     position: currentPosition,
  //   //     scale: vv.Vector3(0.5, 0.5, 0.5),
  //   //   );
  //   //   await arObjectManager.addNode(newNode);
  //   //
  //   //   // Rotate the direction vector based on "left" or "right" (90-degree turns)
  //   //   if (directionList[i] == "left") {
  //   //     currentDirection = vv.Vector3(currentDirection.z, 0, -currentDirection.x); // Rotate 90° left
  //   //   } else if (directionList[i] == "right") {
  //   //     currentDirection = vv.Vector3(-currentDirection.z, 0, currentDirection.x); // Rotate 90° right
  //   //   }
  //   // }
  // }

  void addDirectionalObjects() async {
    print("runnedaddDirectionalObjects");
    // print(forwardd);

    var pose = await arSessionManager.getCameraPose();

    if (pose != null) {

      vv.Vector3 currentCameraPosition = vv.Vector3(pose.row3.x, pose.row3.y-1, pose.row3.z);

      // Check if the user is aligned (adjust conditions as per your requirement)
      //print("✅ User aligned! Placing objects at: $startdirection");

      double fixedCoordinatedY = currentCameraPosition.y - 1.0; // Adjusted Y position

      // Place objects at the user's aligned position
      var newNode = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: cameraPosition,
        scale: vv.Vector3(0.2, 0.2, 0.2),
        rotation: ARTools.getObjectRotation("front"),
      );
      await arObjectManager.addNode(newNode);

      // vv.Vector3 newcurrentCameraPosition = vv.Vector3(pose.row3.x, pose.row3.y-1, pose.row3.z-5);
      //
      //
      // var nextTurnNode = ARNode(
      //     type: NodeType.webGLB,
      //   uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      //   position: vv.Vector3(x,y-1,-5),
      //   scale: vv.Vector3(0.2, 0.2, 0.2),
      //   rotation: ARTools.getObjectRotation("left"),
      // );
      // await arObjectManager.addNode(nextTurnNode);

    }
  }


  @override
  void dispose() {
    alignmentTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
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
      showWorldOrigin: false,
      
    );

    arSessionManager.getCameraPose().then((pose) {
      if (pose != null) {
        initialPosition = vv.Vector3(pose.row3.x, pose.row3.y, pose.row3.z);
        print("Initial Position Captured: $initialPosition");
      } else {
        print("Failed to capture initial position");
      }
    });
    // addFloatingObject();
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Stack(
        children: [
          // ARView occupies the entire screen
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.none,
          ),
          Positioned(
            bottom: 20,
              child: FloatingActionButton(
                onPressed: (){
                  startAlignmentCheck();
                },
                child: Icon(Icons.add),
            )
          )
        ],
      ),
    );
  }
}
