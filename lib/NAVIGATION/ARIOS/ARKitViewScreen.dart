
import 'dart:io';

import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart';

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

  void onARKitViewCreated(ARKitController arkitController) async {
    this.arkitController = arkitController;
    // final newNode = ARKitNode(
    //   geometry: ARKitTorus(pipeRadius: 5,ringRadius: 5),
    //     position: vector.Vector3(0, 0, -5), // 5 meters in front of the camera
    //     scale: vector.Vector3(0.1, 0.1, 0.1),
    // );
    // this.arkitController.add(newNode);

    final String localPath = await saveAssetToFile('assets/directional_arrow.glb');


    // Create the ARKit node
    final node = ARKitReferenceNode(
      url: localPath, // Pass the local file path
      scale: Vector3(0.1, 0.1, 0.1), // Adjust if needed
      position: Vector3(0, 0, -1), // 1 meter in front
    );

    arkitController.add(node);
  }
  Future<String> saveAssetToFile(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/directional_arrow.glb');

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
