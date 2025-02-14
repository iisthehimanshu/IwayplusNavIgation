import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARKitViewScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ARKitViewScreen> {
  late ARKitController arkitController;
  late ARSessionManager arSessionManager;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: ARKitSceneView(onARKitViewCreated: onARKitViewCreated,
        enableTapRecognizer: false,
        showFeaturePoints: false,
        showWorldOrigin: true,
      )
  );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final newNode = ARKitNode(
      geometry: ARKitTorus(pipeRadius: 5,ringRadius: 5),
        position: vector.Vector3(0, 0, -5), // 5 meters in front of the camera
        scale: vector.Vector3(0.1, 0.1, 0.1),
    );
    this.arkitController.add(newNode);

    final node = ARKitReferenceNode(
      url: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: vector.Vector3(0, 0, -5), // 5 meters in front of the camera
      scale: vector.Vector3(0.1, 0.1, 0.1), // Adjust scale if needed
    );
    this.arkitController.add(node);
  }
}
