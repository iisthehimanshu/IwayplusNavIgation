import 'dart:async';
import 'dart:math';

import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:iwaymaps/IWAYPLUS/Elements/HelperClass.dart';
import 'package:iwaymaps/NAVIGATION/ARNavigation/ARTools.dart';
import 'package:iwaymaps/NAVIGATION/navigationTools.dart';
import 'package:iwaymaps/path_snapper.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart';

import '../Cell.dart';
import '../MotionModel.dart';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AR Object Placement")),
      body: ARView(
        onARViewCreated: onARViewCreated,
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.ac_unit),
      //   onPressed: (){
      //
      //   },
      // ),
    );
  }



  void handleCompassEvents(){
    compassSubscription = FlutterCompass.events!.listen((event) {
      double? compassHeading = event.heading!;
      widget.user.theta = compassHeading<0?compassHeading+360:compassHeading;
      userDirectionWRTN = compassHeading<0?compassHeading+360:compassHeading;
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
  List<List<int>> absolutePathCoordinates = [];
  List<List<int>> currCord2List = [];


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
    directionLenList2.add((tools.calculateDistance([widget.user.coordX,widget.user.coordY],[turnPoints[0].x,turnPoints[0].y])/4).toInt());
    directionDirectionList.add("front");

    for(int i=0 ; i<turnPoints.length-1 ; i++){
      print("turn $i ${tools.calculateDistance([turnPoints[i].x,turnPoints[i].y], [turnPoints[i+1].x,turnPoints[i+1].y])}");
      directionLenList2.add((tools.calculateDistance([turnPoints[i].x,turnPoints[i].y], [turnPoints[i+1].x,turnPoints[i+1].y])/4).toInt());
      widget.PathState.directions.forEach((value){
        if(value.x==turnPoints[i].x && value.y==turnPoints[i].y){
          print(value.turnDirection);
          directionDirectionList.add(value.turnDirection!);
          objectRotation = ARTools.getObjectRotation(value.turnDirection!)!;
        }
      });
    }

    print("directionLenList2 ${directionLenList2}");
    print("directionLenList2 ${directionDirectionList}");


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



    
    for(int i=0 ; i<turnPoints.length ; i++){
      // print("Turn $i ${turnPoints[i+1].x} ${turnPoints[i+1].y} ${turnPoints[i].x} ${turnPoints[i].y}");
      // print("Turn $i ${turnPoints[i+1].x - turnPoints[i].x} ${turnPoints[i+1].y - turnPoints[i].y}");
      if(i==0){
        print("forPathX ${forPathX}");
        int xC = (((turnPoints[i].y - forPathX[1])/3.2)*-1).toInt();
        int zC = ((turnPoints[i].x - forPathX[0])/3.2).toInt();
        print("zCXC ${zC} ${xC}");

        print("coordinates ${0} ${0}");
        print("positon ${0} ${0}");
        print("Turnn final coord${i} ${0} ${0}");
        absolutePathCoordinates.add([0,0]);
        currCord2List.add([0,0]);
        double newX = xC*cos(marginAngle) + zC*sin(marginAngle);
        double newY = -xC*sin(marginAngle) + zC*cos(marginAngle);
        print("newX $newX $newY");

        ARNode newNode1 = ARNode(
          type: NodeType.webGLB,
          uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
          scale: Vector3(0.5, 0.5, 0.5),
          position: Vector3(newX,-1,newY), // Front

        );
        await arObjectManager.addNode(newNode1);

      }else if(i==1){
        print("forPathX ${forPathX}");
        int zC = ((turnPoints[i].x - forPathX[0])/3.2).toInt();
        int xC = (((turnPoints[i].y - forPathX[1])/3.2)*-1).toInt();
        print("zCXC ${zC} ${xC}");

        double newX = xC*cos(marginAngle) + zC*sin(marginAngle);
        double newY = -xC*sin(marginAngle) + zC*cos(marginAngle);
        print("newX $newX $newY");

        ARNode newNode1 = ARNode(
          type: NodeType.webGLB,
          uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
          scale: Vector3(0.5, 0.5, 0.5),
          position: Vector3(newX,-1,newY), // Front
        );
        await arObjectManager.addNode(newNode1);
      }else{
        pointB.clear();
        pointB.add(turnPoints[i].lat);
        pointB.add(turnPoints[i].lng);
        double turnAngleWRTN = tools.calculateBearing(pointA, pointB);
        print("forPathX ${forPathX}");

        int zC = ((turnPoints[i].x - forPathX[0])/3.2).toInt();
        int xC = (((turnPoints[i].y - forPathX[1])/3.2)*-1).toInt();
        print("zCXC ${zC} ${xC}");

        double newX = xC*cos(marginAngle) + zC*sin(marginAngle);
        double newY = -xC*sin(marginAngle) + zC*cos(marginAngle);
        print("newX $newX $newY");

        ARNode newNode1 = ARNode(
          type: NodeType.webGLB,
          uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
          scale: Vector3(0.5, 0.5, 0.5),
          position: Vector3(newX,-1,newY), // Front
        );
        await arObjectManager.addNode(newNode1);
      }

    }
    print("absolutePathCoordinates $absolutePathCoordinates");
    print("currCord2List $currCord2List");



    print("turnPoints");
    print(turnPoints);
    turnPoints.forEach((turn) async {
      pointB.clear();
      forPathY.clear();
      pointB.add(turn.lat);
      pointB.add(turn.lng);
      forPathY.add(turn.x);
      forPathY.add(turn.y);
      print("lists ${pointA} ${pointB}");
      print("lists ${forPathX} ${forPathY}");
      double length = tools.calculateDistance(forPathX, forPathY);
      forPathX = forPathY;
      print("currentLength ${length}");
      double turnAngleWRTN = tools.calculateBearing(pointA, pointB);
      print("turnAngleWRTN ${turnAngleWRTN} ${userDirectionWRTN}");
      print("actual andle ${turnAngleWRTN - userDirectionWRTN}");
      double calculatedAngle = turnAngleWRTN - userDirectionWRTN;
      double actualAngle;


      if(calculatedAngle<0){
        actualAngle = calculatedAngle+360;
      }else{
        actualAngle = calculatedAngle;
      }

      print("actualAngle ${actualAngle}");

      int x = 0;
      int z = -5;

      double newX = x*cos(marginAngle) + z*sin(marginAngle);
      double newY = -x*sin(marginAngle) + z*cos(marginAngle);
      print("newX $newX $newY");

      // ARNode newNode1 = ARNode(
      //   type: NodeType.webGLB,
      //   uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      //   scale: Vector3(0.2, 0.2, 0.2),
      //   position: Vector3(newX,-1,newY), // Front
      // );
      // await arObjectManager.addNode(newNode1);

      return;


      List<int> placeInQuad = ARTools.getCoordN(actualAngle);
      print("placeInQuad ${placeInQuad}");

      double aerialDistance = tools.calculateAerialDist(widget.user.lat, widget.user.lng, turn.lat,turn.lng)/2;
      print("aerialDistance ${aerialDistance}");

      double opositeDistance = ARTools.calculateOpposite(actualAngle, aerialDistance);
      print("opositeDistance ${opositeDistance.abs().ceil()}");

      double adjacentDistance = ARTools.calculateAdjacent(actualAngle, aerialDistance);
      print("adjacentDistance ${adjacentDistance.abs().ceil()}");

      print("Actual Coords ${placeInQuad[0]*opositeDistance.abs()}  ${placeInQuad[1]*adjacentDistance.abs()}");



      widget.PathState.directions.forEach((value){
        if(value.x==turn.x && value.y==turn.y){
          print(value.turnDirection);
          objectRotation = ARTools.getObjectRotation(value.turnDirection!)!;
        }
      });

      // ARNode newNode = ARNode(
      //     type: NodeType.webGLB,
      //     uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      //     scale: Vector3(0.2, 0.2, 0.2),
      //     position: Vector3(placeInQuad[0]*adjacentDistance.abs().ceil().toDouble(),-1,placeInQuad[1]*opositeDistance.abs().ceil().toDouble()) , // Front
      //     rotation: objectRotation
      // );
      // await arObjectManager.addNode(newNode);


    });

    // for (var value in widget.PathState.directions) {
    //   if(turnPoints.contains(value.node)){
    //     print("Contians${value.node}");
    //   }
    // }
    //await calculateUserPathAngle();
    //startAlignmentCheck();
    //pathForamation();
  }


  late Vector3 referencePosition;



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



  // void reroute({String? acc}) {
  //
  //   widget.user.isnavigating = false;
  //   widget.user.temporaryExit = true;
  //
  //   widget.user.showcoordX = widget.user.coordX;
  //   widget.user.showcoordY = widget.user.coordY;
  //   setState(() {
  //     onStart=false;
  //     startingNavigation=false;
  //     if (markers.length > 0) {
  //       List<double> dvalue = tools.localtoglobal(
  //           user.coordX.toInt(),
  //           user.coordY.toInt(),
  //           SingletonFunctionController.building.patchData[user.bid]);
  //       markers[user.bid]?[0] = customMarker.move(
  //           LatLng(dvalue[0], dvalue[1]), markers[user.bid]![0]);
  //     }
  //   });
  //   FlutterBeep.beep();
  //   if(acc!= null){
  //     speak("${LocaleData.changingaccessiblepath.getString(context)}", _currentLocale);
  //   }else{
  //     speak("${LocaleData.reroute.getString(context)}", _currentLocale);
  //   }
  //   if(acc != null){
  //     PathState.accessiblePath = acc;
  //     PathState.clearforaccessiblepath();
  //   }
  //   autoreroute(acc: acc);
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



  double objectDegree = 0.0;


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
      showWorldOrigin: true, // Optional: Useful for debugging
    );
    var cameraPose = await arSessionManager.getCameraPose();
    print("Camera Position: first ${cameraPose?.getTranslation()}");
    handleCompassEvents();

    // _addObjects();
  }
  Vector3 _getLeftVector(Quaternion rotation) {
    // Get the forward vector first
    Vector3 forward = _getForwardVector(rotation);

    // Compute the left vector using cross product with the up vector (0, 1, 0)
    Vector3 up = Vector3(0, 1, 0);
    Vector3 left = up.cross(forward);

    return left.normalized();
  }


  var startPointCameraPose;


  Vector3 quaternionToEuler(Quaternion q) {
    double ysqr = q.y * q.y;

    // Compute pitch (X-axis rotation)
    double t0 = 2.0 * (q.w * q.x + q.y * q.z);
    double t1 = 1.0 - 2.0 * (q.x * q.x + ysqr);
    double pitch = atan2(t0, t1);

    // Compute yaw (Y-axis rotation)
    double t2 = 2.0 * (q.w * q.y - q.z * q.x);
    t2 = t2.clamp(-1.0, 1.0);
    double yaw = asin(t2);

    // Compute roll (Z-axis rotation)
    double t3 = 2.0 * (q.w * q.z + q.x * q.y);
    double t4 = 1.0 - 2.0 * (ysqr + q.z * q.z);
    double roll = atan2(t3, t4);

    return Vector3(pitch, yaw, roll); // In radians
  }

  void printEulerAngles(Quaternion q) {
    Vector3 eulerAngles = quaternionToEuler(q);

    print("Euler Angles:");
    print("Pitch (X-axis): ${degrees(eulerAngles.x)}°");
    objectDegree = degrees(eulerAngles.x);
    print("Yaw (Y-axis): ${degrees(eulerAngles.y)}°");
    print("Roll (Z-axis): ${degrees(eulerAngles.z)}°");
  }

  // Extracts rotation as a quaternion from a transformation matrix
  Quaternion _extractRotation(Matrix4 matrix) {
    Vector3 scale = Vector3.zero();
    Vector3 translation = Vector3.zero();
    Quaternion rotation = Quaternion.identity();

    matrix.decompose(scale, rotation, translation);
    return rotation;
  }



  // Function to get the forward direction from camera rotation


  Future<void> _add3DObject({required Vector3 position, required String uri}) async {
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://github.com/Wilson-Daniel/Assignment/raw/refs/heads/main/direction_arrow.glb",
      scale: Vector3(0.2, 0.2, 0.2),
      position: position,
      rotation: ARTools.getObjectRotation("left")
    );
    await arObjectManager.addNode(newNode);
  }
}
