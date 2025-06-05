// import 'package:ar_flutter_plugin/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin/models/ar_node.dart';
// import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {

  // void onARViewCreated(
  //     ARSessionManager arSessionManager,
  //     ARObjectManager? arObjectManager,
  //     ARAnchorManager? arAnchorManager,
  //     ) {
  //   // Your setup logic here
  // }

  late ARKitController arkitController;
  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('ARKit in Flutter')),
      body: ARKitSceneView(onARKitViewCreated: onARKitViewCreated));

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final node = ARKitNode(
        geometry: ARKitText(text: "3A-2B", extrusionDepth: 2),
      position: Vector3(-1, 0, -0.5),
      rotation: Vector4(0, 5, 0,0),
      scale: Vector3(0.03, 0.03, 0.03)
    );
    this.arkitController.add(node);
  }

}
