import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart';
import 'package:iwaymaps/DebugToggle.dart';
import 'package:iwaymaps/Elements/DirectionHeader.dart';
import 'package:iwaymaps/Elements/ExploreModeWidget.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'API/outBuilding.dart';
import 'APIMODELS/outdoormodel.dart';
import 'directionClass.dart';
import 'localizedData.dart';

import 'package:chips_choice/chips_choice.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/API/PolyLineApi.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/APIMODELS/buildingAll.dart';
import 'package:iwaymaps/APIMODELS/landmark.dart';
import 'package:iwaymaps/Elements/HomepageLandmarkClickedSearchBar.dart';
import 'package:iwaymaps/Elements/buildingCard.dart';
import 'package:iwaymaps/Elements/directionInstruction.dart';
import 'package:iwaymaps/PolylineTestClass.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:iwaymaps/buildingState.dart';
import 'package:iwaymaps/navigationTools.dart';
import 'package:iwaymaps/path.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'API/PatchApi.dart';
import 'API/beaconapi.dart';
import 'API/ladmarkApi.dart';
import 'API/outbuildingapi.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/buildingAll.dart';
import 'APIMODELS/outbuildingmodel.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'Cell.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'DestinationSearchPage.dart';
import 'Elements/HomepageSearch.dart';
import 'Elements/NavigationFilterCard.dart';
import 'Elements/SearchNearby.dart';
import 'Elements/landmarkPannelShimmer.dart';
import 'MODELS/FilterInfoModel.dart';
import 'MapState.dart';
import 'MotionModel.dart';
import 'SourceAndDestinationPage.dart';
import 'bluetooth_scanning.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'cutommarker.dart';
import 'dart:math' as math;
import 'APIMODELS/landmark.dart' as la;
import 'dart:ui' as ui;
import 'package:geodesy/geodesy.dart' as geo;
import 'package:lottie/lottie.dart' as lott;
import '../Elements/DirectionHeader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigation(),
    );
  }
}

class Navigation extends StatefulWidget {
  String directLandID = "";

  Navigation({this.directLandID = ''});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  MapState mapState = new MapState();
  Timer? PDRTimer;
  Timer? _exploreModeTimer;
  String maptheme = "";
  var _initialCameraPosition = CameraPosition(
    target: LatLng(60.543833319119475, 77.18729871127312),
    zoom: 0,
  );
  late GoogleMapController _googleMapController;
  Set<Polygon> patch = Set();
  Set<Polygon> otherpatch = Set();
  Map<String, Set<gmap.Polyline>> polylines = Map();
  Set<gmap.Polyline> otherpolylines = Set();
  Set<gmap.Polyline> focusturn = Set();
  Set<Marker> focusturnArrow = Set();
  Map<String, Set<Polygon>> closedpolygons = Map();
  Set<Polygon> otherclosedpolygons = Set();
  Set<Marker> Markers = Set();
  Map<String, Set<Marker>> selectedroomMarker = Map();
  Map<int, Set<Marker>> pathMarkers = {};
  Map<String, List<Marker>> markers = Map();
  Building building = Building(floor: Map(), numberOfFloors: Map());
  Map<int, Set<gmap.Polyline>> singleroute = {};
  Map<int, Set<Marker>> dottedSingleRoute = {};
  BLueToothClass btadapter = new BLueToothClass();
  bool _isLandmarkPanelOpen = false;
  bool _isRoutePanelOpen = false;
  bool _isnavigationPannelOpen = false;
  bool _isreroutePannelOpen = false;
  bool _isBuildingPannelOpen = true;
  bool _isFilterPanelOpen = false;
  bool checkedForPolyineUpdated = false;
  bool checkedForPatchDataUpdated = false;
  bool checkedForLandmarkDataUpdated = false;
  PriorityQueue<MapEntry<String, double>> debugPQ = new PriorityQueue();

  HashMap<String, beacon> apibeaconmap = HashMap();
  late FlutterTts flutterTts;
  double mapbearing = 0.0;
  //UserState user = UserState(floor: 0, coordX: 154, coordY: 94, lat: 28.543406741799892, lng: 77.18761156074972, key: "659001d7e6c204e1eec13e26");
  UserState user = UserState(
      floor: 0, coordX: 0, coordY: 0, lat: 0.0, lng: 0.0, key: "", theta: 0.0);
  pathState PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);

  late String manufacturer;
  double step_threshold = 0.6;

  static const Duration _ignoreDuration = Duration(milliseconds: 20);
  UserAccelerometerEvent? _userAccelerometerEvent;
  DateTime? _userAccelerometerUpdateTime;
  int? _userAccelerometerLastInterval;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  final pdr = <StreamSubscription<dynamic>>[];
  Duration sensorInterval = Duration(milliseconds: 100);

  late StreamSubscription<CompassEvent> compassSubscription;
  bool detected = false;
  List<String> allBuildingList = [];
  List<double> accelerationMagnitudes = [];
  bool isCalibrating = false;
  bool excludeFloorSemanticWork = false;

  @override
  void initState() {
    super.initState();
    //PolylineTestClass.polylineSet.clear();
    // StartPDR();
    setPdrThreshold();

    building.floor.putIfAbsent("", () => 0);
    flutterTts = FlutterTts();
    setState(() {
      isLoading = true;
      speak("Loading maps");
    });
    print("Circular progress bar");
    //  calibrate();

    //btadapter.strtScanningIos(apibeaconmap);
    apiCalls();
    !DebugToggle.Slider ? handleCompassEvents() : () {};

    DefaultAssetBundle.of(context)
        .loadString("assets/mapstyle.json")
        .then((value) {
      maptheme = value;
    });
    checkPermissions();

    getDeviceManufacturer();
    try {
      _streamSubscriptions.add(
        userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
            (UserAccelerometerEvent event) {
          final now = DateTime.now();
          // setState(() {
          //   _userAccelerometerEvent = event;
          //   if (_userAccelerometerUpdateTime != null) {
          //     final interval = now.difference(_userAccelerometerUpdateTime!);
          //     if (interval > _ignoreDuration) {
          //       _userAccelerometerLastInterval = interval.inMilliseconds;
          //     }
          //   }
          // });
          _userAccelerometerUpdateTime = now;
        }, onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support User Accelerometer Sensor"),
                );
              });
          cancelOnError:
          true;
        }),
      );
    } catch (E) {
      print("E----");
      print(E);
    }
    // fetchlist();
    // filterItems();
  }

  void excludeFloorSemanticWorkchange() {
    setState(() {
      excludeFloorSemanticWork = true;
    });
  }

  double minHeight = 92.0;
  bool maxHeightBottomSheet = false;
  void close_isnavigationPannelOpen() {
    _slidePanelDown();
    _resetScrollPosition();
    print("close_isnavigationPannelOpen");
    setState(() {
      print(_isnavigationPannelOpen);
      //_isnavigationPannelOpen = false;
      minHeight = 90;
      print(_isnavigationPannelOpen);
    });
  }

  void calibrate() async {
    setState(() {
      isCalibrating = true;
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      double magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      setState(() {
        accelerationMagnitudes.add(magnitude);
      });
    });

    Timer(Duration(seconds: 10), () {
      //calculateThresholds();
      setState(() {
        isCalibrating = false;
      });
    });
    StartPDR();
  }

  void startOnPath() {
    setState(() {
      _isnavigationPannelOpen = true;
      _isreroutePannelOpen = false;
      user.isnavigating = true;
    });
  }

  void calculateThresholds() {
    if (accelerationMagnitudes.isNotEmpty) {
      double mean = accelerationMagnitudes.reduce((a, b) => a + b) /
          accelerationMagnitudes.length;
      double variance = accelerationMagnitudes
              .map((x) => (x - mean) * (x - mean))
              .reduce((a, b) => a + b) /
          accelerationMagnitudes.length;
      double standardDeviation = sqrt(variance);
      // Adjust multiplier as needed for sensitivity
      double multiplier = 5;
      setState(() {
        peakThreshold = mean + multiplier * standardDeviation;
        valleyThreshold = mean - multiplier * standardDeviation;
      });
    }
  }

  Future<void> getDeviceManufacturer() async {
    try {
      manufacturer = await DeviceInformation.deviceManufacturer;
      if (manufacturer.toLowerCase().contains("samsung")) {
        print("manufacture $manufacturer $step_threshold");
        step_threshold = 0.12;
      } else if (manufacturer.toLowerCase().contains("oneplus")) {
        print("manufacture $manufacturer $step_threshold");
        step_threshold = 0.7;
      } else if (manufacturer.toLowerCase().contains("realme")) {
        print("manufacture $manufacturer $step_threshold");
        step_threshold = 0.7;
      } else if (manufacturer.toLowerCase().contains("redmi")) {
        print("manufacture $manufacturer $step_threshold");
        step_threshold = 0.12;
      } else if (manufacturer.toLowerCase().contains("google")) {
        print("manufacture $manufacturer $step_threshold");
        step_threshold = 1.08;
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<void> setPdrThreshold() async {
    try {
      manufacturer = await DeviceInformation.deviceManufacturer;
      String deviceModel = await DeviceInformation.deviceModel;

      if (manufacturer.toLowerCase().contains("samsung")) {
        print("manufacture $manufacturer $step_threshold");
        if (deviceModel.startsWith("A", 3)) {
          // print(await DeviceInformation.deviceModel);
          peakThreshold = 10.7;
          valleyThreshold = -10.7;
        } else if (deviceModel.startsWith("M", 3)) {
          peakThreshold = 11.0;
          valleyThreshold = -11.0;
        } else {
          peakThreshold = 11.111111;
          valleyThreshold = -11.111111;
        }
      } else if (manufacturer.toLowerCase().contains("oneplus")) {
        print("manufacture $manufacturer $step_threshold");
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
        // step_threshold = 0.7;
      } else if (manufacturer.toLowerCase().contains("realme")) {
        print("manufacture $manufacturer $step_threshold");
        peakThreshold = 11.0;
        valleyThreshold = -11.0;
      } else if (manufacturer.toLowerCase().contains("redmi")) {
        print("manufacture $manufacturer $step_threshold");
        peakThreshold = 11.3;
        valleyThreshold = -11.3;
      } else if (manufacturer.toLowerCase().contains("google")) {
        print("manufacture $manufacturer $step_threshold");
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
      } else {
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
      }
    } catch (e) {
      throw (e);
    }
  }

  void handleCompassEvents() {
    compassSubscription = FlutterCompass.events!.listen((event) {
      double? compassHeading = event.heading!;
      setState(() {
        user.theta = compassHeading!;
        if (mapState.interaction2) {
          mapState.bearing = compassHeading!;
          _googleMapController.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: mapState.target,
                zoom: mapState.zoom,
                bearing: mapState.bearing!,
              ),
            ),
            //duration: Duration(milliseconds: 500), // Adjust the duration here (e.g., 500 milliseconds for a faster animation)
          );
        } else {
          if (markers.length > 0)
            markers[user.Bid]![0] = customMarker.rotate(
                compassHeading! - mapbearing, markers[user.Bid]![0]);
        }
      });
    });
  }

  void showToast(String mssg) {
    Fluttertoast.showToast(
      msg: mssg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  void checkPermissions() async {
    print("running");
    //  await requestLocationPermission();
    await requestBluetoothConnectPermission();
    //  await requestActivityPermission();
  }

  bool isPdr = false;
  // Function to start the timer
  void StartPDR() {
    PDRTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      // print("calling");
      setState(() {
        isPdr = true;
      });
      pdrstepCount();
      // onStepCount();
    });
  }

// Function to stop the timer
  bool isPdrStop = false;
  void StopPDR() async {
    if (PDRTimer != null && PDRTimer!.isActive) {
      setState(() {
        isPdrStop = true;
        isPdr = false;
      });

      PDRTimer!.cancel();
      for (final subscription in pdr) {
        subscription.cancel();
      }
    }
  }

  int stepCount = 0;
  int lastPeakTime = 0;
  int lastValleyTime = 0;
  //will have to set according to the device
  double peakThreshold = 11.1111111;
  double valleyThreshold = -11.1111111;

  int peakInterval = 300;
  int valleyInterval = 300;
  //it is the smoothness factor of the low pass filter.
  double alpha = 0.4;
  double filteredX = 0;
  double filteredY = 0;
  double filteredZ = 0;
  bool restartScanning = false;

// late StreamSubscription<AccelerometerEvent>? pdr;
  void pdrstepCount() {
    pdr.add(accelerometerEventStream().listen((AccelerometerEvent event) {
      if (pdr == null) {
        return; // Exit the event listener if subscription is canceled
      }
      // Apply low-pass filter
      filteredX = alpha * filteredX + (1 - alpha) * event.x;
      filteredY = alpha * filteredY + (1 - alpha) * event.y;
      filteredZ = alpha * filteredZ + (1 - alpha) * event.z;
      // Compute magnitude of acceleration vector
      double magnitude = sqrt((filteredX * filteredX +
          filteredY * filteredY +
          filteredZ * filteredZ));
      // Detect peak and valley
      if (magnitude > peakThreshold &&
          DateTime.now().millisecondsSinceEpoch - lastPeakTime > peakInterval) {
        setState(() {
          lastPeakTime = DateTime.now().millisecondsSinceEpoch;
          stepCount++;

          print("prev [${user.coordX},${user.coordY}]");
          bool isvalid = MotionModel.isValidStep(
              user,
              building.floorDimenssion[user.Bid]![user.floor]![0],
              building.floorDimenssion[user.Bid]![user.floor]![1],
              building.nonWalkable[user.Bid]![user.floor]!,
              reroute);
          if (isvalid) {
            user.move().then((value) {
              renderHere();
            });
          } else {
            if (user.isnavigating) {
              // reroute();
              // showToast("You are out of path");
            }
          }

          print("peakThreshold: ${peakThreshold}");
        });
      } else if (magnitude < valleyThreshold &&
          DateTime.now().millisecondsSinceEpoch - lastValleyTime >
              valleyInterval) {
        setState(() {
          lastValleyTime = DateTime.now().millisecondsSinceEpoch;
        });
      }
    }));
  }

  Future<void> paintMarker(LatLng Location) async {
    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 80);
    final Uint8List userlocdebug =
        await getImagesFromMarker('assets/tealtorch.png', 35);

    if (markers.containsKey(user.Bid)) {
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("debug"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userlocdebug),
        anchor: Offset(0.5, 0.829),
      ));
    } else {
      markers.putIfAbsent(user.Bid, () => []);
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("debug"),
        position: Location,
        icon: BitmapDescriptor.fromBytes(userlocdebug),
        anchor: Offset(0.5, 0.829),
      ));
    }
  }

  void renderHere() {
    setState(() {
      if (markers.length > 0) {
        List<double> lvalue = tools.localtoglobal(
            user.showcoordX.toInt(), user.showcoordY.toInt());
        markers[user.Bid]?[0] = customMarker.move(
            LatLng(lvalue[0], lvalue[1]), markers[user.Bid]![0]);

        mapState.target = LatLng(lvalue[0], lvalue[1]);
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: mapState.target,
              zoom: mapState.zoom,
              bearing: mapState.bearing!,
              tilt: mapState.tilt),
        ));

        List<double> ldvalue =
            tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt());
        markers[user.Bid]?[1] = customMarker.move(
            LatLng(ldvalue[0], ldvalue[1]), markers[user.Bid]![1]);
      }
    });
  }

  void onStepCount() {
    setState(() {
      if (_userAccelerometerEvent?.y != null) {
        if (_userAccelerometerEvent!.y > step_threshold ||
            _userAccelerometerEvent!.y < -step_threshold) {
          bool isvalid = MotionModel.isValidStep(
              user,
              building.floorDimenssion[user.Bid]![user.floor]![0],
              building.floorDimenssion[user.Bid]![user.floor]![1],
              building.nonWalkable[user.Bid]![user.floor]!,
              reroute);
          if (isvalid) {
            user.move().then((value) {
              setState(() {
                if (markers.length > 0) {
                  markers[user.Bid]![0] = customMarker.move(
                      LatLng(
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt())[0],
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt())[1]),
                      markers[user.Bid]![0]);
                }
              });
            });
          } else {
            showToast("You are out of path");
          }
        }
      }
    });
  }

  List<String> finalDirections = [];
  List<String> calcDirectionsExploreMode(List<int> userCords,
      List<int> newUserCord, List<nearestLandInfo> nearbyLandmarkCoords) {
    List<String> finalDirections = [];
    for (int i = 0; i < nearbyLandmarkCoords.length; i++) {
      double value = tools.calculateAngle2(userCords, newUserCord, [
        nearbyLandmarkCoords[i].coordinateX!,
        nearbyLandmarkCoords[i].coordinateY!
      ]);

      // print("value----");
      // print(value);
      String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);
      // print(finalvalue);
      finalDirections.add(finalvalue);
    }
    return finalDirections;
  }

  void repaintUser(String nearestBeacon) {
    reroute();
    paintUser(nearestBeacon, speakTTS: false);
  }

  void paintUser(String nearestBeacon,
      {bool speakTTS = true, bool render = true}) async {
    print("nearestBeacon : $nearestBeacon");

    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 80);
    final Uint8List userlocdebug =
        await getImagesFromMarker('assets/tealtorch.png', 35);

    if (apibeaconmap[nearestBeacon] != null) {
      //buildingAngle compute
      tools.angleBetweenBuildingAndNorth(
          apibeaconmap[nearestBeacon]!.buildingID!);

      //nearestLandmark compute
      await building.landmarkdata!.then((value) {
        nearestLandInfomation = tools.localizefindNearbyLandmark(
            apibeaconmap[nearestBeacon]!, value.landmarksMap!);
      });

      List<int> localBeconCord = [];
      localBeconCord.add(apibeaconmap[nearestBeacon]!.coordinateX!);
      localBeconCord.add(apibeaconmap[nearestBeacon]!.coordinateY!);
      print(
          "check beacon ${apibeaconmap[nearestBeacon]!.coordinateX} ${apibeaconmap[nearestBeacon]!.coordinateY}");

      pathState().beaconCords = localBeconCord;

      List<double> values = [];

      //floor alignment
      if (apibeaconmap[nearestBeacon]!.floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            building.polyLineData!.polyline!.floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!),
            building.polyLineData!.polyline!.floors!);
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
        values = tools.localtoglobal(apibeaconmap[nearestBeacon]!.coordinateX!,
            apibeaconmap[nearestBeacon]!.coordinateY!);
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
        values = tools.localtoglobal(apibeaconmap[nearestBeacon]!.coordinateX!,
            apibeaconmap[nearestBeacon]!.coordinateY!);
      }

      LatLng beaconLocation = LatLng(values[0], values[1]);
      mapState.target = LatLng(values[0], values[1]);

      user.Bid = apibeaconmap[nearestBeacon]!.buildingID!;

      user.coordX = apibeaconmap[nearestBeacon]!.coordinateX!;
      user.coordY = apibeaconmap[nearestBeacon]!.coordinateY!;
      user.showcoordX = user.coordX;
      user.showcoordY = user.coordY;
      UserState.cols = building.floorDimenssion[apibeaconmap[nearestBeacon]!
          .buildingID]![apibeaconmap[nearestBeacon]!.floor]![0];
      UserState.rows = building.floorDimenssion[apibeaconmap[nearestBeacon]!
          .buildingID]![apibeaconmap[nearestBeacon]!.floor]![1];
      UserState.reroute = reroute;
      UserState.closeNavigation = closeNavigation;
      UserState.AlignMapToPath = alignMapToPath;
      UserState.startOnPath = startOnPath;
      UserState.speak = speak;
      UserState.paintMarker = paintMarker;
      List<int> userCords = [];
      userCords.add(user.coordX);
      userCords.add(user.coordY);
      List<int> transitionValue = tools.eightcelltransition(user.theta);
      List<int> newUserCord = [
        user.coordX + transitionValue[0],
        user.coordY + transitionValue[1]
      ];

      user.lat =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.latitude!);
      user.lng =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.longitude!);
      user.floor = apibeaconmap[nearestBeacon]!.floor!;
      user.key = apibeaconmap[nearestBeacon]!.sId!;
      user.initialallyLocalised = true;
      setState(() {
        markers.clear();
        if (render) {
          markers.putIfAbsent(user.Bid, () => []);
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: beaconLocation,
            icon: BitmapDescriptor.fromBytes(userloc),
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: beaconLocation,
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
        } else {
          user.moveToFloor(apibeaconmap[nearestBeacon]!.floor!);
          markers.putIfAbsent(user.Bid, () => []);
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userloc),
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
        }

        building.floor[apibeaconmap[nearestBeacon]!.buildingID!] =
            apibeaconmap[nearestBeacon]!.floor!;
        createRooms(
            building.polyLineData!, apibeaconmap[nearestBeacon]!.floor!);
        building.landmarkdata!.then((value) {
          createMarkers(value, apibeaconmap[nearestBeacon]!.floor!);
        });
      });

      double value = tools.calculateAngle2(userCords, newUserCord, [
        nearestLandInfomation.coordinateX!,
        nearestLandInfomation.coordinateY!
      ]);

      print("value----");
      print(value);
      String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

      // double value =
      //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
      // print(value);
      // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

      // print("final value");
      // print(finalvalue);
      if (user.isnavigating == false) {
        detected = true;
        if (!_isExploreModePannelOpen) {
          _isBuildingPannelOpen = true;
        }
        nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
      }

      if (nearestLandInfomation.name!.isEmpty) {
        nearestLandInfomation.name = apibeaconmap[nearestBeacon]!.name!;

        nearestLandInfomation.floor = apibeaconmap[nearestBeacon]!.floor!;

        //updating user pointer

        building.floor[buildingAllApi.getStoredString()] = user.floor;
        createRooms(building.polyLineData!,
            building.floor[buildingAllApi.getStoredString()]!);
        if (pathMarkers[user.floor] != null) {
          setCameraPosition(pathMarkers[user.floor]!);
        }
        building.landmarkdata!.then((value) {
          createMarkers(
              value, building.floor[buildingAllApi.getStoredString()]!);
        });
        if (markers.length > 0)
          markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        mapState.zoom = 22;
        fitPolygonInScreen(patch.first);

        if (speakTTS) {
          if (finalvalue == "None") {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor, near ${apibeaconmap[nearestBeacon]!.name!}");
          } else {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${apibeaconmap[nearestBeacon]!.name!} is on your ${finalvalue}");
          }
        }
      } else {
        nearestLandInfomation.floor = apibeaconmap[nearestBeacon]!.floor!;

        if (speakTTS) {
          if (finalvalue == "None") {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor, near ${nearestLandInfomation.name}");
          } else {
            speak(
                "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${nearestLandInfomation.name} is on your ${finalvalue}");
          }
        }
      }

      if (speakTTS) {
        mapState.zoom = 22.0;
        _googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(user.lat, user.lng),
            22, // Specify your custom zoom level here
          ),
        );
      }
    } else {
      if (speakTTS) speak("Unable to find your location");
    }
    if (widget.directLandID.isNotEmpty) {
      print("checkdirectLandID");
      onLandmarkVenueClicked(widget.directLandID);
    }
  }

  void moveUser() async {
    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 80);
    final Uint8List userlocdebug =
        await getImagesFromMarker('assets/tealtorch.png', 35);

    LatLng userlocation = LatLng(user.lat, user.lng);
    mapState.target = LatLng(user.lat, user.lng);
    mapState.zoom = 21.0;
    _googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(user.lat, user.lng),
        20, // Specify your custom zoom level here
      ),
    );

    setState(() {
      markers.clear();
      markers.putIfAbsent(user.Bid, () => []);
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("UserLocation"),
        position: userlocation,
        icon: BitmapDescriptor.fromBytes(userloc),
        anchor: Offset(0.5, 0.829),
      ));
      markers[user.Bid]?.add(Marker(
        markerId: MarkerId("debug"),
        position: userlocation,
        icon: BitmapDescriptor.fromBytes(userlocdebug),
        anchor: Offset(0.5, 0.829),
      ));
    });
  }

  void reroute() {
    _isnavigationPannelOpen = false;
    _isRoutePanelOpen = false;
    _isLandmarkPanelOpen = false;
    _isreroutePannelOpen = true;
    user.isnavigating = false;
    print("reroute----- coord ${user.coordX},${user.coordY}");
    print("reroute----- show ${user.showcoordX},${user.showcoordY}");
    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;
    setState(() {
      if (markers.length > 0) {
        List<double> dvalue =
            tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt());
        markers[user.Bid]?[0] = customMarker.move(
            LatLng(dvalue[0], dvalue[1]), markers[user.Bid]![0]);
      }
    });
    speak(
        "You are going away from the path. Click Reroute to Navigate from here. ");
  }

  Future<void> requestBluetoothConnectPermission() async {
    final PermissionStatus permissionStatus =
        await Permission.bluetoothScan.request();
    print("permissionStatus    ----   ${permissionStatus}");
    if (permissionStatus.isGranted) {
      print("Bluetooth permission is granted");
      // Permission granted, you can now perform Bluetooth operations
    } else {
      // Permission denied, handle accordingly
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      print('location permission granted');
    } else {}
  }

  List<FilterInfoModel> landmarkListForFilter = [];
  bool isLoading = false;
  HashMap<String, beacon> resBeacons = HashMap();
  bool isBlueToothLoading = false;
  // Initially set to true to show loader

  void apiCalls() async {
    print("working 1");
    await patchAPI()
        .fetchPatchData(id: buildingAllApi.selectedBuildingID)
        .then((value) {
      print("${value.patchData.toString()}");
      building.patchData[value.patchData!.buildingID!] = value;
      createPatch(value);
      tools.globalData = value;
      for (int i = 0; i < 4; i++) {
        tools.corners.add(math.Point(
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!),
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!)));
      }
    });
    print("working 2");
    await PolyLineApi()
        .fetchPolyData(id: buildingAllApi.selectedBuildingID)
        .then((value) {
      print("object ${value.polyline!.floors!.length}");
      building.polyLineData = value;
      building.numberOfFloors[buildingAllApi.selectedBuildingID] =
          value.polyline!.floors!.length;
      building.polylinedatamap[buildingAllApi.selectedBuildingID] = value;
      createRooms(value, 0);
    });
    building.floor[buildingAllApi.selectedBuildingID] = 0;
    print("working 3");
    building.landmarkdata = landmarkApi()
        .fetchLandmarkData(id: buildingAllApi.selectedBuildingID)
        .then((value) {
      print("Himanshuchecker ids ${value.landmarks![0].name}");
      Map<int, LatLng> coordinates = {};
      for (int i = 0; i < value.landmarks!.length; i++) {
        if (value.landmarks![i].floor == 3 &&
            value.landmarks![i].properties!.name != null) {
          landmarkListForFilter.add(FilterInfoModel(
              LandmarkLat: value.landmarks![i].coordinateX!,
              LandmarkLong: value.landmarks![i].coordinateY!,
              LandmarkName: value.landmarks![i].properties!.name ?? ""));
        }
        if (value.landmarks![i].element!.subType == "AR") {
          coordinates[int.parse(value.landmarks![i].properties!.arValue!)] =
              LatLng(double.parse(value.landmarks![i].properties!.latitude!),
                  double.parse(value.landmarks![i].properties!.longitude!));
        }
        if (value.landmarks![i].element!.type == "Floor") {
          List<int> allIntegers = [];
          String jointnonwalkable =
              value.landmarks![i].properties!.nonWalkableGrids!.join(',');
          RegExp regExp = RegExp(r'\d+');
          Iterable<Match> matches = regExp.allMatches(jointnonwalkable);
          for (Match match in matches) {
            String matched = match.group(0)!;
            allIntegers.add(int.parse(matched));
          }
          Map<int, List<int>> currrentnonWalkable =
              building.nonWalkable[value.landmarks![i].buildingID!] ?? Map();
          currrentnonWalkable[value.landmarks![i].floor!] = allIntegers;

          building.nonWalkable[value.landmarks![i].buildingID!] =
              currrentnonWalkable;
          UserState.nonWalkable = currrentnonWalkable;
          localizedData.nonWalkable = currrentnonWalkable;

          Map<int, List<int>> currentfloorDimenssion =
              building.floorDimenssion[buildingAllApi.selectedBuildingID] ??
                  Map();
          currentfloorDimenssion[value.landmarks![i].floor!] = [
            value.landmarks![i].properties!.floorLength!,
            value.landmarks![i].properties!.floorBreadth!
          ];

          building.floorDimenssion[buildingAllApi.selectedBuildingID] =
              currentfloorDimenssion!;
          localizedData.currentfloorDimenssion = currentfloorDimenssion;

          print("fetch route--  ${building.floorDimenssion}");

          // building.floorDimenssion[value.landmarks![i].floor!] = [
          //   value.landmarks![i].properties!.floorLength!,
          //   value.landmarks![i].properties!.floorBreadth!
          // ];
        }
      }
      createARPatch(coordinates);
      createMarkers(value, 0);
      return value;
    });
    print("working 4");
    await Future.delayed(Duration(seconds: 2));
    print("5 seconds over");
    setState(() {
      isBlueToothLoading = true;
      print("isBlueToothLoading");
      print(isBlueToothLoading);
    });

    await beaconapi().fetchBeaconData().then((value) {
      print("beacondatacheck");

      building.beacondata = value;
      for (int i = 0; i < value.length; i++) {
        print(value[i].name);
        beacon beacons = value[i];
        if (beacons.name != null) {
          apibeaconmap[beacons.name!] = beacons;
        }
      }
      Building.apibeaconmap = apibeaconmap;

      print("scanningggg starteddddd");

      if (Platform.isAndroid) {
        print("starting scanning for android");
        btadapter.startScanning(apibeaconmap);
      } else {
        print("starting scanning for IOS");
        btadapter.startScanningIOS(apibeaconmap);
        // btadapter.strtScanningIos(apibeaconmap);
        // btadapter.getDevicesList();
      }

      //btadapter.startScanning(apibeaconmap);
      setState(() {
        resBeacons = apibeaconmap;
      });
      // print("printing bin");
      // btadapter.printbin();
      late Timer _timer;
      //please wait
      //searching your location

      speak("Please wait");
      speak("Searching your location. .");

      _timer = Timer.periodic(Duration(milliseconds: 9000), (timer) {
        localizeUser();

        print("localize user is calling itself.....");
        _timer.cancel();
      });
    });
    print("Himanshuchecker ids 1 ${buildingAllApi.getStoredAllBuildingID()}");
    print("Himanshuchecker ids 2 ${buildingAllApi.getStoredString()}");
    print("Himanshuchecker ids 3 ${buildingAllApi.getSelectedBuildingID()}");

    List<String> IDS = [];
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) {
      IDS.add(key);
    });
    await outBuilding().outbuilding(IDS).then((out) async {
      if (out != null) {
        buildingAllApi.outdoorID = out!.data!.campusId!;
        buildingAllApi.allBuildingID[out!.data!.campusId!] =
            geo.LatLng(0.0, 0.0);
      }
    });

    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      IDS.add(key);
      if (key != buildingAllApi.getSelectedBuildingID()) {
        await patchAPI().fetchPatchData(id: key).then((value) {
          building.patchData[value.patchData!.buildingID!] = value;
          if (key == buildingAllApi.outdoorID) {
            createotherPatch(value);
          } else {}
        });

        await PolyLineApi().fetchPolyData(id: key).then((value) {
          if (key == buildingAllApi.outdoorID) {
            createRooms(value, 1);
          } else {
            createRooms(value, 0);
          }
          building.polylinedatamap[key] = value;
          building.numberOfFloors[key] = value.polyline!.floors!.length;
          //building.polyLineData!.polyline!.mergePolyline(value.polyline!.floors);
        });

        await landmarkApi().fetchLandmarkData(id: key).then((value) async {
          await building.landmarkdata!.then((Value) {
            Value.mergeLandmarks(value.landmarks);
          });
          Map<int, LatLng> coordinates = {};
          for (int i = 0; i < value.landmarks!.length; i++) {
            if (value.landmarks![i].element!.subType == "AR" &&
                value.landmarks![i].properties!.arName ==
                    "P${int.parse(value.landmarks![i].properties!.arValue!)}") {
              coordinates[int.parse(value.landmarks![i].properties!.arValue!)] =
                  LatLng(
                      double.parse(value.landmarks![i].properties!.latitude!),
                      double.parse(value.landmarks![i].properties!.longitude!));
            }
            if (value.landmarks![i].element!.type == "Floor") {
              List<int> allIntegers = [];
              String jointnonwalkable =
                  value.landmarks![i].properties!.nonWalkableGrids!.join(',');
              RegExp regExp = RegExp(r'\d+');
              Iterable<Match> matches = regExp.allMatches(jointnonwalkable);
              for (Match match in matches) {
                String matched = match.group(0)!;
                allIntegers.add(int.parse(matched));
              }
              Map<int, List<int>> currrentnonWalkable =
                  building.nonWalkable[key] ?? Map();
              currrentnonWalkable[value.landmarks![i].floor!] = allIntegers;
              building.nonWalkable[key] = currrentnonWalkable;

              Map<int, List<int>> currentfloorDimenssion =
                  building.floorDimenssion[key] ?? Map();
              currentfloorDimenssion[value.landmarks![i].floor!] = [
                value.landmarks![i].properties!.floorLength!,
                value.landmarks![i].properties!.floorBreadth!
              ];
              building.floorDimenssion[key] = currentfloorDimenssion!;
              // print("fetch route--  ${building.floorDimenssion}");

              // building.floorDimenssion[value.landmarks![i].floor!] = [
              //   value.landmarks![i].properties!.floorLength!,
              //   value.landmarks![i].properties!.floorBreadth!
              // ];
            }
          }
          createotherARPatch(coordinates, value.landmarks![0].buildingID!);
        });
        await beaconapi().fetchBeaconData(id: key).then((value) {
          // print("beacondatacheck");
          //
          // building.beacondata = value;
          // for (int i = 0; i < value.length; i++) {
          //   print(value[i].name);
          //   beacon beacons = value[i];
          //   if (beacons.name != null) {
          //     apibeaconmap[beacons.name!] = beacons;
          //   }
          // }
          // Building.apibeaconmap = apibeaconmap;
          //
          // print("scanningggg starteddddd");
          //
          // if (Platform.isAndroid) {
          //   btadapter.startScanning(apibeaconmap);
          // } else {
          //   btadapter.strtScanningIos(apibeaconmap);
          // }
          //
          // // btadapter.startScanning(apibeaconmap);
          // setState(() {
          //   resBeacons = apibeaconmap;
          // });
          // // print("printing bin");
          // // btadapter.printbin();
          // late Timer _timer;
          // //please wait
          // //searching your location
          //
          // speak("Please wait");
          // speak("Searching your location. .");
          //
          // _timer = Timer.periodic(Duration(milliseconds: 9000), (timer) {
          //   localizeUser();
          //
          //   print("localize user is calling itself.....");
          //   _timer.cancel();
          // });
        });
      }
    });

    buildingAllApi.setStoredString(buildingAllApi.getSelectedBuildingID());
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isLoading = false;
      isBlueToothLoading = false;
      print("isBlueToothLoading");
      print(isBlueToothLoading);
    });
    print("Circular progress stop");
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the earth in kilometers

    double dLat = degreesToRadians(lat2 - lat1);
    double dLon = degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c; // Distance in kilometers

    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String getRandomString(List<String> stringList) {
    Random random = Random();
    int randomIndex = random.nextInt(stringList.length);
    return stringList[randomIndex];
  }

  String nearestLandmarkToBeacon = "";
  String nearestLandmarkToMacid = "";

  late nearestLandInfo nearestLandInfomation;

  Future<void> localizeUser() async {
    print("Beacon searching started");
    double highestweight = 0;
    String nearestBeacon = "";
    print("btadapter.BIN");
    print(btadapter.BIN);

    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          if (value > highestweight) {
            highestweight = value;
            nearestBeacon = key;
          }
        });
        break;
      }
    }
    setState(() {
      //lastBeaconValue = nearestBeacon;
    });

    nearestLandmarkToBeacon = nearestBeacon;
    nearestLandmarkToMacid = highestweight.toString();

    setState(() {
      testBIn = btadapter.BIN;
      testBIn.forEach((key, value) {
        currentBinSIze.add(value.length);
      });
    });
    btadapter.stopScanning();

    // sumMap = btadapter.calculateAverage();
    paintUser(nearestBeacon);

    //emptying the bin manually
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }
  }

  String nearbeacon = 'null';
  String weight = "null";
  HashMap<int, HashMap<String, double>> testBIn = HashMap();
  List<nearestLandInfo> getallnearestInfo = [];
  //Map<String, double> sumMap  = HashMap();
  List<int> currentBinSIze = [];
  Map<String, double> sumMap = new Map();
  Map<String, double> sortedsumMapfordebug = new Map();
  String lastBeaconValue = "";

  Future<void> realTimeReLocalizeUser(
      HashMap<String, beacon> apibeaconmap) async {
    sumMap.clear();
    setState(() {
      sumMap = btadapter.calculateAverage();
    });

    String firstValue = "";

    if (sumMap.isNotEmpty) {
      Map<String, double> sortedsumMap = sortMapByValue(sumMap);
      firstValue = sortedsumMap.entries.first.key;

      if (lastBeaconValue != firstValue &&
          sortedsumMap.entries.first.value >= 0.5) {
        btadapter.stopScanning();

        await building.landmarkdata!.then((value) {
          getallnearestInfo = tools.localizefindAllNearbyLandmark(
              apibeaconmap[firstValue]!, value.landmarksMap!);
        });

        List<int> tv = tools.eightcelltransition(user.theta);
        finalDirections = calcDirectionsExploreMode([
          apibeaconmap[firstValue]!.coordinateX!,
          apibeaconmap[firstValue]!.coordinateY!
        ], [
          apibeaconmap[firstValue]!.coordinateX! + tv[0],
          apibeaconmap[firstValue]!.coordinateY! + tv[1]
        ], getallnearestInfo);
        paintUser(firstValue);
        ExploreModePannelController.open();
        setState(() {
          lastBeaconValue = firstValue;
        });
        btadapter.emptyBin();
      } else {
        //HelperClass.showToast("Beacon Already scanned");
      }
    }
  }

  void createPatch(patchDataModel value) async {
    if (value.patchData!.coordinates!.isNotEmpty) {
      List<LatLng> polygonPoints = [];
      double latcenterofmap = 0.0;
      double lngcenterofmap = 0.0;

      for (int i = 0; i < 4; i++) {
        latcenterofmap = latcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!);
        lngcenterofmap = lngcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!);
      }
      latcenterofmap = latcenterofmap / 4;
      lngcenterofmap = lngcenterofmap / 4;

      _initialCameraPosition = CameraPosition(
        target: LatLng(latcenterofmap, lngcenterofmap),
        zoom: 20,
      );

      for (int i = 0; i < 4; i++) {
        polygonPoints.add(LatLng(
            latcenterofmap +
                1.1 *
                    (double.parse(
                            value.patchData!.coordinates![i].globalRef!.lat!) -
                        latcenterofmap),
            lngcenterofmap +
                1.1 *
                    (double.parse(
                            value.patchData!.coordinates![i].globalRef!.lng!) -
                        lngcenterofmap)));
      }
      setState(() {
        patch.add(
          Polygon(
              polygonId: PolygonId('patch'),
              points: polygonPoints,
              strokeWidth: 1,
              strokeColor: Colors.white,
              fillColor: Colors.white,
              geodesic: false,
              consumeTapEvents: true,
              zIndex: -1),
        );
      });

      try {
        fitPolygonInScreen(patch.first);
      } catch (e) {}
    }
  }

  void createotherPatch(patchDataModel value) async {
    if (value.patchData!.coordinates!.isNotEmpty) {
      List<LatLng> polygonPoints = [];
      double latcenterofmap = 0.0;
      double lngcenterofmap = 0.0;

      for (int i = 0; i < 4; i++) {
        latcenterofmap = latcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!);
        lngcenterofmap = lngcenterofmap +
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!);
      }
      latcenterofmap = latcenterofmap / 4;
      lngcenterofmap = lngcenterofmap / 4;

      for (int i = 0; i < 4; i++) {
        polygonPoints.add(LatLng(
            latcenterofmap +
                1.1 *
                    (double.parse(
                            value.patchData!.coordinates![i].globalRef!.lat!) -
                        latcenterofmap),
            lngcenterofmap +
                1.1 *
                    (double.parse(
                            value.patchData!.coordinates![i].globalRef!.lng!) -
                        lngcenterofmap)));
      }
      setState(() {
        otherpatch.add(
          Polygon(
              polygonId: PolygonId('otherpatch ${value.patchData!.buildingID}'),
              points: polygonPoints,
              strokeWidth: 1,
              strokeColor: Colors.white,
              fillColor: Colors.white,
              geodesic: false,
              consumeTapEvents: true,
              zIndex: -1),
        );
      });
    }
  }

  void createARPatch(Map<int, LatLng> coordinates) async {
    print("object $coordinates");
    if (coordinates.isNotEmpty) {
      print("$coordinates");
      print("${coordinates.length}");
      List<LatLng> points = [];
      List<MapEntry<int, LatLng>> entryList = coordinates.entries.toList();

      // Sort the list by keys
      entryList.sort((a, b) => a.key.compareTo(b.key));

      // Create a new LinkedHashMap from the sorted list
      LinkedHashMap<int, LatLng> sortedCoordinates =
          LinkedHashMap.fromEntries(entryList);

      // Print the sorted map
      sortedCoordinates.forEach((key, value) {
        points.add(value);
      });
      setState(() {
        patch.clear();
        patch.add(
          Polygon(
              polygonId: PolygonId('patch'),
              points: points,
              strokeWidth: 1,
              strokeColor: Colors.white,
              fillColor: Colors.white,
              geodesic: false,
              consumeTapEvents: true,
              zIndex: -1),
        );
      });
    }
  }

  void createotherARPatch(Map<int, LatLng> coordinates, String bid) async {
    print("HimanshuChecker $bid");
    if (coordinates.isNotEmpty) {
      List<LatLng> points = [];
      List<MapEntry<int, LatLng>> entryList = coordinates.entries.toList();

      // Sort the list by keys
      entryList.sort((a, b) => a.key.compareTo(b.key));

      // Create a new LinkedHashMap from the sorted list
      LinkedHashMap<int, LatLng> sortedCoordinates =
          LinkedHashMap.fromEntries(entryList);

      // Print the sorted map
      sortedCoordinates.forEach((key, value) {
        print("adding $key ${value.latitude},${value.longitude}");
        points.add(value);
      });
      setState(() {
        otherpatch
            .removeWhere((element) => element.polygonId.value.contains(bid));
        otherpatch.add(
          Polygon(
              polygonId: PolygonId('otherpatch $bid'),
              points: points,
              strokeWidth: 1,
              strokeColor: Colors.white,
              fillColor: Colors.white,
              geodesic: false,
              consumeTapEvents: true,
              zIndex: -1),
        );
      });
    }
  }

  Future<void> addselectedRoomMarker(List<LatLng> polygonPoints) async {
    selectedroomMarker.clear(); // Clear existing markers
    setState(() {
      if (selectedroomMarker.containsKey(buildingAllApi.getStoredString())) {
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
              markerId: MarkerId('selectedroomMarker'),
              position: calculateRoomCenter(polygonPoints),
              icon: BitmapDescriptor.defaultMarker,
              onTap: () {
                print("infowindowcheck");
              }),
        );
      } else {
        selectedroomMarker[buildingAllApi.getStoredString()] = Set<Marker>();
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
              markerId: MarkerId('selectedroomMarker'),
              position: calculateRoomCenter(polygonPoints),
              icon: BitmapDescriptor.defaultMarker,
              onTap: () {
                print("infowindowcheck");
              }),
        );
      }
    });
  }

  Future<void> addselectedMarker(LatLng Point) async {
    selectedroomMarker.clear(); // Clear existing markers

    setState(() {
      if (selectedroomMarker.containsKey(buildingAllApi.getStoredString())) {
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
            markerId: MarkerId('selectedroomMarker'),
            position: Point,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      } else {
        selectedroomMarker[buildingAllApi.getStoredString()] = Set<Marker>();
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
            markerId: MarkerId('selectedroomMarker'),
            position: Point,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }
    });
  }

  LatLng calculateRoomCenter(List<LatLng> polygonPoints) {
    double lat = 0.0;
    double long = 0.0;
    if (polygonPoints.length <= 4) {
      for (int i = 0; i < polygonPoints.length; i++) {
        lat = lat + polygonPoints[i].latitude;
        long = long + polygonPoints[i].longitude;
      }
      return LatLng(lat / polygonPoints.length, long / polygonPoints.length);
    } else {
      for (int i = 0; i < 4; i++) {
        lat = lat + polygonPoints[i].latitude;
        long = long + polygonPoints[i].longitude;
      }
      return LatLng(lat / 4, long / 4);
    }
  }

  void fitPolygonInScreen(Polygon polygon) {
    List<LatLng> polygonPoints = getPolygonPoints(polygon);
    double minLat = polygonPoints[0].latitude;
    double maxLat = polygonPoints[0].latitude;
    double minLng = polygonPoints[0].longitude;
    double maxLng = polygonPoints[0].longitude;

    for (LatLng point in polygonPoints) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (point.longitude < minLng) {
        minLng = point.longitude;
      }
      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 0));
  }

  LatLng calculateBoundsCenter(LatLngBounds bounds) {
    double centerLat =
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    double centerLng =
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2;

    return LatLng(centerLat, centerLng);
  }

  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
  }

  void animateToMarkers(Set<Marker> markers) {
    if (markers.isEmpty) return;

    double north = -90.0;
    double south = 90.0;
    double east = -180.0;
    double west = 180.0;

    // Find the bounds of all markers
    for (var marker in markers) {
      LatLng position = marker.position;
      north = max(north, position.latitude);
      south = min(south, position.latitude);
      east = max(east, position.longitude);
      west = min(west, position.longitude);
    }

    // Calculate the center of the map
    double centerLatitude = (north + south) / 2;
    double centerLongitude = (east + west) / 2;
    LatLng center = LatLng(centerLatitude, centerLongitude);

    // Optionally, adjust zoom level based on the spread of markers
    // This zoom level calculation is very basic and might need adjustment based on your specific needs
    double latDiff = north - south;
    double lngDiff = east - west;
    double zoom = max(
        0.0,
        15.0 -
            max(latDiff, lngDiff) *
                10); // Basic heuristic for zoom level: adjust as needed

    // Create a new camera position
    CameraPosition cameraPosition = CameraPosition(
      target: center,
      zoom: zoom,
    );

    // Animate camera to the new position
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void setCameraPosition(Set<Marker> selectedroomMarker1,
      {Set<Marker>? selectedroomMarker2 = null}) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;

    if (selectedroomMarker2 == null) {
      for (Marker marker in selectedroomMarker1) {
        double lat = marker.position.latitude;
        double lng = marker.position.longitude;

        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          100.0, // padding to adjust the bounding box on the screen
        ),
      );
    } else {
      for (Marker marker in selectedroomMarker1) {
        double lat = marker.position.latitude;
        double lng = marker.position.longitude;

        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }
      for (Marker marker in selectedroomMarker2) {
        double lat = marker.position.latitude;
        double lng = marker.position.longitude;

        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          100.0, // padding to adjust the bounding box on the screen
        ),
      );
    }
  }

  List<PolyArray> findLift(String floor, List<Floors> floorData) {
    List<PolyArray> lifts = [];
    floorData.forEach((Element) {
      if (Element.floor == floor) {
        Element.polyArray!.forEach((element) {
          if (element.cubicleName!.toLowerCase().contains("lift")) {
            lifts.add(element);
          }
        });
      }
    });
    return lifts;
  }

  List<int> findCommonLift(List<PolyArray> list1, List<PolyArray> list2) {
    List<int> diff = [0, 0];

    for (int i = 0; i < list1.length; i++) {
      for (int y = 0; y < list2.length; y++) {
        PolyArray l1 = list1[i];
        PolyArray l2 = list2[y];
        if (l1.cubicleName!.toLowerCase() != "lift" &&
            l2.cubicleName!.toLowerCase() != "lift" &&
            l1.cubicleName == l2.cubicleName) {
          print("i ${l1.cubicleName}");
          print("y ${l2.cubicleName}");
          int x1 = 0;
          int y1 = 0;
          for (int a = 0; a < 4; a++) {
            x1 = (x1 + l1.nodes![a].coordx!).toInt();
            y1 = (y1 + l1.nodes![a].coordy!).toInt();
          }

          int x2 = 0;
          int y2 = 0;
          for (int a = 0; a < 4; a++) {
            x2 = (x2 + l2.nodes![a].coordx!).toInt();
            y2 = (y2 + l2.nodes![a].coordy!).toInt();
          }

          x1 = (x1 / 4).toInt();
          y1 = (y1 / 4).toInt();
          x2 = (x2 / 4).toInt();
          y2 = (y2 / 4).toInt();

          diff = [x2 - x1, y2 - y1];
          print("11 ${[x1, y1]}");
          print("22 ${[x2, y2]}");
        }
      }
    }
    return diff;
  }

  void createRooms(polylinedata value, int floor) {
    if (closedpolygons[buildingAllApi.getStoredString()] == null) {
      closedpolygons[buildingAllApi.getStoredString()] = Set();
    }
    print("closepolygon id");
    print(buildingAllApi.getStoredString());
    print(closedpolygons[buildingAllApi.getStoredString()]);
    closedpolygons[value.polyline!.buildingID!]?.clear();
    print(
        "createroomschecker ${closedpolygons[buildingAllApi.getStoredString()]}");
    selectedroomMarker.clear();
    _isLandmarkPanelOpen = false;
    building.selectedLandmarkID = null;
    polylines[value.polyline!.buildingID!]?.clear();

    if (floor != 0) {
      List<PolyArray> prevFloorLifts =
          findLift(tools.numericalToAlphabetical(0), value.polyline!.floors!);
      List<PolyArray> currFloorLifts = findLift(
          tools.numericalToAlphabetical(floor), value.polyline!.floors!);
      List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
      print("iway $dvalue");
      UserState.xdiff = dvalue[0];
      UserState.ydiff = dvalue[1];
    } else {
      UserState.xdiff = 0;
      UserState.ydiff = 0;
    }
    List<PolyArray>? FloorPolyArray = value.polyline!.floors![0].polyArray;
    for (int j = 0; j < value.polyline!.floors!.length; j++) {
      if (value.polyline!.floors![j].floor ==
          tools.numericalToAlphabetical(floor)) {
        FloorPolyArray = value.polyline!.floors![j].polyArray;
      }
    }
    setState(() {
      if (FloorPolyArray != null) {
        for (PolyArray polyArray in FloorPolyArray) {
          if (polyArray.visibilityType == "visible") {
            List<LatLng> coordinates = [];

            for (Nodes node in polyArray.nodes!) {
              //coordinates.add(LatLng(node.lat!,node.lon!));
              coordinates.add(LatLng(
                  tools.localtoglobal(node.coordx!, node.coordy!,
                      patchData:
                          building.patchData[value.polyline!.buildingID])[0],
                  tools.localtoglobal(node.coordx!, node.coordy!,
                      patchData:
                          building.patchData[value.polyline!.buildingID])[1]));
            }
            if (!closedpolygons.containsKey(value.polyline!.buildingID!)) {
              closedpolygons.putIfAbsent(
                  value.polyline!.buildingID!, () => Set<Polygon>());
            }
            if (!polylines.containsKey(value.polyline!.buildingID!)) {
              polylines.putIfAbsent(
                  value.polyline!.buildingID!, () => Set<gmap.Polyline>());
            }

            if (polyArray.polygonType == 'Wall' ||
                polyArray.polygonType == 'undefined') {
              if (coordinates.length >= 2) {
                polylines[value.polyline!.buildingID!]!.add(gmap.Polyline(
                    polylineId: PolylineId(
                        "${value.polyline!.buildingID!} Line ${polyArray.id!}"),
                    points: coordinates,
                    color: polyArray.cubicleColor != null &&
                            polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                            '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Colors.black,
                    width: 1,
                    onTap: () {
                      print("polyArray.id! ${polyArray.id!}");
                    }));
              }
            } else if (polyArray.polygonType == 'Room') {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Room ${polyArray.id!}"),
                    points: coordinates,
                    strokeWidth: 1,
                    // Modify the color and opacity based on the selectedRoomId

                    strokeColor: Colors.black,
                    fillColor: polyArray.cubicleColor != null &&
                            polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                            '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Color(0xffE5F9FF),
                    consumeTapEvents: true,
                    onTap: () {
                      _googleMapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          tools.calculateRoomCenterinLatLng(coordinates),
                          22,
                        ),
                      );
                      setState(() {
                        if (building.selectedLandmarkID != polyArray.id &&
                            !user.isnavigating &&
                            !_isRoutePanelOpen) {
                          user.reset();
                          PathState = pathState.withValues(
                              -1, -1, -1, -1, -1, -1, null, 0);
                          pathMarkers.clear();
                          PathState.path.clear();
                          PathState.sourcePolyID = "";
                          PathState.destinationPolyID = "";
                          singleroute.clear();

                          user.isnavigating = false;
                          _isnavigationPannelOpen = false;
                          building.selectedLandmarkID = polyArray.id;
                          building.ignoredMarker.clear();
                          building.ignoredMarker.add(polyArray.id!);
                          _isBuildingPannelOpen = false;
                          _isRoutePanelOpen = false;
                          singleroute.clear();
                          _isLandmarkPanelOpen = true;
                          PathState.directions = [];
                          interBuildingPath.clear();
                          addselectedRoomMarker(coordinates);
                        }
                      });
                    }));
              }
            } else if (polyArray.polygonType == 'Cubicle') {
              if (polyArray.cubicleName == "Green Area") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffC2F1D5),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("lift")) {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffFFFF00),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName == "Male Washroom") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xff0000FF),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName == "Female Washroom") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffFF69B4),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("fire")) {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffFF4500),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("water")) {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xff00FFFF),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName!
                  .toLowerCase()
                  .contains("wall")) {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffCCCCCC),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName == "Restricted Area") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xff800000),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else if (polyArray.cubicleName == "Non Walkable Area") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Colors.black,
                      fillColor: polyArray.cubicleColor != null &&
                              polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                              '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xff333333),
                      onTap: () {
                        print("polyArray.id! ${polyArray.id!}");
                      }));
                }
              } else {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                    points: coordinates,
                    strokeWidth: 1,
                    strokeColor: Colors.black,
                    onTap: () {
                      print("polyArray.id! ${polyArray.id!}");
                    },
                    fillColor: polyArray.cubicleColor != null &&
                            polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                            '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Colors.black.withOpacity(0.2),
                  ));
                }
              }
            } else if (polyArray.polygonType == "Wall") {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                    points: coordinates,
                    strokeWidth: 1,
                    // Modify the color and opacity based on the selectedRoomId
                    strokeColor: Colors.black,
                    fillColor: polyArray.cubicleColor != null &&
                            polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                            '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Color(0xffCCCCCC),
                    consumeTapEvents: true,
                    onTap: () {
                      print("polyArray.id! ${polyArray.id!}");
                    }));
              }
            } else {
              polylines[value.polyline!.buildingID!]!.add(gmap.Polyline(
                  polylineId: PolylineId(polyArray.id!),
                  points: coordinates,
                  color: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                      ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                      : Colors.black,
                  width: 1,
                  onTap: () {
                    print("polyArray.id! ${polyArray.id!}");
                  }));
            }
          }
        }
      }
    });
  }

  Future<Uint8List> getImagesFromMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void createMarkers(land _landData, int floor) async {
    Markers.clear();
    List<Landmarks> landmarks = _landData.landmarks!;

    for (int i = 0; i < landmarks.length; i++) {
      if (landmarks[i].floor == floor &&
          landmarks[i].buildingID == buildingAllApi.getStoredString()) {
        if (landmarks[i].element!.type == "Rooms" &&
            landmarks[i].element!.subType != "main entry" &&
            landmarks[i].coordinateX != null &&
            !landmarks[i].wasPolyIdNull!) {
          // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
          //   ImageConfiguration(size: Size(44, 44)),
          //   getImagesFromMarker('assets/location_on.png',50),
          // );
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/location_on.png', 55);
          List<double> value = tools.localtoglobal(
              landmarks[i].coordinateX!, landmarks[i].coordinateY!);

          Markers.add(Marker(
              markerId: MarkerId("Room ${landmarks[i].properties!.polyId}"),
              position: LatLng(value[0], value[1]),
              icon: BitmapDescriptor.fromBytes(iconMarker),
              anchor: Offset(0.5, 0.5),
              visible: false,
              onTap: () {
                print("Info Window");
              },
              infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: '${landmarks[i].properties!.polyId}',
                  // Replace with additional information
                  onTap: () {
                    print("Info Window ");
                  })));
        }
        if (landmarks[i].element!.subType != null &&
            landmarks[i].element!.subType == "room door" &&
            landmarks[i].doorX != null) {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/dooricon.png', 45);
          setState(() {
            List<double> value =
                tools.localtoglobal(landmarks[i].doorX!, landmarks[i].doorY!);
            Markers.add(Marker(
                markerId: MarkerId("Door ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].name != null &&
            landmarks[i].name!.toLowerCase().contains("lift") &&
            landmarks[i].element!.subType != "room door") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/entry.png', 75);

          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Lift ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].properties!.washroomType != null &&
            landmarks[i].properties!.washroomType == "Male") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/6.png', 65);
          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].properties!.washroomType != null &&
            landmarks[i].properties!.washroomType == "Female") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/4.png', 65);

          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: false,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                )));
          });
        } else if (landmarks[i].element!.subType != null &&
            landmarks[i].element!.subType == "main entry") {
          final Uint8List iconMarker =
              await getImagesFromMarker('assets/1.png', 90);

          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: BitmapDescriptor.fromBytes(iconMarker),
                visible: true,
                infoWindow: InfoWindow(
                  title: landmarks[i].name,
                  snippet: 'Additional Information',
                  // Replace with additional information
                  onTap: () {
                    if (building.selectedLandmarkID !=
                        landmarks[i].properties!.polyId) {
                      building.selectedLandmarkID =
                          landmarks[i].properties!.polyId;
                      _isRoutePanelOpen = false;
                      singleroute.clear();
                      _isLandmarkPanelOpen = true;
                      addselectedMarker(LatLng(value[0], value[1]));
                    }
                  },
                ),
                onTap: () {
                  if (building.selectedLandmarkID !=
                      landmarks[i].properties!.polyId) {
                    building.selectedLandmarkID =
                        landmarks[i].properties!.polyId;
                    _isRoutePanelOpen = false;
                    singleroute.clear();
                    _isLandmarkPanelOpen = true;
                    addselectedMarker(LatLng(value[0], value[1]));
                  }
                }));
          });
        } else {}
      }
    }
    setState(() {
      Markers.add(Marker(
        markerId: MarkerId("Building marker"),
        position: _initialCameraPosition.target,
        icon: BitmapDescriptor.defaultMarker,
        visible: false,
      ));
    });
  }

  void toggleLandmarkPanel() {
    setState(() {
      _isLandmarkPanelOpen = !_isLandmarkPanelOpen;
      selectedroomMarker.clear();
      building.selectedLandmarkID = null;
      _googleMapController.animateCamera(CameraUpdate.zoomOut());
    });
  }

  PanelController _landmarkPannelController = new PanelController();
  bool calculatingPath = false;
  Widget landmarkdetailpannel(
      BuildContext context, AsyncSnapshot<land> snapshot) {
    pathMarkers.clear();
    clearPathVariables();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (!snapshot.hasData ||
        snapshot.data!.landmarksMap == null ||
        snapshot.data!.landmarksMap![building.selectedLandmarkID] == null) {
      print("object");
      //print(building.selectedLandmarkID);
      // If the data is not available, return an empty container
      _isLandmarkPanelOpen = false;
      _isreroutePannelOpen = false;
      showMarkers();
      selectedroomMarker.clear();
      building.selectedLandmarkID = null;
      return Container();
    }

    return Stack(
      children: [
        Positioned(
          left: 16,
          top: 16,
          right: 16,
          child: Container(
              width: screenWidth - 32,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white, // You can customize the border color
                  width: 1.0, // You can customize the border width
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey, // Shadow color
                    offset: Offset(0, 2), // Offset of the shadow
                    blurRadius: 4, // Spread of the shadow
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 48,
                    margin: EdgeInsets.only(right: 4),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          showMarkers();
                          toggleLandmarkPanel();
                          _isBuildingPannelOpen = true;
                        },
                        icon: Semantics(
                          label: "Back",
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        child: Text(
                      snapshot.data!.landmarksMap![building.selectedLandmarkID]!
                          .name!,
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8e8d8d),
                        height: 25 / 16,
                      ),
                    )),
                  ),
                  Container(
                    height: 48,
                    width: 47,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          showMarkers();
                          toggleLandmarkPanel();
                          _isBuildingPannelOpen = true;
                        },
                        icon: Semantics(
                          label: "Close",
                          child: Icon(
                            Icons.cancel_outlined,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
        SlidingUpPanel(
          controller: _landmarkPannelController,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ],
          minHeight: 145,
          maxHeight: screenHeight,
          snapPoint: 0.6,
          panel: () {
            _isRoutePanelOpen = false;
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Press button to start.');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return landmarkPannelShimmer();
              case ConnectionState.done:
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 6,
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Color(0xffd9d9d9),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: EdgeInsets.only(left: 17, top: 12),
                        child: Focus(
                          autofocus: true,
                          child: Semantics(
                            child: Text(
                              snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .name!,
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff292929),
                                height: 25 / 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 17,
                        ),
                        child: Text(
                          "Floor ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.buildingName!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.venueName!}",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff8d8c8c),
                            height: 25 / 16,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //       "1 min ",
                      //       style: const TextStyle(
                      //         color: Color(0xffDC6A01),
                      //         fontFamily: "Roboto",
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w400,
                      //         height: 25 / 16,
                      //       ),
                      //       textAlign: TextAlign.left,
                      //     ),
                      //     Text(
                      //       "(60 m)",
                      //       style: const TextStyle(
                      //         fontFamily: "Roboto",
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w400,
                      //         height: 25 / 16,
                      //       ),
                      //       textAlign: TextAlign.left,
                      //     )
                      //   ],
                      // ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 17,
                        ),
                        width: 114,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xff24B9B0),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            if (user.coordY != 0 && user.coordX != 0) {
                              PathState.sourceX = user.coordX;
                              PathState.sourceY = user.coordY;
                              PathState.sourceFloor = user.floor;
                              PathState.sourcePolyID = user.key;
                              print("object ${PathState.sourcePolyID}");
                              PathState.sourceName = "Your current location";
                              PathState.destinationPolyID =
                                  building.selectedLandmarkID!;
                              PathState.destinationName = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .name!;
                              PathState.destinationFloor = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .floor!;
                              PathState.sourceBid = user.Bid;

                              PathState.destinationBid = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .buildingID!;

                              setState(() {
                                print("valuechanged");
                                calculatingPath = true;
                              });
                              Future.delayed(Duration(seconds: 1), () {
                                calculateroute(snapshot.data!.landmarksMap!)
                                    .then((value) {
                                  calculatingPath = false;
                                  _isLandmarkPanelOpen = false;
                                  _isRoutePanelOpen = true;
                                });
                              });
                            } else {
                              PathState.sourceName = "Choose Starting Point";
                              PathState.destinationPolyID =
                                  building.selectedLandmarkID!;
                              PathState.destinationName = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .name!;
                              PathState.destinationFloor = snapshot
                                  .data!
                                  .landmarksMap![building.selectedLandmarkID]!
                                  .floor!;
                              building.selectedLandmarkID = "";
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SourceAndDestinationPage(
                                            DestinationID:
                                                PathState.destinationPolyID,
                                          ))).then((value) {
                                if (value != null) {
                                  fromSourceAndDestinationPage(value);
                                }
                              });
                            }
                          },
                          child: (!calculatingPath)
                              ? const Row(
                                  //  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Direction",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                )
                              : Container(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        height: 1,
                        width: screenWidth,
                        color: Color(0xffebebeb),
                      ),
                      Semantics(
                        label: "Information",
                        child: Container(
                          margin: EdgeInsets.only(left: 17, top: 20),
                          child: Text(
                            "Information",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff282828),
                              height: 24 / 18,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16, right: 16),
                        padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.0, color: Color(0xffebebeb))),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(right: 16),
                                width: 32,
                                height: 32,
                                child: Semantics(
                                  excludeSemantics: true,
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xff24B9B0),
                                    size: 24,
                                  ),
                                )),
                            Container(
                              width: screenWidth - 100,
                              margin: EdgeInsets.only(top: 8),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff4a4545),
                                    height: 25 / 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.name!}, Floor ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.buildingName!}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      snapshot.data!.landmarksMap![building.selectedLandmarkID]!
                                  .properties!.contactNo !=
                              null
                          ? Container(
                              margin: EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1.0,
                                    color: Color(0xffebebeb),
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 16),
                                    width: 32,
                                    height: 32,
                                    child: Icon(
                                      Icons.call,
                                      color: Color(0xff24B9B0),
                                      size: 24,
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth - 100,
                                    margin: EdgeInsets.only(top: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff4a4545),
                                          height: 25 / 16,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.properties!.contactNo!}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      snapshot.data!.landmarksMap![building.selectedLandmarkID]!
                                      .properties!.email !=
                                  "" &&
                              snapshot
                                      .data!
                                      .landmarksMap![
                                          building.selectedLandmarkID]!
                                      .properties!
                                      .email !=
                                  null
                          ? Container(
                              margin: EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1.0, color: Color(0xffebebeb))),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: 16),
                                      width: 32,
                                      height: 32,
                                      child: Icon(
                                        Icons.mail_outline,
                                        color: Color(0xff24B9B0),
                                        size: 24,
                                      )),
                                  Container(
                                    width: screenWidth - 100,
                                    margin: EdgeInsets.only(top: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff4a4545),
                                          height: 25 / 16,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.properties!.email!}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                );
            }
          }(),
        ),
      ],
    );
  }

  int calculateindex(int x, int y, int fl) {
    return (y * fl) + x;
  }

  List<CommonLifts> findCommonLifts(
      List<la.Lifts> list1, List<la.Lifts> list2) {
    List<CommonLifts> commonLifts = [];

    for (var lift1 in list1) {
      for (var lift2 in list2) {
        if (lift1.name == lift2.name) {
          // Create a new Lifts object with x and y values from both input lists
          print(
              "name ${lift1.name} (${lift1.x},${lift1.y}) && (${lift2.x},${lift2.y})");
          commonLifts.add(CommonLifts(
              name: lift1.name,
              distance: lift1.distance,
              x1: lift1.x,
              y1: lift1.y,
              x2: lift2.x,
              y2: lift2.y));
          break;
        }
      }
    }

    // Sort the commonLifts based on distance
    commonLifts.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    return commonLifts;
  }

  List<CommonStairs> findCommonStairs(
      List<la.Stairs> list1, List<la.Stairs> list2) {
    List<CommonStairs> commonStairs = [];

    for (var stair1 in list1) {
      for (var stair2 in list2) {
        if (stair1.name == stair2.name) {
          // Create a new Lifts object with x and y values from both input lists
          print(
              "name ${stair1.name} (${stair1.x},${stair2.y}) && (${stair1.x},${stair2.y})");
          commonStairs.add(CommonStairs(
              name: stair1.name,
              distance: stair1.distance,
              x1: stair1.x,
              y1: stair1.y,
              x2: stair2.x,
              y2: stair2.y));
          break;
        }
      }
    }

    // Sort the commonLifts based on distance
    commonStairs.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    return commonStairs;
  }

  Map<List<String>, Set<gmap.Polyline>> interBuildingPath = new Map();
  int pathTypeSelected = 0;
  bool multiFloorPath = false;

  Future<void> calculateroute(Map<String, Landmarks> landmarksMap) async {
    print("landmarksMap");
    print(landmarksMap.keys);
    print(landmarksMap.values);
    print(landmarksMap[PathState.destinationPolyID]!.buildingID);
    print(landmarksMap[PathState.sourcePolyID]!.buildingID);

    singleroute.clear();
    pathMarkers.clear();
    PathState.destinationX =
        landmarksMap[PathState.destinationPolyID]!.coordinateX!;
    PathState.destinationY =
        landmarksMap[PathState.destinationPolyID]!.coordinateY!;
    if (landmarksMap[PathState.destinationPolyID]!.doorX != null) {
      PathState.destinationX =
          landmarksMap[PathState.destinationPolyID]!.doorX!;
      PathState.destinationY =
          landmarksMap[PathState.destinationPolyID]!.doorY!;
    }
    if (PathState.sourceBid == PathState.destinationBid) {
      if (PathState.sourceFloor == PathState.destinationFloor) {
        print("Calculateroute if statement");
        print(
            "${PathState.sourceX},${PathState.sourceY}    ${PathState.destinationX},${PathState.destinationY}");
        await fetchroute(
            PathState.sourceX,
            PathState.sourceY,
            PathState.destinationX,
            PathState.destinationY,
            PathState.destinationFloor,
            bid: PathState.destinationBid);
        building.floor[buildingAllApi.getStoredString()] = user.floor;
        createRooms(building.polyLineData!,
            building.floor[buildingAllApi.getStoredString()]!);

        building.landmarkdata!.then((value) {
          createMarkers(
              value, building.floor[buildingAllApi.getStoredString()]!);
        });
        if (markers.length > 0)
          markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        mapState.zoom = 21;
      } else if (PathState.sourceFloor != PathState.destinationFloor) {
        setState(() {
          multiFloorPath = true;
        });
        if (pathTypeSelected == 0) {
          List<CommonLifts> commonlifts = findCommonLifts(
              landmarksMap[PathState.sourcePolyID]!.lifts!,
              landmarksMap[PathState.destinationPolyID]!.lifts!);

          await fetchroute(
              commonlifts[0].x2!,
              commonlifts[0].y2!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              bid: PathState.destinationBid,
              liftName: commonlifts[0].name);

          await fetchroute(PathState.sourceX, PathState.sourceY,
              commonlifts[0].x1!, commonlifts[0].y1!, PathState.sourceFloor,
              bid: PathState.destinationBid);

          PathState.connections[PathState.destinationBid] = {
            PathState.sourceFloor: calculateindex(
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.sourceFloor]![0]),
            PathState.destinationFloor: calculateindex(
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.destinationFloor]![0])
          };
        } else if (pathTypeSelected == 1) {
          List<CommonStairs> commonstairs = findCommonStairs(
              landmarksMap[PathState.sourcePolyID]!.stairs!,
              landmarksMap[PathState.destinationPolyID]!.stairs!);

          await fetchroute(
              commonstairs[0].x2!,
              commonstairs[0].y2!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              bid: PathState.destinationBid,
              liftName: commonstairs[0].name);

          await fetchroute(PathState.sourceX, PathState.sourceY,
              commonstairs[0].x1!, commonstairs[0].y1!, PathState.sourceFloor,
              bid: PathState.destinationBid);

          PathState.connections[PathState.destinationBid] = {
            PathState.sourceFloor: calculateindex(
                commonstairs[0].x1!,
                commonstairs[0].y1!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.sourceFloor]![0]),
            PathState.destinationFloor: calculateindex(
                commonstairs[0].x2!,
                commonstairs[0].y2!,
                building.floorDimenssion[PathState.destinationBid]![
                    PathState.destinationFloor]![0])
          };
        }
      }
    } else {
      print("calculateroute else statement");
      double sourceEntrylat = 0;
      double sourceEntrylng = 0;
      double destinationEntrylat = 0;
      double destinationEntrylng = 0;

      building.landmarkdata!.then((land) async {
        for (int i = 0; i < land.landmarks!.length; i++) {
          Landmarks element = land.landmarks![i];
          print("running destination location");
          if (element.element!.subType != null &&
              element.element!.subType!.toLowerCase().contains("entry") &&
              element.buildingID == PathState.destinationBid) {
            destinationEntrylat = double.parse(element.properties!.latitude!);
            destinationEntrylng = double.parse(element.properties!.longitude!);
            if (element.floor == PathState.destinationFloor) {
              await fetchroute(
                  element.coordinateX!,
                  element.coordinateY!,
                  PathState.destinationX,
                  PathState.destinationY,
                  PathState.destinationFloor,
                  bid: PathState.destinationBid);
              print("running destination location no lift run");
            } else if (element.floor != PathState.destinationFloor) {
              setState(() {
                multiFloorPath = true;
              });
              if (pathTypeSelected == 0) {
                List<CommonLifts> commonlifts = findCommonLifts(element.lifts!,
                    landmarksMap[PathState.destinationPolyID]!.lifts!);
                await fetchroute(
                    commonlifts[0].x2!,
                    commonlifts[0].y2!,
                    PathState.destinationX,
                    PathState.destinationY,
                    PathState.destinationFloor,
                    bid: PathState.destinationBid);
                await fetchroute(element.coordinateX!, element.coordinateY!,
                    commonlifts[0].x1!, commonlifts[0].y1!, element.floor!,
                    bid: PathState.destinationBid);

                PathState.connections[PathState.destinationBid] = {
                  element.floor!: calculateindex(
                      commonlifts[0].x1!,
                      commonlifts[0].y1!,
                      building.floorDimenssion[PathState.destinationBid]![
                          element.floor!]![0]),
                  PathState.destinationFloor: calculateindex(
                      commonlifts[0].x2!,
                      commonlifts[0].y2!,
                      building.floorDimenssion[PathState.destinationBid]![
                          PathState.destinationFloor]![0])
                };
              } else if (pathTypeSelected == 1) {
                List<CommonStairs> commonstairs = findCommonStairs(
                    element.stairs!,
                    landmarksMap[PathState.destinationPolyID]!.stairs!);
                await fetchroute(
                    commonstairs[0].x2!,
                    commonstairs[0].y2!,
                    PathState.destinationX,
                    PathState.destinationY,
                    PathState.destinationFloor,
                    bid: PathState.destinationBid);
                await fetchroute(element.coordinateX!, element.coordinateY!,
                    commonstairs[0].x1!, commonstairs[0].y1!, element.floor!,
                    bid: PathState.destinationBid);

                PathState.connections[PathState.destinationBid] = {
                  element.floor!: calculateindex(
                      commonstairs[0].x1!,
                      commonstairs[0].y1!,
                      building.floorDimenssion[PathState.destinationBid]![
                          element.floor!]![0]),
                  PathState.destinationFloor: calculateindex(
                      commonstairs[0].x2!,
                      commonstairs[0].y2!,
                      building.floorDimenssion[PathState.destinationBid]![
                          PathState.destinationFloor]![0])
                };
              }
            }
            break;
          }
        }
        // Landmarks source= landmarksMap[PathState.sourcePolyID]!;
        // double sourceLat=double.parse(source.properties!.latitude!);
        // double sourceLng=double.parse(source.properties!.longitude!);
        //
        //
        // Landmarks destination= landmarksMap[PathState.destinationPolyID]!;
        // double destinationLat=double.parse(source.properties!.latitude!);
        // double destinationLng=double.parse(source.properties!.longitude!);

        for (int i = 0; i < land.landmarks!.length; i++) {
          Landmarks element = land.landmarks![i];
          print("running source location");
          if (element.element!.subType != null &&
              element.element!.subType!.toLowerCase().contains("entry") &&
              element.buildingID == PathState.sourceBid) {
            sourceEntrylat = double.parse(element.properties!.latitude!);
            sourceEntrylng = double.parse(element.properties!.longitude!);
            if (PathState.sourceFloor == element.floor) {
              await fetchroute(PathState.sourceX, PathState.sourceY,
                  element.coordinateX!, element.coordinateY!, element.floor!,
                  bid: PathState.sourceBid);
              print("running source location no lift run");
            } else if (PathState.sourceFloor != element.floor) {
              if (pathTypeSelected == 0) {
                List<CommonLifts> commonlifts = findCommonLifts(
                    landmarksMap[PathState.sourcePolyID]!.lifts!,
                    element.lifts!);

                await fetchroute(commonlifts[0].x2!, commonlifts[0].y2!,
                    element.coordinateX!, element.coordinateY!, element.floor!,
                    bid: PathState.sourceBid);
                await fetchroute(
                    PathState.sourceX,
                    PathState.sourceY,
                    commonlifts[0].x1!,
                    commonlifts[0].y1!,
                    PathState.sourceFloor,
                    bid: PathState.sourceBid);

                PathState.connections[PathState.sourceBid] = {
                  PathState.sourceFloor: calculateindex(
                      commonlifts[0].x1!,
                      commonlifts[0].y1!,
                      building.floorDimenssion[PathState.sourceBid]![
                          PathState.sourceFloor]![0]),
                  element.floor!: calculateindex(
                      commonlifts[0].x2!,
                      commonlifts[0].y2!,
                      building.floorDimenssion[PathState.sourceBid]![
                          element.floor!]![0])
                };
              } else if (pathTypeSelected == 1) {
                List<CommonStairs> commonstairs = findCommonStairs(
                    landmarksMap[PathState.sourcePolyID]!.stairs!,
                    element.stairs!);

                await fetchroute(commonstairs[0].x2!, commonstairs[0].y2!,
                    element.coordinateX!, element.coordinateY!, element.floor!,
                    bid: PathState.sourceBid);
                await fetchroute(
                    PathState.sourceX,
                    PathState.sourceY,
                    commonstairs[0].x1!,
                    commonstairs[0].y1!,
                    PathState.sourceFloor,
                    bid: PathState.sourceBid);

                PathState.connections[PathState.sourceBid] = {
                  PathState.sourceFloor: calculateindex(
                      commonstairs[0].x1!,
                      commonstairs[0].y1!,
                      building.floorDimenssion[PathState.sourceBid]![
                          PathState.sourceFloor]![0]),
                  element.floor!: calculateindex(
                      commonstairs[0].x2!,
                      commonstairs[0].y2!,
                      building.floorDimenssion[PathState.sourceBid]![
                          element.floor!]![0])
                };
              }
            }
            break;
          }
        }

        OutBuildingModel? buildData = await OutBuildingData.outBuildingData(
            sourceEntrylat,
            sourceEntrylng,
            destinationEntrylat,
            destinationEntrylng);
        print("build data: $buildData");

        List<LatLng> coords = [];
        if (buildData != null) {
          int len = buildData!.data!.path!.length;
          for (int i = 0; i < len; i++) {
            coords.add(LatLng(buildData!.data!.path![i].lat!,
                buildData!.data!.path![i].lng!));
          }

          List<String> key = [PathState.sourceBid, PathState.destinationBid];
          interBuildingPath[key] = Set();
          interBuildingPath[key]!.add(gmap.Polyline(
            polylineId: PolylineId("InterBuilding"),
            points: coords,
            color: Colors.red,
            width: 1,
          ));
        }
      });
      print("different building detected");

      print(PathState.path.keys);
      print(pathMarkers.keys);
    }

    double time = 0;
    double distance = 0;
    DateTime currentTime = DateTime.now();
    if (PathState.path.isNotEmpty) {
      PathState.path.forEach((key, value) {
        time = time + value.length / 120;
        distance = distance + value.length;
      });
      time = time.ceil().toDouble();

      distance = distance * 0.3048;
      distance = double.parse(distance.toStringAsFixed(1));
      if (PathState.destinationName == "Your current location") {
        speak(
            "${nearestLandInfomation.name} is $distance meter away. Click Start to Navigate.");
      } else {
        speak(
            "${PathState.destinationName} is $distance meter away. Click Start to Navigate.");
      }
    }
  }

  List<int> beaconCord = [];
  double cordL = 0;
  double cordLt = 0;
  List<List<int>> getPoints = [];
  List<int> getnodes = [];

  Future<List<int>> fetchroute(
      int sourceX, int sourceY, int destinationX, int destinationY, int floor,
      {String? bid = null, String? liftName}) async {
    int numRows = building.floorDimenssion[bid]![floor]![1]; //floor breadth
    int numCols = building.floorDimenssion[bid]![floor]![0]; //floor length
    int sourceIndex = calculateindex(sourceX, sourceY, numCols);
    int destinationIndex = calculateindex(destinationX, destinationY, numCols);

    print("numcol $numCols");

    List<int> path = await findBestPathAmongstBoth(
        numRows,
        numCols,
        building.nonWalkable[bid]![floor]!,
        sourceIndex,
        destinationIndex,
        building,
        floor,
        bid ?? "");

    List<int> turns = tools.getTurnpoints(path, numCols);
    for (int i = 0; i < turns.length; i++) {
      int x = turns[i] % numCols;
      int y = turns[i] ~/ numCols;
      getPoints.add([x, y]);
    }
    getPoints.add([destinationX, destinationY]);
    List<Landmarks> nearbyPathLandmarks = [];
    building.landmarkdata!.then((value) {
      List<Landmarks> nearbyLandmarks = tools.findNearbyLandmark(
          path, value.landmarksMap!, 5, numCols, floor, bid!);
      pathState.nearbyLandmarks = nearbyLandmarks;
      // PathState.nearbyLandmarks.forEach((element) {
      //   print(element.name);
      // });
      tools
          .associateTurnWithLandmark(path, nearbyLandmarks, numCols)
          .then((value) {
        PathState.associateTurnWithLandmark = value;
        // PathState.associateTurnWithLandmark.forEach((key, value) {
        //   print("${key} , ${value.name}");
        // });
        List<direction> directions = [];
        if (liftName != null) {
          directions.add(direction(-1, "Take ${liftName}", null, null,
              floor.toDouble(), null, null, floor, bid ?? ""));
        }
        directions.addAll(tools.getDirections(
            path, numCols, value, floor, bid ?? "", PathState));
        // directions.forEach((element) {
        //   print("directioons ${value[element.node]} +++  ${element.node}  +++++  ${element.turnDirection}  +++++++  ${element.nearbyLandmark}");
        // });

        directions.addAll(PathState.directions);
        PathState.directions = directions;
      });

      if (destinationX == PathState.destinationX &&
          destinationY == PathState.destinationY) {
        PathState.directions.add(direction(
            destinationIndex,
            value.landmarksMap![PathState.destinationPolyID]!.name!,
            value.landmarksMap![PathState.destinationPolyID],
            0,
            0,
            destinationX,
            destinationY,
            floor,
            bid,
            isDestination: true));
      }
    });

    List<Cell> Cellpath =
        findCorridorSegments(path, building.nonWalkable[bid]![floor]!, numCols);
    PathState.CellTurnPoints = tools.getCellTurnpoints(Cellpath, numCols);
    List<int> temp = [];
    List<Cell> Celltemp = [];

    temp.addAll(path);
    Celltemp.addAll(Cellpath);
    temp.addAll(PathState.singleListPath);
    Celltemp.addAll(PathState.singleCellListPath);
    PathState.singleListPath = temp;
    PathState.singleCellListPath = Celltemp;

    PathState.path[floor] = path;
    PathState.Cellpath[floor] = Cellpath;
    if (PathState.numCols == null) {
      PathState.numCols = Map();
    }
    if (PathState.numCols![bid!] != null) {
      PathState.numCols![bid]![floor] = numCols;
    } else {
      PathState.numCols![bid] = Map();
      PathState.numCols![bid]![floor] = numCols;
    }

    if (path.isNotEmpty) {
      if (floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            building.polyLineData!.polyline!.floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(floor),
            building.polyLineData!.polyline!.floors!);
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
      }
      List<double> svalue = [];
      List<double> dvalue = [];
      if (bid != null) {
        print("Himanshucheckerpath in if block ");
        print("building.patchData[bid]");
        print(building.patchData[bid]!.patchData!.fileName);
        svalue = tools.localtoglobal(sourceX, sourceY,
            patchData: building.patchData[bid]);
        dvalue = tools.localtoglobal(destinationX, destinationY,
            patchData: building.patchData[bid]);
      } else {
        print("Himanshucheckerpath in else block ");
        svalue = tools.localtoglobal(sourceX, sourceY);
        dvalue = tools.localtoglobal(destinationX, destinationY);
      }

      final Uint8List tealtorch =
          await getImagesFromMarker('assets/tealtorch.png', 35);

      Set<Marker> innerMarker = Set();

      innerMarker.add(Marker(
          markerId: MarkerId("destination${bid}"),
          position: LatLng(dvalue[0], dvalue[1]),
          icon: BitmapDescriptor.defaultMarker));
      innerMarker.add(
        Marker(
          markerId: MarkerId('source${bid}'),
          position: LatLng(svalue[0], svalue[1]),
          icon: BitmapDescriptor.fromBytes(tealtorch),
          anchor: Offset(0.5, 0.5),
        ),
      );
      setCameraPosition(innerMarker);
      pathMarkers[floor] = innerMarker;
    } else {
      print("No path found.");
    }

    List<LatLng> coordinates = [];

    for (int node in path) {
      if (!building.nonWalkable[bid]![floor]!.contains(node)) {
        int row = (node % numCols); //divide by floor length
        int col = (node ~/ numCols); //divide by floor length
        if (bid != null) {
          List<double> value =
              tools.localtoglobal(row, col, patchData: building.patchData[bid]);

          coordinates.add(LatLng(value[0], value[1]));
        } else {
          List<double> value = tools.localtoglobal(row, col);
          coordinates.add(LatLng(value[0], value[1]));
        }
      }
    }
    setState(() {
      singleroute.putIfAbsent(floor, () => Set());
      singleroute[floor]?.add(gmap.Polyline(
        polylineId: PolylineId("$bid"),
        points: coordinates,
        color: Colors.red,
        width: 5,
      ));
    });

    // setState(() {
    //   Set<gmap.Polyline> innerset = Set();
    //   innerset.add(gmap.Polyline(
    //     polylineId: PolylineId("route"),
    //     points: coordinates,
    //     color: Colors.red,
    //     width: 3,
    //   ));
    //   singleroute[floor] = innerset;
    // });

    building.floor[bid!] = floor;
    createRooms(building.polyLineData!, floor);
    return path;
  }

  void closeRoutePannel() {
    _routeDetailPannelController.close();
  }

  void openRoutePannel() {
    _routeDetailPannelController.open();
  }

  void clearPathVariables() {
    getPoints.clear();
  }

  int floors = 0;

  Widget floorColumn() {
    List<int> floorNumbers = List.generate(
        building.numberOfFloors[buildingAllApi.getStoredString()]!,
        (index) => index);

    return Semantics(
      excludeSemantics: excludeFloorSemanticWork,
      child: Container(
        height: 300,
        width: 100,
        child: ListView.builder(
            itemCount:
                building.numberOfFloors[buildingAllApi.getStoredString()]!,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(top: 10),
                child: ClipRRect(
                  // Adjust the radius as needed
                  child: Material(
                    elevation: 4.0, // Add elevation for shadow effect
                    borderRadius: BorderRadius.circular(25.0),
                    child: Semantics(
                      label: "Floor ${index}",
                      child: Container(
                        width: 30,
                        height: 42,
                        child: ListTile(
                          onTap: () {
                            building.floor[buildingAllApi.getStoredString()] =
                                index;
                            createRooms(
                              building.polylinedatamap[
                                  buildingAllApi.getStoredString()]!,
                              building.floor[buildingAllApi.getStoredString()]!,
                            );
                            if (pathMarkers[index] != null) {
                              //setCameraPosition(pathMarkers[i]!);
                            }
                            building.landmarkdata!.then((value) {
                              createMarkers(
                                value,
                                building
                                    .floor[buildingAllApi.getStoredString()]!,
                              );
                            });
                          },
                          title: Center(
                            child: Semantics(
                              excludeSemantics: true,
                              child: Text(
                                floorNumbers[index]
                                    .toString(), // Text to be displayed
                                style: TextStyle(
                                  color: Colors.black, // Text color
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  PanelController _routeDetailPannelController = new PanelController();
  bool startingNavigation = false;
  Widget routeDeatilPannel() {
    setState(() {
      semanticShouldBeExcluded = true;
    });
    double? angle;
    if (PathState.singleCellListPath.isNotEmpty) {
      int l = PathState.singleCellListPath.length;
      angle = tools.calculateAngle([
        PathState.singleCellListPath[l - 2].x,
        PathState.singleCellListPath[l - 2].y
      ], [
        PathState.singleCellListPath[l - 1].x,
        PathState.singleCellListPath[l - 1].y
      ], [
        PathState.destinationX,
        PathState.destinationY
      ]);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> directionWidgets = [];
    directionWidgets.clear();
    if (PathState.directions.isNotEmpty) {
      if (PathState.directions[0].distanceToNextTurn != null) {
        directionWidgets.add(directionInstruction(
            direction: "Go Straight",
            distance: (PathState.directions[0].distanceToNextTurn! * 0.3048)
                .ceil()
                .toString()));
      }

      for (int i = 1; i < PathState.directions.length; i++) {
        if (!PathState.directions[i].isDestination) {
          if (PathState.directions[i].nearbyLandmark != null) {
            directionWidgets.add(directionInstruction(
                direction: PathState.directions[i].turnDirection == "Straight"
                    ? "Go Straight"
                    : "Turn ${PathState.directions[i].turnDirection!} from ${PathState.directions[i].nearbyLandmark!.name!}, and Go Straight",
                distance: (PathState.directions[i].distanceToNextTurn! * 0.3048)
                    .ceil()
                    .toString()));
          } else {
            if (PathState.directions[i].node == -1) {
              directionWidgets.add(directionInstruction(
                  direction: "${PathState.directions[i].turnDirection!}",
                  distance:
                      "and go to ${PathState.directions[i].distanceToPrevTurn ?? 0.toInt()} floor"));
            } else {
              directionWidgets.add(directionInstruction(
                  direction: PathState.directions[i].turnDirection == "Straight"
                      ? "Go Straight"
                      : "Turn ${PathState.directions[i].turnDirection!}, and Go Straight",
                  distance:
                      (PathState.directions[i].distanceToNextTurn ?? 0 * 0.3048)
                          .ceil()
                          .toString()));
            }
          }
        }
      }
    }

    // for (int i = 0; i < PathState.directions.length; i++) {
    //   if (PathState.directions[i].keys.first == "Straight") {
    //     directionWidgets.add(directionInstruction(
    //         direction: "Go " + PathState.directions[i].keys.first,
    //         distance: tools
    //             .roundToNextInt(PathState.directions[i].values.first * 0.3048)
    //             .toString()));
    //   } else if (PathState.directions[i].keys.first.substring(0, 4) == "Take") {
    //     directionWidgets.add(directionInstruction(
    //         direction: PathState.directions[i].keys.first,
    //         distance: "Floor $sourceVal -> Floor $destinationVal"));
    //   } else {
    //     directionWidgets.add(directionInstruction(
    //         direction: "Turn " +
    //             PathState.directions[i].keys.first +
    //             ", and Go Straight",
    //         distance: tools
    //             .roundToNextInt(PathState.directions[++i].values.first * 0.3048)
    //             .toString()));
    //   }
    // }
    double time = 0;
    double distance = 0;
    DateTime currentTime = DateTime.now();
    if (PathState.path.isNotEmpty) {
      PathState.path.forEach((key, value) {
        time = time + value.length / 120;
        distance = distance + value.length;
      });
      time = time.ceil().toDouble();

      distance = distance * 0.3048;
      distance = double.parse(distance.toStringAsFixed(1));
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));

    return Visibility(
      visible: _isRoutePanelOpen,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, top: 16),
            height: (multiFloorPath) ? 160 : 119,
            width: screenWidth - 32,
            padding: EdgeInsets.only(top: 15, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Semantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: IconButton(
                        onPressed: () {
                          showMarkers();
                          List<double> mvalues = tools.localtoglobal(
                              PathState.destinationX, PathState.destinationY);
                          _googleMapController.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(mvalues[0], mvalues[1]),
                              20, // Specify your custom zoom level here
                            ),
                          );
                          _isRoutePanelOpen = false;
                          _isLandmarkPanelOpen = true;
                          PathState = pathState.withValues(
                              -1, -1, -1, -1, -1, -1, null, 0);
                          PathState.path.clear();
                          PathState.sourcePolyID = "";
                          PathState.destinationPolyID = "";
                          singleroute.clear();
                          _isBuildingPannelOpen = true;
                          clearPathVariables();
                          setState(() {
                            Marker? temp = selectedroomMarker[
                                    buildingAllApi.getStoredString()]
                                ?.first;

                            selectedroomMarker.clear();
                            selectedroomMarker[buildingAllApi.getStoredString()]
                                ?.add(temp!);
                            pathMarkers.clear();
                          });
                        },
                        icon: Semantics(
                          label: "Back",
                          onDidGainAccessibilityFocus: closeRoutePannel,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 24,
                          ),
                        )),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Color(0xffE2E2E2)),
                            ),
                            padding:
                                EdgeInsets.only(left: 8, top: 7, bottom: 8),
                            child: Text(
                              PathState.sourceName,
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff24b9b0),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DestinationSearchPage(
                                          hintText: 'Source location',
                                          voiceInputEnabled: false,
                                        ))).then((value) {
                              onSourceVenueClicked(value);
                            });
                          },
                        ),
                        InkWell(
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Color(0xffE2E2E2)),
                            ),
                            padding:
                                EdgeInsets.only(left: 8, top: 7, bottom: 8),
                            child: Semantics(
                              onDidGainAccessibilityFocus: closeRoutePannel,
                              child: Text(
                                PathState.destinationName,
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff282828),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DestinationSearchPage(
                                          hintText: 'Destination location',
                                          voiceInputEnabled: false,
                                        ))).then((value) {
                              _isBuildingPannelOpen = false;
                              onDestinationVenueClicked(value);
                            });
                          },
                        ),

                        (multiFloorPath)
                            ? Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pathTypeSelected = 0;
                                        });
                                        building.landmarkdata!.then((value) {
                                          calculateroute(value.landmarksMap!);
                                        });
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: (pathTypeSelected == 0)
                                                ? Colors.cyan
                                                : Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(10),
                                        child: Text(
                                          'Lift',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pathTypeSelected = 1;
                                        });
                                        building.landmarkdata!.then((value) {
                                          calculateroute(value.landmarksMap!);
                                        });
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: (pathTypeSelected == 1)
                                                ? Colors.cyan
                                                : Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(10),
                                        child: Text(
                                          'Stair',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        // ChipsChoice<String>.multiple(
                        //   value: optionsTags,
                        //   onChanged: (val) {
                        //     print("calledddd");
                        //     // print(
                        //     //     "Filter change${val}${value.values}");
                        //     // value.put(0, val);
                        //     setState(() {
                        //       optionsTags = val;
                        //       onTagsChanged();
                        //     });
                        //   },
                        //   choiceItems: C2Choice.listFrom<String, String>(
                        //     source: options,
                        //     value: (i, v) => v,
                        //     label: (i, v) => v,
                        //     tooltip: (i, v) => v,
                        //   ),
                        //   choiceCheckmark: true,
                        //   choiceStyle: C2ChipStyle.filled(
                        //       selectedStyle: const C2ChipStyle(
                        //           borderRadius: BorderRadius.all(
                        //             Radius.circular(7),
                        //           ),
                        //           backgroundColor: Color(0XFFABF9F4)),
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(7),
                        //       ),
                        //       borderStyle: BorderStyle.solid),
                        //   wrapped: false,
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            PathState.swap();
                            PathState.path.clear();
                            pathMarkers.clear();
                            PathState.directions.clear();
                            clearPathVariables();
                            building.landmarkdata!.then((value) {
                              calculateroute(value.landmarksMap!);
                            });
                          });
                        },
                        icon: Semantics(
                          label: "Swap location",
                          child: Icon(
                            Icons.swap_vert_circle_outlined,
                            size: 24,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: PathState.sourceX != 0,
            child: SlidingUpPanel(
                controller: _routeDetailPannelController,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20.0,
                    color: Colors.grey,
                  ),
                ],
                minHeight: 163,
                maxHeight: screenHeight * 0.9,
                panel: Semantics(
                  sortKey: const OrdinalSortKey(0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Semantics(
                              excludeSemantics: true,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 6,
                                    margin: EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xffd9d9d9),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              padding: EdgeInsets.only(left: 17, top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Focus(
                                    autofocus: true,
                                    child: Semantics(
                                      label:
                                          "Your destination is ${distance}m away ",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Semantics(
                                            excludeSemantics: true,
                                            child: Text(
                                              "${time.toInt()} min ",
                                              style: const TextStyle(
                                                color: Color(0xffDC6A01),
                                                fontFamily: "Roboto",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                height: 24 / 18,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Semantics(
                                            excludeSemantics: true,
                                            child: Text(
                                              "(${distance} m)",
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                height: 24 / 18,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Spacer(),
                                          IconButton(
                                              onPressed: () {
                                                multiFloorPath = false;
                                                showMarkers();
                                                _isBuildingPannelOpen = true;
                                                _isRoutePanelOpen = false;
                                                selectedroomMarker.clear();
                                                pathMarkers.clear();

                                                building.selectedLandmarkID =
                                                    null;

                                                PathState =
                                                    pathState.withValues(
                                                        -1,
                                                        -1,
                                                        -1,
                                                        -1,
                                                        -1,
                                                        -1,
                                                        null,
                                                        0);
                                                PathState.path.clear();
                                                PathState.sourcePolyID = "";
                                                PathState.destinationPolyID =
                                                    "";
                                                PathState.sourceBid = "";
                                                PathState.destinationBid = "";
                                                singleroute.clear();
                                                PathState.directions = [];
                                                interBuildingPath.clear();
                                                clearPathVariables();
                                                fitPolygonInScreen(patch.first);
                                              },
                                              icon: Semantics(
                                                label: "Close",
                                                child: Icon(
                                                  Icons.cancel_outlined,
                                                  size: 25,
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Text(
                                  //   "via",
                                  //   style: const TextStyle(
                                  //     fontFamily: "Roboto",
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.w400,
                                  //     color: Color(0xff4a4545),
                                  //     height: 25 / 16,
                                  //   ),
                                  //   textAlign: TextAlign.left,
                                  // ),
                                  // Text(
                                  //   "ETA- ${newTime.hour}:${newTime.minute}",
                                  //   style: const TextStyle(
                                  //     fontFamily: "Roboto",
                                  //     fontSize: 14,
                                  //     fontWeight: FontWeight.w400,
                                  //     color: Color(0xff8d8c8c),
                                  //     height: 20 / 14,
                                  //   ),
                                  //   textAlign: TextAlign.left,
                                  // ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Semantics(
                                        sortKey: const OrdinalSortKey(1),
                                        child: Container(
                                          width: 108,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Color(0xff24B9B0),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: TextButton(
                                            onPressed: () async {
                                              user.Bid = PathState.sourceBid;
                                              user.floor =
                                                  PathState.sourceFloor;
                                              user.pathobj = PathState;
                                              user.path =
                                                  PathState.singleListPath;
                                              user.isnavigating = true;
                                              user.Cellpath =
                                                  PathState.singleCellListPath;
                                              user
                                                  .moveToStartofPath()
                                                  .then((value) async {
                                                final Uint8List userloc =
                                                    await getImagesFromMarker(
                                                        'assets/userloc0.png',
                                                        80);
                                                final Uint8List userlocdebug =
                                                    await getImagesFromMarker(
                                                        'assets/tealtorch.png',
                                                        35);

                                                setState(() {
                                                  markers.clear();
                                                  List<double> val =
                                                      tools.localtoglobal(
                                                          user.showcoordX
                                                              .toInt(),
                                                          user.showcoordY
                                                              .toInt());

                                                  markers.putIfAbsent(
                                                      user.Bid, () => []);
                                                  markers[user.Bid]?.add(Marker(
                                                    markerId: MarkerId(
                                                        "UserLocation"),
                                                    position:
                                                        LatLng(val[0], val[1]),
                                                    icon: BitmapDescriptor
                                                        .fromBytes(userloc),
                                                    anchor: Offset(0.5, 0.829),
                                                  ));

                                                  val = tools.localtoglobal(
                                                      user.coordX.toInt(),
                                                      user.coordY.toInt());

                                                  markers[user.Bid]?.add(Marker(
                                                    markerId: MarkerId("debug"),
                                                    position:
                                                        LatLng(val[0], val[1]),
                                                    icon: BitmapDescriptor
                                                        .fromBytes(
                                                            userlocdebug),
                                                    anchor: Offset(0.5, 0.829),
                                                  ));
                                                });
                                              });
                                              _isRoutePanelOpen = false;

                                              building.selectedLandmarkID =
                                                  null;

                                              _isnavigationPannelOpen = true;

                                              semanticShouldBeExcluded = false;

                                              StartPDR();
                                              alignMapToPath([
                                                user.lat,
                                                user.lng
                                              ], [
                                                PathState
                                                    .singleCellListPath[
                                                        user.pathobj.index + 1]
                                                    .lat,
                                                PathState
                                                    .singleCellListPath[
                                                        user.pathobj.index + 1]
                                                    .lng
                                              ]);
                                            },
                                            child: !startingNavigation
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .assistant_navigation,
                                                        color: Colors.black,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Start",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    )),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 98,
                                        height: 40,
                                        margin: EdgeInsets.only(left: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            if (_routeDetailPannelController
                                                .isPanelOpen) {
                                              _routeDetailPannelController
                                                  .close();
                                            } else {
                                              _routeDetailPannelController
                                                  .open();
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _routeDetailPannelController
                                                        .isAttached
                                                    ? _routeDetailPannelController
                                                            .isPanelClosed
                                                        ? Icons
                                                            .short_text_outlined
                                                        : Icons.map_sharp
                                                    : Icons.short_text_outlined,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 8),
                                              Semantics(
                                                sortKey:
                                                    const OrdinalSortKey(2),
                                                onDidGainAccessibilityFocus:
                                                    openRoutePannel,
                                                child: Text(
                                                  _routeDetailPannelController
                                                          .isAttached
                                                      ? _routeDetailPannelController
                                                              .isPanelClosed
                                                          ? "Steps"
                                                          : "Map"
                                                      : "Steps",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 17, top: 12, right: 17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Semantics(
                                      excludeSemantics: true,
                                      child: Text(
                                        "Steps",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff000000),
                                          height: 24 / 18,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22,
                                  ),
                                  Container(
                                    height: screenHeight - 300,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Semantics(
                                            excludeSemantics: false,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 25,
                                                  margin:
                                                      EdgeInsets.only(right: 8),
                                                  child: SvgPicture.asset(
                                                      "assets/StartpointVector.svg"),
                                                ),
                                                Semantics(
                                                  label:
                                                      "Steps preview,    You are heading from",
                                                  child: Text(
                                                    "${PathState.sourceName}",
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff0e0d0d),
                                                      height: 25 / 16,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                            width: screenHeight,
                                            height: 1,
                                            color: Color(0xffEBEBEB),
                                          ),
                                          Column(
                                            children: directionWidgets,
                                          ),
                                          SizedBox(
                                            height: 22,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 25,
                                                margin:
                                                    EdgeInsets.only(right: 8),
                                                child: Icon(
                                                  Icons.pin_drop_sharp,
                                                  size: 24,
                                                ),
                                              ),
                                              Semantics(
                                                label:
                                                    "Your are heading towards ",
                                                child: Text(
                                                  angle != null
                                                      ? "${PathState.destinationName} will be ${tools.angleToClocks3(angle)}"
                                                      : PathState
                                                          .destinationName,
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff0e0d0d),
                                                    height: 25 / 16,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                            width: screenHeight,
                                            height: 1,
                                            color: Color(0xffEBEBEB),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void alignMapToPath(List<double> A, List<double> B) {
    mapState.tilt = 50;

    mapState.bearing = tools.calculateBearing(A, B);
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: mapState.target,
          zoom: mapState.zoom,
          bearing: mapState.bearing!,
          tilt: mapState.tilt),
    ));
  }

  void shouldBeOpenedVarChangeFunc() {
    setState(() {
      semanticShouldBeExcluded = false;
    });
  }

  bool shouldStepOpen = false;
  void shouldStepOpenfunc() {
    setState(() {
      shouldStepOpen = true;
    });
  }

  void noshouldStepOpenfunc() {
    setState(() {
      shouldStepOpen = false;
    });
  }

  bool isLift = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  void _startScrolling() {
    _scrollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 3),
          curve: Curves.easeInOut,
        );
        _resetScrollPosition();
      }
    });
  }

  void _resetScrollPosition() {
    Timer(Duration(seconds: 3), () {
      _scrollController.animateTo(
        0.0,
        duration: Duration(seconds: 3),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget navigationPannel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double time = 0;
    double distance = 0;
    DateTime currentTime = DateTime.now();
    if (PathState.path.isNotEmpty) {
      PathState.path.forEach((key, value) {
        time = time + value.length / 120;
        distance = distance + value.length;
      });
      time = time.ceil().toDouble();
      distance = distance * 0.3048;
      distance = double.parse(distance.toStringAsFixed(1));
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));

    //implement the turn functionality.
    if (user.isnavigating && user.pathobj.numCols![user.Bid] != null) {
      int col = user.pathobj.numCols![user.Bid]![user.floor]!;

      if (MotionModel.reached(user, col) == false) {
        List<int> a = [user.showcoordX, user.showcoordY];
        List<int> tval = tools.eightcelltransition(user.theta);
        //print(tval);
        List<int> b = [user.showcoordX + tval[0], user.showcoordY + tval[1]];

        int index =
            user.path.indexOf((user.showcoordY * col) + user.showcoordX);

        int node = user.path[index + 1];

        List<int> c = [node % col, node ~/ col];
        int val = tools.calculateAngleSecond(a, b, c).toInt();
        //print("val $val");

        // print("user corrds");
        // print("${user.showcoordX}+" "+ ${user.showcoordY}");

        // print("pointss matchedddd ${getPoints.contains(
        //     [user.showcoordX, user.showcoordY])}");
        for (int i = 0; i < getPoints.length; i++) {
          // print("---length  = ${getPoints.length}");
          // print("--- point  = ${getPoints[i]}");
          // print("---- usercoord  = ${user.showcoordX} , ${user.showcoordY}");
          // print("--- val  = $val");
          // print("--- isPDRStop  = $isPdrStop");

          //print("turn corrds");

          //print("${getPoints[i][0]}, ${getPoints[i][1]}");
          if (isPdrStop && val == 0) {
            //print("points unmatchedddd");

            Future.delayed(Duration(milliseconds: 1800))
                .then((value) => {StartPDR()});

            setState(() {
              isPdrStop = false;
            });

            break;
          }
          if (getPoints[i][0] == user.showcoordX &&
              getPoints[i][1] == user.showcoordY) {
            //print("points matchedddddddd");

            StopPDR();
            getPoints.removeAt(i);
            break;
          }
        }
      }
    }

    return Visibility(
        visible: _isnavigationPannelOpen,
        child: Stack(
          children: [
            SlidingUpPanel(
              controller: _panelController,
              isDraggable: false,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20.0,
                  color: Colors.grey,
                ),
              ],
              minHeight: 92,
              maxHeight: screenHeight * 0.9,
              snapPoint: 0.9,
              panel: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 92,
                      padding: EdgeInsets.fromLTRB(11, 22, 14.08, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Focus(
                              autofocus: true,
                              child: Semantics(
                                onDidGainAccessibilityFocus:
                                    noshouldStepOpenfunc,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Semantics(
                                          excludeSemantics: false,
                                          child: Row(
                                            children: [
                                              Semantics(
                                                label: "Travel time",
                                                child: Text(
                                                  "${time.toInt()} min",
                                                  style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 26 / 20,
                                                      color: Color(0xffDC6A01)),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              Text(
                                                " (${distance} m)",
                                                style: const TextStyle(
                                                  fontFamily: "Roboto",
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  height: 26 / 20,
                                                ),
                                                textAlign: TextAlign.left,
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Semantics(
                                          excludeSemantics: true,
                                          child: Text(
                                            "ETA- ${newTime.hour}:${newTime.minute}",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff8d8c8c),
                                              height: 20 / 14,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Color(0xffDF3535),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  _isnavigationPannelOpen = false;
                                  user.reset();
                                  PathState = pathState.withValues(
                                      -1, -1, -1, -1, -1, -1, null, 0);
                                  selectedroomMarker.clear();
                                  pathMarkers.clear();
                                  PathState.path.clear();
                                  PathState.sourcePolyID = "";
                                  PathState.destinationPolyID = "";
                                  singleroute.clear();
                                  fitPolygonInScreen(patch.first);
                                  setState(() {
                                    if (markers.length > 0) {
                                      List<double> lvalue = tools.localtoglobal(
                                          user.showcoordX.toInt(),
                                          user.showcoordY.toInt());
                                      markers[user.Bid]?[0] = customMarker.move(
                                          LatLng(lvalue[0], lvalue[1]),
                                          markers[user.Bid]![0]);
                                    }
                                  });
                                },
                                child: Text(
                                  "Exit",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffFFFFFF),
                                    height: 20 / 14,
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      height: 1,
                      color: Color(0xffEBEBEB),
                    ),
                  ],
                ),
              ),
            ),
            DirectionHeader(
              user: user,
              paint: paintUser,
              repaint: repaintUser,
              reroute: reroute,
              moveUser: moveUser,
              closeNavigation: closeNavigation,
              isRelocalize: false,
              focusOnTurn: focusOnTurn,
              clearFocusTurnArrow: clearFocusTurnArrow,
            )
          ],
        ));
  }

  bool rerouting = false;
  Widget reroutePannel() {
    return Visibility(
        visible: _isreroutePannelOpen,
        child: SlidingUpPanel(
          minHeight: 119,
          backdropEnabled: true,
          isDraggable: false,
          panel: Container(
            padding: EdgeInsets.only(left: 13, top: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/Reroutevector.svg"),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Off-Path Notification",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff000000),
                        height: 26 / 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      "Lost the path? New route?",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8d8c8c),
                        height: 20 / 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        FocusScope(
                          autofocus: true,
                          child: Semantics(
                            label: "Reroute",
                            child: Container(
                              width: 85,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(0xff24B9B0),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  if (!rerouting) {
                                    setState(() {
                                      rerouting = true;
                                    });
                                    clearPathVariables();
                                    PathState.clear();
                                    PathState.sourceX = user.coordX;
                                    PathState.sourceY = user.coordY;
                                    user.showcoordX = user.coordX;
                                    user.showcoordY = user.coordY;
                                    PathState.sourceFloor = user.floor;
                                    PathState.sourcePolyID = user.key;
                                    PathState.sourceName =
                                        "Your current location";
                                    building.landmarkdata!.then((value) async {
                                      await calculateroute(value.landmarksMap!)
                                          .then((value) {
                                        user.pathobj = PathState;
                                        user.path = PathState.path.values
                                            .expand((list) => list)
                                            .toList();
                                        user.Cellpath =
                                            PathState.singleCellListPath;
                                        user.pathobj.index = 0;
                                        user.isnavigating = true;
                                        user.moveToStartofPath().then((value) {
                                          setState(() {
                                            if (markers.length > 0) {
                                              markers[user.Bid]?[
                                                      0] =
                                                  customMarker.move(
                                                      LatLng(
                                                          tools.localtoglobal(
                                                              user.showcoordX
                                                                  .toInt(),
                                                              user.showcoordY
                                                                  .toInt())[0],
                                                          tools.localtoglobal(
                                                              user.showcoordX
                                                                  .toInt(),
                                                              user.showcoordY
                                                                  .toInt())[1]),
                                                      markers[user.Bid]![0]);
                                            }
                                          });
                                        });
                                        _isRoutePanelOpen = false;
                                        building.selectedLandmarkID = null;
                                        _isnavigationPannelOpen = true;
                                        _isreroutePannelOpen = false;
                                        int numCols = building.floorDimenssion[
                                            PathState
                                                .sourceBid]![PathState
                                            .sourceFloor]![0]; //floor length
                                        double angle =
                                            tools.calculateAngleBWUserandPath(
                                                user,
                                                PathState.path[
                                                    PathState.sourceFloor]![1],
                                                numCols);
                                        if (angle != 0) {
                                          speak("Turn " +
                                              tools.angleToClocks(angle));
                                        } else {}

                                        mapState.tilt = 50;

                                        mapState.bearing =
                                            tools.calculateBearing([
                                          user.lat,
                                          user.lng
                                        ], [
                                          PathState
                                              .singleCellListPath[
                                                  user.pathobj.index + 1]
                                              .lat,
                                          PathState
                                              .singleCellListPath[
                                                  user.pathobj.index + 1]
                                              .lng
                                        ]);
                                        _googleMapController.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: mapState.target,
                                              zoom: mapState.zoom,
                                              bearing: mapState.bearing!,
                                              tilt: mapState.tilt),
                                        ));
                                      });
                                    });
                                    rerouting = false;
                                  }
                                },
                                child: !rerouting
                                    ? Text(
                                        "Reroute",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff000000),
                                          height: 20 / 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    : Container(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        // Container(
                        //   width: 92,
                        //   height: 36,
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(4.0),
                        //       border: Border.all(color: Colors.black)),
                        //   // child: TextButton(
                        //   //   onPressed: () {
                        //   //
                        //   //   },
                        //   //
                        //   //
                        //   //   child: Text(
                        //   //     "Continue",
                        //   //     style: const TextStyle(
                        //   //       fontFamily: "Roboto",
                        //   //       fontSize: 14,
                        //   //       fontWeight: FontWeight.w400,
                        //   //       color: Color(0xff000000),
                        //   //       height: 20 / 14,
                        //   //     ),
                        //   //     textAlign: TextAlign.left,
                        //   //   ),
                        //   // ),
                        // )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  List<String> optionsTags = [];
  List<String> floorOptionsTags = [];

  List<String> options = [
    'Washroom',
    'Food & Drinks',
    'Reception',
    'Break Room',
    'Education',
    'Fashion',
    'Travel',
    'Rooms',
    'Tech',
    'Science',
  ];
  List<String> floorOptions = [
    'All',
    'Floor 0',
    'Floor 1',
    'Floor 2',
    'Floor 3'
  ];

  List<ImageProvider<Object>> imageList = [];
  late land landmarkData = new land();
  List<Landmarks> LandmarkItems = [];
  List<Landmarks> filteredItems = [];

  void fetchlist() async {
    // await landmarkApi().fetchLandmarkData().then((value){
    //   landmarkData = value;
    //   LandmarkItems = value.landmarks!;
    // });
    //LandmarkItems = landmarkData.landmarks!;
    print("Landmarks");
    print(LandmarkItems);
  }

  void filterItems() {
    if (optionsTags == null && floorOptionsTags != null) {
      setState(() {
        filteredItems = LandmarkItems.where(
                (item) => floorOptionsTags.contains('Floor ${item.floor}'))
            .toList();
      });
    } else if (optionsTags != null && floorOptionsTags == null) {
      setState(() {
        filteredItems = LandmarkItems.where((item) =>
            optionsTags.contains(item.element?.type) &&
            floorOptionsTags.contains('Floor ${item.floor}')).toList();
      });
    } else {
      setState(() {
        filteredItems = LandmarkItems.where(
            (item) => optionsTags.contains(item.element?.type)).toList();
      });
    }
  }

// Call filterItems() whenever tags change
  void onTagsChanged() {
    setState(() {
      filterItems();
    });
  }

  final PanelController _panelController = PanelController();

  void _slidePanelUp() {
    _panelController.open();
  }

  void _slidePanelUpNavigation() {
    _panelController.animatePanelToSnapPoint();
  }

  void _slidePanelDown() {
    _panelController.close();
  }

  void _slidePanelDownNavigation() {
    _panelController.animatePanelToPosition(90.0);
  }

  bool _isFilterOpen = false;
  bool isLiveLocalizing = false;

  Future<int> getHiveBoxLength() async {
    final box = await Hive.openBox(
        'Filters'); // Replace 'yourBoxName' with the name of your box
    return box.length;
  }

  Widget buildingDetailPannel() {
    buildingAll element = new buildingAll.buildngAllAPIModel();
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();
    if (BuildingAllBox.length > 0) {
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAll> buildingList =
          responseBody.map((data) => buildingAll.fromJson(data)).toList();
      buildingList.forEach((Element) {
        if (Element.sId == buildingAllApi.getStoredString()) {
          setState(() {
            element = Element;
          });
        }
      });
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //fetchlist();
    //filterItems();
    return Visibility(
        visible: _isBuildingPannelOpen,
        child: SlidingUpPanel(
            controller: _panelController,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ],
            minHeight:
                element.workingDays != null && element.workingDays!.length > 0
                    ? 155
                    : 140,
            snapPoint:
                element.workingDays != null && element.workingDays!.length > 0
                    ? 190 / screenHeight
                    : 175 / screenHeight,
            maxHeight: screenHeight * 0.9,
            panel: Semantics(
              child: Container(
                  child: !_isFilterOpen
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 6,
                                    margin: EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xffd9d9d9),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 16),
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, bottom: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${element.buildingName}",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            height: 27 / 18,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        element.workingDays != null &&
                                                element.workingDays!.length > 0
                                            ? Row(
                                                children: [
                                                  Text(
                                                    "Open ",
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff4caf50),
                                                      height: 25 / 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    "  Closes ${element.workingDays![0].closingTime}",
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff8d8c8c),
                                                      height: 25 / 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, top: 8, bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 142,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: Color(0xff24B9B0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: TextButton(
                                            onPressed: () {},
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/ExploreInside.svg"),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Explore Inside",
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xffffffff),
                                                    height: 20 / 14,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Container(
                                          width: 83,
                                          height: 42,
                                          decoration: BoxDecoration(
                                              color: Color(0xffffffff),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                  color: Color(0xff000000))),
                                          child: TextButton(
                                            onPressed: () {},
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.call,
                                                  color: Color(0xff000000),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Call",
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xff000000),
                                                    height: 20 / 14,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Semantics(
                                          label: "Share",
                                          onDidGainAccessibilityFocus:
                                              _slidePanelUp,
                                          // onDidLoseAccessibilityFocus: _slidePanelDown,
                                          child: Container(
                                            width: 95,
                                            height: 42,
                                            decoration: BoxDecoration(
                                                color: Color(0xffffffff),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                    color: Color(0xff000000))),
                                            child: TextButton(
                                              onPressed: () {},
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.share,
                                                    color: Color(0xff000000),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Share",
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xff000000),
                                                      height: 20 / 14,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Semantics(
                                    label: "",
                                    child: Container(
                                        child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 16, right: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Semantics(
                                                header: true,
                                                child: GestureDetector(
                                                  onTap: _slidePanelUp,
                                                  child: Text(
                                                    "Services",
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xff000000),
                                                      height: 23 / 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Semantics(
                                                label: 'Services',
                                                child: TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        print(
                                                            "Himanshuchecker");
                                                        //_isBuildingPannelOpen = !_isBuildingPannelOpen;
                                                        _isFilterOpen =
                                                            !_isFilterOpen;
                                                      });
                                                    },
                                                    child: Text(
                                                      "See All",
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xff4a4545),
                                                        height: 20 / 14,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 16),
                                          child: Row(
                                            children: [
                                              Semantics(
                                                label: "",
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 61,
                                                        height: 56,
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xffB3B3B3))),
                                                        child: SvgPicture.asset(
                                                            "assets/washroomservice.svg"),
                                                      ),
                                                      Text(
                                                        "Washroom",
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xff4a4545),
                                                          height: 20 / 14,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              Semantics(
                                                label: "",
                                                header: true,
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 61,
                                                        height: 56,
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xffB3B3B3))),
                                                        child: SvgPicture.asset(
                                                            "assets/foodservice.svg"),
                                                      ),
                                                      Text(
                                                        "Food",
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xff4a4545),
                                                          height: 20 / 14,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              Semantics(
                                                label: "",
                                                header: true,
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 61,
                                                        height: 56,
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xffB3B3B3))),
                                                        child: SvgPicture.asset(
                                                            "assets/accservice.svg"),
                                                      ),
                                                      Text(
                                                        "Accessibility",
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xff4a4545),
                                                          height: 20 / 14,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              Semantics(
                                                label: "",
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 61,
                                                        height: 56,
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xffB3B3B3))),
                                                        child: SvgPicture.asset(
                                                            "assets/exitservice.svg"),
                                                      ),
                                                      Text(
                                                        "Exit",
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xff4a4545),
                                                          height: 20 / 14,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Semantics(
                                          onDidLoseAccessibilityFocus:
                                              _slidePanelDown,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: _slidePanelDown,
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 17),
                                                      child: Text(
                                                        "Information",
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Color(0xff000000),
                                                          height: 23 / 16,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      )),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 16, right: 16),
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 11, 0, 10),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            width: 1.0,
                                                            color: Color(
                                                                0xffebebeb))),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SvgPicture.asset(
                                                          "assets/Depth 3, Frame 0.svg"),
                                                      SizedBox(
                                                        width: 16,
                                                      ),
                                                      Container(
                                                        width:
                                                            screenWidth - 100,
                                                        margin: EdgeInsets.only(
                                                            top: 8),
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  "Roboto",
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color(
                                                                  0xff4a4545),
                                                              height: 25 / 16,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    "${element.address}",
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Container(
                                                //   margin:
                                                //   EdgeInsets.only(left: 16, right: 16),
                                                //   padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                                                //   decoration: BoxDecoration(
                                                //     border: Border(
                                                //         bottom: BorderSide(
                                                //             width: 1.0,
                                                //             color: Color(0xffebebeb))),
                                                //   ),
                                                //   child: Row(
                                                //     crossAxisAlignment:
                                                //     CrossAxisAlignment.center,
                                                //     children: [
                                                //       SvgPicture.asset("assets/Depth 3, Frame 1.svg"),
                                                //       SizedBox(width: 16,),
                                                //       Container(
                                                //         margin: EdgeInsets.only(top: 8),
                                                //         child: RichText(
                                                //           text: TextSpan(
                                                //             style: const TextStyle(
                                                //               fontFamily: "Roboto",
                                                //               fontSize: 16,
                                                //               fontWeight: FontWeight.w400,
                                                //               color: Color(0xff4a4545),
                                                //               height: 25 / 16,
                                                //             ),
                                                //             children: [
                                                //               TextSpan(
                                                //                 text:
                                                //                 "6 Floors",
                                                //               ),
                                                //             ],
                                                //           ),
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                                element.phone != null
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 16,
                                                            right: 16),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 11, 0, 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  width: 1.0,
                                                                  color: Color(
                                                                      0xffebebeb))),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                                "assets/Depth 3, Frame 1-1.svg"),
                                                            SizedBox(
                                                              width: 16,
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(top: 8),
                                                              child: RichText(
                                                                text: TextSpan(
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        "Roboto",
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xff4a4545),
                                                                    height:
                                                                        25 / 16,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "${element.phone}",
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                element.website != null
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 16,
                                                            right: 16),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 11, 0, 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  width: 1.0,
                                                                  color: Color(
                                                                      0xffebebeb))),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                                "assets/Depth 3, Frame 1-2.svg"),
                                                            SizedBox(
                                                              width: 16,
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(top: 8),
                                                              child: RichText(
                                                                text: TextSpan(
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        "Roboto",
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xff4a4545),
                                                                    height:
                                                                        25 / 16,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "${element.website}",
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                element.workingDays != null &&
                                                        element.workingDays!
                                                                .length >
                                                            1
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 16,
                                                            right: 16),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 11, 0, 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  width: 1.0,
                                                                  color: Color(
                                                                      0xffebebeb))),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                                "assets/Depth 3, Frame 1-3.svg"),
                                                            SizedBox(
                                                              width: 16,
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              8),
                                                                  child:
                                                                      RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            "Roboto",
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Color(
                                                                            0xff4a4545),
                                                                        height:
                                                                            25 /
                                                                                16,
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "${element.workingDays![0].day} to ${element.workingDays![element.workingDays!.length - 1].day}",
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              8),
                                                                  child:
                                                                      RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            "Roboto",
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: Color(
                                                                            0xff4a4545),
                                                                        height:
                                                                            25 /
                                                                                16,
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "${element.workingDays![0].openingTime} - ${element.workingDays![element.workingDays!.length - 1].closingTime}",
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 6,
                                    margin: EdgeInsets.only(top: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xffd9d9d9),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 17, top: 8),
                                    child: IconButton(
                                      onPressed: () {
                                        _isFilterOpen = !_isFilterOpen;
                                      },
                                      icon: SvgPicture.asset(
                                        "assets/Navigation_closeIcon.svg",
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 17, top: 8),
                                    child: Text(
                                      "Filters",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff000000),
                                        height: 26 / 20,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    margin: EdgeInsets.only(right: 14, top: 10),
                                    child: TextButton(
                                      onPressed: () {
                                        optionsTags.clear();
                                        floorOptionsTags.clear();
                                      },
                                      child: Text(
                                        "Clear All",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff24b9b0),
                                          height: 20 / 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              Container(
                                margin: EdgeInsets.only(top: 8, left: 16),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Services",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff000000),
                                    height: 23 / 16,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              //-----------------------------CHECK FILTER SELECTED DATABASE---------------------------
                              // FutureBuilder<int>(
                              //   future: getHiveBoxLength(),
                              //   builder: (context, snapshot) {
                              //     if (snapshot.connectionState != ConnectionState.waiting) {
                              //       return Text('Error: ${snapshot.error}'); // or any loading indicator
                              //     } else if (snapshot.hasError) {
                              //       return Text('Error: ${snapshot.error}');
                              //     } else {
                              //       return Text('Length of Hive Box: ${snapshot.data}');
                              //     }
                              //   },
                              // ),
                              //---------------------------------------------------------------------------------------

                              Container(
                                child: ValueListenableBuilder(
                                  valueListenable:
                                      Hive.box('Filters').listenable(),
                                  builder: (BuildContext context, value,
                                      Widget? child) {
                                    //List<dynamic> aa = []
                                    if (value.length != 0) {
                                      optionsTags = value.getAt(0);
                                      print("tags");
                                      print(optionsTags);
                                    }
                                    return ChipsChoice<String>.multiple(
                                      value: optionsTags,
                                      onChanged: (val) {
                                        print(
                                            "Filter change${val}${value.values}");
                                        value.put(0, val);
                                        setState(() {
                                          optionsTags = val;
                                          onTagsChanged();
                                        });
                                      },
                                      choiceItems:
                                          C2Choice.listFrom<String, String>(
                                        source: options,
                                        value: (i, v) => v,
                                        label: (i, v) => v,
                                        tooltip: (i, v) => v,
                                      ),
                                      choiceCheckmark: true,
                                      choiceStyle: C2ChipStyle.filled(
                                          selectedStyle: const C2ChipStyle(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(7),
                                              ),
                                              backgroundColor:
                                                  Color(0XFFABF9F4)),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(7),
                                          ),
                                          borderStyle: BorderStyle.solid),
                                      wrapped: false,
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8, left: 16),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Choose Floor",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff000000),
                                    height: 23 / 16,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                child: ValueListenableBuilder(
                                  valueListenable:
                                      Hive.box('Filters').listenable(),
                                  builder: (BuildContext context, value,
                                      Widget? child) {
                                    //List<dynamic> aa = []
                                    if (value.length == 2) {
                                      floorOptionsTags = value.getAt(1);
                                    }
                                    return ChipsChoice<String>.multiple(
                                      value: floorOptionsTags,
                                      onChanged: (val) {
                                        print(
                                            "Filter change${val}${value.values}");
                                        value.put(1, val);
                                        setState(() {
                                          floorOptionsTags = val;
                                          onTagsChanged();
                                        });
                                      },
                                      choiceItems:
                                          C2Choice.listFrom<String, String>(
                                        source: floorOptions,
                                        value: (i, v) => v,
                                        label: (i, v) => v,
                                        tooltip: (i, v) => v,
                                      ),
                                      choiceLeadingBuilder: (data, i) {
                                        if (data.meta == null) return null;
                                        return CircleAvatar(
                                          maxRadius: 12,
                                          backgroundImage: data.avatarImage,
                                        );
                                      },
                                      choiceCheckmark: true,
                                      choiceStyle: C2ChipStyle.filled(
                                        selectedStyle: const C2ChipStyle(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(7),
                                            ),
                                            backgroundColor: Color(0XFFABF9F4)),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(7),
                                        ),
                                      ),
                                      wrapped: false,
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8, left: 16),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Filter results ${filteredItems.length}",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff000000),
                                    height: 23 / 16,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 12),
                                height: screenHeight - 410,
                                child: ListView.builder(
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    return NavigatonFilterCard(
                                      LandmarkName: item.venueName!,
                                      LandmarkDistance: "90 m",
                                      LandmarkFloor: "Floor ${item.floor}",
                                      LandmarksubName: item.buildingName!,
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        )),
            )));
  }

  String nearestLandmarkNameForPannel = "";
  String nearestAddressForPannel = "";

  bool _isExploreModePannelOpen = false;
  PanelController ExploreModePannelController = new PanelController();

  Widget ExploreModePannel() {
    List<Widget> Exwidgets = [];
    for (int i = 0; i < getallnearestInfo.length; i++) {
      Exwidgets.add(
          ExploreModeWidget(getallnearestInfo[i], finalDirections[i]));
    }

    return Visibility(
        visible: _isExploreModePannelOpen,
        child: SlidingUpPanel(
          maxHeight: 90 + 8 + (getallnearestInfo.length * 100),
          minHeight: 90 + 8,
          controller: ExploreModePannelController,
          panel: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(0xff79747E),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Explore Mode",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff000000),
                        height: 20 / 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    IconButton(
                        onPressed: () {
                          isLiveLocalizing = false;
                          HelperClass.showToast("Explore mode is disabled");
                          _exploreModeTimer!.cancel();
                          _isExploreModePannelOpen = false;
                          _isBuildingPannelOpen = true;
                          lastBeaconValue = "";
                        },
                        icon: Icon(Icons.close))
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  children: Exwidgets,
                )
              ],
            ),
          ),
        ));
  }

  Widget nearestLandmarkpannel() {
    buildingAll element = new buildingAll.buildngAllAPIModel();
    final BuildingAllBox = BuildingAllAPIModelBOX.getData();
    if (BuildingAllBox.length > 0) {
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      List<buildingAll> buildingList =
          responseBody.map((data) => buildingAll.fromJson(data)).toList();
      buildingList.forEach((Element) {
        if (Element.sId == buildingAllApi.getStoredString()) {
          setState(() {
            allBuildingList.add(Element.sId!);
            element = Element;
          });
        }
      });
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //fetchlist();
    //filterItems();

    return Visibility(
        visible: _isBuildingPannelOpen,
        child: Semantics(
          excludeSemantics: true,
          child: SlidingUpPanel(
            controller: _panelController,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ],
            minHeight: 90,
            snapPoint:
                element.workingDays != null && element.workingDays!.length > 0
                    ? 220 / screenHeight
                    : 175 / screenHeight,
            panel: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 6,
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Color(0xffd9d9d9),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.only(left: 17, top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${nearestLandInfomation.name}, Floor ${nearestLandInfomation.floor}",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff292929),
                                height: 25 / 18,
                              ),
                              textAlign: TextAlign.left,
                            )
                          ],
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          _isBuildingPannelOpen = false;
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 20),
                          alignment: Alignment.topCenter,
                          child: SvgPicture.asset("assets/closeicon.svg"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Set<Marker> getCombinedMarkers() {
    if (user.floor == building.floor[buildingAllApi.getStoredString()]) {
      if (_isLandmarkPanelOpen) {
        Set<Marker> marker = Set();

        selectedroomMarker.forEach((key, value) {
          marker = marker.union(value);
        });

        // print(Set<Marker>.of(markers[user.Bid]!));
        return (marker.union(Set<Marker>.of(markers[user.Bid] ?? [])));
      } else {
        return pathMarkers[building.floor[buildingAllApi.getStoredString()]] !=
                null
            ? (pathMarkers[building.floor[buildingAllApi.getStoredString()]]!
                    .union(Set<Marker>.of(markers[user.Bid] ?? [])))
                .union(Markers)
            : (Set<Marker>.of(markers[user.Bid] ?? [])).union(Markers);
      }
    } else {
      if (_isLandmarkPanelOpen) {
        Set<Marker> marker = Set();
        selectedroomMarker.forEach((key, value) {
          marker = marker.union(value);
        });
        return marker.union(Markers);
      } else {
        return pathMarkers[building.floor[buildingAllApi.getStoredString()]] !=
                null
            ? (pathMarkers[building.floor[buildingAllApi.getStoredString()]]!)
                .union(Markers)
            : Markers;
      }
    }
  }

  Set<Polygon> getCombinedPolygons() {
    Set<Polygon> polygons = Set();
    closedpolygons.forEach((key, value) {
      polygons = polygons.union(value);
    });
    return polygons;
  }

  Set<gmap.Polyline> getCombinedPolylines() {
    Set<gmap.Polyline> poly = Set();
    polylines.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });
    interBuildingPath.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });
    return poly;
  }

  void _updateMarkers(double zoom) {
    print(zoom);
    if (building.updateMarkers) {
      Set<Marker> updatedMarkers = Set();
      setState(() {
        Markers.forEach((marker) {
          List<String> words = marker.markerId.value.split(' ');
          if (marker.markerId.value.contains("Room")) {
            Marker _marker = customMarker.visibility(zoom > 20.5, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Rest")) {
            Marker _marker = customMarker.visibility(zoom > 19, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Entry")) {
            Marker _marker = customMarker.visibility(
                (zoom > 18.5 && zoom < 19) || zoom > 20.3, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Building")) {
            Marker _marker = customMarker.visibility(zoom < 16.0, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Lift")) {
            Marker _marker = customMarker.visibility(zoom > 19, marker);
            updatedMarkers.add(_marker);
          }
          if (building.ignoredMarker.contains(words[1])) {
            if (marker.markerId.value.contains("Door")) {
              Marker _marker = customMarker.visibility(true, marker);
              print(_marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Room")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
          }
        });
        Markers = updatedMarkers;
      });
    }
  }

  void hideMarkers() {
    building.updateMarkers = false;
    Set<Marker> updatedMarkers = Set();
    Markers.forEach((marker) {
      Marker _marker = customMarker.visibility(false, marker);
      updatedMarkers.add(_marker);
    });
    Markers = updatedMarkers;
  }

  void showMarkers() {
    building.ignoredMarker.clear();
    building.updateMarkers = true;
  }

  void _updateBuilding(double zoom) {
    Set<Polygon> updatedclosedPolygon = Set();
    Set<Polygon> updatedpatchPolygon = Set();
    Set<gmap.Polyline> updatedpolyline = Set();
    setState(() {
      closedpolygons[buildingAllApi.getStoredString()]?.forEach((polygon) {
        Polygon _polygon = polygon.copyWith(visibleParam: zoom > 16.0);
        updatedclosedPolygon.add(_polygon);
      });
      patch.forEach((polygon) {
        Polygon _polygon = polygon.copyWith(visibleParam: zoom > 16.0);
        updatedpatchPolygon.add(_polygon);
      });
      polylines[buildingAllApi.getStoredString()]!.forEach((polyline) {
        gmap.Polyline _polyline = polyline.copyWith(visibleParam: zoom > 16.0);
        updatedpolyline.add(_polyline);
      });
      closedpolygons[buildingAllApi.getStoredString()] = updatedclosedPolygon;
      patch = updatedpatchPolygon;
      polylines[buildingAllApi.getStoredString()] = updatedpolyline;
    });
  }

  void clearFocusTurnArrow() {
    setState(() {
      focusturnArrow.clear();
    });
  }

  void closeNavigation() {
    StopPDR();
    _isnavigationPannelOpen = false;
    user.reset();
    PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
    selectedroomMarker.clear();
    pathMarkers.clear();
    PathState.path.clear();
    PathState.sourcePolyID = "";
    PathState.destinationPolyID = "";
    singleroute.clear();
    fitPolygonInScreen(patch.first);
    setState(() {
      focusturnArrow.clear();
    });

    // setState(() {
    if (markers.length > 0) {
      List<double> lvalue =
          tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt());
      markers[user.Bid]?[0] = customMarker.move(
          LatLng(lvalue[0], lvalue[1]), markers[user.Bid]![0]);
    }
    // });
  }

  void onLandmarkVenueClicked(String ID,
      {bool DirectlyStartNavigation = false}) {
    setState(() {
      if (building.selectedLandmarkID != ID) {
        building.landmarkdata!.then((value) {
          _isBuildingPannelOpen = false;
          building.floor[value.landmarksMap![ID]!.buildingID!] =
              value.landmarksMap![ID]!.floor!;
          createRooms(
              building.polylinedatamap[value.landmarksMap![ID]!.buildingID]!,
              building.floor[value.landmarksMap![ID]!.buildingID!]!);
          createMarkers(
              value, building.floor[value.landmarksMap![ID]!.buildingID!]!);
          building.selectedLandmarkID = ID;
          singleroute.clear();
          _isRoutePanelOpen = DirectlyStartNavigation;
          _isLandmarkPanelOpen = !DirectlyStartNavigation;
          List<double> pvalues = tools.localtoglobal(
              value.landmarksMap![ID]!.coordinateX!,
              value.landmarksMap![ID]!.coordinateY!,
              patchData:
                  building.patchData[value.landmarksMap![ID]!.buildingID]);
          LatLng point = LatLng(pvalues[0], pvalues[1]);
          _googleMapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              point,
              22,
            ),
          );
          addselectedMarker(point);
        });
      }
    });

    if (DirectlyStartNavigation) {}
  }

  void fromSourceAndDestinationPage(List<String> value) {
    _isBuildingPannelOpen = false;
    markers.clear();
    building.landmarkdata!.then((land) {
      print("Himanshuchecker ${land.landmarksMap}");
      print("Himanshuchecker ${value[0]}");
      PathState.sourceX = land.landmarksMap![value[0]]!.coordinateX!;
      PathState.sourceY = land.landmarksMap![value[0]]!.coordinateY!;
      if (land.landmarksMap![value[0]]!.doorX != null) {
        PathState.sourceX = land.landmarksMap![value[0]]!.doorX!;
        PathState.sourceY = land.landmarksMap![value[0]]!.doorY!;
      }
      PathState.sourceBid = land.landmarksMap![value[0]]!.buildingID!;
      PathState.sourceFloor = land.landmarksMap![value[0]]!.floor!;
      PathState.sourcePolyID = value[0];
      PathState.sourceName = land.landmarksMap![value[0]]!.name!;

      PathState.destinationName = land.landmarksMap![value[1]]!.name!;
      PathState.destinationX = land.landmarksMap![value[1]]!.coordinateX!;
      PathState.destinationY = land.landmarksMap![value[1]]!.coordinateY!;
      if (land.landmarksMap![value[1]]!.doorX != null) {
        PathState.destinationX = land.landmarksMap![value[1]]!.doorX!;
        PathState.destinationY = land.landmarksMap![value[1]]!.doorY!;
      }
      PathState.destinationBid = land.landmarksMap![value[1]]!.buildingID!;
      PathState.destinationFloor = land.landmarksMap![value[1]]!.floor!;
      PathState.destinationPolyID = value[1];

      calculateroute(land.landmarksMap!).then((value) {
        _isRoutePanelOpen = true;
      });
    });
  }

  void onSourceVenueClicked(String ID) {
    setState(() {
      building.landmarkdata!.then((value) {
        _isLandmarkPanelOpen = false;
        PathState.sourceX = value.landmarksMap![ID]!.coordinateX!;
        PathState.sourceY = value.landmarksMap![ID]!.coordinateY!;
        if (value.landmarksMap![ID]!.doorX != null) {
          PathState.sourceX = value.landmarksMap![ID]!.doorX!;
          PathState.sourceY = value.landmarksMap![ID]!.doorY!;
        }
        PathState.sourceFloor = value.landmarksMap![ID]!.floor!;
        PathState.sourcePolyID = ID;
        PathState.sourceName = value.landmarksMap![ID]!.name!;
        PathState.sourceBid = value.landmarksMap![ID]!.buildingID!;
        PathState.path.clear();
        PathState.directions.clear();
        PathState.sourceBid = user.Bid;
        PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
        calculateroute(value.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
      });
    });
  }

  void onDestinationVenueClicked(String ID) {
    setState(() {
      building.landmarkdata!.then((value) {
        _isLandmarkPanelOpen = false;
        PathState.destinationX = value.landmarksMap![ID]!.coordinateX!;
        PathState.destinationY = value.landmarksMap![ID]!.coordinateY!;
        if (value.landmarksMap![ID]!.doorX != null) {
          PathState.destinationX = value.landmarksMap![ID]!.doorX!;
          PathState.destinationY = value.landmarksMap![ID]!.doorY!;
        }
        PathState.destinationFloor = value.landmarksMap![ID]!.floor!;
        PathState.destinationPolyID = ID;
        PathState.destinationName = value.landmarksMap![ID]!.name!;
        PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
        PathState.path.clear();
        PathState.directions.clear();
        PathState.sourceBid = user.Bid;
        PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
        calculateroute(value.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
      });
    });
  }

  focusOnTurn(direction turn) async {
    focusturnArrow.clear();
    if (turn.x != null && turn.y != null && turn.numCols != null) {
      int i = user.path.indexWhere((element) => element == turn.node);
      if (building.floor[buildingAllApi.getStoredString()] != turn.floor) {
        i++;
      } else {
        i--;
      }

      //List<LatLng> coordinates = [];
      BitmapDescriptor greytorch = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(44, 44)),
        'assets/greytorch.png',
      );
      // for(int a = i;a>i-5;a--){
      //   if(a!=i && tools.isTurn([user.path[a-1]%turn.numCols!,user.path[a-1]~/turn.numCols!], [user.path[a]%turn.numCols!,user.path[a]~/turn.numCols!], [user.path[a+1]%turn.numCols!,user.path[a+1]~/turn.numCols!])){
      //     break;
      //   }
      //   List<double> ltln = tools.localtoglobal(user.path[a]%turn.numCols!, user.path[a]~/turn.numCols!);
      //   coordinates.insert(0,LatLng(ltln[0], ltln[1]));
      // }
      //
      // for(int a = i+1;a<i+6;a++){
      //   // if(a!=i && tools.isTurn([user.path[a-1]%turn.numCols!,user.path[a-1]~/turn.numCols!], [user.path[a]%turn.numCols!,user.path[a]~/turn.numCols!], [user.path[a+1]%turn.numCols!,user.path[a+1]~/turn.numCols!])){
      //   //   break;
      //   // }
      //   List<double> ltln = tools.localtoglobal(user.path[a]%turn.numCols!, user.path[a]~/turn.numCols!);
      //   coordinates.add(LatLng(ltln[0], ltln[1]));
      // }

      if (turn.floor != null &&
          building.floor[buildingAllApi.getStoredString()] != turn.floor) {
        building.floor[buildingAllApi.getStoredString()] = turn.floor!;
        createRooms(building.polyLineData!,
            building.floor[buildingAllApi.getStoredString()]!);
      }

      List<int> nextPoint = [
        user.path[i] % turn.numCols!,
        user.path[i] ~/ turn.numCols!
      ];
      List<double> latlng = tools.localtoglobal(turn.x!, turn.y!,
          patchData: building.patchData[turn.Bid]);
      List<double> latlng2 = tools.localtoglobal(nextPoint[0], nextPoint[1],
          patchData: building.patchData[turn.Bid]);

      setState(() {
        // focusturn.add(gmap.Polyline(
        //   polylineId: PolylineId("focusturn"),
        //   points: coordinates,
        //   color: Colors.blue,
        //   width: 5,
        // ));

        focusturnArrow.add(Marker(
            markerId: MarkerId("focusturn"),
            position: LatLng(latlng[0], latlng[1]),
            icon: greytorch,
            anchor: Offset(0.5, 0.5)));
      });

      mapState.target = LatLng(latlng[0], latlng[1]);
      mapState.bearing = tools
          .calculateBearing([latlng2[0], latlng2[1]], [latlng[0], latlng[1]]);
      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: mapState.target,
            zoom: mapState.zoom,
            bearing: mapState.bearing!,
            tilt: mapState.tilt),
      ));
    }
  }

  void focusBuildingChecker(CameraPosition position) {
    // LatLng currentLatLng = position.target;
    // double distanceThreshold = 100.0;
    // String closestBuildingId = "";
    // buildingAllApi.getStoredAllBuildingID().forEach((key, value) {

    //   if(key != buildingAllApi.outdoorID){
    //
    //     // tempMarkers.add(Marker(
    //     //     markerId: MarkerId("$key"),
    //     //     position: LatLng(value.latitude, value.longitude),
    //     //     onTap: () {
    //     //       print("$key");
    //     //     },
    //     // ));
    //     num distance = geo.Geodesy().distanceBetweenTwoGeoPoints(
    //       geo.LatLng(value.latitude, value.longitude),
    //       geo.LatLng(currentLatLng.latitude, currentLatLng.longitude),
    //     );
    //
    //     print("distance for $key is $distance");
    //
    //     if (distance < distanceThreshold) {
    //       closestBuildingId = key;
    //       buildingAllApi.setStoredString(key);
    //     }

    //   }
    // });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    compassSubscription.cancel();
    flutterTts.cancelHandler;
    _timer.cancel();
    btadapter.stopScanning();
    super.dispose();
  }

  List<String> scannedDevices = [];
  late Timer _timer;

  Set<gmap.Polyline> finalSet = {};

  bool ispdrStart = false;
  bool semanticShouldBeExcluded = false;
  bool isSemanticEnabled = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidthPixels = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
    double screenHeightPixel = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
    isSemanticEnabled = MediaQuery.of(context).accessibleNavigation;
    HelperClass.SemanticEnabled = MediaQuery.of(context).accessibleNavigation;
    return SafeArea(
      child: isLoading && isBlueToothLoading
          ? Scaffold(
              body: Center(
                child: lott.Lottie.asset(
                  'assets/loading_bluetooth.json', // Path to your Lottie animation
                  width: 500,
                  height: 500,
                ),
              ),
            )
          : isLoading
              ? Scaffold(
                  body: Center(
                      child: lott.Lottie.asset(
                    'assets/loding_animation.json', // Path to your Lottie animation
                    width: 500,
                    height: 500,
                  )),
                )
              : Scaffold(
                  body: Stack(
                    children: [
                      detected
                          ? Semantics(
                              excludeSemantics: true,
                              child: ExploreModePannel())
                          : Semantics(
                              excludeSemantics: true, child: Container()),
                      Semantics(
                        excludeSemantics: true,
                        child: Container(
                          child: GoogleMap(
                            padding: EdgeInsets.only(
                                left: 20), // <--- padding added here
                            initialCameraPosition: _initialCameraPosition,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            zoomGesturesEnabled: true,

                            polygons: patch
                                .union(getCombinedPolygons())
                                .union(otherpatch),
                            polylines: singleroute[building.floor[
                                        buildingAllApi.getStoredString()]] !=
                                    null
                                ? getCombinedPolylines().union(singleroute[
                                    building.floor[
                                        buildingAllApi.getStoredString()]]!)
                                : getCombinedPolylines(),
                            markers: getCombinedMarkers().union(focusturnArrow),
                            onTap: (x) {
                              mapState.interaction = true;
                            },
                            mapType: MapType.normal,
                            buildingsEnabled: false,
                            compassEnabled: true,
                            rotateGesturesEnabled: true,
                            minMaxZoomPreference: MinMaxZoomPreference(2, 30),
                            onMapCreated: (controller) {
                              controller.setMapStyle(maptheme);
                              _googleMapController = controller;
                              print("tumhari galti hai sb saalo");

                              if (patch.isNotEmpty) {
                                fitPolygonInScreen(patch.first);
                              }
                            },
                            onCameraMove: (CameraPosition cameraPosition) {
                              print("plpl ${cameraPosition.tilt}");
                              focusBuildingChecker(cameraPosition);
                              mapState.interaction = true;
                              mapbearing = cameraPosition.bearing;
                              if (!mapState.interaction) {
                                mapState.zoom = cameraPosition.zoom;
                              }
                              if (true) {
                                _updateMarkers(cameraPosition.zoom);
                                //_updateBuilding(cameraPosition.zoom);
                              }
                            },
                            onCameraIdle: () {
                              if (!mapState.interaction) {
                                mapState.interaction2 = true;
                              }
                            },
                            onCameraMoveStarted: () {
                              mapState.interaction2 = false;
                            },
                          ),
                        ),
                      ),
                      //debug----

                      DebugToggle.PDRIcon
                          ? Positioned(
                              top: 150,
                              right: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(20),
                                  color: (isPdr) ? Colors.green : Colors.red,
                                ),
                                height: 20,
                                width: 20,
                              ))
                          : Container(),
                      Positioned(
                        bottom: 150.0, // Adjust the position as needed
                        right: 16.0,

                        child: Semantics(
                          excludeSemantics: false,
                          child: Column(
                            children: [
                              //
                              // // Text(Building.thresh),
                              Visibility(
                                visible: DebugToggle.StepButton,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(24))),
                                    child: IconButton(
                                        onPressed: () {
                                          //StartPDR();

                                          bool isvalid =
                                              MotionModel.isValidStep(
                                                  user,
                                                  building.floorDimenssion[user
                                                      .Bid]![user.floor]![0],
                                                  building.floorDimenssion[user
                                                      .Bid]![user.floor]![1],
                                                  building.nonWalkable[
                                                      user.Bid]![user.floor]!,
                                                  reroute);
                                          if (isvalid) {
                                            user.move().then((value) {
                                              renderHere();
                                            });
                                          } else {
                                            if (user.isnavigating) {
                                              // reroute();
                                              // showToast("You are out of path");
                                            }
                                          }
                                        },
                                        icon: Icon(Icons.directions_walk))),
                              ),

                              SizedBox(height: 28.0),
                              DebugToggle.Slider
                                  ? Text("${user.theta}")
                                  : Container(),
                              DebugToggle.Slider
                                  ? Slider(
                                      value: user.theta,
                                      min: -180,
                                      max: 180,
                                      onChanged: (newvalue) {
                                        double? compassHeading = newvalue;
                                        setState(() {
                                          user.theta = compassHeading!;
                                          if (mapState.interaction2) {
                                            mapState.bearing = compassHeading!;
                                            _googleMapController.moveCamera(
                                              CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                  target: mapState.target,
                                                  zoom: mapState.zoom,
                                                  bearing: mapState.bearing!,
                                                ),
                                              ),
                                              //duration: Duration(milliseconds: 500), // Adjust the duration here (e.g., 500 milliseconds for a faster animation)
                                            );
                                          } else {
                                            if (markers.length > 0)
                                              markers[user.Bid]?[0] =
                                                  customMarker.rotate(
                                                      compassHeading! -
                                                          mapbearing,
                                                      markers[user.Bid]![0]);
                                          }
                                        });
                                      })
                                  : Container(),
                              SizedBox(height: 28.0),
                              !isSemanticEnabled
                                  ? Semantics(
                                      label: "Change floor",
                                      child: SpeedDial(
                                        child: Text(
                                          building.floor == 0
                                              ? 'G'
                                              : '${building.floor[buildingAllApi.getStoredString()]}',
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff24b9b0),
                                            height: 19 / 16,
                                          ),
                                        ),
                                        activeIcon: Icons.close,
                                        backgroundColor: Colors.white,
                                        children: List.generate(
                                          building.numberOfFloors[buildingAllApi
                                              .getStoredString()]!,
                                          (int i) {
                                            return SpeedDialChild(
                                              child: Semantics(
                                                label: "i",
                                                child: Text(
                                                  i == 0 ? 'G' : '$i',
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    height: 19 / 16,
                                                  ),
                                                ),
                                              ),
                                              backgroundColor:
                                                  pathMarkers[i] == null
                                                      ? Colors.white
                                                      : Color(0xff24b9b0),
                                              onTap: () {
                                                building.floor[buildingAllApi
                                                    .getStoredString()] = i;
                                                createRooms(
                                                  building.polylinedatamap[
                                                      buildingAllApi
                                                          .getStoredString()]!,
                                                  building.floor[buildingAllApi
                                                      .getStoredString()]!,
                                                );
                                                if (pathMarkers[i] != null) {
                                                  //setCameraPosition(pathMarkers[i]!);
                                                }
                                                building.landmarkdata!
                                                    .then((value) {
                                                  createMarkers(
                                                    value,
                                                    building.floor[buildingAllApi
                                                        .getStoredString()]!,
                                                  );
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : floorColumn(),
                              SizedBox(
                                  height: 28.0), // Adjust the height as needed

                              // Container(
                              //   width: 300,
                              //   height: 100,
                              //   child: SingleChildScrollView(
                              //     scrollDirection: Axis.horizontal,
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: [
                              //         Text(testBIn.keys.toString()),
                              //         Text(testBIn.values.toString()),
                              //         Text("summap"),
                              //         Text(sortedsumMapfordebug.toString()),
                              //       ],
                              //     ),
                              //   ),
                              // ),

                              Semantics(
                                child: FloatingActionButton(
                                  onPressed: () async {
                                    print(FlutterBluePlus.adapterStateNow
                                        .toString());
                                    btadapter.startScanningIOS(apibeaconmap);
                                    // //print(PathState.connections);
                                    // building.floor[buildingAllApi
                                    //     .getStoredString()] = user.floor;
                                    // createRooms(
                                    //     building.polyLineData!,
                                    //     building.floor[
                                    //         buildingAllApi.getStoredString()]!);
                                    // if (pathMarkers[user.floor] != null) {
                                    //   setCameraPosition(
                                    //       pathMarkers[user.floor]!);
                                    // }
                                    // building.landmarkdata!.then((value) {
                                    //   createMarkers(
                                    //       value,
                                    //       building.floor[buildingAllApi
                                    //           .getStoredString()]!);
                                    // });
                                    // if (markers.length > 0)
                                    //   markers[user.Bid]?[0] = customMarker
                                    //       .rotate(0, markers[user.Bid]![0]);
                                    // if (user.initialallyLocalised) {
                                    //   mapState.interaction =
                                    //       !mapState.interaction;
                                    // }
                                    // mapState.zoom = 21;
                                    // fitPolygonInScreen(patch.first);
                                  },
                                  child: Semantics(
                                    label: "Localize",
                                    onDidGainAccessibilityFocus:
                                        close_isnavigationPannelOpen,
                                    child: Icon(
                                      Icons.my_location_sharp,
                                      color: Colors.black,
                                    ),
                                  ),

                                  backgroundColor: Colors
                                      .white, // Set the background color of the FAB
                                ),
                              ),
                              SizedBox(height: 28.0),
                              FloatingActionButton(
                                onPressed: () async {
                                  if (user.initialallyLocalised) {
                                    setState(() {
                                      if (isLiveLocalizing) {
                                        isLiveLocalizing = false;
                                        HelperClass.showToast(
                                            "Explore mode is disabled");
                                        _exploreModeTimer!.cancel();
                                        _isExploreModePannelOpen = false;
                                        _isBuildingPannelOpen = true;
                                        lastBeaconValue = "";
                                      } else {
                                        speak("Explore Mode Enabled");
                                        isLiveLocalizing = true;
                                        HelperClass.showToast(
                                            "Explore mode enabled");
                                        _exploreModeTimer = Timer.periodic(
                                            Duration(milliseconds: 5000),
                                            (timer) async {
                                          btadapter.startScanning(resBeacons);
                                          Future.delayed(
                                                  Duration(milliseconds: 2000))
                                              .then((value) => {
                                                    realTimeReLocalizeUser(
                                                        resBeacons)
                                                    // listenToBin()
                                                  });
                                        });
                                        _isBuildingPannelOpen = false;
                                        _isExploreModePannelOpen = true;
                                      }
                                    });
                                  }
                                },
                                child: SvgPicture.asset(
                                  "assets/Navigation_RTLIcon.svg",
                                  // color:
                                  // (isLiveLocalizing) ? Colors.white : Colors.cyan,
                                ),
                                backgroundColor: Color(
                                    0xff24B9B0), // Set the background color of the FAB
                              ), // Adjust the height as needed// Adjust the height as needed

                              // FloatingActionButton(
                              //   onPressed: (){
                              //     print("checkingBuildingfloor");
                              //     //building.floor == 0 ? 'G' : '${building.floor}',
                              //     print(building.floor);
                              //     int firstKey = building.floor.values.first;
                              //     print(firstKey);
                              //     print(singleroute[building.floor.values.first]);
                              //
                              //     print(singleroute.keys);
                              //     print(singleroute.values);
                              //     print(building.floor[buildingAllApi.getStoredString()]);
                              //     print(singleroute[building.floor[buildingAllApi.getStoredString()]]);
                              //   },
                              //   child: Icon(Icons.add)
                              // ),
                              // FloatingActionButton(
                              //   onPressed: () async {
                              //
                              // StopPDR();
                              //
                              //
                              //
                              //     // if (user.initialallyLocalised) {
                              //     //   setState(() {
                              //     //     isLiveLocalizing = !isLiveLocalizing;
                              //     //   });
                              //     //
                              //     //   Timer.periodic(
                              //     //       Duration(milliseconds: 6000),
                              //     //           (timer) async {
                              //     //         print(resBeacons);
                              //     //         btadapter.startScanning(resBeacons);
                              //     //         Future.delayed(Duration(milliseconds: 4000)).then((value) => {
                              //     //           //c(resBeacons)
                              //     //         });
                              //     //
                              //     //       });
                              //     //
                              //     // }
                              //
                              //   },
                              //   child: Icon(
                              //     Icons.location_history_sharp,
                              //     color: (isLiveLocalizing)
                              //         ? Colors.cyan
                              //         : Colors.black,
                              //   ),
                              //   backgroundColor: Colors
                              //       .white, // Set the background color of the FAB
                              // ),
                            ],
                          ),
                        ),
                      ),
                      //-------
                      Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: _isLandmarkPanelOpen ||
                                  _isRoutePanelOpen ||
                                  _isnavigationPannelOpen
                              ? Semantics(
                                  excludeSemantics: true, child: Container())
                              : FocusScope(
                                  autofocus: true,
                                  child: Focus(
                                    child: Semantics(
                                      sortKey: const OrdinalSortKey(
                                          0), // header: true,
                                      child: HomepageSearch(
                                        onVenueClicked: onLandmarkVenueClicked,
                                        fromSourceAndDestinationPage:
                                            fromSourceAndDestinationPage,
                                      ),
                                    ),
                                  ),
                                )),
                      FutureBuilder(
                        future: building.landmarkdata,
                        builder: (context, snapshot) {
                          if (_isLandmarkPanelOpen) {
                            return landmarkdetailpannel(context, snapshot);
                          } else {
                            return Semantics(
                                excludeSemantics: true, child: Container());
                          }
                        },
                      ),
                      routeDeatilPannel(),
                      navigationPannel(),
                      reroutePannel(),
                      ExploreModePannel(),
                      detected
                          ? Semantics(child: nearestLandmarkpannel())
                          : Container(),
                      SizedBox(height: 28.0), // Adjust the height as needed
                      // FloatingActionButton(
                      //     onPressed: (){
                      //       print("checkingBuildingfloor");
                      //       //building.floor == 0 ? 'G' : '${building.floor}',
                      //       print(building.floor);
                      //       int firstKey = building.floor.values.first;
                      //       print(firstKey);
                      //       print(singleroute[building.floor.values.first]);
                      //
                      //       print(singleroute.keys);
                      //       print(singleroute.values);
                      //       print(building.floor[buildingAllApi.getStoredString()]);
                      //       print(singleroute[building.floor[buildingAllApi.getStoredString()]]);
                      //     },
                      //     child: Icon(Icons.add)
                      // ),

                      // FloatingActionButton(
                      //   onPressed: () async {
                      //
                      //     //StopPDR();
                      //
                      //     if (user.initialallyLocalised) {
                      //       setState(() {
                      //         isLiveLocalizing = !isLiveLocalizing;
                      //       });
                      //       HelperClass.showToast("realTimeReLocalizeUser started");
                      //
                      //       Timer.periodic(
                      //           Duration(milliseconds: 5000),
                      //               (timer) async {
                      //             print(resBeacons);
                      //             btadapter.startScanning(resBeacons);
                      //
                      //
                      //             // setState(() {
                      //             //   sumMap=  btadapter.calculateAverage();
                      //             // });
                      //
                      //
                      //             Future.delayed(Duration(milliseconds: 2000)).then((value) => {
                      //               realTimeReLocalizeUser(resBeacons)
                      //               // listenToBin()
                      //
                      //
                      //             });
                      //
                      //             setState(() {
                      //               debugPQ = btadapter.returnPQ();
                      //
                      //             });
                      //
                      //           });
                      //
                      //     }
                      //
                      //   },
                      //   child: Icon(
                      //     Icons.location_history_sharp,
                      //     color: (isLiveLocalizing)
                      //         ? Colors.cyan
                      //         : Colors.black,
                      //   ),
                      //   backgroundColor: Colors
                      //       .white, // Set the background color of the FAB
                      // ),
                    ],
                  ),
                ),
    );
  }
  //
  // int d=0;
  // bool listenToBin(){
  //   double highestweight = 0;
  //   String nearestBeacon = "";
  //   Map<String, double> sumMap = btadapter.calculateAverage();
  //
  //   print("-90---   ${sumMap.length}");
  //   print("checkingavgmap   ${sumMap}");
  //  // widget.direction = "";
  //
  //
  //   for (int i = 0; i < btadapter.BIN.length; i++) {
  //     if(btadapter.BIN[i]!.isNotEmpty){
  //       btadapter.BIN[i]!.forEach((key, value) {
  //         key = "";
  //         value = 0.0;
  //       });
  //     }
  //   }
  //   btadapter.numberOfSample.clear();
  //   btadapter.rs.clear();
  //   Building.thresh = "";
  //   print("Empty BIn");
  //   d++;
  //   sumMap.forEach((key, value) {
  //
  //     setState(() {
  //      // direction = "${widget.direction}$key   $value\n";
  //     });
  //
  //     print("-90-   $key   $value");
  //
  //     if(value>highestweight){
  //       highestweight =  value;
  //       nearestBeacon = key;
  //     }
  //   });
  //
  //   //print("$nearestBeacon   $highestweight");
  //
  //
  //   if(nearestBeacon !=""){
  //
  //     if(user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null){
  //       if(user.key != Building.apibeaconmap[nearestBeacon]!.sId){
  //
  //         if(user.floor == Building.apibeaconmap[nearestBeacon]!.floor  && highestweight >9){
  //           List<int> beaconcoord = [Building.apibeaconmap[nearestBeacon]!.coordinateX!,Building.apibeaconmap[nearestBeacon]!.coordinateY!];
  //           List<int> usercoord = [user.showcoordX, user.showcoordY];
  //           double d = tools.calculateDistance(beaconcoord, usercoord);
  //           if(d < 5){
  //             //near to user so nothing to do
  //             return true;
  //           }else{
  //             int distanceFromPath = 100000000;
  //             int? indexOnPath = null;
  //             int numCols = user.pathobj.numCols![user.Bid]![user.floor]!;
  //             user.path.forEach((node) {
  //               List<int> pathcoord = [node % numCols, node ~/ numCols];
  //               double d1 = tools.calculateDistance(beaconcoord, pathcoord);
  //               if(d1<distanceFromPath){
  //                 distanceFromPath = d1.toInt();
  //                 print("node on path $node");
  //                 print("distanceFromPath $distanceFromPath");
  //                 indexOnPath = user.path.indexOf(node);
  //                 print(indexOnPath);
  //               }
  //             });
  //
  //             if(distanceFromPath>5){
  //               _timer.cancel();
  //               repaintUser(nearestBeacon);
  //               return false;//away from path
  //             }else{
  //               user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
  //
  //               speak("You are near ${Building.apibeaconmap[nearestBeacon]!.name}");
  //               user.moveToPointOnPath(indexOnPath!);
  //               moveUser();
  //               return true; //moved on path
  //             }
  //           }
  //
  //
  //           // print("d $d");
  //           // print("widget.user.key ${widget.user.key}");
  //           // print("beaconcoord ${beaconcoord}");
  //           // print("usercoord ${usercoord}");
  //           // print(nearestBeacon);
  //         }else{
  //
  //           speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor");
  //           paintUser(nearestBeacon); //different floor
  //           return true;
  //         }
  //
  //       }
  //     }else{
  //       print("listening");
  //
  //       print(nearestBeacon);
  //       _timer.cancel();
  //       repaintUser(nearestBeacon);
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort(
          (a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }
}
