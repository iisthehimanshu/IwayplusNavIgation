// import 'dart:async';
//
// import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
// import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
// import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
// import 'package:flutter/material.dart';
// import 'package:vector_math/vector_math_64.dart' as vv;
//
//
// class UserPositionScreen extends StatefulWidget {
//   const UserPositionScreen({Key? key}) : super(key: key);
//
//   @override
//   _UserPositionScreenState createState() => _UserPositionScreenState();
// }
// class _UserPositionScreenState extends State<UserPositionScreen> {
//   ARLocationManager? arLocationManager;
//   ARObjectManager? arObjectManager;
//   String userPosition = "Fetching location...";
//   late Timer _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     arLocationManager = ARLocationManager();
//
//     // Set up periodic polling for user location
//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       getUserLocation();
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _timer.cancel(); // Stop the periodic polling when the screen is disposed
//     arLocationManager?.stopLocationUpdates();
//   }
//   late StoreLatLng currentValue;
//
//   // Method to get the current user location
//   Future<StoreLatLng> getUserLocation() async {
//     arLocationManager?.startLocationUpdates();
//
//     final location = await arLocationManager?.currentLocation;
//     if (location != null) {
//       setState(() {
//         userPosition = 'Latitude: ${location.latitude}, Longitude: ${location.longitude}';
//       });
//       currentValue = StoreLatLng(lat: location.latitude,long: location.longitude);
//       print("User Position: ${location.latitude}, ${location.longitude}");
//       // Call method to detect the plane and place 3D object at the user's position
//       //addObjectAtLocation(location.latitude!, location.longitude!);
//     }
//     return currentValue;
//   }
//   ARSessionManager? arSessionManager;
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
//       showFeaturePoints: false,
//       showPlanes: false,
//       customPlaneTexturePath: "Images/triangle.png",
//       showWorldOrigin: false,
//       showAnimatedGuide: false,
//       handleTaps: false,
//     );
//
//     arObjectManager.onInitialize();
//
//     // Handle plane taps and add object
//     arSessionManager.onPlaneDetected = (plane) async {
//       // Retrieve the current camera pose
//       print("plane");
//       print(plane);
//       StoreLatLng value = await getUserLocation();
//       // Retrieve the current camera pose
//       final cameraPose = await arSessionManager.getCameraPose();
//       if (cameraPose != null) {
//         // Get the current camera position
//         vv.Vector3 cameraPosition = cameraPose.getTranslation();
//         vv.Vector3 forwardDirection = vv.Vector3(
//             -cameraPose.storage[8], -cameraPose.storage[9],
//             -cameraPose.storage[10]);
//         // vv.Vector3 planeCenterPosition = vv.Vector3(
//         //   plane.,
//         //   plane.center.y,
//         //   plane.center.z,
//         // );
//         // Calculate the position 1 meter ahead of the camera
//         vv.Vector3 targetPosition = cameraPosition + forwardDirection * 3.0;
//
//         addObjectAtLocation(28.52777,77.2566083);
//         // Create an ARNode for the model
//         ARNode objectNode = ARNode(
//           type: NodeType.webGLB,
//           // uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb", // Path to your model file
//           uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrows2.glb",
//           // Path to your model file
//           position: targetPosition,
//           scale: vv.Vector3(0.2, 0.2, 0.2),
//           // Adjust the scale of the object
//           // rotation: vv.Vector4(1.0, 1.0, 1.0, -2.0), // Rotate the object (w, x, y, z)
//           rotation: vv.Vector4(-1.0, -1.0, -1.0, 0), // Rotate the object (w, x, y, z)
//         );
//
//         // Add the object to the scene
//         bool? didAddNode = await arObjectManager.addNode(objectNode);
//         if (didAddNode != null && didAddNode) {
//           // Set the flag to true after adding the object
//           //isObjectAdded = true;
//           print("Object added 1 meter ahead of the camera!");
//         } else {
//           print("Failed to add object.");
//         }
//       }
//     };
//   }
//   // Method to add a 3D object at a given latitude and longitude
//   Future<void> addObjectAtLocation(double latitude, double longitude) async {
//     // Here, you would use the latitude and longitude to calculate the position in the AR world
//     // For simplicity, we just use it as a position offset
//
//     // Let's assume the target position is based on the AR session's current pose.
//     vv.Vector3 targetPosition = vv.Vector3(latitude.toDouble(), 0.0, longitude.toDouble());
//
//     // Create the ARNode (3D object) and add it to the scene
//     ARNode objectNode = ARNode(
//       type: NodeType.webGLB,
//       uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb", // Your model URL
//       position: targetPosition,
//       scale: vv.Vector3(0.5, 0.5, 0.5), // Scale of the object
//     );
//
//     bool? didAddNode = await arObjectManager!.addNode(objectNode);
//     if (didAddNode != null && didAddNode) {
//       print("Object added at position: $targetPosition");
//     } else {
//       print("Failed to add object.");
//     }
//   }
//
//   // AR View to render the AR scene
//   Widget _buildARView() {
//     return ARView(
//       onARViewCreated: onARViewCreated,
//       planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
//       showPlatformType: true,
//     );
//   }
//
//   // Method to add the model on the detected plane
//   // Future<void> addObjectOnPlane(int plane) async {
//   //   // Get the position of the plane
//   //   vv.Vector3 planePosition = vv.Vector3(plane., plane.center.y, plane.center.z);
//   //
//   //   // Create the ARNode (3D object) and add it to the detected plane
//   //   ARNode objectNode = ARNode(
//   //     type: NodeType.webGLB,
//   //     uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb", // Your model URL
//   //     position: planePosition,
//   //     scale: vv.Vector3(0.5, 0.5, 0.5), // Scale of the object
//   //   );
//   //
//   //   bool? didAddNode = await arObjectManager!.addNode(objectNode);
//   //   if (didAddNode != null && didAddNode) {
//   //     print("Object added at plane center: $planePosition");
//   //   } else {
//   //     print("Failed to add object on the plane.");
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Position Tracker'),
//       ),
//       body: Stack(
//         children: [
//           _buildARView(), // AR View for rendering AR content
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'User Position:',
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     userPosition, // Display current position here
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: getUserLocation,
//                     child: const Text('Get Current Location'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class StoreLatLng{
//   double lat;
//   double long;
//
//   StoreLatLng({required this.lat,required this.long});
//
// }