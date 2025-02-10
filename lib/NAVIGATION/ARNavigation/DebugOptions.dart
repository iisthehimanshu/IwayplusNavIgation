// import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
// import 'package:ar_flutter_plugin_flutterflow/models/ar_hittest_result.dart';
// import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:iwaymaps/IWAYPLUS/Elements/HelperClass.dart';
// import 'package:vector_math/vector_math_64.dart' as vv;
//
//
// class DebugOptions extends StatefulWidget {
//   const DebugOptions({
//     super.key,
//     this.width,
//     this.height,
//   });
//
//   final double? width;
//   final double? height;
//
//   @override
//   State<DebugOptions> createState() => _DebugOptionsState();
// }
//
// class _DebugOptionsState extends State<DebugOptions> {
//   ARSessionManager? arSessionManager;
//   ARObjectManager? arObjectManager;
//   bool _showFeaturePoints = false;
//   bool _showPlanes = false;
//   bool _showWorldOrigin = false;
//   bool _showAnimatedGuide = true;
//   String _planeTexturePath = "Images/triangle.png";
//   bool _handleTaps = true;
//   bool isObjectAdded = false;
//
//   @override
//   void dispose() {
//     super.dispose();
//     arSessionManager?.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Debug Options'),
//       ),
//       body: Container(
//         child: Stack(
//           children: [
//             ARView(
//               onARViewCreated: onARViewCreated,
//               planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
//               showPlatformType: true,
//             ),
//             Positioned(
//               bottom: 20,
//               left: 20,
//               child: ElevatedButton(
//                 onPressed: _placeObjectOnPlane,
//                 child: const Text("Place Object"),
//               ),
//             ),
//             Align(
//               alignment: FractionalOffset.bottomRight,
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.5,
//                 color: Color(0xFFFFFFF).withOpacity(0.5),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SwitchListTile(
//                       title: const Text('Feature Points'),
//                       value: _showFeaturePoints,
//                       onChanged: (bool value) {
//                         setState(() {
//                           _showFeaturePoints = value;
//                           updateSessionSettings();
//                         });
//                       },
//                     ),
//                     SwitchListTile(
//                       title: const Text('Planes'),
//                       value: _showPlanes,
//                       onChanged: (bool value) {
//                         setState(() {
//                           _showPlanes = value;
//                           updateSessionSettings();
//                         });
//                       },
//                     ),
//                     SwitchListTile(
//                       title: const Text('World Origin'),
//                       value: _showWorldOrigin,
//                       onChanged: (bool value) {
//                         setState(() {
//                           _showWorldOrigin = value;
//                           updateSessionSettings();
//                         });
//                       },
//                     ),
//                     SwitchListTile(
//                       title: const Text('Place Object on Plane'),
//                       value: _handleTaps,
//                       onChanged: (bool value) {
//                         setState(() {
//                           _handleTaps = value;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//   void onARViewCreated(
//       ARSessionManager arSessionManager,
//       ARObjectManager arObjectManager,
//       ARAnchorManager arAnchorManager,
//       ARLocationManager arLocationManager) {
//     this.arSessionManager = arSessionManager;
//     this.arObjectManager = arObjectManager;
//
//
//     arSessionManager.onInitialize(
//       showFeaturePoints: _showFeaturePoints,
//       showPlanes: _showPlanes,
//       customPlaneTexturePath: _planeTexturePath,
//       showWorldOrigin: _showWorldOrigin,
//       showAnimatedGuide: _showAnimatedGuide,
//       handleTaps: _handleTaps,
//     );
//
//     arObjectManager.onInitialize();
//
//     // Handle plane taps and add object
//     arSessionManager.onPlaneDetected = (plane) async {
//       // Retrieve the current camera pose
//       if (isObjectAdded) {
//         print("Object already added. Cannot add another one.");
//         return; // Prevent adding a new object if one is already placed
//       }
//
//       // Retrieve the current camera pose
//       final cameraPose = await arSessionManager.getCameraPose();
//       if (cameraPose != null) {
//         // Get the current camera position
//         vv.Vector3 cameraPosition = cameraPose.getTranslation();
//         vv.Vector3 forwardDirection = vv.Vector3(-cameraPose.storage[8], -cameraPose.storage[9], -cameraPose.storage[10]);
//         // vv.Vector3 planeCenterPosition = vv.Vector3(
//         //   plane.,
//         //   plane.center.y,
//         //   plane.center.z,
//         // );
//         // Calculate the position 1 meter ahead of the camera
//         vv.Vector3 targetPosition = cameraPosition + forwardDirection * 3.0;
//
//         // Create an ARNode for the model
//         ARNode objectNode = ARNode(
//           type: NodeType.webGLB,
//           // uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb", // Path to your model file
//           uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrows2.glb", // Path to your model file
//           position: targetPosition,
//           scale: vv.Vector3(0.2, 0.2, 0.2), // Adjust the scale of the object
//           // rotation: vv.Vector4(1.0, 1.0, 1.0, -2.0), // Rotate the object (w, x, y, z)
//           rotation: vv.Vector4(1.0, 0.0, 0.0, 0), // Rotate the object (w, x, y, z)
//         );
//
//         // Add the object to the scene
//         bool? didAddNode = await arObjectManager.addNode(objectNode);
//         if (didAddNode != null && didAddNode) {
//           // Set the flag to true after adding the object
//           isObjectAdded = true;
//           print("Object added 1 meter ahead of the camera!");
//         } else {
//           print("Failed to add object.");
//         }
//       }
//     };
//
//     arSessionManager.onPlaneOrPointTap = (List<ARHitTestResult> hitTestResults) {
//       if (hitTestResults.isNotEmpty && _handleTaps) {
//         final hitTestResult = hitTestResults.first;
//         double distance = hitTestResult.distance;  // The distance from the camera to the hit test result
//         // addObjectToPlane(hitTestResult);
//         print("Distance is ${distance}");
//         HelperClass.showToast("Distance is ${distance}");
//         arSessionManager.getCameraPose().then((cameraPose) async {
//           // Calculate the position 3 meters in front of the camera
//           if (cameraPose != null) {
//             vv.Vector3 cameraPosition = cameraPose!.getTranslation();
//             vv.Vector3 newPosition = vv.Vector3(cameraPosition.x, cameraPosition.y, cameraPosition.z - 1.0); // 3 meters in front
//
//             // Add the cube (or 3D object) to the AR scene at the new position
//             ARNode objectNode = ARNode(
//               type: NodeType.webGLB,
//               uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb", // Path to your model file
//               position: newPosition,
//               scale: vv.Vector3(0.1, 0.1, 0.1), // Adjust the scale of the object
//             );
//
//             // Add the node to the AR scene
//             await arObjectManager!.addNode(objectNode);
//
//           }
//
//         });
//       }
//     };
//   }
//
//   void _placeObjectOnPlane() async {
//     arSessionManager?.onPlaneDetected = (plane) {
//       arSessionManager?.getCameraPose().then((cameraPose) async {
//         // Calculate the position 3 meters in front of the camera
//         if (cameraPose != null) {
//           vv.Vector3 cameraPosition = cameraPose!.getTranslation();
//           vv.Vector3 newPosition = vv.Vector3(
//               cameraPosition.x, cameraPosition.y,
//               cameraPosition.z - 1.0); // 3 meters in front
//           if (arObjectManager != null) {
//             ARNode objectNode = ARNode(
//               type: NodeType.webGLB,
//               uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
//               // Path to your model file
//               position: newPosition,
//               scale: vv.Vector3(
//                   0.1, 0.1, 0.1), // Adjust the scale of the object
//             );
//
//             bool? didAddNode = await arObjectManager!.addNode(objectNode);
//             if (didAddNode != null && didAddNode) {
//               setState(() {
//                 isObjectAdded = true;
//               });
//               print("Object added to the detected plane!");
//             } else {
//               print("Failed to add object.");
//             }
//           }
//         }
//       });
//     };
//   }
//   // Function to add object to plane
//   void addObjectToPlane(ARHitTestResult hitTestResult) async {
//     if (arObjectManager != null) {
//       // Create a node to add a 3D model (GLTF format)
//       ARNode objectNode = ARNode(
//         type: NodeType.webGLB,
//         uri: "https://github.com/KhronosGroup/glTF-Sample-Models/raw/refs/heads/main/2.0/Duck/glTF-Binary/Duck.glb", // Path to your model file
//         position: hitTestResult.worldTransform.getTranslation(),
//         scale: vv.Vector3(0.1, 0.1, 0.1), // Adjust the scale of the object
//       );
//       // Add the node to the AR scene
//       await arObjectManager!.addNode(objectNode);
//     }
//   }
//
//   void updateSessionSettings() {
//     arSessionManager?.onInitialize(
//       showFeaturePoints: _showFeaturePoints,
//       showPlanes: _showPlanes,
//       customPlaneTexturePath: _planeTexturePath,
//       showWorldOrigin: _showWorldOrigin,
//     );
//   }
// }
