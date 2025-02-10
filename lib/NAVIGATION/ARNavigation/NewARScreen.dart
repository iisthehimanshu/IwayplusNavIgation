import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';

import '../Cell.dart';
import '../UserState.dart';
import '../navigationTools.dart';
import '../pathState.dart';
import 'ARTools.dart';

class ARScreen extends StatefulWidget {
  UserState user;
  pathState PathState;

  ARScreen({required this.user,required this.PathState});
  @override
  _ARScreenState createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;
  ARNode? objectNode;


  @override
  void initState() {
    super.initState();
    // doInitialAsyncTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AR Object Rendering")),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: placeObjectAhead,
              child: Text("Place Object"),
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) async{
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;
    arSessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false,
    );
    // var newNode = ARNode(
    //   type: NodeType.webGLB,
    //   uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
    //   position: Vector3(0, -1, 0),
    //   scale: Vector3(0.5, 0.5, 0.5),
    //   rotation: ARTools.getObjectRotation("front"),
    //
    // );
    // await arObjectManager.addNode(newNode);
    doInitialAsyncTasks();

  }
  late List<Cell> turnPoints = [];
  List<ARNode> arNodes = [];


  void doInitialAsyncTasks()async {
    turnPoints = await tools.getCellTurnpoints(widget.user.cellPath);
    print("turnPoints");
    print(turnPoints);
    List<int> initial = [];
    String direction = "";
    double lastXAxisTravel = 0;
    double lastZAxisTravel = 0;
    for(int i=0 ; i<turnPoints.length ; i++){
      if(i==0){
        initial.add(0);
        initial.add(0);
        widget.PathState.directions.forEach((value) {
          if (value.x == turnPoints[i].x && value.y == turnPoints[i].y) {
            direction = value.turnDirection!;
          }
        });
        ARNode node = ARNode(
          type: NodeType.webGLB,
          uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
          position: Vector3(initial[0].toDouble(), -1, initial[1].toDouble()), // 5 meters ahead in AR
          scale: Vector3(0.5, 0.5, 0.5),
          rotation: ARTools.getObjectRotation("left"),
        );
        await arObjectManager!.addNode(node);

      }else{
        print("For turn ${i}");
        print("initial was${initial} ${direction}");
        List<int> getQuad = ARTools.getQuadrant(initial, direction);
        print("gotSecondQuad${getQuad}");
        print("previousXY ${turnPoints[i-1].x} ${turnPoints[i-1].y}");
        print("currentXY ${turnPoints[i].x} ${turnPoints[i].y}");
        int distanceX = turnPoints[i].y - turnPoints[i-1].y;
        int distanceZ = turnPoints[i].x - turnPoints[i-1].x;
        print("gotdistanceCoord ${distanceX.abs()} ${distanceZ.abs()}");
        double VectorXdistance;
        double VectorZdistance;
        if(distanceX == 0 && getQuad[0].abs()==1 && getQuad[1].abs()==1){
          distanceX = lastXAxisTravel.toInt();
          VectorXdistance = distanceX.abs().toDouble();
          print("distanceX is 0 adding ${lastXAxisTravel.toInt()} =  ${distanceX}") ;
        }else{
          if(getQuad[0]==0 && getQuad[1]==-1) {
            if (direction == "Turn Left, and Go Straight"){
              VectorXdistance = distanceX.abs() + lastXAxisTravel.abs();
            }else if(direction == "Turn Right, and Go Straight"){
              VectorXdistance = distanceX.abs() - lastZAxisTravel.abs();
            }
          }
          VectorXdistance = distanceX.abs().toDouble()/2-lastXAxisTravel;
          lastXAxisTravel = VectorXdistance;
        }
        if(distanceZ == 0 && getQuad[0].abs()==1 && getQuad[1].abs()==1){
          distanceZ = lastZAxisTravel.toInt();
          print("distanceZ is 0 adding lasttravel${lastZAxisTravel.toInt()} =  ${distanceZ}") ;

        }else{
          VectorZdistance = distanceZ.abs().toDouble()/2-lastZAxisTravel;
          lastZAxisTravel = VectorZdistance;
        }


        // print("gotdistanceCoord ${VectorXdistance} ${VectorZdistance}");
        //
        // print("gotdistanceCoord ${getQuad[0]*VectorXdistance.abs()} ${getQuad[1]*VectorZdistance.abs()}");
        ARNode node = ARNode(
          type: NodeType.webGLB,
          uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
          position: Vector3(initial[0]==0?distanceZ.toDouble()/2:distanceZ*initial[0].toDouble()/2, -1, initial[1]==0?distanceX.toDouble()/2:distanceX*initial[1].toDouble()/2), // 5 meters ahead in AR
          scale: Vector3(0.5, 0.5, 0.5),
          rotation: ARTools.getObjectRotation("left"),
        );
        await arObjectManager!.addNode(node);

        initial = getQuad;
        widget.PathState.directions.forEach((value) {
          if (value.x == turnPoints[i].x && value.y == turnPoints[i].y) {
            direction = value.turnDirection!;
          }
        });

      }

      print("turnpointsss---${turnPoints[i]}");
    }

  }

  void placeObjectAhead() async {
    if (arObjectManager == null) return;

    objectNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: Vector3(0.0, -1, -5.0), // 5 meters ahead in AR
      scale: Vector3(0.5, 0.5, 0.5),
      rotation: ARTools.getObjectRotation("left"),
    );

    bool? didAdd = await arObjectManager!.addNode(objectNode!);
    if (didAdd == true) {
      print("Object placed 5m ahead");
    }

    ARNode objectNode1 = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: Vector3(-7.0, -1, -5.0), // 5 meters ahead in AR
      scale: Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("back") // left
    );
    await arObjectManager!.addNode(objectNode1!);
    ARNode objectNode2 = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        position: Vector3(-7.0, -1, 15.0), // 5 meters ahead in AR
        scale: Vector3(0.5, 0.5, 0.5),
        rotation: ARTools.getObjectRotation("right") // left
    );
    await arObjectManager!.addNode(objectNode2!);
  }
}
