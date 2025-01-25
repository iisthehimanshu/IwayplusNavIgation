// import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class ARHome extends StatefulWidget {
//   @override
//   _ARHomeState createState() => _ARHomeState();
// }
//
// class _ARHomeState extends State<ARHome> {
//   ARSessionManager? arSessionManager;
//   ARObjectManager? arObjectManager;
//   late ARPlaneManager? arPlaneManager;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("AR Plane Detection"),
//       ),
//       body: ARView(
//         onARViewCreated: onARViewCreated,
//       ),
//     );
//   }
//
//   void onARViewCreated(ARSessionManager sessionManager) {
//     arSessionManager = sessionManager;
//
//     // Initialize ARObjectManager to manage 3D objects
//     arObjectManager = ARObjectManager(arSessionManager: sessionManager);
//
//     // Start plane detection
//     arSessionManager?.onPlaneDetected = (plane) {
//       debugPrint("Plane detected at ${plane}");
//     };
//
//     // Initialize ARPlaneManager
//     arPlaneManager = ARPlaneManager(arSessionManager: sessionManager);
//   }
//
//   void onPlaneDetected(ARPlane plane) {
//     // Plane detected, you can use the plane information here
//     debugPrint('Plane detected at ${plane.center}');
//   }
//
//   Future<void> placeObjectOnPlane() async {
//     if (arObjectManager != null) {
//       // Define a 3D object to place
//       ARNode objectNode = ARNode(
//         type: NodeType.fileSystemAppFolderGLTF2, // Use GLTF format for 3D models
//         uri: "assets/model.gltf", // Path to your 3D model
//         position: Vector3(0, 0, 0), // Position relative to the plane
//         scale: Vector3(0.1, 0.1, 0.1), // Adjust the scale of the object
//       );
//
//       // Add the object to the detected plane
//       await arObjectManager!.addNode(objectNode);
//     }
//   }
// }