// import 'package:ar_flutter_plugin/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin/models/ar_node.dart';
// import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
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

  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  ARNode? modelNode;
  @override
  void dispose() {
    arSessionManager.dispose();
    arObjectManager.removeNode(modelNode!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: ARView(
        onARViewCreated: onARViewCreated,
      ),
    );
  }

  void onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager, ARAnchorManager _ ,ARLocationManager __) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
    );
    arObjectManager.onInitialize();

    _addModel();
  }


  Future<void> _addModel() async {
    final newNode = ARNode(
      type: NodeType.webGLB,
      uri: 'https://github.com/udit6023/uditsoni_assignment/raw/refs/heads/main/wilson_text.glb', // <-- your .glb file
      scale: Vector3(0.2, 0.2, 0.2),
      position: Vector3(0.0, 0.0, -1.0), // 1 meter in front
      rotation: Vector4(0, 390, -200,-180), // rotate if needed
    );

    final didAdd = await arObjectManager.addNode(newNode);
    if (didAdd!) {
      modelNode = newNode;
    }
  }

}
