import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';


class DebugOptions extends StatefulWidget {
  const DebugOptions({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<DebugOptions> createState() => _DebugOptionsState();
}

class _DebugOptionsState extends State<DebugOptions> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  bool _showFeaturePoints = true;
  bool _showPlanes = true;
  bool _showWorldOrigin = true;
  bool _showAnimatedGuide = true;
  String _planeTexturePath = "Images/triangle.png";
  bool _handleTaps = true;

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Options'),
      ),
      body: Container(
        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
              showPlatformType: true,
            ),
            Align(
              alignment: FractionalOffset.bottomRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                color: Color(0xFFFFFFF).withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Feature Points'),
                      value: _showFeaturePoints,
                      onChanged: (bool value) {
                        setState(() {
                          _showFeaturePoints = value;
                          updateSessionSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Planes'),
                      value: _showPlanes,
                      onChanged: (bool value) {
                        setState(() {
                          _showPlanes = value;
                          updateSessionSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('World Origin'),
                      value: _showWorldOrigin,
                      onChanged: (bool value) {
                        setState(() {
                          _showWorldOrigin = value;
                          updateSessionSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Place Object on Plane'),
                      value: _handleTaps,
                      onChanged: (bool value) {
                        setState(() {
                          _handleTaps = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: _showFeaturePoints,
      showPlanes: _showPlanes,
      customPlaneTexturePath: _planeTexturePath,
      showWorldOrigin: _showWorldOrigin,
      showAnimatedGuide: _showAnimatedGuide,
      handleTaps: _handleTaps,
    );

    arObjectManager.onInitialize();

    // Handle plane taps and add object
    arSessionManager.onPlaneOrPointTap = (List<ARHitTestResult> hitTestResults) {
      if (hitTestResults.isNotEmpty && _handleTaps) {
        final hitTestResult = hitTestResults.first;
        addObjectToPlane(hitTestResult);
      }
    };
  }

  // Function to add object to plane
  void addObjectToPlane(ARHitTestResult hitTestResult) async {
    if (arObjectManager != null) {
      // Create a node to add a 3D model (GLTF format)
      ARNode objectNode = ARNode(
        type: NodeType.fileSystemAppFolderGLB,
        uri: "assets/fan2.glb", // Path to your model file
        position: hitTestResult.worldTransform.getTranslation(),
        scale: Vector3(0.1, 0.1, 0.1), // Adjust the scale of the object
      );

      // Add the node to the AR scene
      await arObjectManager!.addNode(objectNode);
    }
  }

  void updateSessionSettings() {
    arSessionManager?.onInitialize(
      showFeaturePoints: _showFeaturePoints,
      showPlanes: _showPlanes,
      customPlaneTexturePath: _planeTexturePath,
      showWorldOrigin: _showWorldOrigin,
    );
  }
}
