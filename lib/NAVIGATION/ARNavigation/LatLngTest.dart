// import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
// import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;
//
// class ARLocationMarker extends StatefulWidget {
//   @override
//   _ARLocationMarkerState createState() => _ARLocationMarkerState();
// }
//
// class _ARLocationMarkerState extends State<ARLocationMarker> {
//   ARSessionManager? arSessionManager;
//   ARObjectManager? arObjectManager;
//   ARNode? localObjectNode;
//
//   Position? _currentPosition;
//   double markerLatitude = 37.7749; // Example marker latitude
//   double markerLongitude = -122.4194; // Example marker longitude
//   double markerDistance = 10.0; //Example marker distance in meters.
//   double markerBearing = 45.0; //Example marker bearing in degrees.
//   bool arReady = false;
//
//   @override
//   void dispose() {
//     arSessionManager?.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }
//
//   Future<void> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     _currentPosition = await Geolocator.getCurrentPosition();
//     setState(() {
//       arReady = true;
//     });
//   }
//
//   void onARViewCreated(
//       ARSessionManager arSessionManager, ARObjectManager arObjectManager) {
//     this.arSessionManager = arSessionManager;
//     this.arObjectManager = arObjectManager;
//     this.arSessionManager!.onInitialize(
//       showFeaturePoints: false,
//       showPlanes: false,
//       customPlaneTexturePath: "assets/trianglePlane.png",
//       showWorldOrigin: true,
//       handleTaps: false,
//     );
//     this.arObjectManager!.onInitialize();
//     _addMarker();
//   }
//
//   Future<void> _addMarker() async {
//     if (!arReady || _currentPosition == null) return;
//     double userLat = _currentPosition!.latitude;
//     double userLong = _currentPosition!.longitude;
//     double userBearing = _currentPosition!.heading;
//
//     // Simplified calculation, needs refinement for real-world accuracy
//     vector.Vector3 markerPosition = calculateMarkerPosition(
//         userLat, userLong, userBearing, markerLatitude, markerLongitude, markerDistance, markerBearing);
//
//     var newNode = ARNode(
//         type: NodeType.webGLB,
//         position: markerPosition,
//         scale: vector.Vector3(0.1, 0.1, 0.1), uri: '');
//
//     bool? didAddLocalNode = await this.arObjectManager!.addNode(newNode);
//     localObjectNode = (didAddLocalNode!) ? newNode : null;
//   }
//
//   vector.Vector3 calculateMarkerPosition(
//       double userLat,
//       double userLong,
//       double userBearing,
//       double markerLat,
//       double markerLong,
//       double distance,
//       double bearing) {
//     // This is a placeholder. Real calculation requires complex coordinate transformations.
//     // Consider using libraries like geocoding or specialized spatial math libraries.
//     // This example uses a simplified linear approximation, which will be inaccurate.
//     double x = distance * vector.cos(vector.radians(bearing));
//     double z = distance * vector.sin(vector.radians(bearing));
//     return vector.Vector3(x, 0, -z); // Y is 0 for simplicity, adjust as needed.
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('AR Location Marker')),
//       body: arReady ? ARView(
//         onARViewCreated: onARViewCreated,
//       ) : Center(child: CircularProgressIndicator()),
//     );
//   }
// }