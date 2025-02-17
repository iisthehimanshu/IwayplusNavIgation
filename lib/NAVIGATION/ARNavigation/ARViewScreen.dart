import 'dart:async';

import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ARViewScreen extends StatefulWidget {
  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;
  ARNode? node;
  bool isDragging = false;
  Timer? moveTimer;
  Vector3 currentPosition = Vector3(0.0, 0.0, -5.0); // Initial position



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AR View')),
      body: ARView(
        onARViewCreated: onARViewCreated,
      ),
    );
  }


  Future<void> onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager, ARAnchorManager anchorManager, ARLocationManager locationManager,) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
      handleTaps: true,
    );

    arObjectManager.onNodeTap = (nodes) {
      if (nodes.isNotEmpty && node != null) {
        //_moveObject(); // Move when tapped
        _startAnimation();
      }
    };

    _placeObject(currentPosition);
  }

  Future<void> _placeObject(Vector3 position) async {
    // Remove the existing node before placing a new one
    if (node != null) {
      await arObjectManager.removeNode(node!);
    }

    node = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      scale: Vector3(0.5, 0.5, 0.5),
      position: position, // Updated position
    );

    bool? added = await arObjectManager.addNode(node!);
    if (!added!) {
      print("Failed to add object");
    }
  }
  void _startAnimation() {
    moveTimer?.cancel(); // Cancel any existing animation
    double moveStep = 5; // Adjust speed
    moveTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      currentPosition = Vector3(
        currentPosition.x,
        currentPosition.y,
        currentPosition.z + moveStep, // Move forward
      );

      _placeObject(currentPosition); // Remove & re-add at new position
    });
  }

  @override
  void dispose() {
    moveTimer?.cancel();
    super.dispose();
  }

  // Move object dynamically
  void _moveObject() {
    if (node != null) {
      Vector3 newPosition = Vector3(node!.position.x + 1.0, node!.position.y, node!.position.z);
      _placeObject(newPosition); // Re-add at new position
      print("Object moved to: $newPosition");
    }
  }
}