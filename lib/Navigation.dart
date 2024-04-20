import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:http/http.dart';
import 'package:iwayplusnav/Elements/DirectionHeader.dart';

import 'package:vibration/vibration.dart';
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
import 'package:iwayplusnav/API/PolyLineApi.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/APIMODELS/buildingAll.dart';
import 'package:iwayplusnav/APIMODELS/landmark.dart';
import 'package:iwayplusnav/Elements/HomepageLandmarkClickedSearchBar.dart';
import 'package:iwayplusnav/Elements/buildingCard.dart';
import 'package:iwayplusnav/Elements/directionInstruction.dart';
import 'package:iwayplusnav/PolylineTestClass.dart';
import 'package:iwayplusnav/UserState.dart';
import 'package:iwayplusnav/buildingState.dart';
import 'package:iwayplusnav/navigationTools.dart';
import 'package:iwayplusnav/path.dart';
import 'package:iwayplusnav/pathState.dart';
import 'package:iwayplusnav/pathState.dart';
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
  Navigation();

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  MapState mapState = new MapState();
  Timer? PDRTimer;
  String maptheme = "";
  var _initialCameraPosition = CameraPosition(
    target: LatLng(60.543833319119475, 77.18729871127312),
    zoom: 0,
  );
  late GoogleMapController _googleMapController;
  Set<Polygon> patch = Set();
  Set<Polygon> otherpatch = Set();
  Map<String,Set<gmap.Polyline>> polylines = Map();
  Set<gmap.Polyline> otherpolylines = Set();
  Map<String,Set<Polygon>> closedpolygons = Map();
  Set<Polygon> otherclosedpolygons = Set();
  Set<Marker> Markers = Set();
  Map<String,Set<Marker>> selectedroomMarker = Map();
  Map<int, Set<Marker>> pathMarkers = {};
  Map<String,List<Marker>> markers = Map();


  Building building = Building(floor: Map(), numberOfFloors: Map());
  Map<int, Set<gmap.Polyline>> singleroute = {};
  BT btadapter = new BT();
  bool _isLandmarkPanelOpen = false;
  bool _isRoutePanelOpen = false;
  bool _isnavigationPannelOpen = false;
  bool _isreroutePannelOpen = false;
  bool _isBuildingPannelOpen = false;
  bool _isNearestLandmarkPannelOpen = false;
  bool _isFilterPanelOpen = false;
  bool checkedForPolyineUpdated = false;
  bool checkedForPatchDataUpdated = false;
  bool checkedForLandmarkDataUpdated = false;

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

  @override
  void initState() {
    super.initState();
    //PolylineTestClass.polylineSet.clear();
   // StartPDR();
    building.floor.putIfAbsent("", () => 0);
    flutterTts = FlutterTts();
    setState(() {
      isLoading = true;
      speak("Loading maps");
    });
    print("Circular progress bar");
  //  calibrate();
    apiCalls();

    //handleCompassEvents();
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

void calibrate()async{
    setState(() {
      isCalibrating = true;
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
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
  void calculateThresholds() {
    if (accelerationMagnitudes.isNotEmpty) {
      double mean = accelerationMagnitudes.reduce((a, b) => a + b) / accelerationMagnitudes.length;
      double variance = accelerationMagnitudes.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
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
            markers[user.Bid]![0] =
                customMarker.rotate(compassHeading! - mapbearing, markers[user.Bid]![0]);
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
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  void checkPermissions() async {
    print("running");
    await requestLocationPermission();
    await requestBluetoothConnectPermission();
    //  await requestActivityPermission();
  }

  // Function to start the timer
  void StartPDR() {
    PDRTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
     // print("calling");
      pdrstepCount();
      // onStepCount();
    });
  }

// Function to stop the timer
  bool isPdrStop=false;
  void StopPDR() async{
    if (PDRTimer != null && PDRTimer!.isActive) {

      setState(() {
        isPdrStop=true;
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
  double peakThreshold = 11.111111111;
  double valleyThreshold = -11.111111111;

  int peakInterval = 300;
  int valleyInterval = 300;
  //it is the smoothness factor of the low pass filter.
  double alpha = 0.4;
  double filteredX = 0;
  double filteredY = 0;
  double filteredZ = 0;

// late StreamSubscription<AccelerometerEvent>? pdr;
  void pdrstepCount(){
   pdr.add(

       accelerometerEventStream().listen((AccelerometerEvent event) {

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
          filteredZ * filteredZ))
      ;
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

           if(MotionModel.reached(user, building.floorDimenssion[user.Bid]![user.floor]![0])==false){
             user.move().then((value) {
               //  user.move().then((value){
               setState(() {

                 if (markers.length > 0) {
                   List<double> lvalue = tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt());
                   markers[user.Bid]?[0] = customMarker.move(
                       LatLng(lvalue[0],lvalue[1]),
                       markers[user.Bid]![0]
                   );

                   List<double> ldvalue = tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt());
                   markers[user.Bid]?[1] = customMarker.move(
                       LatLng(ldvalue[0],ldvalue[1]),
                       markers[user.Bid]![1]
                   );
                 }
               });
               // });
             });
           }else{
             StopPDR();
             setState(() {
               user.isnavigating=false;
             });
             speak("haaan bhaiiii aaaagya");

           }

            print("next [${user.coordX}${user.coordY}]");

          } else {
            if(user.isnavigating){
              // reroute();
              // showToast("You are out of path");
            }
          }



          print("peakThreshold: ${peakThreshold}");
        });
      } else if (magnitude < valleyThreshold &&
          DateTime.now().millisecondsSinceEpoch - lastValleyTime > valleyInterval) {
        setState(() {
          lastValleyTime = DateTime.now().millisecondsSinceEpoch;
        });
      }
    })
   );
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

  void repaintUser(String nearestBeacon){
    reroute();
    paintUser(nearestBeacon,speakTTS: false);
  }

  void paintUser(String nearestBeacon, {bool speakTTS = true})async{
    print("nearestBeacon : $nearestBeacon");
    BitmapDescriptor userloc = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(44, 44)),
      'assets/userloc0.png',
    );
    BitmapDescriptor userlocdebug = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(44, 44)),
      'assets/tealtorch.png',
    );
    List<int> landCords = [];
    if (apibeaconmap[nearestBeacon] != null) {
      await building.landmarkdata!.then((value) {
        nearestLandInfomation = tools.localizefindNearbyLandmark(
            apibeaconmap[nearestBeacon]!, value.landmarksMap!);
        landCords = tools.localizefindNearbyLandmarkCoordinated(
            apibeaconmap[nearestBeacon]!, value.landmarksMap!);
      });

      List<double> values = [];

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
      if(speakTTS){
        mapState.zoom = 21.0;
        _googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(values[0], values[1]),
            20, // Specify your custom zoom level here
          ),
        );
      }

      user.Bid = apibeaconmap[nearestBeacon]!.buildingID!;
      user.coordX = apibeaconmap[nearestBeacon]!.coordinateX!;
      user.coordY = apibeaconmap[nearestBeacon]!.coordinateY!;
      user.showcoordX = user.coordX;
      user.showcoordY = user.coordY;
      List<int> userCords = [];
      userCords.add(user.coordX);
      userCords.add(user.coordY);
      List<int> transitionValue = tools.eightcelltransition(user.theta);
      List<int> newUserCord = [user.coordX + transitionValue[0], user.coordY + transitionValue[1]];

      user.lat =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.latitude!);
      user.lng =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.longitude!);
      user.floor = apibeaconmap[nearestBeacon]!.floor!;
      user.key = apibeaconmap[nearestBeacon]!.sId!;
      user.initialallyLocalised = true;
      setState(() {
        markers.clear();
        if(markers.containsKey(user.Bid)){
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: beaconLocation,
            icon: userloc,
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: beaconLocation,
            icon: userlocdebug,
            anchor: Offset(0.5, 0.829),
          ));
        }else{
          markers.putIfAbsent(user.Bid, () => []);
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("UserLocation"),
            position: beaconLocation,
            icon: userloc,
            anchor: Offset(0.5, 0.829),
          ));
          markers[user.Bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: beaconLocation,
            icon: userlocdebug,
            anchor: Offset(0.5, 0.829),
          ));

        }


        building.floor[apibeaconmap[nearestBeacon]!.buildingID!] = apibeaconmap[nearestBeacon]!.floor!;
        createRooms(building.polyLineData!, apibeaconmap[nearestBeacon]!.floor!);
        building.landmarkdata!.then((value) {
          createMarkers(value, apibeaconmap[nearestBeacon]!.floor!);
        });
      });
      double value = tools.calculateAngleSecond(userCords, newUserCord, landCords);
      String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

      detected = !detected;
      _isBuildingPannelOpen = true;
      _isNearestLandmarkPannelOpen = !_isNearestLandmarkPannelOpen;
      nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
      if (nearestLandInfomation.name == "") {
        nearestLandInfomation.name = apibeaconmap[nearestBeacon]!.name!;
        nearestLandInfomation.floor = apibeaconmap[nearestBeacon]!.floor!.toString();
        if(speakTTS)
          speak("You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${apibeaconmap[nearestBeacon]!.name!} is on your ${finalvalue}");
      } else {
        nearestLandInfomation.floor =
            apibeaconmap[nearestBeacon]!.floor!.toString();
        if(speakTTS)
          speak("You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${nearestLandInfomation.name} is on your ${finalvalue}");
      }
    } else {
      if(speakTTS)
        speak("Unable to find your location");
    }
    btadapter.stopScanning();
  }


  void moveUser()async{
    BitmapDescriptor userloc = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(44, 44)),
      'assets/userloc0.png',
    );
    BitmapDescriptor userlocdebug = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(44, 44)),
      'assets/tealtorch.png',
    );
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
      if(markers.containsKey(user.Bid)){
        markers[user.Bid]?.add(Marker(
          markerId: MarkerId("UserLocation"),
          position: userlocation,
          icon: userloc,
          anchor: Offset(0.5, 0.829),
        ));
        markers[user.Bid]?.add(Marker(
          markerId: MarkerId("debug"),
          position: userlocation,
          icon: userlocdebug,
          anchor: Offset(0.5, 0.829),
        ));
      }else{
        markers.putIfAbsent(user.Bid, () => []);
        markers[user.Bid]?.add(Marker(
          markerId: MarkerId("UserLocation"),
          position: userlocation,
          icon: userloc,
          anchor: Offset(0.5, 0.829),
        ));
        markers[user.Bid]?.add(Marker(
          markerId: MarkerId("debug"),
          position: userlocation,
          icon: userlocdebug,
          anchor: Offset(0.5, 0.829),
        ));

      }
    });
  }

  void reroute() {
    _isnavigationPannelOpen = false;
    _isRoutePanelOpen = false;
    _isLandmarkPanelOpen = false;
    _isreroutePannelOpen = true;
    user.isnavigating = false;
    PathState.sourceX = user.coordX;
    PathState.sourceY = user.coordY;
    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;
    PathState.sourceFloor = user.floor;
    PathState.sourcePolyID = user.key;
    PathState.sourceName = "Your current location";
    setState(() {
      if (markers.length > 0) {
        List<double> dvalue = tools.localtoglobal(
            user.coordX.toInt(),
            user.coordY.toInt());
        markers[user.Bid]?[0] = customMarker.move(LatLng(dvalue[0],dvalue[1]), markers[user.Bid]![0]);
      }
    });
    speak("You are going away from the path. Click Reroute to Navigate from here. ");
  }


  Future<void> requestBluetoothConnectPermission() async {
    final PermissionStatus permissionStatus =
    await Permission.bluetoothScan.request();
    if (permissionStatus.isGranted) {
      // Permission granted, you can now perform Bluetooth operations
    } else {
      // Permission denied, handle accordingly
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
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
      building.patchData[value.patchData!.buildingID!] = value;
      createPatch(value);
      tools.globalData = value;
      for (int i = 0; i < 4; i++) {
        tools.corners.add(math.Point(
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!),
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!)));
      }
      tools.angleBetweenBuildingAndNorth();
    });
    print("working 2");
    await PolyLineApi()
        .fetchPolyData(id: buildingAllApi.selectedBuildingID)
        .then((value) {
      print("object ${value.polyline!.floors!.length}");
      building.polyLineData = value;
      building.numberOfFloors[buildingAllApi.selectedBuildingID] = value.polyline!.floors!.length;
      building.polylinedatamap[buildingAllApi.selectedBuildingID] = value;
      createRooms(value, 0);
    });

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
          Map<int, List<int>> currrentnonWalkable = building.nonWalkable[value.landmarks![i].buildingID!] ?? Map();
          currrentnonWalkable[value.landmarks![i].floor!] = allIntegers;
          building.nonWalkable[value.landmarks![i].buildingID!] = currrentnonWalkable;

          Map<int,List<int>> currentfloorDimenssion = building.floorDimenssion[buildingAllApi.selectedBuildingID] ?? Map();
          currentfloorDimenssion[value.landmarks![i].floor!] = [value.landmarks![i].properties!.floorLength!, value.landmarks![i].properties!.floorBreadth!];
          building.floorDimenssion[buildingAllApi.selectedBuildingID] = currentfloorDimenssion!;
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
      print(value.toString());
      building.beacondata = value;
      for (int i = 0; i < value.length; i++) {
        beacon beacons = value[i];
        if (beacons.properties!.macId != null) {
          apibeaconmap[beacons.properties!.macId!] = beacons;
        }
      }
      Building.apibeaconmap = apibeaconmap;
      btadapter.startScanning(apibeaconmap);
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
        _timer.cancel();
      });
    });
    print("Himanshuchecker ids 1 ${buildingAllApi.getStoredAllBuildingID()}");
    print("Himanshuchecker ids 2 ${buildingAllApi.getStoredString()}");
    print("Himanshuchecker ids 3 ${buildingAllApi.getSelectedBuildingID()}");
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      if (key != buildingAllApi.getSelectedBuildingID()) {
        await patchAPI().fetchPatchData(id: key).then((value) {
          building.patchData[value.patchData!.buildingID!] = value;
          createotherPatch(value);
        });

        await PolyLineApi().fetchPolyData(id: key).then((value) {
          createRooms(value, 0);
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
            if (value.landmarks![i].element!.subType == "AR") {
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
              Map<int, List<int>> currrentnonWalkable = building.nonWalkable[key] ?? Map();
              currrentnonWalkable[value.landmarks![i].floor!] = allIntegers;
              building.nonWalkable[key] = currrentnonWalkable;

              Map<int,List<int>> currentfloorDimenssion = building.floorDimenssion[key] ?? Map();
              currentfloorDimenssion[value.landmarks![i].floor!] = [value.landmarks![i].properties!.floorLength!, value.landmarks![i].properties!.floorBreadth!];
              building.floorDimenssion[key] = currentfloorDimenssion!;
              print("fetch route--  ${building.floorDimenssion}");

              // building.floorDimenssion[value.landmarks![i].floor!] = [
              //   value.landmarks![i].properties!.floorLength!,
              //   value.landmarks![i].properties!.floorBreadth!
              // ];
            }
          }
          createotherARPatch(coordinates, value.landmarks![0].buildingID!);
        });
      }
    });

    buildingAllApi.setStoredString(buildingAllApi.getSelectedBuildingID());
    print("working over");
    await Future.delayed(Duration(seconds: 3));
    print("5 seconds over");
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

  late nearestLandInfo nearestLandInfomation;

  Future<void> localizeUser() async {
    print("Beacon searching started");
    double highestweight = 0;
    String nearestBeacon = "";

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


    paintUser(nearestBeacon);
  }

  String nearbeacon = 'null';
  String weight = "null";
  HashMap<int, HashMap<String, double>> testBIn = HashMap();

  Future<void> realTimeReLocalizeUser(
      HashMap<String, beacon> apibeaconmap) async {
    print("Beacon searching started");
    BitmapDescriptor userloc = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(44, 44)),
      'assets/userloc0.png',
    );
    double highestweight = 0;
    String nearestBeacon = "";
    List<int> landCords = [];

    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          print("Wilsonchecker");
          print(value.toString());
          print(key);
          if (value > highestweight) {
            highestweight = value;
            nearestBeacon = key;
          }
        });
        break;
      }
    }
    setState(() {
      nearbeacon = nearestBeacon;
      weight = highestweight.toString();
    });
    // btadapter.emptyBin();

    print("nearestBeacon : $nearestBeacon");

    if (apibeaconmap[nearestBeacon] != null) {
      await building.landmarkdata!.then((value) {
        nearestLandInfomation = tools.localizefindNearbyLandmark(
            apibeaconmap[nearestBeacon]!, value.landmarksMap!);
        landCords = tools.localizefindNearbyLandmarkCoordinated(
            apibeaconmap[nearestBeacon]!, value.landmarksMap!);
      });

      List<double> values = tools.localtoglobal(
          apibeaconmap[nearestBeacon]!.coordinateX!,
          apibeaconmap[nearestBeacon]!.coordinateY!);
      LatLng beaconLocation = LatLng(values[0], values[1]);
      mapState.target = LatLng(values[0], values[1]);
      mapState.zoom = 21.0;
      _googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(values[0], values[1]),
          20, // Specify your custom zoom level here
        ),
      );
      user.Bid = apibeaconmap[nearestBeacon]!.buildingID!;
      user.coordX = apibeaconmap[nearestBeacon]!.coordinateX!;
      user.coordY = apibeaconmap[nearestBeacon]!.coordinateY!;
      print("user.coordXuser.coordY");
      print("${user.coordX}${user.coordY}");
      List<int> userCords = [];
      userCords.add(user.coordX);
      userCords.add(user.coordY);
      List<int> transitionValue = tools.eightcelltransition(user.theta);
      int newX = user.coordX + transitionValue[0];
      int newY = user.coordY + transitionValue[1];
      List<int> newUserCord = [];
      newUserCord.add(newX);
      newUserCord.add(newY);

      user.lat =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.latitude!);
      user.lng =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.longitude!);
      user.floor = apibeaconmap[nearestBeacon]!.floor!;
      user.key = apibeaconmap[nearestBeacon]!.sId!;
      user.initialallyLocalised = true;
      setState(() {
        print("hehe: $beaconLocation");
        markers.clear();
        markers[user.Bid]?.add(Marker(
          markerId: MarkerId("UserLocation"),
          position: beaconLocation,
          icon: userloc,
          anchor: Offset(0.5, 0.829),
        ));
        building.floor[apibeaconmap[nearestBeacon]!.buildingID!] = apibeaconmap[nearestBeacon]!.floor!;
        createRooms(building.polyLineData!, apibeaconmap[nearestBeacon]!.floor!);
        building.landmarkdata!.then((value) {
          createMarkers(value, apibeaconmap[nearestBeacon]!.floor!);
        });
      });
      print("userCords");
      print(userCords);
      print(newUserCord);
      print(landCords);

      double value = tools.calculateAngle(userCords, newUserCord, landCords);

      print("value----");
      print(value);
      String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);
      print("finalvalue");
      print(finalvalue);
      detected = true;
      _isBuildingPannelOpen = true;
      _isNearestLandmarkPannelOpen = !_isNearestLandmarkPannelOpen;
      nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
      if (nearestLandInfomation.name == "") {
        print("no beacon found");
        nearestLandInfomation.name = apibeaconmap[nearestBeacon]!.name!;
        nearestLandInfomation.floor =
            apibeaconmap[nearestBeacon]!.floor!.toString();
        speak(
            "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${apibeaconmap[nearestBeacon]!.name!} is on your ${finalvalue}");
      } else {
        nearestLandInfomation.floor =
            apibeaconmap[nearestBeacon]!.floor!.toString();
        speak(
            "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor,${nearestLandInfomation.name} is on your ${finalvalue}");
      }
    } else {
      speak("Unable to find your location");
    }
    btadapter.stopScanning();
    print("Beacon searching Stoped");
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
      if(selectedroomMarker.containsKey(buildingAllApi.getStoredString())){
      selectedroomMarker[buildingAllApi.getStoredString()]?.add(
        Marker(
            markerId: MarkerId('selectedroomMarker'),
            position: calculateRoomCenter(polygonPoints),
            icon: BitmapDescriptor.defaultMarker,
            onTap: () {
              print("infowindowcheck");
            }),
      );
      }else{
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
      if(selectedroomMarker.containsKey(buildingAllApi.getStoredString())) {
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
            markerId: MarkerId('selectedroomMarker'),
            position: Point,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }else{
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

  void setCameraPosition(Set<Marker> selectedroomMarker1, {Set<Marker>? selectedroomMarker2 = null}) {
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
    print("Himanshuchecker");
    print(list1.length);
    print(list2.length);
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
          l1.nodes!.forEach((element) {
            x1 = x1 + element.coordx!;
            y1 = y1 + element.coordy!;
          });

          int x2 = 0;
          int y2 = 0;
          l2.nodes!.forEach((element) {
            x2 = x2 + element.coordx!;
            y2 = y2 + element.coordy!;
          });

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
    if(closedpolygons[buildingAllApi.getStoredString()] == null){
      closedpolygons[buildingAllApi.getStoredString()] = Set();
    }
    print("closepolygon id");
    print(buildingAllApi.getStoredString());
    print(closedpolygons[buildingAllApi.getStoredString()]);
    closedpolygons[value.polyline!.buildingID!]?.clear();
    print("createroomschecker ${closedpolygons[buildingAllApi.getStoredString()]}");
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
          if(!closedpolygons.containsKey(value.polyline!.buildingID!)) {
            closedpolygons.putIfAbsent(
                value.polyline!.buildingID!, () => Set<Polygon>());
          }
          if(!polylines.containsKey(value.polyline!.buildingID!)){
            polylines.putIfAbsent(value.polyline!.buildingID!, () => Set<gmap.Polyline>());
          }

          if (polyArray.polygonType == 'Wall' ||
              polyArray.polygonType == 'undefined') {
            if (coordinates.length >= 2) {
              polylines[value.polyline!.buildingID!]!.add(gmap.Polyline(
                polylineId: PolylineId(
                    "${value.polyline!.buildingID!} Line ${polyArray.id!}"),
                points: coordinates,
                color: Colors.black,
                width: 1,
              ));
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
                  fillColor: Color(0xffE5F9FF),
                  consumeTapEvents: true,
                  onTap: () {
                    _googleMapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        tools.calculateRoomCenterinLatLng(coordinates),
                        22,
                      ),
                    );
                    setState(() {
                      if (building.selectedLandmarkID != polyArray.id) {
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
                  fillColor: Color(0xffC2F1D5),
                  consumeTapEvents: true,
                ));

              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("lift")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                  polygonId: PolygonId(
                      "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffFFFF00),
                  consumeTapEvents: true,
                ));
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
                  fillColor: Color(0xff0000FF),
                  consumeTapEvents: true,
                ));
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
                  fillColor: Color(0xffFF69B4),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("fire")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                  polygonId: PolygonId(
                      "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffFF4500),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("water")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                  polygonId: PolygonId(
                      "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xff00FFFF),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("wall")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                  polygonId: PolygonId(
                      "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffCCCCCC),
                  consumeTapEvents: true,
                ));
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
                  fillColor: Color(0xff800000),
                  consumeTapEvents: true,
                ));
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
                  fillColor: Color(0xff333333),
                  consumeTapEvents: true,
                ));
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
                  fillColor: Colors.black.withOpacity(0.2),
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
                fillColor: Color(0xffCCCCCC),
                consumeTapEvents: true,
              ));
            }
          } else {
            polylines[value.polyline!.buildingID!]!.add(gmap.Polyline(
              polylineId: PolylineId(polyArray.id!),
              points: coordinates,
              color: Colors.black,
              width: 1,
            ));
          }
        }
      }
    });
  }

  void createotherRooms(polylinedata value, int floor) {
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
          List<LatLng> coordinates = [];

          for (Nodes node in polyArray.nodes!) {
            //coordinates.add(LatLng(node.lat!,node.lon!));
            coordinates.add(LatLng(node.lat!, node.lon!));
          }

          if (polyArray.polygonType == 'Wall' ||
              polyArray.polygonType == 'undefined') {
            if (coordinates.length >= 2) {
              otherpolylines.add(gmap.Polyline(
                polylineId: PolylineId(polyArray.id!),
                points: coordinates,
                color: Colors.black,
                width: 1,
              ));
            }
          } else if (polyArray.polygonType == 'Room') {
            if (coordinates.length > 2) {
              coordinates.add(coordinates.first);
              otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffE5F9FF),
                  consumeTapEvents: true,
                  onTap: () {
                    _googleMapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        tools.calculateRoomCenterinLatLng(coordinates),
                        22,
                      ),
                    );
                    setState(() {
                      if (building.selectedLandmarkID != polyArray.id) {
                        building.selectedLandmarkID = polyArray.id;
                        building.ignoredMarker.clear();
                        building.ignoredMarker.add(polyArray.id!);
                        _isBuildingPannelOpen = false;
                        _isRoutePanelOpen = false;
                        singleroute.clear();
                        _isLandmarkPanelOpen = true;
                        addselectedRoomMarker(coordinates);
                      }
                    });
                  }));
            }
          } else if (polyArray.polygonType == 'Cubicle') {
            if (polyArray.cubicleName == "Green Area") {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffc2f1d5),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("lift")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                    polygonId: PolygonId(polyArray.id!),
                    points: coordinates,
                    strokeWidth: 1,
                    // Modify the color and opacity based on the selectedRoomId

                    strokeColor: Colors.black,
                    fillColor: Color(0xffFFFF00),
                    consumeTapEvents: true,
                    onTap: () {
                      if (building.selectedLandmarkID != polyArray.id) {
                        building.selectedLandmarkID = polyArray.id;
                        building.ignoredMarker.clear();
                        building.ignoredMarker.add(polyArray.id!);
                        _isRoutePanelOpen = false;
                        singleroute.clear();
                        _isLandmarkPanelOpen = true;
                        addselectedRoomMarker(coordinates);
                      }
                    }));
              }
            } else if (polyArray.cubicleName == "Male Washroom") {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xff0000FF),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName == "Female Washroom") {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffFF69B4),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("fire")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffFF4500),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("water")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xff00FFFF),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName!.toLowerCase().contains("wall")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xffCCCCCC),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName == "Restricted Area") {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xff800000),
                  consumeTapEvents: true,
                ));
              }
            } else if (polyArray.cubicleName == "Non Walkable Area") {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xff333333),
                  consumeTapEvents: true,
                ));
              }
            } else {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                otherclosedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  strokeColor: Colors.black,
                  fillColor: Colors.black.withOpacity(0.2),
                ));
              }
            }
          } else if (polyArray.polygonType == "Wall") {
            if (coordinates.length > 2) {
              coordinates.add(coordinates.first);
              otherclosedpolygons.add(Polygon(
                polygonId: PolygonId(polyArray.id!),
                points: coordinates,
                strokeWidth: 1,
                // Modify the color and opacity based on the selectedRoomId

                strokeColor: Colors.black,
                fillColor: Color(0xffCCCCCC),
                consumeTapEvents: true,
              ));
            }
          } else {
            otherpolylines.add(gmap.Polyline(
              polylineId: PolylineId(polyArray.id!),
              points: coordinates,
              color: Colors.black,
              width: 1,
            ));
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
          await getImagesFromMarker('assets/dooricon.png', 65);
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
            landmarks[i].name!.toLowerCase().contains("lift")) {
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (!snapshot.hasData ||
        snapshot.data!.landmarksMap == null ||
        snapshot.data!.landmarksMap![building.selectedLandmarkID] == null) {
      print("object");
      //print(building.selectedLandmarkID);
      // If the data is not available, return an empty container
      _isLandmarkPanelOpen = false;
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
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 24,
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
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: Colors.black,
                          size: 24,
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
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.only(left: 17, top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
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
                            Text(
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
                              width: 114,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xff24B9B0),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  _isNearestLandmarkPannelOpen = false;

                                  if (user.coordY != 0 && user.coordX != 0) {
                                    PathState.sourceX = user.coordX;
                                    PathState.sourceY = user.coordY;
                                    PathState.sourceFloor = user.floor;
                                    PathState.sourcePolyID = user.key;
                                    print("object ${PathState.sourcePolyID}");
                                    PathState.sourceName =
                                    "Your current location";
                                    PathState.destinationPolyID =
                                    building.selectedLandmarkID!;
                                    PathState.destinationName = snapshot
                                        .data!
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .name!;
                                    PathState.destinationFloor = snapshot
                                        .data!
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .floor!;
                                    PathState.sourceBid = user.Bid;

                                    PathState.destinationBid = snapshot
                                        .data!
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .buildingID!;

                                    setState(() {
                                      print("valuechanged");
                                      calculatingPath = true;
                                    });
                                    Future.delayed(Duration(seconds: 1), () {
                                      calculateroute(
                                          snapshot.data!.landmarksMap!)
                                          .then((value) {
                                        calculatingPath = false;
                                        _isLandmarkPanelOpen = false;
                                        _isRoutePanelOpen = true;
                                      });
                                    });
                                  } else {
                                    PathState.sourceName =
                                    "Choose Starting Point";
                                    PathState.destinationPolyID =
                                    building.selectedLandmarkID!;
                                    PathState.destinationName = snapshot
                                        .data!
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .name!;
                                    PathState.destinationFloor = snapshot
                                        .data!
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .floor!;
                                    building.selectedLandmarkID = "";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SourceAndDestinationPage(
                                                  DestinationID: PathState
                                                      .destinationPolyID,
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
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        width: screenWidth,
                        color: Color(0xffebebeb),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 17),
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
                                      child: Icon(
                                        Icons.location_on_outlined,
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
                                            "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.name!}, Floor ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.buildingName!}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            snapshot
                                .data!
                                .landmarksMap![
                            building.selectedLandmarkID]!
                                .properties!
                                .contactNo !=
                                null
                                ? Container(
                              margin:
                              EdgeInsets.only(left: 16, right: 16),
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
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
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
                            snapshot
                                .data!
                                .landmarksMap![
                            building.selectedLandmarkID]!
                                .properties!
                                .email !=
                                "" &&
                                snapshot
                                    .data!
                                    .landmarksMap![
                                building.selectedLandmarkID]!
                                    .properties!
                                    .email !=
                                    null
                                ? Container(
                              margin:
                              EdgeInsets.only(left: 16, right: 16),
                              padding: EdgeInsets.fromLTRB(0, 11, 0, 10),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1.0,
                                        color: Color(0xffebebeb))),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
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
                      )
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

  int sourceVal=0;
  int destinationVal=0;
  Map<List<String>,Set<gmap.Polyline>> interBuildingPath=new Map();

  Future<void> calculateroute(Map<String, Landmarks> landmarksMap) async {
    print("landmarksMap");
    print(landmarksMap.keys);
    print(landmarksMap.values);
    print(landmarksMap[PathState.destinationPolyID]!.buildingID);
    print(landmarksMap[PathState.sourcePolyID]!.buildingID);

    singleroute.clear();
    pathMarkers.clear();
    PathState.destinationX = landmarksMap[PathState.destinationPolyID]!.coordinateX!;
    PathState.destinationY = landmarksMap[PathState.destinationPolyID]!.coordinateY!;
    if (landmarksMap[PathState.destinationPolyID]!.doorX != null) {
      PathState.destinationX = landmarksMap[PathState.destinationPolyID]!.doorX!;
      PathState.destinationY = landmarksMap[PathState.destinationPolyID]!.doorY!;
    }
    if (PathState.sourceBid == PathState.destinationBid) {
      if (PathState.sourceFloor == PathState.destinationFloor) {
        print("Calculateroute if statement");
        print("${PathState.sourceX},${PathState.sourceY}    ${PathState.destinationX},${PathState.destinationY}");
        await fetchroute(
            PathState.sourceX,
            PathState.sourceY,
            PathState.destinationX,
            PathState.destinationY,
            PathState.destinationFloor,bid: PathState.destinationBid);
        print("fetchroute done");
      } else if (PathState.sourceFloor != PathState.destinationFloor) {
        List<CommonLifts> commonlifts = findCommonLifts(
            landmarksMap[PathState.sourcePolyID]!.lifts!,
            landmarksMap[PathState.destinationPolyID]!.lifts!);



        await fetchroute(
            commonlifts[0].x2!,
            commonlifts[0].y2!,
            PathState.destinationX,
            PathState.destinationY,
            PathState.destinationFloor,
            bid: PathState.destinationBid);



        Map<String, int> map = {
          'Take ${commonlifts[0].name}': -1,
        };
        print("test map: ${PathState.sourceFloor}");

        setState(() {
          sourceVal=PathState.sourceFloor;
          destinationVal=PathState.destinationFloor;
        });




        PathState.directions.add(map);

        await fetchroute(PathState.sourceX, PathState.sourceY,
            commonlifts[0].x1!, commonlifts[0].y1!, PathState.sourceFloor,bid: PathState.destinationBid);
      }
    } else {
      print("calculateroute else statement");
      double sourceEntrylat = 0;
      double sourceEntrylng = 0;
      double destinationEntrylat = 0;
      double destinationEntrylng = 0;


      building.landmarkdata!.then((land)async{

        for(int i = 0 ; i<land.landmarks!.length ; i++){
          Landmarks element = land.landmarks![i];
          print("running destination location");
          if(element.element!.subType != null && element.element!.subType!.toLowerCase().contains("entry") && element.buildingID == PathState.destinationBid){
            destinationEntrylat = double.parse(element.properties!.latitude!);
            destinationEntrylng= double.parse(element.properties!.longitude!);
            if (element.floor == PathState.destinationFloor) {
              await fetchroute(element.coordinateX!, element.coordinateY!, PathState.destinationX, PathState.destinationY, PathState.destinationFloor, bid: PathState.destinationBid);
              print("running destination location no lift run");
            } else if (element.floor != PathState.destinationFloor) {
              List<CommonLifts> commonlifts = findCommonLifts(element.lifts!, landmarksMap[PathState.destinationPolyID]!.lifts!);
              await fetchroute(commonlifts[0].x2!, commonlifts[0].y2!, PathState.destinationX, PathState.destinationY, PathState.destinationFloor, bid: PathState.destinationBid);
              print("running destination location lift run");
              await fetchroute(element.coordinateX!, element.coordinateY!, commonlifts[0].x1!, commonlifts[0].y1!, element.floor!,bid: PathState.destinationBid);
              print("running destination location dest run");
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






        for (int i =0 ; i< land.landmarks!.length ; i++){
          Landmarks element = land.landmarks![i];
          print("running source location");
          if(element.element!.subType != null && element.element!.subType!.toLowerCase().contains("entry") && element.buildingID == PathState.sourceBid){
            sourceEntrylat= double.parse(element.properties!.latitude!);
            sourceEntrylng= double.parse(element.properties!.longitude!);
            if (PathState.sourceFloor == element.floor) {
              await fetchroute(PathState.sourceX, PathState.sourceY, element.coordinateX!, element.coordinateY!, element.floor!,bid: PathState.sourceBid);
              print("running source location no lift run");
            } else if (PathState.sourceFloor != element.floor) {
              List<CommonLifts> commonlifts = findCommonLifts(landmarksMap[PathState.sourcePolyID]!.lifts!, element.lifts!);

              await fetchroute(commonlifts[0].x2!, commonlifts[0].y2!, element.coordinateX!, element.coordinateY!, element.floor!,bid: PathState.sourceBid);
              await fetchroute(PathState.sourceX, PathState.sourceY, commonlifts[0].x1!, commonlifts[0].y1!, PathState.sourceFloor,bid: PathState.sourceBid);
            }
            break;
          }
        }


        OutBuildingModel? buildData= await OutBuildingData.outBuildingData(sourceEntrylat,sourceEntrylng,destinationEntrylat,destinationEntrylng);
        print("build data: $buildData");

        List<LatLng> coords=[];
        if(buildData!=null){
          int len=buildData!.data!.path!.length;
          for(int i=0;i<len;i++)
          {
            coords.add(LatLng(buildData!.data!.path![i].lat!, buildData!.data!.path![i].lng!));
          }

          List<String> key=[PathState.sourceBid,PathState.destinationBid];
          interBuildingPath[key]=Set();
          interBuildingPath[key]!.add(gmap.Polyline(
            polylineId: PolylineId("InterBuilding"),
            points: coords,
            color: Colors.red,
            width: 3,
          ));
        }

        });
      print("different building detected");

      print(PathState.path.keys);
      print(pathMarkers.keys);

    }
  }

  List<int> beaconCord = [];
  double cordL = 0;
  double cordLt = 0;
  List<List<int>> getPoints=[];
  List<int> getnodes=[];

  Future<List<int>> fetchroute(int sourceX, int sourceY, int destinationX, int destinationY, int floor, {String? bid = null}) async {

    int numRows = building.floorDimenssion[bid]![floor]![1]; //floor breadth
    int numCols = building.floorDimenssion[bid]![floor]![0]; //floor length
    int sourceIndex = calculateindex(sourceX, sourceY, numCols);
    int destinationIndex = calculateindex(destinationX, destinationY, numCols);


    //List<int> path = [];
    //findPath(numRows, numCols, building.nonWalkable[bid]![floor]!, sourceIndex, destinationIndex);
    List<int> path=findPath(numRows, numCols, building.nonWalkable[bid]![floor]!, sourceIndex, destinationIndex);
    List<int>temp = [];
    temp.addAll(path);
    temp.addAll(PathState.singleListPath);
    PathState.singleListPath = temp;

    // print("allTurnPoints ${x1} ,${y1}");
    //
    // List<Node> nodes = List.generate(numRows * numCols, (index) {
    //   int x = index % numCols;
    //   int y = index ~/ numCols;
    //   return Node(index, x, y);
    // });
    // path.map((index) => nodes[index - 1]).toList();
    //
    // for(int i=0;i<path.length;i++){
    //   int x = path[i] % numCols;
    //   int y = path[i] ~/ numCols;
    //
    //   print("allPathPoints: ${x} ,${y}");
    //
    //
    // }


     Map<int,int> getTurns= tools.getTurnMap(path, numCols);


    print("getTurnsss ${getTurns}");

    Map<int,int> pt={};
    var keys=getTurns.keys.toList();
    for(int i=0;i<keys.length-1;i++){
      if(keys[i+1]-1==keys[i]){
        pt[keys[i+1]]=getTurns[keys[i+1]]!;
      }
    }

var ptKeys=pt.keys.toList();
    for(int i=0;i<pt.length;i++){
      int curr=path[ptKeys[i]];
      int next=path[ptKeys[i]+1];
      int prev=path[ptKeys[i]-1];
      int nextNext=path[ptKeys[i]+2];


      int currX=curr%numCols;
      int currY=curr~/numCols;

      int nextX=next%numCols;
      int nextY=next~/numCols;

      int prevX=prev%numCols;
      int prevY=prev~/numCols;


      int nextNextX=nextNext%numCols;
      int nextNextY=nextNext~/numCols;



      if(nextX==currX){
        currY=prevY;
        int newIndexY=currY*numCols+currX;
        path[ptKeys[i]]=newIndexY;
      }else if(nextY==currY){
        currX=prevX;
        int newIndexX=currY*numCols+currX;
        path[ptKeys[i]]=newIndexX;
      }


    }



    
      //print("rdp* path ${res}");
    print("A* path ${path}");
    print("non walkable path ${building.nonWalkable[bid]![floor]!}");
    
    //print("fetch route- $path");
    PathState.path[floor] = path;
    if(PathState.numCols == null){
      PathState.numCols = Map();
    }
    if(PathState.numCols![bid!] != null){
      PathState.numCols![bid]![floor] = numCols;
    }else{
      PathState.numCols![bid] = Map();
      PathState.numCols![bid]![floor] = numCols;
    }

    List<Map<String, int>> directions = tools.getDirections(path, numCols);
    directions.forEach((element) {
     // print("direction elements $element");
      PathState.directions.add(element);
    });

    // await building.landmarkdata!.then((value) {
    //   List<Landmarks> nearbyLandmarks = tools.findNearbyLandmark(
    //       path, value.landmarksMap!, 20, numCols, floor);
    //   print("nearbyLandmarks");
    //   List<int> landCoord = [];
    //
    //   for(int i=0 ; i<nearbyLandmarks.length ; i++){
    //     landCoord.add(nearbyLandmarks[i].coordinateX!);
    //     landCoord.add(nearbyLandmarks[i].coordinateY!);
    //     //double distL = calculateDistance(nearbyLandmarks[i].coordinateX! as double, nearbyLandmarks[i].coordinateY! as double, cordL, cordLt);
    //     // print("${nearbyLandmarks[i].coordinateX!} ${nearbyLandmarks[i].coordinateY!}");
    //     // print(distL);
    //
    //     // double dist = calculateDistance(landCoord as double,beaconCord);
    //     print(nearbyLandmarks[i].coordinateX!-cordL);
    //     if(nearbyLandmarks[i].coordinateX! - cordL < 10){
    //       print(nearbyLandmarks[i].coordinateX!-cordL);
    //       print(nearbyLandmarks[i].name);
    //     }
    //   }
    //   //print(nearbyLandmarks);
    //
    // });
    // await building.landmarkdata!.then((value) {
    //   List<Landmarks> near = tools.localizefindNearbyLandmark(0,3,value.landmarksMap!, 3);
    //   print("near---");
    //   for(int i=0 ; i<near.length ; i++){
    //     print(near[i].name);
    //   }
    // });

    print("Himanshucheckerpath $path");
    if (path.isNotEmpty) {
      if (floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(tools.numericalToAlphabetical(0), building.polyLineData!.polyline!.floors!);
        List<PolyArray> currFloorLifts = findLift(tools.numericalToAlphabetical(floor), building.polyLineData!.polyline!.floors!);
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

      BitmapDescriptor tealtorch = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/tealtorch.png',
      );
      Set<Marker> innerMarker = Set();

      innerMarker.add(Marker(
          markerId: MarkerId("destination${bid}"),
          position: LatLng(dvalue[0], dvalue[1]),
          icon: BitmapDescriptor.defaultMarker));
      innerMarker.add(
        Marker(
          markerId: MarkerId('source${bid}'),
          position: LatLng(svalue[0], svalue[1]),
          icon: tealtorch,
          anchor: Offset(0.5, 0.5),
        ),
      );
      print("pathMarkers[floor]");
      //print(innerMarker);

      print(pathMarkers.keys);
      print(pathMarkers.values.length);
      pathMarkers[floor]= innerMarker;


      // for (Marker marker in innerMarker) {
      //   pathMarkers[floor]?.add(marker);
      // }



      print(pathMarkers[floor]);
      setCameraPosition(innerMarker);
      print("Path found: $path");
      print("Path markers: $innerMarker");

    } else {
      print("No path found.");
    }

    List<LatLng> coordinates = [];

    for (int node in path) {
      print("Bharti debug");
      print(user.Bid);
      print(buildingAllApi.getStoredString());
      if (!building.nonWalkable[bid]![floor]!.contains(node)) {
        int row = (node % numCols); //divide by floor length
        int col = (node ~/ numCols); //divide by floor length
        if (bid != null) {
          print("Himanshubid $bid");
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
      if(singleroute.containsKey(floor)){
        print("contained call $bid");
        singleroute[floor]?.add(gmap.Polyline(
          polylineId: PolylineId("$bid"),
          points: coordinates,
          color: Colors.red,
          width: 3,
        ));
      }else{
        print("new call $bid $coordinates");
        singleroute.putIfAbsent(floor, () => Set());
        singleroute[floor]?.add(gmap.Polyline(
          polylineId: PolylineId("$bid"),
          points: coordinates,
          color: Colors.red,
          width: 3,
        ));
      }

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


    print("$floor    $path");
    building.floor[bid!] = floor;
    createRooms(building.polyLineData!, floor);
    print("path polyline ${singleroute[floor]}");
    return path;
  }

  PanelController _routeDetailPannelController = new PanelController();
  bool startingNavigation = false;
  Widget routeDeatilPannel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> directionWidgets = [];
    directionWidgets.clear();
    for (int i = 0; i < PathState.directions.length; i++) {

      if (PathState.directions[i].keys.first == "Straight") {
        directionWidgets.add(directionInstruction(
            direction: "Go " + PathState.directions[i].keys.first,
            distance: tools.roundToNextInt(PathState.directions[i].values.first * 0.3048).toString()));
      } else if (PathState.directions[i].keys.first.substring(0,4) == "Take") {
        directionWidgets.add(directionInstruction(
            direction: PathState.directions[i].keys.first,
            distance: "Floor $sourceVal -> Floor $destinationVal"));
      } else {
        directionWidgets.add(directionInstruction(
            direction: "Turn " + PathState.directions[i].keys.first + ", and Go Straight",
            distance: tools.roundToNextInt(PathState.directions[++i].values.first * 0.3048).toString()));
      }
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
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));
    return Visibility(
      visible: _isRoutePanelOpen,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, top: 16),
            height: 119,
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
                        PathState =
                            pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
                        PathState.path.clear();
                        PathState.sourcePolyID = "";
                        PathState.destinationPolyID = "";
                        singleroute.clear();
                        _isBuildingPannelOpen = true;
                        setState(() {
                          Marker? temp = selectedroomMarker[buildingAllApi.getStoredString()]?.first;
                          selectedroomMarker.clear();
                          selectedroomMarker[buildingAllApi.getStoredString()]?.add(temp!);
                          pathMarkers.clear();
                        });
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 24,
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
                          padding: EdgeInsets.only(left: 8, top: 7, bottom: 8),
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
                          padding: EdgeInsets.only(left: 8, top: 7, bottom: 8),
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
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DestinationSearchPage(
                                    hintText: 'Destination location',
                                  ))).then((value) {
                            _isBuildingPannelOpen = false;
                            onDestinationVenueClicked(value);
                          });
                        },
                      ),
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
                          building.landmarkdata!.then((value) {
                            calculateroute(value.landmarksMap!);
                          });
                        });
                      },
                      icon: Icon(
                        Icons.swap_vert_circle_outlined,
                        size: 24,
                      )),
                ),
              ],
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
                snapPoint: 0.9,
                panel: Stack(
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
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.only(left: 17, top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
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
                                    Text(
                                      "(${distance} m)",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        height: 24 / 18,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
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
                                    Container(
                                      width: 108,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Color(0xff24B9B0),
                                        borderRadius:
                                        BorderRadius.circular(4.0),
                                      ),
                                      child: TextButton(
                                        onPressed: ()async{
                                          print("checkingshow ${user.showcoordX.toInt()}, ${user.showcoordY.toInt()}");
                                          user.pathobj = PathState;
                                          user.path = PathState.singleListPath;
                                          user.isnavigating = true;
                                          user.moveToStartofPath().then((value) {
                                            setState(() {
                                              if (markers.length > 0) {
                                                print("checkingshow ${user.showcoordX.toInt()}, ${user.showcoordY.toInt()}");
                                                List<double> val = tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt());
                                                markers[user.Bid]?[0] = customMarker.move(
                                                    LatLng(val[0], val[1]),
                                                    markers[user.Bid]![0]);

                                                val = tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt());
                                                markers[user.Bid]?[1] = customMarker.move(
                                                    LatLng(val[0], val[1]),
                                                    markers[user.Bid]![1]);
                                              }
                                            });
                                          });
                                          _isRoutePanelOpen = false;
                                          //selectedroomMarker.clear();
                                          //pathMarkers.clear();
                                          building.selectedLandmarkID = null;
                                          _isnavigationPannelOpen = true;

                                        },
                                        child: !startingNavigation?Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.assistant_navigation,
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
                                        ):Container(width:24,height:24,child: CircularProgressIndicator(color: Colors.white,)),
                                      ),
                                    ),
                                    Container(
                                      width: 95,
                                      height: 40,
                                      margin: EdgeInsets.only(left: 12),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(4.0),
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          if (_routeDetailPannelController
                                              .isPanelOpen) {
                                            _routeDetailPannelController
                                                .close();
                                          } else {
                                            _routeDetailPannelController.open();
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
                                            Text(
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
                            width: screenWidth,
                            height: 1,
                            color: Color(0xffEBEBEB),
                          ),
                          Container(
                            margin:
                            EdgeInsets.only(left: 17, top: 12, right: 17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
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
                                SizedBox(
                                  height: 22,
                                ),
                                Container(
                                  height: 522,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 25,
                                              margin: EdgeInsets.only(right: 8),
                                              child: SvgPicture.asset(
                                                  "assets/StartpointVector.svg"),
                                            ),
                                            Text(
                                              "${PathState.sourceName}",
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff0e0d0d),
                                                height: 25 / 16,
                                              ),
                                              textAlign: TextAlign.left,
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
                                              margin: EdgeInsets.only(right: 8),
                                              child: Icon(
                                                Icons.pin_drop_sharp,
                                                size: 24,
                                              ),
                                            ),
                                            Text(
                                              PathState.destinationName,
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff0e0d0d),
                                                height: 25 / 16,
                                              ),
                                              textAlign: TextAlign.left,
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
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        top: 13,
                        right: 15,
                        child: IconButton(
                            onPressed: () {
                              showMarkers();
                              _isBuildingPannelOpen = true;
                              _isRoutePanelOpen = false;
                              selectedroomMarker.clear();
                              pathMarkers.clear();
                              building.selectedLandmarkID = null;
                              PathState = pathState.withValues(
                                  -1, -1, -1, -1, -1, -1, null, 0);
                              PathState.path.clear();
                              PathState.sourcePolyID = "";
                              PathState.destinationPolyID = "";
                              PathState.sourceBid = "";
                              PathState.destinationBid = "";
                              singleroute.clear();
                              PathState.directions = [];
                              interBuildingPath.clear();
                              fitPolygonInScreen(patch.first);
                            },
                            icon: Icon(
                              Icons.cancel_outlined,
                              size: 25,
                            )))
                  ],
                )),
          ),
        ],
      ),
    );
  }

    Widget navigationPannel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> directionWidgets = [];
    directionWidgets.clear();
    for (int i = 0; i < PathState.directions.length; i++) {
      if (PathState.directions[i].keys.first == "Straight") {
        directionWidgets.add(directionInstruction(
            direction: "Go " + PathState.directions[i].keys.first,
            distance: tools.roundToNextInt(PathState.directions[i].values.first * 0.3048).toString()));
      }
      else if (PathState.directions[i].keys.first.substring(0,4) == "Take") {
        directionWidgets.add(directionInstruction(
            direction: PathState.directions[i].keys.first,
            distance: "Floor $sourceVal -> Floor $destinationVal"));
      }
      else {
        directionWidgets.add(directionInstruction(
            direction: "Turn " +
                PathState.directions[i].keys.first +
                ", and Go Straight",
            distance: tools.roundToNextInt(PathState.directions[++i].values.first * 0.3048).toString()));
      }
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
    }
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));


    //implement the turn functionality.
if(user.isnavigating) {

  int col = user.pathobj.numCols![user.Bid]![user.floor]!;


  if (MotionModel.reached(user, col)==false) {
    List<int> a = [user.showcoordX, user.showcoordY];
    List<int> tval = tools.eightcelltransition(user.theta);
    print(tval);
    List<int> b = [user.showcoordX + tval[0], user.showcoordY + tval[1]];


    int index = user.path.indexOf((user.showcoordY * col) + user.showcoordX);

    int node = user.path[index + 1];

    List<int> c = [node % col, node ~/ col];
    int val = tools.calculateAngleSecond(a, b, c).toInt();

    // print("user corrds");
    // print("${user.showcoordX}+" "+ ${user.showcoordY}");

    print("pointss matchedddd ${getPoints.contains(
        [user.showcoordX, user.showcoordY])}");
    for (int i = 0; i < getPoints.length; i++) {
      print("---length  = ${getPoints.length}");
      print("--- point  = ${getPoints[i]}");
      print("---- usercoord  = ${user.showcoordX} , ${user.showcoordY}");
      print("--- val  = $val");
      print("--- isPDRStop  = $isPdrStop");

      // print("turn corrds");
      //
      // print("${getPoints[i].a}, ${getPoints[i].b}");
      if (isPdrStop && val == 0) {
        print("points unmatchedddd");

        setState(() {
          isPdrStop = false;
        });
        StartPDR();
        break;
      }
      if (getPoints[i][0] == user.showcoordX &&
          getPoints[i][1] == user.showcoordY) {
        print("points matchedddd");

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
          children: [SlidingUpPanel(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20.0,
                color: Colors.grey,
              ),
            ],
            minHeight: 90,
            maxHeight: screenHeight * 0.9,
            snapPoint: 0.9,
            panel: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 90,
                    padding: EdgeInsets.fromLTRB(11, 22, 14.08, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.keyboard_arrow_up_outlined,
                              size: 36,
                              color: Colors.black,
                            )),
                        Container(
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/navigationVector.svg"),
                              SizedBox(
                                width: 12,
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${time.toInt()} min",
                                        style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            height: 26 / 20,
                                            color: Color(0xffDC6A01)),
                                        textAlign: TextAlign.left,
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
                                  Text(
                                    "ETA- ${newTime.hour}:${newTime.minute}",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff8d8c8c),
                                      height: 20 / 14,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
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
                                if (markers.length > 0) {
                                  List<double> lvalue = tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt());
                                  markers[user.Bid]?[0] = customMarker.move(
                                      LatLng(lvalue[0],lvalue[1]),
                                      markers[user.Bid]![0]
                                  );
                                }
                              });
                            },
                            icon: Icon(
                              Icons.cancel_outlined,
                              size: 24,
                              color: Colors.black,
                            ))
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth,
                    height: 1,
                    color: Color(0xffEBEBEB),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 17, top: 12, right: 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                        SizedBox(
                          height: 22,
                        ),
                        Container(
                          height: 522,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 25,
                                      margin: EdgeInsets.only(right: 8),
                                      child: SvgPicture.asset(
                                          "assets/StartpointVector.svg"),
                                    ),
                                    Text(
                                      "${PathState.sourceName}",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff0e0d0d),
                                        height: 25 / 16,
                                      ),
                                      textAlign: TextAlign.left,
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
                                Column(
                                  children: directionWidgets,
                                ),
                                SizedBox(
                                  height: 22,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 25,
                                      margin: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.pin_drop_sharp,
                                        size: 24,
                                      ),
                                    ),
                                    Text(
                                      PathState.destinationName,
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff0e0d0d),
                                        height: 25 / 16,
                                      ),
                                      textAlign: TextAlign.left,
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
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),DirectionHeader(user: user, paint: paintUser, repaint: repaintUser, reroute: reroute, moveUser: moveUser,)],
        ));
  }


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
                        Container(
                          width: 85,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(0xff24B9B0),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              PathState.sourceX = user.coordX;
                              PathState.sourceY = user.coordY;
                              user.showcoordX = user.coordX;
                              user.showcoordY = user.coordY;
                              PathState.sourceFloor = user.floor;
                              PathState.sourcePolyID = user.key;
                              PathState.sourceName = "Your current location";
                              building.landmarkdata!.then((value) async {
                                await calculateroute(value.landmarksMap!)
                                    .then((value) {
                                  user.pathobj = PathState;
                                  user.path = PathState.path.values
                                      .expand((list) => list)
                                      .toList();
                                  user.pathobj.index = 0;
                                  user.isnavigating = true;
                                  user.moveToStartofPath().then((value) {
                                    setState(() {
                                      if (markers.length > 0) {
                                        markers[user.Bid]?[0] = customMarker.move(
                                            LatLng(
                                                tools.localtoglobal(
                                                    user.showcoordX.toInt(),
                                                    user.showcoordY.toInt())[0],
                                                tools.localtoglobal(
                                                    user.showcoordX.toInt(),
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
                                  int numCols = building.floorDimenssion[PathState.sourceBid]![PathState.sourceFloor]![0]; //floor length
                                  double angle = tools.calculateAngleBWUserandPath(user, PathState.path[PathState.sourceFloor]![1], numCols);
                                  if(angle != 0){
                                    speak("Turn "+ tools.angleToClocks(angle));
                                  }else{

                                  }
                                });
                              });
                            },
                            child: Text(
                              "Reroute",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff000000),
                                height: 20 / 14,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Container(
                          width: 92,
                          height: 36,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(color: Colors.black)),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Continue",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff000000),
                                height: 20 / 14,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        )
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

  void _slidePanelDown() {
    _panelController.close();
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
              sortKey: const OrdinalSortKey(1),
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
                                              sortKey:
                                              const OrdinalSortKey(6),
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
                                              sortKey:
                                              const OrdinalSortKey(7),
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
                                              sortKey:
                                              const OrdinalSortKey(1),
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
          maxHeight: 90,
          panel: Semantics(
              sortKey: const OrdinalSortKey(1),
              child: Container(
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
                    Container(
                      height: 1,
                      width: screenWidth,
                      color: Color(0xffebebeb),
                    ),
                  ],
                ),
              )),
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
        return (marker.union(Set<Marker>.of(markers[user.Bid]??[])));
      } else {
        return pathMarkers[building.floor[buildingAllApi.getStoredString()]] != null
            ? (pathMarkers[building.floor[buildingAllApi.getStoredString()]]!.union(Set<Marker>.of(markers[user.Bid]??[])))
            .union(Markers)
            : (Set<Marker>.of(markers[user.Bid]??[])).union(Markers);
      }
    } else {
      if (_isLandmarkPanelOpen) {
        Set<Marker> marker = Set();
        selectedroomMarker.forEach((key, value) {
          marker = marker.union(value);
        });
        return marker.union(Markers);
      } else {
        return pathMarkers[building.floor[buildingAllApi.getStoredString()]] != null
            ? (pathMarkers[building.floor[buildingAllApi.getStoredString()]]!).union(Markers)
            : Markers;
      }
    }
  }

  Set<Polygon> getCombinedPolygons(){
    Set<Polygon> polygons = Set();
    closedpolygons.forEach((key, value) {
      polygons = polygons.union(value);
    });
    return polygons;
  }

  Set<gmap.Polyline> getCombinedPolylines(){
    Set<gmap.Polyline> poly = Set();
    polylines.forEach((key, value) {
      poly = poly.union(value);
    });
    interBuildingPath.forEach((key, value) {
      poly=poly.union(value);
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

  void onLandmarkVenueClicked(String ID) {
    setState(() {
      if (building.selectedLandmarkID != ID) {
        building.landmarkdata!.then((value) {
          _isBuildingPannelOpen = false;
          building.floor[value.landmarksMap![ID]!.buildingID!] = value.landmarksMap![ID]!.floor!;
          createRooms(
              building.polylinedatamap[value.landmarksMap![ID]!.buildingID]!,
              building.floor[value.landmarksMap![ID]!.buildingID!]!);
          createMarkers(value, building.floor[value.landmarksMap![ID]!.buildingID!]!);
          building.selectedLandmarkID = ID;
          _isRoutePanelOpen = false;
          singleroute.clear();
          _isLandmarkPanelOpen = true;
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

  void focusBuildingChecker(CameraPosition position) {
    LatLng currentLatLng = position.target;
    double distanceThreshold = 100.0;
    String closestBuildingId = "";
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) {
      num distance = geo.Geodesy().distanceBetweenTwoGeoPoints(
        geo.LatLng(value.latitude, value.longitude),
        geo.LatLng(currentLatLng.latitude, currentLatLng.longitude),
      );

      if (distance < distanceThreshold) {
        closestBuildingId = key;
        buildingAllApi.setStoredString(key);
      }
    });
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
    super.dispose();
  }

  List<String> scannedDevices = [];
  late Timer _timer;

  Set<gmap.Polyline> finalSet = {};
  bool ispdrStart=false;


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidthPixels = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
    double screenHeightPixel = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;


    return SafeArea(
      child: isLoading && isBlueToothLoading? Scaffold(
        body: Center(
          child: lott.Lottie.asset(
            'assets/loading_bluetooth.json', // Path to your Lottie animation
            width: 500,
            height: 500,
          ),
        ),
      )
          : isLoading?
      Scaffold(
        body: Center(
            child:  lott.Lottie.asset(
              'assets/loding_animation.json', // Path to your Lottie animation
              width: 500,
              height: 500,
            )
        ),
      )

          :Scaffold(
        body: Stack(
          children: [
            Container(
              child: GoogleMap(
                padding: EdgeInsets.only(left: 20), // <--- padding added here
                initialCameraPosition: _initialCameraPosition,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                polygons: patch.union(getCombinedPolygons()).union(otherpatch),
                polylines:singleroute[building.floor[buildingAllApi.getStoredString()]] != null
                    ? getCombinedPolylines().union(singleroute[building.floor[buildingAllApi.getStoredString()]]!)
                    : getCombinedPolylines(),
                markers: getCombinedMarkers(),
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

            Positioned(
              bottom: 150.0, // Adjust the position as needed
              right: 16.0,
              child: Column(
                children: [
                  Visibility(
                    visible: true,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(24))),
                        child: IconButton(
                            onPressed: () {

                              // StartPDR();

                              bool isvalid = MotionModel.isValidStep(
                                  user,
                                  building.floorDimenssion[user.Bid]![user.floor]![0],
                                  building.floorDimenssion[user.Bid]![user.floor]![1],
                                  building.nonWalkable[user.Bid]![user.floor]!,
                                  reroute);
                              if (isvalid) {
                                user.move().then((value) {
                                  //  user.move().then((value){
                                  setState(() {

                                    if (markers.length > 0) {
                                      List<double> lvalue = tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt());
                                      markers[user.Bid]?[0] = customMarker.move(
                                          LatLng(lvalue[0],lvalue[1]),
                                          markers[user.Bid]![0]
                                      );

                                      List<double> ldvalue = tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt());
                                      markers[user.Bid]?[1] = customMarker.move(
                                          LatLng(ldvalue[0],ldvalue[1]),
                                          markers[user.Bid]![1]
                                      );
                                    }
                                  });
                                  // });
                                });
                                print("next [${user.coordX}${user.coordY}]");

                              } else {
                                if(user.isnavigating){
                                  reroute();
                                  showToast("You are out of path");
                                }
                              }
                            }, icon: Icon(Icons.directions_walk))),
                  ),
                  SizedBox(height: 28.0),
                  Slider(value: user.theta,min: -180,max: 180, onChanged: (newvalue){

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
                              customMarker.rotate(compassHeading! - mapbearing, markers[user.Bid]![0]);
                      }
                    });

                  }),
                  SizedBox(height: 28.0),
                  Semantics(
                    sortKey: const OrdinalSortKey(2),
                    child: SpeedDial(
                      child: Text(
                        building.floor == 0 ? 'G' : '${building.floor[buildingAllApi.getStoredString()]}',
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
                      children: [
                        for (int i = 0; i < building.numberOfFloors[buildingAllApi.getStoredString()]!; i++)
                          SpeedDialChild(
                            child: Text(
                              i == 0 ? 'G' : '${i}',
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 19 / 16,
                              ),
                            ),
                            backgroundColor: pathMarkers[i] == null
                                ? Colors.white
                                : Color(0xff24b9b0),
                            onTap: () {
                              building.floor[buildingAllApi.getStoredString()] = i;
                              createRooms(building.polylinedatamap[buildingAllApi.getStoredString()]!, building.floor[buildingAllApi.getStoredString()]!);
                              if (pathMarkers[i] != null) {
                                //setCameraPosition(pathMarkers[i]!);
                              }
                              building.landmarkdata!.then((value) {
                                createMarkers(value, building.floor[buildingAllApi.getStoredString()]!);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.0), // Adjust the height as needed
                  Semantics(
                    sortKey: const OrdinalSortKey(3),
                    child: FloatingActionButton(
                      onPressed: () {
                        building.floor[buildingAllApi.getStoredString()] = user.floor;
                        createRooms(building.polyLineData!, building.floor[buildingAllApi.getStoredString()]!);
                        if (pathMarkers[user.floor] != null) {
                          setCameraPosition(pathMarkers[user.floor]!);
                        }
                        building.landmarkdata!.then((value) {
                          createMarkers(value, building.floor[buildingAllApi.getStoredString()]!);
                        });
                        if (markers.length > 0)
                          markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
                        if (user.initialallyLocalised) {
                          mapState.interaction = !mapState.interaction;
                        }
                        mapState.zoom = 21;
                        fitPolygonInScreen(patch.first);
                      },
                      child: Icon(
                        Icons.my_location_sharp,
                        color: Colors.black,
                      ),
                      backgroundColor:
                      Colors.white, // Set the background color of the FAB
                    ),
                  ),
                  SizedBox(height: 28.0), // Adjust the height as needed
                  FloatingActionButton(
                    onPressed: (){
                      print("checkingBuildingfloor");
                      //building.floor == 0 ? 'G' : '${building.floor}',
                      print(building.floor);
                      int firstKey = building.floor.values.first;
                      print(firstKey);
                      print(singleroute[building.floor.values.first]);

                      print(singleroute.keys);
                      print(singleroute.values);
                      print(building.floor[buildingAllApi.getStoredString()]);
                      print(singleroute[building.floor[buildingAllApi.getStoredString()]]);
                    },
                    child: Icon(Icons.add)
                  ),
                  FloatingActionButton(
                    onPressed: () async {

                  StopPDR();



                      // if (user.initialallyLocalised) {
                      //   setState(() {
                      //     isLiveLocalizing = !isLiveLocalizing;
                      //   });
                      //
                      //   Timer.periodic(
                      //       Duration(milliseconds: 6000),
                      //           (timer) async {
                      //         print(resBeacons);
                      //         btadapter.startScanning(resBeacons);
                      //         Future.delayed(Duration(milliseconds: 4000)).then((value) => {
                      //           //realTimeReLocalizeUser(resBeacons)
                      //         });
                      //
                      //       });
                      //
                      // }

                    },
                    child: Icon(
                      Icons.location_history_sharp,
                      color: (isLiveLocalizing)
                          ? Colors.cyan
                          : Colors.black,
                    ),
                    backgroundColor: Colors
                        .white, // Set the background color of the FAB
                  ),

                ],
              ),
            ),
            Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _isLandmarkPanelOpen || _isRoutePanelOpen || _isnavigationPannelOpen
                    ? Container()
                    : Semantics(
                  // header: true,
                  sortKey: const OrdinalSortKey(0),
                  child: HomepageSearch(
                    onVenueClicked: onLandmarkVenueClicked,
                    fromSourceAndDestinationPage:
                    fromSourceAndDestinationPage,
                  ),
                )),
            FutureBuilder(
              future: building.landmarkdata,
              builder: (context, snapshot) {
                if (_isLandmarkPanelOpen) {
                  return landmarkdetailpannel(context, snapshot);
                } else {
                  return Container();
                }
              },
            ),

            routeDeatilPannel(),
            navigationPannel(),
            reroutePannel(),
            detected? Semantics(
                child: nearestLandmarkpannel()): Container(),

          ],
        ),
      ),
    );
  }
}
