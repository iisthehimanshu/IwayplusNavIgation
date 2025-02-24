import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:geodesy/geodesy.dart';
import 'package:iwaymaps/IWAYPLUS/Elements/HelperClass.dart';
import 'package:iwaymaps/NAVIGATION/ARNavigation/ARTools.dart';
import 'package:iwaymaps/NAVIGATION/navigationTools.dart';
import 'package:iwaymaps/path_snapper.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../IWAYPLUS/Elements/locales.dart';
import '../../IWAYPLUS/websocket/UserLog.dart';
import '../APIMODELS/landmark.dart';
import '../Cell.dart';
import '../ELEMENTS/DirectionHeader.dart';
import '../MotionModel.dart';
import '../Navigation.dart';
import '../UserState.dart';
import '../pathState.dart';
import '../singletonClass.dart';

class ARObjectPlacementScreen extends StatefulWidget {
  UserState user;
  pathState PathState;
  ARObjectPlacementScreen({required this.user,required this.PathState});

  @override
  _ARObjectPlacementScreenState createState() => _ARObjectPlacementScreenState();
}

class _ARObjectPlacementScreenState extends State<ARObjectPlacementScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;
  late StreamSubscription<CompassEvent> compassSubscription;
  double userDirectionWRTN = 0.0;


  late int userPathAngle;
  Timer? alignmentTimer; // Timer reference

  bool objectRendered = false;
  var newNode;
  final pdr = <StreamSubscription<dynamic>>[];
  DateTime? lastStepTime; // To track the last step detection time
  int lastPeakTime = 0;
  late List<Cell> turnPoints = [];







  @override
  void initState() {
    super.initState();
  }

  String detectionText = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isAndroid? ARView(
        onARViewCreated: onARViewCreated,
      ) : ARKitSceneView(onARKitViewCreated: onARKitViewCreated,
        enableTapRecognizer: false,
        showFeaturePoints: false,
        showWorldOrigin: true,
      ),
      floatingActionButton: Column(
        children: [
          Spacer(),
          Text("Turn Value${check1turnAngleWRTN}"),
          Text(userDirectionWRTN.toString()),
          Text(detectionText),

          FloatingActionButton(
            child: Icon(Icons.ac_unit),
            onPressed: (){
              clearNodes();
            },
          ),
          FloatingActionButton(
            child: Icon(Icons.ac_unit),
            onPressed: (){
              reRenderPath(arObjectManager, realWorldARPathCoordinates);
            },
          ),

        ],
      ),
    );
  }

  late ARKitController arkitController;

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final newNode = ARKitNode(
      geometry: ARKitTorus(pipeRadius: 5,ringRadius: 5),
      position: Vector3(0, 0, -5), // 5 meters in front of the camera
      scale: Vector3(0.1, 0.1, 0.1),
    );
    this.arkitController.add(newNode);

    final node = ARKitReferenceNode(
      url: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: Vector3(0, 0, -5), // 5 meters in front of the camera
      scale: Vector3(0.1, 0.1, 0.1), // Adjust scale if needed
    );
    this.arkitController.add(node);
    //handleCompassEvents();
  }


  Future<void> onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false, // Optional: Useful for debugging
      showAnimatedGuide: false,
    );

    print("arLocationManager ${arLocationManager.getLastKnownPosition().then((value){
      print("value ${value?.longitude}");
      print("value ${value?.latitude}");
    })}");

    handleCompassEvents();
  }



  void handleCompassEvents(){
    compassSubscription = FlutterCompass.events!.listen((event) {
      double? compassHeading = event.heading!;
      widget.user.theta = compassHeading<0?compassHeading+360:compassHeading;
      userDirectionWRTN = compassHeading<0?compassHeading+360:compassHeading;
      setState(() {});
      // print("userDirectionWRTN");
      // print(userDirectionWRTN);
      Future.microtask(() => compassSubscription?.cancel());
      doInitialAsyncTasks();
    },onError: (error) {
      if(kDebugMode){
        HelperClass.showToast("Compass Error!! ${error}");
      }
    });
  }

  late Vector4 objectRotation;

  List<double> directionLenList = [];
  List<int> directionLenList2 = [];
  List<String> directionDirectionList = [];
  late double marginAngle;
  List<List<int>> absoluteARPathCoordinates = [];
  List<List<double>> realWorldARPathCoordinates = [];
  List<List<int>> currCord2List = [];

  List<double> rotationARValueList = [];


  List<List<int>> modifiedPath = [];
  List<List<double>> realWorldModifiedPath = [];

  List<ARNode> addedNodes = [];

  double check1turnAngleWRTN = 0.0;




  void doInitialAsyncTasks() async {
    turnPoints = await tools.getCellTurnpoints(widget.user.cellPath);
    List<double> pointA = [];
    List<double> pointB = [];
    List<int> forPathX = [];
    List<int> forPathY = [];

    pointA.add(widget.user.lat);
    pointA.add(widget.user.lng);
    forPathX.add(widget.user.coordX);
    forPathX.add(widget.user.coordY);
    print("userCoordd ${forPathX}");
    print("doInitialAsyncTasks");
    turnPoints.forEach((value){
      print("turnPoints");
      print(value.lat);
      print(value.lng);
      print(value.x);
      print(value.y);
    });


    // directionLenList2.add((tools.calculateDistance([widget.user.coordX,widget.user.coordY],[turnPoints[0].x,turnPoints[0].y])/4).toInt());
    // directionDirectionList.add("front");

    // for(int i=0 ; i<turnPoints.length-1 ; i++){
    //   print("turn $i ${tools.calculateDistance([turnPoints[i].x,turnPoints[i].y], [turnPoints[i+1].x,turnPoints[i+1].y])}");
    //   directionLenList2.add((tools.calculateDistance([turnPoints[i].x,turnPoints[i].y], [turnPoints[i+1].x,turnPoints[i+1].y])/4).toInt());
    //   widget.PathState.directions.forEach((value){
    //     if(value.x==turnPoints[i].x && value.y==turnPoints[i].y){
    //       print(value.turnDirection);
    //       directionDirectionList.add(value.turnDirection!);
    //       objectRotation = ARTools.getObjectRotation(value.turnDirection!)!;
    //     }
    //   });
    // }
    //
    // print("directionLenList2 ${directionLenList2}");
    // print("directionLenList2 ${directionDirectionList}");

    if(widget.user.coordX == widget.PathState.sourceX && widget.user.coordY == widget.PathState.sourceY){
      print("Iniff");
      List<double> newpointB = [];
      newpointB.add(turnPoints[0].lat);
      newpointB.add(turnPoints[0].lng);
      double turnAngleWRTN = tools.calculateBearing(pointA, newpointB);
      marginAngle = (360 - ((turnAngleWRTN-20) - userDirectionWRTN))/180*3.14;
      print("marginAngle ${marginAngle} ${turnAngleWRTN} $userDirectionWRTN");
    }else{
      print("Inelse");
      List<double> newpointB = [];
      newpointB.add(turnPoints[1].lat);
      newpointB.add(turnPoints[1].lng);
      double turnAngleWRTN = tools.calculateBearing(pointA, newpointB);
      marginAngle = (360 - ((turnAngleWRTN-20) - userDirectionWRTN))/180*3.14;
      print("marginAngle ${marginAngle} ${turnAngleWRTN} $userDirectionWRTN");
    }
    print("turnPoints.length ${turnPoints.length}");



    print("marginAngleforloop ${marginAngle}");
    for(int i=0 ; i<turnPoints.length ; i++){
        pointB.clear();
        pointB.add(turnPoints[i].lat);
        pointB.add(turnPoints[i].lng);
        if(i==1){
          check1turnAngleWRTN = tools.calculateBearing(pointA, pointB);
          setState(() {

          });
        }
        print("forPathX ${forPathX}");
        print("turnpoints ${turnPoints[i].x} ${turnPoints[i].y}");

        int zC = ((turnPoints[i].x - forPathX[0])/3.2).toInt();
        int xC = (((turnPoints[i].y - forPathX[1])/3.2)*-1).toInt();
        print("zCXC ${zC} ${xC}");

        double newX = xC*cos(marginAngle) + zC*sin(marginAngle);
        double newZ = -xC*sin(marginAngle) + zC*cos(marginAngle);
        print("newX $newX $newZ");
        absoluteARPathCoordinates.add([xC,zC]);
        realWorldARPathCoordinates.add([newX,newZ]);
        // ARNode newNode1 = ARNode(
        //   type: NodeType.webGLB,
        //   uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
        //   scale: Vector3(0.5, 0.5, 0.5),
        //   position: Vector3(newX,-1,newZ), // Front
        // );
        // await arObjectManager.addNode(newNode1);
      }


    //for last turn means adding destination coord for last turn object render
    print("widget.turnPoint ${turnPoints[turnPoints.length-1].x} ${turnPoints[turnPoints.length-1].y}");
    print("widget.PathState.destinationX ${widget.PathState.destinationX} ${widget.PathState.destinationY}");
    int zC = ((widget.PathState.destinationX - forPathX[0])/3.2).ceil().toInt();
    int xC = (((widget.PathState.destinationY - forPathX[1])/3.2)*-1).ceil().toInt();
    print("zCXC ${zC} ${xC}");
    double newX = xC*cos(marginAngle) + zC*sin(marginAngle);
    double newZ = -xC*sin(marginAngle) + zC*cos(marginAngle);
    print("newX $newX $newZ");
    absoluteARPathCoordinates.add([xC,zC]);
    realWorldARPathCoordinates.add([newX,newZ]);
    modifiedPath = ARTools.generatePath(absoluteARPathCoordinates);
    print("absoluteARPathCoordinates $absoluteARPathCoordinates ${absoluteARPathCoordinates.length}");
    print("modifiedPath $modifiedPath");
    modifiedPath.removeWhere((point) =>
        absoluteARPathCoordinates.any((value) => value[0] == point[0] && value[1] == point[1])
    );
    // print("finalremovedList $modifiedPath");

    print("realWorldARPathCoordinates $realWorldARPathCoordinates ${realWorldARPathCoordinates.length}");
    realWorldModifiedPath = ARTools.realWorldARPathCoordinates(modifiedPath, forPathX, marginAngle);
    print("realWorldModifiedPath $realWorldModifiedPath");



    for(int i=0 ; i<absoluteARPathCoordinates.length-1; i++){
      rotationARValueList.add(ARTools.giveRotationDouble(absoluteARPathCoordinates[i+1][1].toInt(),absoluteARPathCoordinates[i][1].toInt(),absoluteARPathCoordinates[i+1][0].toInt(),absoluteARPathCoordinates[i][0].toInt())!);
    }
    // print("absoluteARPathCoordinates $absoluteARPathCoordinates ${absoluteARPathCoordinates.length}");
    // print("realWorldARPathCoordinates $realWorldARPathCoordinates ${realWorldARPathCoordinates.length}");
    // print("rotationARValueList $rotationARValueList");



    for(int i=0 ; i<realWorldModifiedPath.length-1 ; i++){
      if(Platform.isAndroid) {
        ARNode newNode = ARNode(
          type: NodeType.webGLB,
          uri: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/sphere.fbx.glb",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(
              realWorldModifiedPath[i][0], -1, realWorldModifiedPath[i][1]),
        );
        await arObjectManager.addNode(newNode);
      }else if(Platform.isIOS){
        final node = ARKitReferenceNode(
          url: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/sphere.fbx.glb",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(realWorldModifiedPath[i][0], -1, realWorldModifiedPath[i][1]), // Adjust scale if needed
        );
        this.arkitController.add(node);
      }
    }



    for (int i = 0; i < realWorldARPathCoordinates.length-1; i++) {
      print("inIfPart");
      if(Platform.isAndroid) {
        ARNode newNode$i = ARNode(
          type: NodeType.webGLB,
          uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
          scale: Vector3(0.4, 0.4, 0.4),
          rotation: Vector4(
              0.0, 1.0, 0.0, rotationARValueList[i] + marginAngle),
          position: Vector3(realWorldARPathCoordinates[i][0], -1,
              realWorldARPathCoordinates[i][1]),
        );
        bool? isAdded = await arObjectManager.addNode(newNode$i);
        if (isAdded == true) {
          addedNodes.add(newNode$i); // Store the reference of added node
        }
      }else if(Platform.isIOS){
        final node = ARKitReferenceNode(
          url: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/sphere.fbx.glb",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(realWorldModifiedPath[i][0], -1, realWorldModifiedPath[i][1]), // Adjust scale if needed
        );
        this.arkitController.add(node);
      }

    }
    // List<List<int>> modifiedPath = ARTools.generatePath(absoluteARPathCoordinates);
    // print("modifiedPath $modifiedPath");
    // List<List<double>> realWorldModifiedPath = ARTools.realWorldARPathCoordinates(modifiedPath, forPathX, marginAngle);
    // print("realWorldModifiedPath $realWorldModifiedPath");
    // List<double> modifiedRotationARValueList = ARTools.generateRotationARValues(modifiedPath);
    // print("modifiedRotationARValueList ${modifiedRotationARValueList}");
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (addedNodes.isNotEmpty) {
        print("addedNodes${addedNodes[1].position!}");
        checkProximity(addedNodes[1], 1);  // Check proximity for the first node
      }
    });
  }
  Future<void> checkProximity(ARNode node, double threshold) async {
    print("checkingProximity");
    // Get the camera position
    var cameraPose = await arSessionManager.getCameraPose();
    Vector3? cameraPosition = cameraPose?.getTranslation();

    // Get the ARNode position
    Vector3 objectPosition = node.position;
    print("obejct position is ${objectPosition}");

    // Compute Euclidean distance
    double? distance = cameraPosition?.distanceTo(objectPosition);

    // Check if the device is close to the AR object
    if(distance != null) {
      if (distance <= threshold) {
        detectionText = "You're very close $distance";
        print("You're very close to the object! Distance: $distance meters");
        // You can trigger any action here, like displaying a message
      } else {
        detectionText = "You're too far $distance";

        print("You're too far. Distance: $distance meters");
      }
      setState(() {});
    }
  }

  Future<void> clearNodes() async {
    for (ARNode node in addedNodes) {
      await arObjectManager.removeNode(node);
    }
    addedNodes.clear();  // Clear the list after removing nodes
  }

  Future<void> reRenderPath(ARObjectManager arObjectManager, List<List<double>> realWorldModifiedPath) async {
    print("reRenderPath");
    for(int i=(realWorldModifiedPath.length/2).toInt() ; i<realWorldModifiedPath.length-1 ; i++){
      ARNode newNode$i = ARNode(
        type: NodeType.webGLB,
        uri: "https://github.com/Wilson-Daniel/3DModels/raw/refs/heads/main/sphere.fbx.glb",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(realWorldModifiedPath[i][0], -1.2, realWorldModifiedPath[i][1]),
      );
      bool? isAdded = await arObjectManager.addNode(newNode$i);
      if (isAdded==true) {
        addedNodes.add(newNode$i);  // Store the reference of added node
      }
    }
  }




  Future<void> add3DObject(ARObjectManager arObjectManager, Vector3 position) async {
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      position: position,
      scale: Vector3(0.2, 0.2, 0.2),
      rotation: Vector4(0, 1, 0, 0), // No rotation
    );
    await arObjectManager.addNode(newNode);
  }



  //pdrstepCount variables
  int stepCount = 0;
  double alpha = 0.4;
  double filteredX = 0;
  double filteredY = 0;
  double filteredZ = 0;
  List<double> orientationHistory = [];
  int orientationWindowSize = 10;  // Number of readings for stability check
  double orientationThreshold = 0.1;
  double peakThreshold = 11.1111111;
  double valleyThreshold = -11.1111111;
  int peakInterval = 300;
  int valleyInterval = 300;
  int lastValleyTime = 0;
  void pdrstepCount() {
    pdr.add(accelerometerEventStream().listen(
          (AccelerometerEvent event) {
        if (pdr == null) {
          return; // Exit the event listener if subscription is canceled
        }

        if (detectStep(event.x, event.y, event.z)) {
          setState(() {
            lastPeakTime = DateTime
                .now()
                .millisecondsSinceEpoch;
            stepCount++;
            bool isvalid = MotionModel.isValidStep(
                widget.user,
                SingletonFunctionController
                    .building.floorDimenssion[widget.user.bid]![widget.user.floor]![0],
                SingletonFunctionController
                    .building.floorDimenssion[widget.user.bid]![widget.user.floor]![1],
                SingletonFunctionController
                    .building.nonWalkable[widget.user.bid]![widget.user.floor]!,
                (){});
            if (isvalid) {
              widget.user.move(context).then((value) {
              });
            } else {
              if (widget.user.isnavigating) {
                // reroute();
                // showToast("You are out of path");
              }
            }
          });
        }
        else {
          filteredX = alpha * filteredX + (1 - alpha) * event.x;
          filteredY = alpha * filteredY + (1 - alpha) * event.y;
          filteredZ = alpha * filteredZ + (1 - alpha) * event.z;
          // Compute orientation angle from accelerometer data (e.g., pitch or roll)
          double orientation = atan2(filteredY,
              sqrt(filteredX * filteredX + filteredZ * filteredZ))
          ;
          // Add orientation to history and check variability
          orientationHistory.add(orientation);
          if (orientationHistory.length > orientationWindowSize) {
            orientationHistory.removeAt(0); // Maintain a fixed window size

            // Calculate standard deviation of orientation
            double avgOrientation = orientationHistory.reduce((a, b) =>
            a + b) / orientationWindowSize;
            double orientationVariance = orientationHistory.fold(
                0, (sum, value) => sum +
                pow(value - avgOrientation, 2).toInt()) /
                orientationWindowSize;
            double orientationStability = sqrt(orientationVariance);

            // Suppress step detection if orientation is too variable
            if (orientationStability > orientationThreshold) {
              // Too random, assume the user is stationary or talking, ignore steps
              return;
            }
          }
          // Compute magnitude of acceleration vector
          double magnitude = sqrt((filteredX * filteredX +
              filteredY * filteredY +
              filteredZ * filteredZ));
          // Detect peak and valley
          if (magnitude > peakThreshold &&
              DateTime
                  .now()
                  .millisecondsSinceEpoch - lastPeakTime >
                  peakInterval) {
            setState(() {
              lastPeakTime = DateTime
                  .now()
                  .millisecondsSinceEpoch;
              stepCount++;
              bool isvalid = MotionModel.isValidStep(
                  widget.user,
                  SingletonFunctionController
                      .building.floorDimenssion[widget.user.bid]![widget.user.floor]![0],
                  SingletonFunctionController
                      .building.floorDimenssion[widget.user.bid]![widget.user.floor]![1],
                  SingletonFunctionController
                      .building.nonWalkable[widget.user.bid]![widget.user.floor]!,
                  (){});
              if (isvalid) {
                widget.user.move(context).then((value) {

                });
              } else {
                if (widget.user.isnavigating) {
                  // reroute();
                  // showToast("You are out of path");
                }
              }
            });
          } else if (magnitude < valleyThreshold &&
              DateTime
                  .now()
                  .millisecondsSinceEpoch - lastValleyTime >
                  valleyInterval) {
            setState(() {
              lastValleyTime = DateTime
                  .now()
                  .millisecondsSinceEpoch;
            });
          }
        }

      },
      onError: (error) {

      },
    ));
  }


  bool onStart=false;
  bool startingNavigation = false;
  late String _currentLocale = '';


  void reroute({String? acc}) {

    widget.user.isnavigating = false;
    widget.user.temporaryExit = true;

    widget.user.showcoordX = widget.user.coordX;
    widget.user.showcoordY = widget.user.coordY;
    // setState(() {
    //   onStart=false;
    //   startingNavigation=false;
    //   if (markers.length > 0) {
    //     List<double> dvalue = tools.localtoglobal(
    //         widget.user.coordX.toInt(),
    //         widget.user.coordY.toInt(),
    //         SingletonFunctionController.building.patchData[widget.user.bid]);
    //     markers[widget.user.bid]?[0] = customMarker.move(
    //         LatLng(dvalue[0], dvalue[1]), markers[widget.user.bid]![0]);
    //   }
    // });
    FlutterBeep.beep();
    if(acc!= null){
      //speak("${LocaleData.changingaccessiblepath.getString(context)}", _currentLocale);
    }else{
      //speak("${LocaleData.reroute.getString(context)}", _currentLocale);
    }
    if(acc != null){
      widget.PathState.accessiblePath = acc;
      widget.PathState.clearforaccessiblepath();
    }
    //autoreroute(acc: acc);
  }

  // Future<void> speak(String msg, String lngcode, {bool prevpause = false}) async {
  //   if (!UserState.ttsAllStop) {
  //     if (disposed) return;
  //     if (prevpause) {
  //       await flutterTts.pause();
  //     }
  //
  //     if (lngcode == "hi") {
  //       if (Platform.isAndroid) {
  //         await flutterTts
  //             .setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
  //       } else {
  //         await flutterTts.setVoice({"name": "Lekha", "locale": "hi-IN"});
  //       }
  //     } else {
  //       await flutterTts
  //           .setVoice({"name": "en-US-language", "locale": "en-US"});
  //     }
  //     await flutterTts.stop();
  //     if (Platform.isAndroid) {
  //       await flutterTts.setSpeechRate(0.7);
  //     } else {
  //       await flutterTts.setSpeechRate(0.55);
  //     }
  //
  //     await flutterTts.setPitch(1.0);
  //     if(isSemanticEnabled){
  //       print("mssg");
  //       print(msg);
  //       PushNotifications.showSimpleNotification(body: "",payload: "",title: msg);
  //     }else {
  //       // PushNotifications.showSimpleNotification(body: "",payload: "",title: msg);
  //
  //       await flutterTts.speak(msg);
  //     }
  //
  //   }
  // }




  bool isPdrActive = false;
  final Duration stepCooldown = Duration(milliseconds: 800);
  bool detectStep(double x, double y, double z) {
    if (!isPdrActive) return false;
    // Calculate pitch and roll
    double pitch = atan(x / sqrt(y * y + z * z)) * (180 / pi);
    double roll = atan(y / sqrt(x * x + z * z)) * (180 / pi);
    // Define problematic orientation thresholds
    bool isProblematicOrientation =
        (pitch > 80 && pitch < 100) || (roll > 80 && roll < 100);
    // Calculate movement magnitude
    double magnitude = sqrt(x * x + y * y + z * z);
    // Threshold to detect significant movement
    double movementThreshold = 9.85;// Adjust based on your testing
    // Check if a step is detected
    if (isProblematicOrientation && magnitude > movementThreshold) {
      DateTime now = DateTime.now();

      // Ensure cooldown between steps
      if (lastStepTime == null || now.difference(lastStepTime!) > stepCooldown) {

        lastStepTime = now; // Update the last step detection time
        return true; // Step detected
      }
    }
    return false; // No step detected
  }

  bool isLocalized = false;

  void paintUser(
      String? nearestBeacon,
      String? polyID,
      LatLng? gpsCoordinates,
      {bool speakTTS = true, bool render = true, bool providePinSelection = false}
      ) async {
    Landmarks? userSetLocation = Landmarks();

    // Handle direct source ID case
    // if (widget.directsourceID.length > 2){
    //   nearestBeacon = null;
    //   polyID = widget.directsourceID;
    //   widget.directsourceID = '';
    // }
    // If nearestBeacon is provided, localize the user to it
    if (nearestBeacon != null && nearestBeacon.isNotEmpty) {
      //await _handleBeaconLocalization(nearestBeacon, speakTTS, render,providePinSelection);
    }
    // If polyID is provided, localize the user to the polygon
    else if (polyID != null && polyID.isNotEmpty) {
      await _handlePolygonLocalization(polyID, speakTTS, render);
    }
    // Fallback to global coordinates if neither nearestBeacon nor polyID is available
    else {
      //await _handleGlobalCoordinatesLocalization(speakTTS, render,providePinSelection);
    }

    // Reset direct source ID and Land ID
    // widget.directLandID = '';
    // widget.directsourceID = '';
    // _recenterMap();
    setState(() {
      isLocalized = false;
    });
  }

  bool detected = false;

  Navigation navigation = Navigation();


  // Future<void> _handleBeaconLocalization(
  //     String nearestBeacon,
  //     bool speakTTS,
  //     bool render,
  //     bool providePinSelection
  //     ) async {
  //   try {
  //     wsocket.message["AppInitialization"]["localizedOn"] = nearestBeacon;
  //
  //     final beaconData = SingletonFunctionController.apibeaconmap[nearestBeacon];
  //     if (beaconData != null) {
  //       print("beacon debug: $beaconData");
  //
  //       final landmarkData = await SingletonFunctionController.building.landmarkdata;
  //       if (landmarkData != null) {
  //         if(providePinSelection){
  //           SingletonFunctionController.building.listOfNearbyLandmarksToLocalize = tools.findListOfNearbyLandmark(beaconData,
  //               landmarkData.landmarksMap!);
  //           if(SingletonFunctionController.building.listOfNearbyLandmarksToLocalize != null){
  //             detected = false;
  //             //showListOfNearbyLandmarks(SingletonFunctionController.building.listOfNearbyLandmarksToLocalize!);
  //             return;
  //           }
  //         } else{
  //           final userSetLocation = tools.localizefindNearbyLandmark(
  //               beaconData,
  //               landmarkData.landmarksMap!
  //           );
  //
  //           if (userSetLocation != null) {
  //             initializeUser(userSetLocation,beaconData, speakTTS: speakTTS, render: render);
  //           } else {
  //             unableToFindLocation();
  //           }
  //         }
  //
  //       } else {
  //         print("_handleBeaconLocalization2");
  //         unableToFindLocation();
  //       }
  //     } else {
  //       print("_handleBeaconLocalization3");
  //       if (speakTTS) unableToFindLocation();
  //     }
  //   } catch (e) {
  //     print("Error during beacon localization: $e");
  //     if (speakTTS) unableToFindLocation();
  //   }
  // }




  Future<void> _handlePolygonLocalization(
      String polyID,
      bool speakTTS,
      bool render
      ) async {
    try {
      final landmarkData = await SingletonFunctionController.building.landmarkdata;
      final userSetLocation = landmarkData?.landmarksMap?[polyID];

      if (userSetLocation != null) {
        //initializeUser(userSetLocation,null, speakTTS: speakTTS, render: render);
      } else {
        //unableToFindLocation();
      }
    } catch (e) {
      print("Error during polygon localization: $e");
      //if (speakTTS) unableToFindLocation();
    }
  }
  //
  //
  //
  // Future<void> _handleGlobalCoordinatesLocalization(
  //     bool speakTTS,
  //     bool render,
  //     bool providePinSelection
  //     ) async {
  //
  //
  //   GPS gps = GPS();
  //   KalmanFilter _kalmanFilter = KalmanFilter();
  //   await gps.startGpsUpdates();
  //   StreamSubscription<Position>? subscription;
  //   subscription = gps.positionStream.listen((position) {
  //     _kalmanFilter.applyFilter(position.latitude, position.longitude);
  //   });
  //   await Future.delayed(const Duration(seconds: 9));
  //   subscription.cancel();
  //   gps.dispose();
  //
  //   if(_kalmanFilter.latitudeEstimate != null && _kalmanFilter.longitudeEstimate != null) {
  //     UserState.geoLat = _kalmanFilter.latitudeEstimate;
  //     UserState.geoLng = _kalmanFilter.longitudeEstimate;
  //     print("globalcoord ${UserState.geoLat},${UserState.geoLng}");
  //     final userSetLocation = await getglobalcoords(
  //         LatLng(UserState.geoLat!, UserState.geoLng!)
  //     );
  //
  //     if (userSetLocation != null) {
  //       String polyID = userSetLocation.properties!.polyId!;
  //       initializeUser(userSetLocation,null, speakTTS: speakTTS, render: render);
  //     } else {
  //       unableToFindLocation();
  //     }
  //   }else{
  //     unableToFindLocation();
  //   }
  // }



}
