import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARDepthScreen extends StatefulWidget {
  @override
  _ARDepthScreenState createState() => _ARDepthScreenState();
}

class _ARDepthScreenState extends State<ARDepthScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;

  vector.Vector3? lastCameraPosition;
  double? distanceMoved;

  Future<void> onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager,ARAnchorManager anchorManager, ARLocationManager locationManager) async {
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false, // Optional: Useful for debugging
    );
    try {
      final cameraPose = await arSessionManager.getCameraPose();
      if (cameraPose == null) {
        print("Error: Unable to get camera pose");
        return;
      }

      vector.Vector3 currentCameraPosition = vector.Vector3(
        cameraPose.storage[12], // X position
        cameraPose.storage[13], // Y position
        cameraPose.storage[14], // Z position
      );

      if (lastCameraPosition != null) {
        // Calculate the Euclidean distance moved
        double moved = (currentCameraPosition - lastCameraPosition!).length;
        setState(() {
          distanceMoved = moved;
        });
        print("Camera moved: $moved meters");
      }

      // Update the last known position
      lastCameraPosition = currentCameraPosition;
    } catch (e) {
      print("Error getting camera pose: $e");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera Movement Estimation")),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.none,
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: ElevatedButton(
              onPressed: estimateCameraMovement,
              child: Text("Measure Camera Movement"),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: Text(
              distanceMoved != null ? "Moved: ${distanceMoved!.toStringAsFixed(2)}m" : "Move the Camera",
              style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Function to estimate camera movement
  void estimateCameraMovement() async {
    try {
      arSessionManager.onInitialize(
        showFeaturePoints: false,
        showPlanes: false,
        showWorldOrigin: false, // Optional: Useful for debugging
      );
      final cameraPose = await arSessionManager.getCameraPose();
      if (cameraPose == null) {
        print("Error: Unable to get camera pose");
        return;
      }

      vector.Vector3 currentCameraPosition = vector.Vector3(
        cameraPose.storage[12], // X position
        cameraPose.storage[13], // Y position
        cameraPose.storage[14], // Z position
      );

      if (lastCameraPosition != null) {
        // Calculate the Euclidean distance moved
        double moved = (currentCameraPosition - lastCameraPosition!).length;
        setState(() {
          distanceMoved = moved;
        });
        print("Camera moved: $moved meters");
      }

      // Update the last known position
      lastCameraPosition = currentCameraPosition;
    } catch (e) {
      print("Error getting camera pose: $e");
    }
  }
}
