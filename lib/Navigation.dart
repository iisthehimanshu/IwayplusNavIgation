import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:collection/collection.dart';
import 'package:collection/collection.dart' as pac;
import 'package:fluster/fluster.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:http/http.dart';
import 'package:iwaymaps/API/RatingsaveAPI.dart';
import 'package:iwaymaps/API/waypoint.dart';
import 'package:iwaymaps/DebugToggle.dart';
import 'package:iwaymaps/Elements/DirectionHeader.dart';
import 'package:iwaymaps/Elements/ExploreModeWidget.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/Elements/UserCredential.dart';
import 'package:iwaymaps/VenueSelectionScreen.dart';
import 'package:iwaymaps/dijkastra.dart';
import 'package:iwaymaps/wayPointPath.dart';
import 'package:iwaymaps/waypoint.dart';
import 'package:iwaymaps/websocket/UserLog.dart';
import 'API/DataVersionApi.dart';
import 'API/outBuilding.dart';
import 'APIMODELS/DataVersion.dart';
import 'APIMODELS/outdoormodel.dart';
import 'CLUSTERING/MapHelper.dart';
import 'CLUSTERING/MapMarkers.dart';
import 'DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import 'DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import 'Elements/QRLandmarkScreen.dart';
import 'Elements/locales.dart';
import 'MainScreen.dart';
import 'UserExperienceRatingScreen.dart';
import 'VersioInfo.dart';
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
  String directsourceID = "";
  static bool bluetoothGranted = false;

  Navigation({this.directLandID = '',this.directsourceID = ''});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with TickerProviderStateMixin {
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
  Map<String,Map<int, Set<gmap.Polyline>>> singleroute = {};
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
  pac.PriorityQueue<MapEntry<String, double>> debugPQ = new pac.PriorityQueue();

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
  bool markerSldShown = true;
  Set<Marker> _markers = Set();
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale = '';
  final GlobalKey rerouteButton = GlobalKey();

  //-----------------------------------------------------------------------------------------
  /// Set of displayed markers and cluster markers on the map

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker>? _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 15;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Url image used on normal markers
  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';

  /// Color of the cluster circle
  final Color _clusterColor = Color(0xfffddaa9);

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  /// Example marker coordinates
  final Map<LatLng, String> _markerLocationsMap = {};
  final Map<LatLng, String> _markerLocationsMapLanName = {};

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    final List<MapMarker> markers = [];

    for (LatLng keys in _markerLocationsMap.keys) {
      final String values = _markerLocationsMap[keys]!;
      final String LandmarkValue = _markerLocationsMapLanName[keys]!;

      // Uint8List iconMarker = await getImagesFromMarker('assets/user.png', 45);
      // print("values$values");
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(_markerImageUrl);
      //BitmapDescriptor bb = await getImageMarker(5,Colors.black,Colors.white,60,'Entry','assets/lift.png');

      if (values == 'Lift') {
        Uint8List iconMarker = await getImagesFromMarker('assets/lift.png', 65);
        markers.add(
          MapMarker(
            id: keys.toString(),
            position: keys,
            icon: BitmapDescriptor.fromBytes(iconMarker),
            Landmarkname: LandmarkValue,
            mapController: _googleMapController,
          ),
        );
      } else if (values == 'Entry') {
        Uint8List iconMarker =
            await getImagesFromMarker('assets/log-in.png', 65);
        try {
          markers.add(
            MapMarker(
              id: keys.toString(),
              position: keys,
              icon: BitmapDescriptor.fromBytes(iconMarker),
              Landmarkname: LandmarkValue,
              mapController: _googleMapController,
            ),
          );
        } catch (e) {}
      } else if(values == 'Pharmacy'){
        Uint8List iconMarker = await getImagesFromMarker('assets/hospital.png', 70);
        markers.add(
          MapMarker(
            id: keys.toString(),
            position: keys,
            icon: BitmapDescriptor.fromBytes(iconMarker),
            Landmarkname: LandmarkValue,
            mapController: _googleMapController
          ),
        );
      } else if(values == 'Kitchen'){
        Uint8List iconMarker = await getImagesFromMarker('assets/cutlery.png', 60);
        markers.add(
          MapMarker(
              id: keys.toString(),
              position: keys,
              icon: BitmapDescriptor.fromBytes(iconMarker),
              Landmarkname: LandmarkValue,
              mapController: _googleMapController
          ),
        );
      } else if (values == 'Female') {
        Uint8List iconMarker =
            await getImagesFromMarker('assets/Femaletoilet.png', 65);
        markers.add(
          MapMarker(
            id: keys.toString(),
            position: keys,
            icon: BitmapDescriptor.fromBytes(iconMarker),
            Landmarkname: LandmarkValue,
            mapController: _googleMapController,
          ),
        );
      } else if (values == 'Male') {
        Uint8List iconMarker =
            await getImagesFromMarker('assets/Maletoilet.png', 65);
        markers.add(
          MapMarker(
            id: keys.toString(),
            position: keys,
            icon: BitmapDescriptor.fromBytes(iconMarker),
            Landmarkname: LandmarkValue,
            mapController: _googleMapController,
          ),
        );
      }

      // markers.add(
      //   MapMarker(
      //     id: keys.toString(),
      //     position: keys,
      //     icon: BitmapDescriptor.fromBytes(values=='Lift'? await getImagesFromMarker('assets/lift.png', 45) : await getImagesFromMarker('assets/user.png', 45)),
      //   ),
      // );
    }

    _clusterManager = await MapHelper.initClusterManager(
        markers, _minClusterZoom, _maxClusterZoom, _googleMapController);

    await _updateMarkers11();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers11([double? updatedZoom]) async {
    if (updatedZoom != null && updatedZoom! > 15.5) {
      if (_clusterManager == null || updatedZoom == _currentZoom) return;

      if (updatedZoom != null) {
        _currentZoom = updatedZoom;
      }

      setState(() {
        _areMarkersLoading = true;
      });

      final updatedMarkers = await MapHelper.getClusterMarkers(
          _clusterManager,
          _currentZoom,
          _clusterColor,
          _clusterTextColor,
          70,
          _googleMapController);

      _markers
        ..clear()
        ..addAll(updatedMarkers);

      setState(() {
        _areMarkersLoading = false;
      });
    }
  }

  Future<Uint8List> getIconBytes(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List bytes =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    return bytes;
  }
  //--------------------------------------------------------------------------------------
double _progressValue=0.0;
  @override
  void initState() {
    super.initState();

    //add a timer of duration 5sec
    //PolylineTestClass.polylineSet.clear();
    // StartPDR();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
    _messageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      wsocket.sendmessg();
    });
    setPdrThreshold();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Create the animation
    _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
      ..addListener(() {
        _updateCircle(user.lat, user.lng);
      });

    building.floor.putIfAbsent("", () => 0);
    flutterTts = FlutterTts();
    setState(() {
      isLoading = true;
    });
    print("Circular progress bar");
    //  calibrate();

    //btadapter.strtScanningIos(apibeaconmap);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      speak("${LocaleData.loadingMaps.getString(context)}", _currentLocale);

      apiCalls(context);
    });

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
    print("widget.directLandID");
    print(widget.directLandID);
  }


  Future<void> zoomWhileWait(Map<String, LatLng> allBuildingID, GoogleMapController controller) async {
if(allBuildingID.length>1) {
  while (!user.initialallyLocalised && !building.qrOpened) {
    for (var entry in allBuildingID.entries) {
      if (user.initialallyLocalised || building.qrOpened) {
        return;
      }
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: entry.value, zoom: 16),
      ));
      if (user.initialallyLocalised || building.qrOpened) {
        return;
      }
      await Future.delayed(Duration(milliseconds: 500));
      if (user.initialallyLocalised || building.qrOpened) {
        return;
      }
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: entry.value, zoom: 20),
      ));
      if (user.initialallyLocalised || building.qrOpened) {
        return;
      }
      await Future.delayed(Duration(seconds: 3));
      if (user.initialallyLocalised || building.qrOpened) {
        return;
      }
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: entry.value, zoom: 16),
      ));
      if (user.initialallyLocalised || building.qrOpened) {
        return;
      }
    }

    print("Completed zooming on all locations.");

    // Check the conditions before starting the next loop iteration
    if (user.initialallyLocalised || building.qrOpened) {
      print("Condition met after looping through all locations, stopping.");
      return; // Exit the function if conditions are met
    }
  }
}else{
  if (patch.isNotEmpty) {
    fitPolygonInScreen(patch.first);
  }
}
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
      wsocket.message["deviceInfo"]["deviceManufacturer"] =
          manufacturer.toString();
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
      } else if (manufacturer.toLowerCase().contains("apple")) {
        print("manufacture $manufacturer $step_threshold");
        peakThreshold = 10.111111;
        valleyThreshold = -10.111111;
      }else {
        print("manufacture $manufacturer $step_threshold");
        peakThreshold = 11.111111;
        valleyThreshold = -11.111111;
      }
    } catch (e) {
      throw (e);
    }
  }

  void handleCompassEvents() {
    compassSubscription = FlutterCompass.events!.listen((event) {
      wsocket.message["deviceInfo"]["permissions"]["compass"] = true;
      wsocket.message["deviceInfo"]["sensors"]["compass"] = true;
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
    }, onError: (error) {
      wsocket.message["deviceInfo"]["permissions"]["compass"] = false;
      wsocket.message["deviceInfo"]["sensors"]["compass"] = false;
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
bool disposed=false;
  Future<void> speak(String msg, String lngcode,
      {bool prevpause = false}) async {

    if(!UserState.ttsAllStop){
      if(disposed)return;
      if (prevpause) {
        await flutterTts.pause();
      }

      if (lngcode == "hi") {
        if(Platform.isAndroid){
          await flutterTts
              .setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
        }else{
          await flutterTts
              .setVoice({"name": "Lekha", "locale": "hi-IN"});
        }

      } else {
        await flutterTts.setVoice({"name": "en-US-language", "locale": "en-US"});
      }
      await flutterTts.stop();
      if(Platform.isAndroid){
        await flutterTts.setSpeechRate(0.7);
      }else{
        await flutterTts.setSpeechRate(0.55);
      }

      await flutterTts.setPitch(1.0);
      await flutterTts.speak(msg);
    }

  }

  void checkPermissions() async {
    print("running");
    await requestLocationPermission();
    await requestBluetoothConnectPermission();
    await enableBT();
    //  await requestActivityPermission();
  }

  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) {
      print("enableBTResponse");
      print(value);
    });
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
    pdr.add(accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (pdr == null) {
          return; // Exit the event listener if subscription is canceled
        }
        wsocket.message["deviceInfo"]["permissions"]["activity"] = true;
        wsocket.message["deviceInfo"]["sensors"]["activity"] = true;
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
            DateTime.now().millisecondsSinceEpoch - lastPeakTime >
                peakInterval) {
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
              user.move(context).then((value) {
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
      },
      onError: (error) {
        wsocket.message["deviceInfo"]["permissions"]["activity"] = false;
        wsocket.message["deviceInfo"]["sensors"]["activity"] = false;
      },
    ));
  }

  Future<void> paintMarker(LatLng Location) async {
    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 130);
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
            user.showcoordX.toInt(), user.showcoordY.toInt(), building.patchData[user.Bid]);
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
            tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt(), building.patchData[user.Bid]);
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
            user.move(context).then((value) {
              setState(() {
                if (markers.length > 0) {
                  markers[user.Bid]![0] = customMarker.move(
                      LatLng(
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt(), building.patchData[user.Bid])[0],
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt(), building.patchData[user.Bid])[1]),
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
      String finalvalue =
          tools.angleToClocksForNearestLandmarkToBeacon(value, context);
      // print(finalvalue);
      finalDirections.add(finalvalue);
    }
    return finalDirections;
  }

  void repaintUser(String nearestBeacon) {
    reroute();
    paintUser(nearestBeacon, speakTTS: false);
  }

  String convertTolng(String msg, String lngcode, String finalvalue) {
    if (msg ==
        "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(user.floor)} मंज़िल, ${user.locationName} पर हैं";
      }
    } else if (msg ==
        "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(user.floor)} मंजिल पर हैं, ${user.locationName} आपके ${LocaleData.properties5[finalvalue]?.getString(context)} पर है";
      }
    }
    return "";
  }

  late AnimationController _controller;
  late Animation<double> _animation;
  // land userSetLandmarkMap = land().landmarksMap;


  void paintUser(String? nearestBeacon, {bool speakTTS = true, bool render = true,String? polyID}) async {
    if(widget.directsourceID.length>2){
      nearestBeacon = null;
      polyID = widget.directsourceID;
      widget.directsourceID = '';
    }
    if(nearestBeacon==null && polyID!=null){
      print("Inside");
      Landmarks userSetLocation = Landmarks();
      await building.landmarkdata!.then((value) {
        print("value.landmarksMap");
        value.landmarksMap?.forEach((key, valuee) {
          if(key==polyID){
            userSetLocation = valuee;
          }
        });
        print("userLandmark: ${userSetLocation.name}");
      });
      final Uint8List userloc =
      await getImagesFromMarker('assets/userloc0.png', 130);
      final Uint8List userlocdebug =
      await getImagesFromMarker('assets/tealtorch.png', 35);

      tools.setBuildingAngle(building
          .patchData[userSetLocation.buildingID]!
          .patchData!
          .buildingAngle!);

      //nearestLandmark compute
      nearestLandInfo currentnearest = nearestLandInfo(sId: userSetLocation.sId, buildingID: userSetLocation.buildingID, coordinateX: userSetLocation.coordinateX, coordinateY: userSetLocation.coordinateY, doorX: userSetLocation.doorX, doorY: userSetLocation.doorY, type: userSetLocation.type, floor: userSetLocation.floor, name: userSetLocation.name, updatedAt: userSetLocation.updatedAt, buildingName: userSetLocation.buildingName, venueName: userSetLocation.venueName);
      nearestLandInfomation = currentnearest;

      setState(() {
        buildingAllApi.selectedID = userSetLocation!.buildingID!;
        buildingAllApi.selectedBuildingID = userSetLocation!.buildingID!;
      });

      List<int> localBeconCord = [];
      localBeconCord.add(userSetLocation.coordinateX!);
      localBeconCord.add(userSetLocation.coordinateY!);
      print(
          "check beacon || landmark ${userSetLocation
              .coordinateX} ${userSetLocation.coordinateY}");

      pathState().beaconCords = localBeconCord;

      List<double> values = [];

      //floor alignment
      await building.landmarkdata!.then((land){
        if (land.landmarksMap![polyID]!.floor != 0) {
          List<PolyArray> prevFloorLifts = findLift(
              tools.numericalToAlphabetical(0),
              building.polylinedatamap[
              land.landmarksMap![polyID]!.buildingID!]!.polyline!.floors!);
          List<PolyArray> currFloorLifts = findLift(
              tools.numericalToAlphabetical(
                  land.landmarksMap![polyID]!.floor!),
              building.polylinedatamap[
              land.landmarksMap![polyID]!.buildingID!]!.polyline!.floors!);
          print("print cubicle data");
          for (int i = 0; i < prevFloorLifts.length; i++) {
            print(prevFloorLifts[i].name);
          }
          print("data2");
          for (int i = 0; i < currFloorLifts.length; i++) {
            print(currFloorLifts[i].name);
          }
          List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
          print("dvalue");
          print(dvalue);
          UserState.xdiff = dvalue[0];
          UserState.ydiff = dvalue[1];
          values =
              tools.localtoglobal(land.landmarksMap![polyID]!.coordinateX!,
                  land.landmarksMap![polyID]!.coordinateY!, building.patchData[land.landmarksMap![polyID]!.buildingID!]);
          print(values);
        } else {
          UserState.xdiff = 0;
          UserState.ydiff = 0;
          values =
              tools.localtoglobal(land.landmarksMap![polyID]!.coordinateX!,
                  land.landmarksMap![polyID]!.coordinateY!, building.patchData[land.landmarksMap![polyID]!.buildingID!]);
        }
      });

      print("values");
      print(values);

      mapState.target = LatLng(values[0], values[1]);

      user.Bid = userSetLocation.buildingID!;
      user.locationName = userSetLocation.name;

      //double.parse(apibeaconmap[nearestBeacon]!.properties!.latitude!);

      //double.parse(apibeaconmap[nearestBeacon]!.properties!.longitude!);

      //did this change over here UDIT...
      user.coordX = userSetLocation.coordinateX!;
      user.coordY = userSetLocation.coordinateY!;
      List<double> ls = tools.localtoglobal(user.coordX, user.coordY,
          
          building.patchData[userSetLocation.buildingID]);
      user.lat = ls[0];
      user.lng = ls[1];

      if (nearestLandInfomation != null &&
          nearestLandInfomation!.doorX != null) {
        user.coordX = nearestLandInfomation!.doorX!;
        user.coordY = nearestLandInfomation!.doorY!;
        List<double> latlng = tools.localtoglobal(
            nearestLandInfomation!.doorX!, nearestLandInfomation!.doorY!,
             building.patchData[nearestLandInfomation!.buildingID]);
        print("latlnghhjhj");
        print(latlng);
        user.lat = latlng[0];
        user.lng = latlng[1];
        user.locationName = nearestLandInfomation!.name ??
            nearestLandInfomation!.element!.subType;
      } else if (nearestLandInfomation != null &&
          nearestLandInfomation!.doorX == null) {
        user.coordX = nearestLandInfomation!.coordinateX!;
        user.coordY = nearestLandInfomation!.coordinateY!;
        List<double> latlng = tools.localtoglobal(
            nearestLandInfomation!.coordinateX!,
            nearestLandInfomation!.coordinateY!,
             building.patchData[nearestLandInfomation!.buildingID]);
        print("latlnghhjhj");
        print(latlng);
        user.lat = latlng[0];
        user.lng = latlng[1];
        user.locationName = nearestLandInfomation!.name ??
            nearestLandInfomation!.element!.subType;
      }
      user.showcoordX = user.coordX;
      user.showcoordY = user.coordY;
      UserState.cols = building.floorDimenssion[userSetLocation.buildingID]![userSetLocation.floor]![0];
      UserState.rows = building.floorDimenssion[userSetLocation.buildingID]![userSetLocation.floor]![1];
      UserState.lngCode = _currentLocale;
      UserState.reroute = reroute;
      UserState.closeNavigation = closeNavigation;
      UserState.AlignMapToPath = alignMapToPath;
      UserState.startOnPath = startOnPath;
      UserState.speak = speak;
      UserState.paintMarker = paintMarker;
      UserState.createCircle = updateCircle;
      List<int> userCords = [];
      userCords.add(user.coordX);
      userCords.add(user.coordY);
      List<int> transitionValue = tools.eightcelltransition(user.theta);
      List<int> newUserCord = [
        user.coordX + transitionValue[0],
        user.coordY + transitionValue[1]
      ];
      user.floor = userSetLocation.floor!;
      user.key = userSetLocation.properties!.polyId!;
      user.initialallyLocalised = true;
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);

      // Create the animation
      _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
        ..addListener(() {
          _updateCircle(user.lat, user.lng);
        });
      setState(() {
        markers.clear();
        //List<double> ls=tools.localtoglobal(user.coordX, user.coordY,patchData: building.patchData[apibeaconmap[nearestBeacon]!.buildingID]);
        if (render) {
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
          circles.add(
            Circle(
              circleId: CircleId("circle"),
              center: LatLng(user.lat, user.lng),
              radius: _animation.value,
              strokeWidth: 1,
              strokeColor: Colors.blue,
              fillColor: Colors.lightBlue.withOpacity(0.2),
            ),
          );
        } else {
          user.moveToFloor(userSetLocation.floor!);
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

        building.floor[userSetLocation.buildingID!] =
        userSetLocation.floor!;
        createRooms(
            building.polyLineData!, userSetLocation.floor!);
        building.landmarkdata!.then((value) {
          createMarkers(value, userSetLocation!.floor!,bid: user.Bid);
        });
      });

      double value = 0;
      if (nearestLandInfomation != null) {
        value = tools.calculateAngle2([
          userSetLocation.doorX??userSetLocation.coordinateX!,
          userSetLocation.doorY??userSetLocation.coordinateY!
        ], newUserCord, [
          nearestLandInfomation!.coordinateX!,
          nearestLandInfomation!.coordinateY!
        ]);
      }

      mapState.zoom = 22;
      print("value----l0p[]");
      print(value);
      String? finalvalue = value == 0
          ? null
          : tools.angleToClocksForNearestLandmarkToBeacon(value, context);

      // double value =
      //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
      // print(value);
      // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

      // print("final value");
      // print(finalvalue);
      if (user.isnavigating == false) {
        detected = true;
        if (!_isExploreModePannelOpen && speakTTS) {
          _isBuildingPannelOpen = true;
        }
        nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
      }
      String name = nearestLandInfomation == null
          ? userSetLocation.name!
          : nearestLandInfomation!.name!;
      if (nearestLandInfomation == null) {
        //updating user pointer
        building.floor[buildingAllApi.getStoredString()] = user.floor;
        createRooms(building.polyLineData!,
            building.floor[buildingAllApi.getStoredString()]!);
        if (pathMarkers[user.floor] != null) {
          setCameraPosition(pathMarkers[user.floor]!);
        }
        if (markers.length > 0)
          markers[user.Bid]?[0] =
              customMarker.rotate(0, markers[user.Bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        fitPolygonInScreen(patch.first);

        if (speakTTS) {
          if (finalvalue == null) {
            speak(
                convertTolng(
                    "You are on ${tools.numericalToAlphabetical(
                        user.floor)} floor,${user.locationName}",
                    _currentLocale,
                    ''),
                _currentLocale);
          } else {
            speak(
                convertTolng(
                    "You are on ${tools.numericalToAlphabetical(
                        user.floor)} floor,${user
                        .locationName} is on your ${LocaleData
                        .properties5[finalvalue]?.getString(context)}",
                    _currentLocale,
                    finalvalue),
                _currentLocale);
          }
        }
      } else {
        if (speakTTS) {
          if (finalvalue == null) {
            speak(
                convertTolng(
                    "You are on ${tools.numericalToAlphabetical(
                        user.floor)} floor,${user.locationName}",
                    _currentLocale,
                    ''),
                _currentLocale);
          } else {
            speak(
                convertTolng(
                    "You are on ${tools.numericalToAlphabetical(
                        user.floor)} floor,${user
                        .locationName} is on your ${LocaleData
                        .properties5[finalvalue]?.getString(context)}",
                    _currentLocale,
                    finalvalue),
                _currentLocale);
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


    }else {
      wsocket.message["AppInitialization"]["localizedOn"] = nearestBeacon;
      print("nearestBeacon : $nearestBeacon");



      final Uint8List userloc =
      await getImagesFromMarker('assets/userloc0.png', 130);
      final Uint8List userlocdebug =
      await getImagesFromMarker('assets/tealtorch.png', 35);

      if (apibeaconmap[nearestBeacon] != null) {
        //buildingAngle compute

        tools.setBuildingAngle(building
            .patchData[apibeaconmap[nearestBeacon]!.buildingID]!
            .patchData!
            .buildingAngle!);

        //nearestLandmark compute

        try {
          await building.landmarkdata!.then((value) {
            nearestLandInfomation = tools.localizefindNearbyLandmark(
                apibeaconmap[nearestBeacon]!, value.landmarksMap!);
          });
        } catch (e) {
          print("inside catch");
          print(Exception(e));
        }

        setState(() {
          buildingAllApi.selectedID = apibeaconmap[nearestBeacon]!.buildingID!;
          buildingAllApi.selectedBuildingID =
          apibeaconmap[nearestBeacon]!.buildingID!;
        });

        List<int> localBeconCord = [];
        localBeconCord.add(apibeaconmap[nearestBeacon]!.coordinateX!);
        localBeconCord.add(apibeaconmap[nearestBeacon]!.coordinateY!);
        print(
            "check beacon ${apibeaconmap[nearestBeacon]!
                .coordinateX} ${apibeaconmap[nearestBeacon]!.coordinateY}");

        pathState().beaconCords = localBeconCord;

        List<double> values = [];

        //floor alignment
        if (apibeaconmap[nearestBeacon]!.floor != 0) {
          List<PolyArray> prevFloorLifts = findLift(
              tools.numericalToAlphabetical(0),
              building.polylinedatamap[
              apibeaconmap[nearestBeacon]!.buildingID!]!.polyline!.floors!);
          List<PolyArray> currFloorLifts = findLift(
              tools.numericalToAlphabetical(
                  apibeaconmap[nearestBeacon]!.floor!),
              building.polylinedatamap[
              apibeaconmap[nearestBeacon]!.buildingID!]!.polyline!.floors!);
          print("print cubicle data");
          for (int i = 0; i < prevFloorLifts.length; i++) {
            print(prevFloorLifts[i].name);
          }
          print("data2");
          for (int i = 0; i < currFloorLifts.length; i++) {
            print(currFloorLifts[i].name);
          }
          List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
          print("dvalue");
          print(dvalue);
          UserState.xdiff = dvalue[0];
          UserState.ydiff = dvalue[1];
          values =
              tools.localtoglobal(apibeaconmap[nearestBeacon]!.coordinateX!,
                  apibeaconmap[nearestBeacon]!.coordinateY!, building.patchData[apibeaconmap[nearestBeacon]!.buildingID!]);
          print(values);
        } else {
          UserState.xdiff = 0;
          UserState.ydiff = 0;
          values =
              tools.localtoglobal(apibeaconmap[nearestBeacon]!.coordinateX!,
                  apibeaconmap[nearestBeacon]!.coordinateY!, building.patchData[apibeaconmap[nearestBeacon]!.buildingID!]);
        }
        print("values");
        print(values);

        mapState.target = LatLng(values[0], values[1]);

        user.Bid = apibeaconmap[nearestBeacon]!.buildingID!;
        user.locationName = apibeaconmap[nearestBeacon]!.name;

        //double.parse(apibeaconmap[nearestBeacon]!.properties!.latitude!);

        //double.parse(apibeaconmap[nearestBeacon]!.properties!.longitude!);

        //did this change over here UDIT...
        user.coordX = apibeaconmap[nearestBeacon]!.coordinateX!;
        user.coordY = apibeaconmap[nearestBeacon]!.coordinateY!;
        List<double> ls = tools.localtoglobal(user.coordX, user.coordY,
            
            building.patchData[apibeaconmap[nearestBeacon]!.buildingID]);
        user.lat = ls[0];
        user.lng = ls[1];

        if (nearestLandInfomation != null &&
            nearestLandInfomation!.doorX != null) {
          user.coordX = nearestLandInfomation!.doorX!;
          user.coordY = nearestLandInfomation!.doorY!;
          List<double> latlng = tools.localtoglobal(
              nearestLandInfomation!.doorX!, nearestLandInfomation!.doorY!,
               building.patchData[nearestLandInfomation!.buildingID]);
          print("latlnghhjhj");
          print(latlng);
          user.lat = latlng[0];
          user.lng = latlng[1];
          user.locationName = nearestLandInfomation!.name ??
              nearestLandInfomation!.element!.subType;
        } else if (nearestLandInfomation != null &&
            nearestLandInfomation!.doorX == null) {
          user.coordX = nearestLandInfomation!.coordinateX!;
          user.coordY = nearestLandInfomation!.coordinateY!;
          List<double> latlng = tools.localtoglobal(
              nearestLandInfomation!.coordinateX!,
              nearestLandInfomation!.coordinateY!,
               building.patchData[nearestLandInfomation!.buildingID]);
          print("latlnghhjhj");
          print(latlng);
          user.lat = latlng[0];
          user.lng = latlng[1];
          user.locationName = nearestLandInfomation!.name ??
              nearestLandInfomation!.element!.subType;
        }
        user.showcoordX = user.coordX;
        user.showcoordY = user.coordY;
        UserState.cols = building.floorDimenssion[apibeaconmap[nearestBeacon]!
            .buildingID]![apibeaconmap[nearestBeacon]!.floor]![0];
        UserState.rows = building.floorDimenssion[apibeaconmap[nearestBeacon]!
            .buildingID]![apibeaconmap[nearestBeacon]!.floor]![1];
        UserState.lngCode = _currentLocale;
        UserState.reroute = reroute;
        UserState.closeNavigation = closeNavigation;
        UserState.AlignMapToPath = alignMapToPath;
        UserState.startOnPath = startOnPath;
        UserState.speak = speak;
        UserState.paintMarker = paintMarker;
        UserState.createCircle = updateCircle;
        List<int> userCords = [];
        userCords.add(user.coordX);
        userCords.add(user.coordY);
        List<int> transitionValue = tools.eightcelltransition(user.theta);
        List<int> newUserCord = [
          user.coordX + transitionValue[0],
          user.coordY + transitionValue[1]
        ];
        user.floor = apibeaconmap[nearestBeacon]!.floor!;
        user.key = apibeaconmap[nearestBeacon]!.sId!;
        user.initialallyLocalised = true;
        setState(() {
          markers.clear();
          //List<double> ls=tools.localtoglobal(user.coordX, user.coordY,patchData: building.patchData[apibeaconmap[nearestBeacon]!.buildingID]);
          if (render) {
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
            circles.add(
              Circle(
                circleId: CircleId("circle"),
                center: LatLng(user.lat, user.lng),
                radius: _animation.value,
                strokeWidth: 1,
                strokeColor: Colors.blue,
                fillColor: Colors.lightBlue.withOpacity(0.2),
              ),
            );
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
              building.polylinedatamap[
              user.Bid]!, apibeaconmap[nearestBeacon]!.floor!);
          building.landmarkdata!.then((value) {
            createMarkers(value, apibeaconmap[nearestBeacon]!.floor!,bid: user.Bid);
          });
        });

        double value = 0;
        if (nearestLandInfomation != null) {
          value = tools.calculateAngle2([
            user.coordX,user.coordY
          ], newUserCord, [
            nearestLandInfomation!.coordinateX!,
            nearestLandInfomation!.coordinateY!
          ]);
        }

        mapState.zoom = 22;
        print("value----");

        print(value);
        if(value<45){
          value = value + 45;
        }
        String? finalvalue = value == 0
            ? null
            : tools.angleToClocksForNearestLandmarkToBeacon(value, context);

        // double value =
        //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
        // print(value);
        // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);

        // print("final value");
        // print(finalvalue);
        if (user.isnavigating == false) {
          detected = true;
          if (!_isExploreModePannelOpen && speakTTS) {
            _isBuildingPannelOpen = true;
          }
          nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
        }
        String name = nearestLandInfomation == null
            ? apibeaconmap[nearestBeacon]!.name!
            : nearestLandInfomation!.name!;
        if (nearestLandInfomation == null) {
          //updating user pointer
          building.floor[buildingAllApi.getStoredString()] = user.floor;
          createRooms(building.polyLineData!,
              building.floor[buildingAllApi.getStoredString()]!);
          if (pathMarkers[user.floor] != null) {
            setCameraPosition(pathMarkers[user.floor]!);
          }
          if (markers.length > 0)
            markers[user.Bid]?[0] =
                customMarker.rotate(0, markers[user.Bid]![0]);
          if (user.initialallyLocalised) {
            mapState.interaction = !mapState.interaction;
          }
          fitPolygonInScreen(patch.first);

          if (speakTTS) {
            if (finalvalue == null) {
              speak(
                  convertTolng(
                      "You are on ${tools.numericalToAlphabetical(
                          user.floor)} floor,${user.locationName}",
                      _currentLocale,
                      ''),
                  _currentLocale);
            } else {
              speak(
                  convertTolng(
                      "You are on ${tools.numericalToAlphabetical(
                          user.floor)} floor,${user
                          .locationName} is on your ${LocaleData
                          .properties5[finalvalue]?.getString(context)}",
                      _currentLocale,
                      finalvalue),
                  _currentLocale);
            }
          }
        } else {
          if (speakTTS) {
            if (finalvalue == null) {
              speak(
                  convertTolng(
                      "You are on ${tools.numericalToAlphabetical(
                          user.floor)} floor,${user.locationName}",
                      _currentLocale,
                      ''),
                  _currentLocale);
            } else {
              speak(
                  convertTolng(
                      "You are on ${tools.numericalToAlphabetical(
                          user.floor)} floor,${user
                          .locationName} is on your ${LocaleData
                          .properties5[finalvalue]?.getString(context)}",
                      _currentLocale,
                      finalvalue),
                  _currentLocale);
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
        if (speakTTS) {
          speak("${LocaleData.unabletofindyourlocation.getString(context)}.....${LocaleData.scanQr.getString(context)}",
              _currentLocale);
          showLocationDialog(context);
          building.qrOpened = true;
        }
      }
      if (widget.directLandID.isNotEmpty) {
        print("checkdirectLandID");
        onLandmarkVenueClicked(
            widget.directLandID, DirectlyStartNavigation: true);
      }
    }
  }
  bool _isExpanded = false;
  String? qrText;


  void showLocationDialog(BuildContext context) {
    Future.delayed(Duration(milliseconds: 2000)).then((value){
      //speak("${LocaleData.scanQr.getString(context)}", _currentLocale);
      double screenWidth = MediaQuery.of(context).size.width;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: EdgeInsets.only(top:20,left:15,right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Choose Your Location",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "We couldn't detect your location",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffa1a1aa),
                      height: 20/14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: screenWidth,
                    child: TextField(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DestinationSearchPage(hintText: 'Source location',voiceInputEnabled: false,userLocalized: user.key,))
                        ).then((value){
                          setState(() {
                            //widget.SourceID = value;
                            print("dataPOpped:$value");

                            if(value!=null){
                              Navigator.of(context).pop();
                              paintUser(null,polyID: value);
                            }else{
                              print("selectionvalnotempty");
                            }

                            // SourceName = landmarkData.landmarksMap![value]!.name!;
                            // if(widget.SourceID != "" && widget.DestinationID != ""){
                            //   print("h3");
                            //   Navigator.pop(context,[widget.SourceID,widget.DestinationID]);
                            // }
                          });
                        });
                      },

                      decoration: InputDecoration(
                        hintText: 'Search your current location',
                        hintStyle: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffa1a1aa),
                          height: 20/14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.teal,width: 1),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.teal, width: 1),
                        ),

                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0), // Adjust vertical padding to center text

                      ),
                      textAlign: TextAlign.center, // Center the text and hint

                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Or",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffa0a0a0),
                      height: 20/14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Scan the Nearby QR Code",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff18181b),
                      height: 25/16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                        // Navigator.of(context).pop();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QRViewExample()),
                        ).then((value){
                          print("navigation polyID $value");
                          setState(() {
                            isLoading = false;
                            isBlueToothLoading = false;
                          });
                          paintUser(null,polyID: value);
                        });
                        //Navigator.of(context).pop();
                        // if (result != null) {
                        //   setState(() {
                        //     qrText = result;
                        //   });
                        //   print('QR Code: $qrText');
                        //   // Handle the scanned QR code text
                        // }else{
                        //   print("resultNull");
                        // }
                      },
                      child: AnimatedContainer(
                        duration: Duration(seconds: 3),
                        width: _isExpanded ? 120 : 80,
                        height: _isExpanded ? 120 : 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.qr_code_scanner, size: 50, color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text('Skip', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });


  }

  void moveUser() async {
    print("User is moving");
    final Uint8List userloc =
        await getImagesFromMarker('assets/userloc0.png', 130);
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

  void autoreroute() {
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      fitPolygonInScreen(patch.first);
    });
    Future.delayed(Duration(seconds: 3)).then((value) {
      if (!rerouting) {
        setState(() {
          rerouting = true;
        });
        //  if(user.isnavigating==false){
        clearPathVariables();
        // }

        PathState.clear();
        PathState.sourceX = user.coordX;
        PathState.sourceY = user.coordY;
        user.showcoordX = user.coordX;
        user.showcoordY = user.coordY;
        PathState.sourceFloor = user.floor;
        PathState.sourceName = "Your current location";
        building.landmarkdata!.then((value) async {
          await calculateroute(value.landmarksMap!).then((value) {
            if (PathState.path.isNotEmpty) {
              user.pathobj = PathState;
              user.path = [
                ...PathState.path[PathState.sourceFloor]!,
                ...PathState.path[PathState.destinationFloor]!,
              ];
              user.Cellpath = PathState.singleCellListPath;
              user.pathobj.index = 0;
              user.isnavigating = true;
              user.temporaryExit = false;
              user.moveToStartofPath().then((value) {
                setState(() {
                  if (markers.length > 0) {
                    markers[user.Bid]?[0] = customMarker.move(
                        LatLng(
                            tools.localtoglobal(user.showcoordX.toInt(),
                                user.showcoordY.toInt(), building.patchData[user.Bid])[0],
                            tools.localtoglobal(user.showcoordX.toInt(),
                                user.showcoordY.toInt(), building.patchData[user.Bid])[1]),
                        markers[user.Bid]![0]);
                  }
                });
              });
              _isRoutePanelOpen = false;
              building.selectedLandmarkID = null;
              _isnavigationPannelOpen = true;
              _isreroutePannelOpen = false;
              int numCols = building.floorDimenssion[PathState.sourceBid]![
                  PathState.sourceFloor]![0]; //floor length
              double angle = tools.calculateAngleBWUserandPath(
                  user, PathState.path[PathState.sourceFloor]![1], numCols);
              if (angle != 0) {
                speak(
                    "${LocaleData.turn.getString(context)} " +
                        LocaleData.getProperty5(
                            tools.angleToClocks(angle, context), context),
                    _currentLocale);
              } else {}

              mapState.tilt = 50;

              mapState.bearing = tools.calculateBearing([
                user.lat,
                user.lng
              ], [
                PathState.singleCellListPath[user.pathobj.index + 1].lat,
                PathState.singleCellListPath[user.pathobj.index + 1].lng
              ]);
              _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: mapState.target,
                    zoom: mapState.zoom,
                    bearing: mapState.bearing!,
                    tilt: mapState.tilt),
              ));
            } else {
              setState(() {
                _isreroutePannelOpen = false;
                _isLandmarkPanelOpen = false;
                _isBuildingPannelOpen = false;
                _isRoutePanelOpen = true;
              });
            }
          });
        });
        rerouting = false;
      }
    });
  }

  void reroute() {
    _isnavigationPannelOpen = false;
    _isRoutePanelOpen = false;
    _isLandmarkPanelOpen = false;
    _isreroutePannelOpen = true;
    user.isnavigating = false;
    user.temporaryExit = true;
    print("reroute----- coord ${user.coordX},${user.coordY}");
    print("reroute----- show ${user.showcoordX},${user.showcoordY}");
    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;
    setState(() {
      if (markers.length > 0) {
        List<double> dvalue =
            tools.localtoglobal(user.coordX.toInt(), user.coordY.toInt(), building.patchData[user.Bid]);
        markers[user.Bid]?[0] = customMarker.move(
            LatLng(dvalue[0], dvalue[1]), markers[user.Bid]![0]);
      }
    });
    FlutterBeep.beep();
    speak("${LocaleData.reroute.getString(context)}",
        _currentLocale);

    autoreroute();
  }

  Future<void> requestBluetoothConnectPermission() async {
    final PermissionStatus permissionStatus =
        await Permission.bluetoothScan.request();
    print("permissionStatus    ----   ${permissionStatus}");
    print("permissionStatus    ----   ${permissionStatus.isDenied}");

    if (permissionStatus.isGranted) {
      wsocket.message["deviceInfo"]["permissions"]["BLE"] = true;
      wsocket.message["deviceInfo"]["sensors"]["BLE"] = true;
      print("Bluetooth permission is granted");
      //widget.bluetoothGranted = true;
      // Permission granted, you can now perform Bluetooth operations
    } else {
      wsocket.message["deviceInfo"]["permissions"]["BLE"] = false;
      wsocket.message["deviceInfo"]["sensors"]["BLE"] = false;

      // Permission denied, handle accordingly
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      wsocket.message["deviceInfo"]["permissions"]["location"] = true;
      wsocket.message["deviceInfo"]["sensors"]["location"] = true;
      print('location permission granted');
    } else {
      wsocket.message["deviceInfo"]["permissions"]["location"] = false;
      wsocket.message["deviceInfo"]["sensors"]["location"] = false;
    }
  }

  List<FilterInfoModel> landmarkListForFilter = [];
  bool isLoading = false;
  HashMap<String, beacon> resBeacons = HashMap();
  bool isBlueToothLoading = false;
  // Initially set to true to show loader
void _updateProgress(){
  const onsec=const Duration(seconds: 1);
  Timer.periodic(onsec,(Timer t){
      setState(() {
        _progressValue+=0.08;
        if(_progressValue.toStringAsFixed(1)=='1.0'){
          t.cancel();
          return;
        }
      });
  });
}
  void apiCalls(context) async {
    await DataVersionApi().fetchDataVersionApiData(buildingAllApi.selectedBuildingID);

    _updateProgress();
    await Future.wait(buildingAllApi.allBuildingID.entries.map((entry) async {
      var key = entry.key;

      var beaconData = await beaconapi().fetchBeaconData(key);
      if (building.beacondata == null) {
        building.beacondata = List.from(beaconData);
      } else {
        building.beacondata = List.from(building.beacondata!)..addAll(beaconData);
      }

      for (var beacon in beaconData) {
        if (beacon.name != null) {
          apibeaconmap[beacon.name!] = beacon;
        }
      }
      Building.apibeaconmap = apibeaconmap;
    }));
    if(Platform.isAndroid){
      btadapter.startScanning(apibeaconmap);
    }else{
      btadapter.startScanningIOS(apibeaconmap);
    }
    Future<void> timer = Future.delayed(Duration(seconds:(widget.directsourceID.length<2)? 9:0));

    setState(() {
      resBeacons = apibeaconmap;
    });

    var patchData = await patchAPI().fetchPatchData(id: buildingAllApi.selectedBuildingID);
    building.patchData[patchData.patchData!.buildingID!] = patchData;
    createPatch(patchData);
    findCentroid(patchData.patchData!.coordinates!, buildingAllApi.selectedBuildingID);
    tools.globalData = patchData;
    tools.setBuildingAngle(patchData.patchData!.buildingAngle!);

    for (var i = 0; i < 4; i++) {
      tools.corners.add(math.Point(
          double.parse(patchData.patchData!.coordinates![i].globalRef!.lat!),
          double.parse(patchData.patchData!.coordinates![i].globalRef!.lng!)
      ));
    }

    var polylineData = await PolyLineApi().fetchPolyData(id: buildingAllApi.selectedBuildingID);
    building.polyLineData = polylineData;
    building.numberOfFloors[buildingAllApi.selectedBuildingID] = polylineData.polyline!.floors!.length;
    building.polylinedatamap[buildingAllApi.selectedBuildingID] = polylineData;

    List<int> currentBuildingFloor = polylineData.polyline!.floors!.map((element) {
      return tools.alphabeticalToNumerical(element.floor!);
    }).toList();

    Building.numberOfFloorsDelhi[buildingAllApi.selectedBuildingID] = currentBuildingFloor;
    createRooms(polylineData, 0);

    building.floor[buildingAllApi.selectedBuildingID] = buildingAllApi.selectedBuildingID == "666848685496124d04fc6761" ? 5 : 0;

    var landmarkData = await landmarkApi().fetchLandmarkData(id: buildingAllApi.selectedBuildingID);
    building.landmarkdata = Future.value(landmarkData);
    var coordinates = <int, LatLng>{};

    for (var landmark in landmarkData.landmarks!) {
      if (landmark.floor == 3 && landmark.properties!.name != null) {
        landmarkListForFilter.add(FilterInfoModel(
            LandmarkLat: landmark.coordinateX!,
            LandmarkLong: landmark.coordinateY!,
            LandmarkName: landmark.properties!.name ?? ""
        ));
      }

      if (landmark.element!.subType == "AR") {
        coordinates[int.parse(landmark.properties!.arValue!)] = LatLng(
            double.parse(landmark.properties!.latitude!),
            double.parse(landmark.properties!.longitude!)
        );
      }

      if (landmark.element!.type == "Floor") {
        var nonWalkableGrids = landmark.properties!.nonWalkableGrids!.join(',');
        var regExp = RegExp(r'\d+');
        var matches = regExp.allMatches(nonWalkableGrids);
        var allIntegers = matches.map((match) => int.parse(match.group(0)!)).toList();

        var currentNonWalkable = building.nonWalkable[landmark.buildingID!] ?? {};
        currentNonWalkable[landmark.floor!] = allIntegers;

        building.nonWalkable[landmark.buildingID!] = currentNonWalkable;
        UserState.nonWalkable = building.nonWalkable;
        localizedData.nonWalkable = currentNonWalkable;

        var currentFloorDimensions = building.floorDimenssion[buildingAllApi.selectedBuildingID] ?? {};
        currentFloorDimensions[landmark.floor!] = [
          landmark.properties!.floorLength!,
          landmark.properties!.floorBreadth!
        ];

        building.floorDimenssion[buildingAllApi.selectedBuildingID] = currentFloorDimensions;
        localizedData.currentfloorDimenssion = currentFloorDimensions;
      }
    }

    createARPatch(coordinates);
    createMarkers(landmarkData, 0, bid: buildingAllApi.selectedBuildingID);

    await Future.delayed(Duration(seconds: 2));
    speak("${LocaleData.searchingyourlocation.getString(context)}", _currentLocale);

    setState(() {
      isBlueToothLoading = true;
    });


    List<String> ids = buildingAllApi.getStoredAllBuildingID().keys.toList();

    try {
      var outBuildingData = await outBuilding().outbuilding(ids);
      if (outBuildingData != null) {
        buildingAllApi.outdoorID = outBuildingData.data!.campusId!;
        buildingAllApi.allBuildingID[outBuildingData.data!.campusId!] = LatLng(0.0, 0.0);
      }
    } catch (_) {}

    Future<void> allBuildingCalls = Future.wait(buildingAllApi.getStoredAllBuildingID().entries.map((entry) async {
      var key = entry.key;

      building.floor[key] = 0;

      try {
        var waypointData = await waypointapi().fetchwaypoint(key);
        Building.waypoint[key] = waypointData;
      } catch (_) {}

      if (key != buildingAllApi.getSelectedBuildingID()) {
        try {
          await DataVersionApi().fetchDataVersionApiData(key);
        }catch(e){

        }


        var patchData = await patchAPI().fetchPatchData(id: key);
        building.patchData[patchData.patchData!.buildingID!] = patchData;
        if (key == buildingAllApi.outdoorID || buildingAllApi.outdoorID.isEmpty) {
          createotherPatch(patchData);
        }else{
          findCentroid(patchData.patchData!.coordinates!, key);
        }



        var polylineData = await PolyLineApi().fetchPolyData(id: key);
        building.polylinedatamap[key] = polylineData;
        building.numberOfFloors[key] = polylineData.polyline!.floors!.length;

        List<int> currentBuildingFloor = polylineData.polyline!.floors!.map((element) {
          return tools.alphabeticalToNumerical(element.floor!);
        }).toList();

        Building.numberOfFloorsDelhi[key] = currentBuildingFloor;

        if (key == buildingAllApi.outdoorID) {
          createRooms(polylineData, 1);
        } else {
          createRooms(polylineData, 0);
        }

        var otherLandmarkData = await landmarkApi().fetchLandmarkData(id: key);
        var otherLandmarkdata = await building.landmarkdata;
        otherLandmarkdata?.mergeLandmarks(otherLandmarkData.landmarks);

        var otherCoordinates = <int, LatLng>{};
        for (var landmark in otherLandmarkData.landmarks!) {
          if (landmark.element!.subType == "AR" && landmark.properties!.arName == "P${int.parse(landmark.properties!.arValue!)}") {
            otherCoordinates[int.parse(landmark.properties!.arValue!)] = LatLng(
                double.parse(landmark.properties!.latitude!),
                double.parse(landmark.properties!.longitude!)
            );
          }

          if (landmark.element!.type == "Floor") {
            var nonWalkableGrids = landmark.properties!.nonWalkableGrids!.join(',');
            var regExp = RegExp(r'\d+');
            var matches = regExp.allMatches(nonWalkableGrids);
            var allIntegers = matches.map((match) => int.parse(match.group(0)!)).toList();

            var currentNonWalkable = building.nonWalkable[key] ?? {};
            currentNonWalkable[landmark.floor!] = allIntegers;

            building.nonWalkable[key] = currentNonWalkable;

            var currentFloorDimensions = building.floorDimenssion[key] ?? {};
            currentFloorDimensions[landmark.floor!] = [
              landmark.properties!.floorLength!,
              landmark.properties!.floorBreadth!
            ];

            building.floorDimenssion[key] = currentFloorDimensions;
          }
        }

        createMarkers(otherLandmarkData, 0, bid: key);
        createotherARPatch(otherCoordinates, otherLandmarkData.landmarks![0].buildingID!);
      }
    }));
    print("before Calling localize user");

    await Future.wait([timer,allBuildingCalls]);
    print("Calling localize user");
    localizeUser();
    buildingAllApi.setStoredString(buildingAllApi.getSelectedBuildingID());

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      isLoading = false;
      isBlueToothLoading = false;
    });

  }

  var versionBox = Hive.box('VersionData');
  final DataVersionLocalModelBox = DataVersionLocalModelBOX.getData();

  void findCentroid(List<Coordinates> vertices, String bid) {
    double xSum = 0;
    double ySum = 0;
    int n = vertices.length;

    for (Coordinates vertex in vertices) {
      xSum += double.parse(vertex.globalRef!.lat!);
      ySum += double.parse(vertex.globalRef!.lng!);
    }

    Building.allBuildingID[bid] = LatLng(xSum / n, ySum / n);
  }


  void _updateCircle(double lat, double lng) {
    // Create a new Tween with the provided begin and end values
    // Optionally update UI or logic with animation value
    final Circle updatedCircle = Circle(
      circleId: CircleId("circle"),
      center: LatLng(lat, lng),
      radius: _animation.value,
      strokeWidth: 1,
      strokeColor: Colors.blue,
      fillColor: Colors.lightBlue.withOpacity(0.2),
    );
if(mounted){
  setState(() {
    circles.removeWhere((circle) => circle.circleId == CircleId("circle"));
    circles.add(updatedCircle);
  });
}

  }

  void updateCircle(double lat, double lng,
      {double begin = 7, double end = 0}) {
    // Create a new Tween with the provided begin and end values
    _animation = Tween<double>(begin: begin, end: end).animate(_controller)
      ..addListener(() {
        // Optionally update UI or logic with animation value
        final Circle updatedCircle = Circle(
          circleId: CircleId("circle"),
          center: LatLng(lat, lng),
          radius: _animation.value,
          strokeWidth: 1,
          strokeColor: Colors.blue,
          fillColor: Colors.lightBlue.withOpacity(0.2),
        );

        setState(() {
          circles
              .removeWhere((circle) => circle.circleId == CircleId("circle"));
          circles.add(updatedCircle);
        });
      });
    // Start the animation
    _controller.forward(from: 0.0);
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

  nearestLandInfo? nearestLandInfomation;

  Future<void> localizeUser() async {
    print("Beacon searching started");
    double highestweight = 0;
    String nearestBeacon = "";
    print("btadapter.BIN");
    print(btadapter.BIN);

    if(await FlutterBluePlus.isOn){
      for (int i = 0; i < btadapter.BIN.length; i++) {
        if (btadapter.BIN[i]!.isNotEmpty) {
          btadapter.BIN[i]!.forEach((key, value) {
            if(value<0){
              value = value * -1;
            }
            if (value > highestweight) {
              highestweight = value;
              nearestBeacon = key;
            }
          });
          break;
        }
      }
    }


    setState(() {
      //lastBeaconValue = nearestBeacon;
    });

    // nearestLandmarkToBeacon = nearestBeacon;
    // nearestLandmarkToMacid = highestweight.toString();

    setState(() {
      testBIn = btadapter.BIN;
      testBIn.forEach((key, value) {
        currentBinSIze.add(value.length);
      });
    });
    btadapter.stopScanning();
    print("nearestbeacon $nearestBeacon");
    // sumMap = btadapter.calculateAverage();
    if(nearestBeacon != ""){
      buildingAllApi.setStoredString(Building.apibeaconmap[nearestBeacon]!.buildingID!);
      buildingAllApi.selectedID = Building.apibeaconmap[nearestBeacon]!.buildingID!;
      buildingAllApi.selectedBuildingID = Building.apibeaconmap[nearestBeacon]!.buildingID!;
    }
    paintUser(nearestBeacon);
    Future.delayed(Duration(milliseconds: 1500)).then((value) => {
      _controller.stop(),
    });

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
          sortedsumMap.entries.first.value >= 0.4) {
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

  Map<int, List<Nodes>> extractWaypoint(polylinedata polyline) {
    Map<int, List<Nodes>> wayPoints = {};
    polyline.polyline!.floors!.forEach((floor) {
      floor.polyArray!.forEach((element) {
        if (element.polygonType!.toLowerCase() == "waypoints") {
          wayPoints.putIfAbsent(
              tools.alphabeticalToNumerical(element.floor!), () => []);
          wayPoints[tools.alphabeticalToNumerical(element.floor!)]!
              .addAll(element.nodes!);
        }
      });
    });
    print("waypoint $wayPoints");
    return wayPoints;
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

  Set<Polygon> _polygon = Set();

  Future<void> addselectedRoomMarker(List<LatLng> polygonPoints) async {
    selectedroomMarker.clear(); // Clear existing markers
    _polygon.clear(); // Clear existing markers
   // circles.clear();
    print("WilsonInSelected");
    print(polygonPoints);
    _polygon.add(Polygon(
      polygonId: PolygonId("$polygonPoints"),
      points: polygonPoints,
      fillColor: Colors.lightBlueAccent.withOpacity(0.4),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    )); // Clear existing markers
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
    _googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 0))
        .then((value) {
      return;
    });
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
          200.0, // padding to adjust the bounding box on the screen
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
          200.0, // padding to adjust the bounding box on the screen
        ),
      );
    }
  }

  void setCameraPositionusingCoords(List<LatLng> selectedroomMarker1,
      {List<LatLng>? selectedroomMarker2 = null}) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;

    if (selectedroomMarker2 == null) {
      for (LatLng marker in selectedroomMarker1) {
        double lat = marker.latitude;
        double lng = marker.longitude;

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
          200.0, // padding to adjust the bounding box on the screen
        ),
      );
    } else {
      for (LatLng marker in selectedroomMarker1) {
        double lat = marker.latitude;
        double lng = marker.longitude;

        minLat = math.min(minLat, lat);
        minLng = math.min(minLng, lng);
        maxLat = math.max(maxLat, lat);
        maxLng = math.max(maxLng, lng);
      }
      for (LatLng marker in selectedroomMarker2) {
        double lat = marker.latitude;
        double lng = marker.longitude;

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
          200.0, // padding to adjust the bounding box on the screen
        ),
      );
    }
  }

  List<PolyArray> findLift(String floor, List<Floors> floorData) {
    List<PolyArray> lifts = [];
    floorData.forEach((Element) {
      if (Element.floor == floor) {
        Element.polyArray!.forEach((element) {
          if (element.name!.toLowerCase().contains("lift")) {
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

        if (l1.name!.toLowerCase().contains("lift") &&
            l2.name!.toLowerCase().contains("lift") &&
            l1.name!.length>4&&
            l1.name == l2.name) {
          print("iiiii ${l1.cubicleName}");
          print("yyyyyy ${l2.cubicleName}");
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
          print("checkingLift");
          print(diff);
          print(l2.id);

          print("11 ${[x1, y1]}");
          print("22 ${[x2, y2]}");
        }
      }
    }
    return diff;
  }

  Future<void> createRooms(polylinedata value, int floor)async{
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
          if (polyArray.visibilityType == "visible" &&
              polyArray.polygonType != "Waypoints") {
            List<LatLng> coordinates = [];

            for (Nodes node in polyArray.nodes!) {
              //coordinates.add(LatLng(node.lat!,node.lon!));
              coordinates.add(LatLng(
                  tools.localtoglobal(node.coordx!, node.coordy!,
                      
                          building.patchData[value.polyline!.buildingID])[0],
                  tools.localtoglobal(node.coordx!, node.coordy!,
                      
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
    return;
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
  Future<BitmapDescriptor> bitmapDescriptorFromTextAndImage(String text, String imagePath, {Size imageSize = const Size(50, 50)}) async {
    print("bitmapDescriptorFromTextAndImage $text");
    // Load the base marker image
    final ByteData baseImageBytes = await rootBundle.load(imagePath);
    final ui.Codec markerImageCodec = await ui.instantiateImageCodec(baseImageBytes.buffer.asUint8List(), targetWidth: imageSize.width.toInt(), targetHeight: imageSize.height.toInt());
    final ui.FrameInfo markerImageFrame = await markerImageCodec.getNextFrame();
    final ui.Image markerImage = markerImageFrame.image;

    // Set the text style and layout
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 30.0, // Increased font size
        color: Colors.black,
      ),
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );

    // Calculate the overall canvas size
    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;
    final double canvasWidth = textWidth > imageSize.width ? textWidth : imageSize.width;
    final double canvasHeight = textHeight + imageSize.height + 20.0; // Increased padding

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Draw the text centered above the marker image
    final double textX = (canvasWidth - textWidth) / 2;
    final double textY = 0.0;
    textPainter.paint(canvas, Offset(textX, textY));

    // Draw the base marker image below the text
    final double imageX = (canvasWidth - imageSize.width) / 2;
    final double imageY = textHeight + 10.0; // Padding between text and image
    canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());

    // Generate the final image
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );

    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes!);
  }

  void createMarkers(land _landData, int floor, {String? bid}) async {
    print("Markercleared");
    print(Markers.length);
    _markers.clear();
    _markerLocationsMap.clear();
    _markerLocationsMapLanName.clear();
    Markers.removeWhere((marker)=>marker.markerId.value.contains(bid??buildingAllApi.selectedBuildingID));
    List<Landmarks> landmarks = _landData.landmarks!;
    try {
      for (int i = 0; i < landmarks.length; i++) {
        if (landmarks[i].floor == floor &&
            landmarks[i].buildingID ==
                (bid ?? buildingAllApi.selectedBuildingID)) {
          if (landmarks[i].element!.type == "Rooms" &&
              landmarks[i].element!.subType != "main entry" &&
              landmarks[i].coordinateX != null &&
              !landmarks[i].wasPolyIdNull!) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );
            final Uint8List iconMarker =
            await getImagesFromMarker('assets/pin.png', 50);
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!,
                building.patchData[bid ?? buildingAllApi.getStoredString()]);
            //_markerLocations.add(LatLng(value[0],value[1]));
            BitmapDescriptor textMarker;
            String markerText;
            // String splitOption;
            // if(landmarks[i].name!.contains('-')){
            //   splitOption = '-';
            // }else if(landmarks[i].name!.contains(' ')){
            //   splitOption = ' ';
            // }
            List<String> parts = landmarks[i].name!.split('-');
            print("parts $parts");
            markerText = parts.isNotEmpty ? parts[0].trim() : '';
            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/pin.png');


            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i]
                        .buildingID}"),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 0.5),
                visible: false,
                onTap: () {
                  print("Info Window");
                },
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
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
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!, landmarks[i].coordinateY!,

                  building.patchData[bid ?? buildingAllApi.getStoredString()]);
              Markers.add(Marker(
                  markerId: MarkerId(
                      "Door ${landmarks[i].properties!.polyId} ${landmarks[i]
                          .buildingID}"),
                  position: LatLng(value[0], value[1]),
                  icon: BitmapDescriptor.fromBytes(iconMarker),
                  visible: false,
                  infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: 'Additional Information',
                    // Replace with additional information
                    onTap: () {
                      if (building.selectedLandmarkID !=
                          landmarks[i].properties!.polyId) {
                        building.selectedLandmarkID =
                            landmarks[i].properties!.polyId;
                        _isRoutePanelOpen = false;
                        singleroute.clear();
                        //realWorldPath.clear();
                        _isLandmarkPanelOpen = true;
                        addselectedMarker(LatLng(value[0], value[1]));
                      }
                    },
                  )));
            });
          } else if (landmarks[i].name != null &&
              landmarks[i].element!.type == ("FloorConnection") &&
              landmarks[i].element!.subType == "lift") {
            final Uint8List iconMarker =
            await getImagesFromMarker('assets/entry.png', 75);

            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!, landmarks[i].coordinateY!,

                  building.patchData[bid ?? buildingAllApi.getStoredString()]);

              // _markerLocations[LatLng(value[0], value[1])] = '1';
              _markerLocationsMap[LatLng(value[0], value[1])] = 'Lift';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
              landmarks[i].name!;
              // _markers!.add(Marker(
              //   markerId: MarkerId("Lift ${landmarks[i].properties!.polyId}"),
              //   position: LatLng(value[0], value[1]),
              //   icon: BitmapDescriptor.fromBytes(iconMarker),
              // ));

              // Markers.add(Marker(
              //     markerId: MarkerId("Lift ${landmarks[i].properties!.polyId}"),
              //     position: LatLng(value[0], value[1]),
              //     icon: BitmapDescriptor.fromBytes(iconMarker),
              //     visible: false,
              //     infoWindow: InfoWindow(
              //       title: landmarks[i].name,
              //       snippet: 'Additional Information',
              //       // Replace with additional information
              //       onTap: () {
              //         if (building.selectedLandmarkID !=
              //             landmarks[i].properties!.polyId) {
              //           building.selectedLandmarkID =
              //               landmarks[i].properties!.polyId;
              //           _isRoutePanelOpen = false;
              //           singleroute.clear();
              //           _isLandmarkPanelOpen = true;
              //           addselectedMarker(LatLng(value[0], value[1]));
              //         }
              //       },
              //     ))
              // );
            });
          } else if (landmarks[i].name != null &&
              landmarks[i].name!.toLowerCase().contains("pharmacy")) {
            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!, landmarks[i].coordinateY!,
                  building.patchData[bid ?? buildingAllApi.getStoredString()]);
              _markerLocationsMap[LatLng(value[0], value[1])] = 'Pharmacy';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
              landmarks[i].name!;
            });
          }
          // else if (landmarks[i].name != null &&
          //     landmarks[i].name!.toLowerCase().contains("kitchen")) {
          //   print("Kitchen");
          //   setState(() {
          //     List<double> value = tools.localtoglobal(
          //         landmarks[i].coordinateX!, landmarks[i].coordinateY!,
          //         building.patchData[bid ?? buildingAllApi.getStoredString()]);
          //     _markerLocationsMap[LatLng(value[0], value[1])] = 'Kitchen';
          //     _markerLocationsMapLanName[LatLng(value[0], value[1])] =
          //     landmarks[i].name!;
          //   });
          // }
          else if (landmarks[i].properties!.washroomType != null &&
              landmarks[i].properties!.washroomType == "Male") {
            final Uint8List iconMarker =
            await getImagesFromMarker('assets/6.png', 65);
            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!, landmarks[i].coordinateY!,

                  building.patchData[bid ?? buildingAllApi.getStoredString()]);
              _markerLocationsMap[LatLng(value[0], value[1])] = 'Male';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
              landmarks[i].name!;
              // Markers.add(Marker(
              //     markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
              //     position: LatLng(value[0], value[1]),
              //     icon: BitmapDescriptor.fromBytes(iconMarker),
              //     visible: false,
              //     infoWindow: InfoWindow(
              //       title: landmarks[i].name,
              //       snippet: 'Additional Information',
              //       // Replace with additional information
              //       onTap: () {
              //         if (building.selectedLandmarkID !=
              //             landmarks[i].properties!.polyId) {
              //           building.selectedLandmarkID =
              //               landmarks[i].properties!.polyId;
              //           _isRoutePanelOpen = false;
              //           singleroute.clear();
              //           _isLandmarkPanelOpen = true;
              //           addselectedMarker(LatLng(value[0], value[1]));
              //         }
              //       },
              //     )));
            });
          } else if (landmarks[i].properties!.washroomType != null &&
              landmarks[i].properties!.washroomType == "Female") {
            final Uint8List iconMarker =
            await getImagesFromMarker('assets/4.png', 65);

            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!, landmarks[i].coordinateY!,

                  building.patchData[bid ?? buildingAllApi.getStoredString()]);
              _markerLocationsMap[LatLng(value[0], value[1])] = 'Female';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
              landmarks[i].name!;
              // Markers.add(Marker(
              //     markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
              //     position: LatLng(value[0], value[1]),
              //     icon: BitmapDescriptor.fromBytes(iconMarker),
              //     visible: false,
              //     infoWindow: InfoWindow(
              //       title: landmarks[i].name,
              //       snippet: 'Additional Information',
              //       // Replace with additional information
              //       onTap: () {
              //         if (building.selectedLandmarkID !=
              //             landmarks[i].properties!.polyId) {
              //           building.selectedLandmarkID =
              //               landmarks[i].properties!.polyId;
              //           _isRoutePanelOpen = false;
              //           singleroute.clear();
              //           _isLandmarkPanelOpen = true;
              //           addselectedMarker(LatLng(value[0], value[1]));
              //         }
              //       },
              //     )));
            });
          } else if (landmarks[i].element!.subType != null &&
              landmarks[i].element!.subType == "main entry") {
            final Uint8List iconMarker =
            await getImagesFromMarker('assets/1.png', 90);

            setState(() {
              List<double> value = tools.localtoglobal(
                  landmarks[i].coordinateX!, landmarks[i].coordinateY!,

                  building.patchData[bid ?? buildingAllApi.getStoredString()]);
              // _markerLocations[LatLng(value[0], value[1])] = '1';
              _markerLocationsMap[LatLng(value[0], value[1])] = 'Entry';
              _markerLocationsMapLanName[LatLng(value[0], value[1])] =
              landmarks[i].name!;
              print("_markerLocationsMap");
              print("$_markerLocationsMap");
              // _markers!.add(Marker(
              //   markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
              //   position: LatLng(value[0], value[1]),
              //   icon: BitmapDescriptor.fromBytes(iconMarker),
              // ));

              // Markers.add(Marker(
              //     markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
              //     position: LatLng(value[0], value[1]),
              //     icon: BitmapDescriptor.fromBytes(iconMarker),
              //     visible: true,
              //     infoWindow: InfoWindow(
              //       title: landmarks[i].name,
              //       snippet: 'Additional Information',
              //       // Replace with additional information
              //       onTap: () {
              //         if (building.selectedLandmarkID !=
              //             landmarks[i].properties!.polyId) {
              //           building.selectedLandmarkID =
              //               landmarks[i].properties!.polyId;
              //           _isRoutePanelOpen = false;
              //           singleroute.clear();
              //           _isLandmarkPanelOpen = true;
              //           addselectedMarker(LatLng(value[0], value[1]));
              //         }
              //       },
              //     ),
              //     onTap: () {
              //       if (building.selectedLandmarkID !=
              //           landmarks[i].properties!.polyId) {
              //         building.selectedLandmarkID =
              //             landmarks[i].properties!.polyId;
              //         _isRoutePanelOpen = false;
              //         singleroute.clear();
              //         _isLandmarkPanelOpen = true;
              //         addselectedMarker(LatLng(value[0], value[1]));
              //       }
              //     }));
            });
          } else if (landmarks[i].element!.type == "Services" &&
              landmarks[i].element!.subType == "kiosk" &&
              landmarks[i].coordinateX != null) {
            // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(size: Size(44, 44)),
            //   getImagesFromMarker('assets/location_on.png',50),
            // );
            final Uint8List iconMarker =
            await getImagesFromMarker('assets/pin.png', 50);
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!,
                building.patchData[bid ?? buildingAllApi.getStoredString()]);
            //_markerLocations.add(LatLng(value[0],value[1]));
            BitmapDescriptor textMarker;
            String markerText;
            try {
              if (landmarks[i].name != "kiosk") {
                List<String> parts = landmarks[i].name!.split(' ');
                markerText = parts.isNotEmpty ? parts[1].trim() : '';
              } else {
                markerText = "Kiosk";
              }
            } catch (e) {
              markerText = "Kiosk";
            }

            textMarker = await bitmapDescriptorFromTextAndImage(
                markerText, 'assets/check-in.png');

            Markers.add(Marker(
                markerId: MarkerId(
                    "Room ${landmarks[i].properties!.polyId} ${landmarks[i]
                        .buildingID}"),
                position: LatLng(value[0], value[1]),
                icon: textMarker,
                anchor: Offset(0.5, 0.5),
                visible: false,
                onTap: () {
                  print("Info Window");
                },
                infoWindow: InfoWindow(
                    title: landmarks[i].name,
                    // snippet: '${landmarks[i].properties!.polyId}',
                    // Replace with additional information
                    onTap: () {
                      print("Info Window ");
                    })));
          } else {}
        }
      }
    }catch(e){

    }
    setState(() {
      Markers.add(Marker(
        markerId: MarkerId("Building marker"),
        position: _initialCameraPosition.target,
        icon: BitmapDescriptor.defaultMarker,
        visible: false,
      ));
    });
    print("_markerLocationsMap");
    print("$_markerLocationsMap");

    _initMarkers();
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
  double aerialDist=0.0;
  Widget landmarkdetailpannel(
      BuildContext context, AsyncSnapshot<land> snapshot) {

    pathMarkers.clear();
    // if(user.isnavigating==false){
    //   clearPathVariables();
    // }

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

    if(user.initialallyLocalised){
      double val1=double.parse(snapshot
          .data!
          .landmarksMap![
      building.selectedLandmarkID]!
          .properties!.latitude!);
      double val2=double.parse(snapshot
          .data!
          .landmarksMap![
      building.selectedLandmarkID]!
          .properties!.longitude!);
      aerialDist=tools.calculateAerialDist(user.lat,user.lng,val1,val2);
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
                          _polygon.clear();
                        //  circles.clear();
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
                              .name ??
                          snapshot
                              .data!
                              .landmarksMap![building.selectedLandmarkID]!
                              .element!
                              .subType!,
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
                          _polygon.clear();
                        //  circles.clear();
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
          minHeight: 150,
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
                      Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 17, top: 12),
                              child: Focus(
                                autofocus: true,
                                child: Semantics(
                                  child: Text(
                                    snapshot
                                        .data!
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .name ??
                                        snapshot
                                            .data!
                                            .landmarksMap![
                                        building.selectedLandmarkID]!
                                            .element!
                                            .subType!,
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
                                "${LocaleData.floor.getString(context)} ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.buildingName!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.venueName!}",
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

                            (user.initialallyLocalised)?  Container(
                              padding: EdgeInsets.only(
                                left: 17,
                              ),
                              child: Text(
                                "${aerialDist.toStringAsFixed(2)} mtr",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff8d8c8c),
                                  height: 25 / 16,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ):SizedBox(),
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
                                  _polygon.clear();
                                 // circles.clear();
                                  Markers.clear();

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
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .name ??
                                        snapshot
                                            .data!
                                            .landmarksMap![
                                        building.selectedLandmarkID]!
                                            .element!
                                            .subType!;
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
                                        .landmarksMap![
                                    building.selectedLandmarkID]!
                                        .name ??
                                        snapshot
                                            .data!
                                            .landmarksMap![
                                        building.selectedLandmarkID]!
                                            .element!
                                            .subType!;
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
                                                  user: user,
                                                ))).then((value) {
                                      if (value != null) {
                                        fromSourceAndDestinationPage(value);
                                      }
                                    });
                                  }
                                },
                                child: (!calculatingPath)
                                    ? Row(
                                  //  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "${LocaleData.direction.getString(context)}",
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
                        Container(
                          margin:EdgeInsets.only(top:8,right: 16),
                            child: IconButton(onPressed: (){
                              HelperClass.shareContent("https://dev.iwayplus.in/#/iway-apps/iwaymaps.com/landmark?bid=${buildingAllApi.getStoredString()}&landmark=${building.selectedLandmarkID!}&appStore=rgci-navigation/id6505062168&playStore=com.iwayplus.rgcinavigation");
                            }, icon: Icon(Icons.share)))
                      ],),


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
                                          "${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.name ?? snapshot.data!.landmarksMap![building.selectedLandmarkID]!.element!.subType}, Floor ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!}, ${snapshot.data!.landmarksMap![building.selectedLandmarkID]!.buildingName!}",
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

  List<CommonConnection> findCommonLifts(
      Landmarks landmark1, Landmarks landmark2, String accessibleby) {
    List<CommonConnection> commonLifts = [];
    print("accessibleby recieved $accessibleby");
    if (accessibleby == "Lifts") {
      print("inside lifts");
      for (var lift1 in landmark1.lifts!) {
        for (var lift2 in landmark2.lifts!) {
          if (lift1.name == lift2.name) {
            // Create a new Lifts object with x and y values from both input lists
            print(
                "name ${lift1.name} (${lift1.x},${lift1.y}) && (${lift2.x},${lift2.y})");
            commonLifts.add(CommonConnection(
                name: lift1.name,
                x1: lift1.x,
                y1: lift1.y,
                x2: lift2.x,
                y2: lift2.y,
            d1: lift1.distance,
            d2: lift2.distance));
            break;
          }
        }
      }
    } else if (accessibleby == "Stairs") {
      print("inside stairs");
      for (var stair1 in landmark1.stairs!) {
        for (var stair2 in landmark2.stairs!) {
          if (stair1.name == stair2.name) {
            // Create a new Lifts object with x and y values from both input lists
            print(
                "name ${stair1.name} (${stair1.x},${stair1.y}) && (${stair2.x},${stair2.y})");
            commonLifts.add(CommonConnection(
                name: stair1.name,
                x1: stair1.x,
                y1: stair1.y,
                x2: stair2.x,
                y2: stair2.y,
                d1: stair1.distance,
                d2: stair2.distance));
            break;
          }
        }
      }
    } else if (accessibleby == "ramp") {
      print("inside stairs");
      for (var ramp1 in landmark1.others!) {
        for (var ramp2 in landmark2.others!) {
          if (ramp1.name == ramp2.name) {
            // Create a new Lifts object with x and y values from both input lists
            print(
                "name ${ramp1.name} (${ramp1.x},${ramp1.y}) && (${ramp2.x},${ramp2.y})");
            commonLifts.add(CommonConnection(
                name: ramp1.name,
                x1: ramp1.x,
                y1: ramp1.y,
                x2: ramp2.x,
                y2: ramp2.y,
                d1: ramp1.distance,
                d2: ramp2.distance));
            break;
          }
        }
      }
    }
    // Sort the commonLifts based on distance
    commonLifts.sort((a, b) {
      // Ensure that d1 and d2 are not null before summing them up
      final aSum = (a.d1 ?? 0) + (a.d2 ?? 0);
      final bSum = (b.d1 ?? 0) + (b.d2 ?? 0);
      return aSum.compareTo(bSum);
    });
    return commonLifts;
  }

  Map<List<String>, Set<gmap.Polyline>> interBuildingPath = new Map();

  Future<void> calculateroute(Map<String, Landmarks> landmarksMap,
      {String accessibleby = "Lifts"}) async {
    print("polyidchecker ${PathState.sourcePolyID}");
    if(PathState.sourcePolyID == ""){
      PathState.sourcePolyID = tools.localizefindNearbyLandmarkSecond(user, landmarksMap)!.properties!.polyId!;
    }else if(landmarksMap[PathState.sourcePolyID]!.lifts == null || landmarksMap[PathState.sourcePolyID]!.lifts!.isEmpty ){
      landmarksMap[PathState.sourcePolyID]!.lifts = tools.localizefindNearbyLandmarkSecond(user, landmarksMap,increaserange: true)!.lifts;
    }
    try{
    if(PathState.sourcePolyID == ""){
      PathState.sourcePolyID = tools.localizefindNearbyLandmarkSecond(user, landmarksMap)!.properties!.polyId!;
    }else if(landmarksMap[PathState.sourcePolyID]!.lifts == null || landmarksMap[PathState.sourcePolyID]!.lifts!.isEmpty ){
      landmarksMap[PathState.sourcePolyID]!.lifts = tools.localizefindNearbyLandmarkSecond(user, landmarksMap,increaserange: true)!.lifts;
    }
    }catch(e){
      print("$e error in finding nearest landmark second");
    }
   // circles.clear();
    print("landmarksMap");
    // print(landmarksMap.keys);
    // print(landmarksMap.values);
    // print(landmarksMap[PathState.destinationPolyID]!.buildingID);
    // print(landmarksMap[PathState.sourcePolyID]!.buildingID);

    PathState.noPathFound=false;
    singleroute.clear();
    pathMarkers.clear();
    Markers.clear();

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

        if (markers.length > 0)
          markers[user.Bid]?[0] = customMarker.rotate(0, markers[user.Bid]![0]);
        if (user.initialallyLocalised) {
          mapState.interaction = !mapState.interaction;
        }
        mapState.zoom = 21;
      } else if (PathState.sourceFloor != PathState.destinationFloor) {
        print(PathState.sourcePolyID!);
        print(landmarksMap[PathState.sourcePolyID]!.lifts);
        print(landmarksMap[PathState.destinationPolyID]!.lifts!);
        List<CommonConnection> commonlifts = findCommonLifts(
            landmarksMap[PathState.sourcePolyID]!,
            landmarksMap[PathState.destinationPolyID]!,
            accessibleby);

        if (commonlifts.isEmpty) {
          setState(() {
            PathState.noPathFound = true;
            _isLandmarkPanelOpen = false;
            _isRoutePanelOpen = true;
          });
          return;
        }

        print(commonlifts);

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
      }
    } else {
      print("calculateroute else statement");
      double sourceEntrylat = 0;
      double sourceEntrylng = 0;
      double destinationEntrylat = 0;
      double destinationEntrylng = 0;

      building.landmarkdata!.then((land) async {



        Landmarks destinationEntry = tools.findNearestPoint(PathState.destinationPolyID, PathState.sourcePolyID, land.landmarks!);
        destinationEntrylat = double.parse(destinationEntry.properties!.latitude!);
        destinationEntrylng = double.parse(destinationEntry.properties!.longitude!);
        if (destinationEntry.floor == PathState.destinationFloor) {
          await fetchroute(
              destinationEntry.coordinateX!,
              destinationEntry.coordinateY!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              bid: PathState.destinationBid);
          print("running destination location no lift run");
        } else if (destinationEntry.floor != PathState.destinationFloor) {
          List<dynamic> commonlifts = findCommonLifts(destinationEntry,
              landmarksMap[PathState.destinationPolyID]!, accessibleby);
          if (commonlifts.isEmpty) {
            setState(() {
              PathState.noPathFound = true;
              _isLandmarkPanelOpen = false;
              _isRoutePanelOpen = true;
            });
            return;
          }
          await fetchroute(
              commonlifts[0].x2!,
              commonlifts[0].y2!,
              PathState.destinationX,
              PathState.destinationY,
              PathState.destinationFloor,
              bid: PathState.destinationBid);
          await fetchroute(destinationEntry.coordinateX!, destinationEntry.coordinateY!,
              commonlifts[0].x1!, commonlifts[0].y1!, destinationEntry.floor!,
              bid: PathState.destinationBid);

          PathState.connections[PathState.destinationBid] = {
            destinationEntry.floor!: calculateindex(
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                building.floorDimenssion[PathState.destinationBid]![
                destinationEntry.floor!]![0]),
            PathState.destinationFloor: calculateindex(
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                building.floorDimenssion[PathState.destinationBid]![
                PathState.destinationFloor]![0])
          };
        }
        // Landmarks source= landmarksMap[PathState.sourcePolyID]!;
        // double sourceLat=double.parse(source.properties!.latitude!);
        // double sourceLng=double.parse(source.properties!.longitude!);
        //
        //
        // Landmarks destination= landmarksMap[PathState.destinationPolyID]!;
        // double destinationLat=double.parse(source.properties!.latitude!);
        // double destinationLng=double.parse(source.properties!.longitude!);
        Landmarks sourceEntry = tools.findNearestPoint(PathState.sourcePolyID, PathState.destinationPolyID, land.landmarks!);
        sourceEntrylat = double.parse(sourceEntry.properties!.latitude!);
        sourceEntrylng = double.parse(sourceEntry.properties!.longitude!);
        if (PathState.sourceFloor == sourceEntry.floor) {
          await fetchroute(PathState.sourceX, PathState.sourceY,
              sourceEntry.coordinateX!, sourceEntry.coordinateY!, sourceEntry.floor!,
              bid: PathState.sourceBid);
          print("running source location no lift run");
        } else if (PathState.sourceFloor != sourceEntry.floor) {
          List<dynamic> commonlifts = findCommonLifts(
              landmarksMap[PathState.sourcePolyID]!, sourceEntry, accessibleby);
          if (commonlifts.isEmpty) {
            setState(() {
              PathState.noPathFound = true;
              _isLandmarkPanelOpen = false;
              _isRoutePanelOpen = true;
            });
            return;
          }

          await fetchroute(commonlifts[0].x2!, commonlifts[0].y2!,
              sourceEntry.coordinateX!, sourceEntry.coordinateY!, sourceEntry.floor!,
              bid: PathState.sourceBid);
          await fetchroute(PathState.sourceX, PathState.sourceY,
              commonlifts[0].x1!, commonlifts[0].y1!, PathState.sourceFloor,
              bid: PathState.sourceBid);

          PathState.connections[PathState.sourceBid] = {
            PathState.sourceFloor: calculateindex(
                commonlifts[0].x1!,
                commonlifts[0].y1!,
                building.floorDimenssion[PathState.sourceBid]![
                PathState.sourceFloor]![0]),
            sourceEntry.floor!: calculateindex(
                commonlifts[0].x2!,
                commonlifts[0].y2!,
                building.floorDimenssion[PathState.sourceBid]![
                sourceEntry.floor!]![0])
          };
        }

        List<double> sourceEntryCoordinates = tools.localtoglobal(sourceEntry.coordinateX!, sourceEntry.coordinateY!, building.patchData[sourceEntry.buildingID]);
        List<double> destinationEntryCoordinates = tools.localtoglobal(destinationEntry.coordinateX!, destinationEntry.coordinateY!, building.patchData[destinationEntry.buildingID]);

        OutBuildingModel? buildData = await OutBuildingData.outBuildingData(
            sourceEntryCoordinates[0],
            sourceEntryCoordinates[1],
            destinationEntryCoordinates[0],
            destinationEntryCoordinates[1]
        );
        print("build data: $buildData");
        List<LatLng> coords = [LatLng(sourceEntryCoordinates[0], sourceEntryCoordinates[1])];
        PathState.realWorldCoordinates.clear();
        PathState.realWorldCoordinates.add(sourceEntryCoordinates);
        final Uint8List realWorldPathMarker =
            await getImagesFromMarker('assets/rw.png', 30);


        if (buildData != null) { //uncomment here
          int len = buildData.path.length;
          for (int i = 0; i < len; i++) {
            // realWorldPath.add(Marker(
            //   markerId: MarkerId('rw [${buildData.path[i][1]},${buildData.path[i][0]}]'),
            //   position: LatLng(buildData.path[i][1],
            //       buildData.path[i][0]),
            //   icon: BitmapDescriptor.fromBytes(realWorldPathMarker),
            // ),);
            coords.add(LatLng(buildData.path[i][1], buildData.path[i][0]));
            PathState.realWorldCoordinates
                .add([buildData.path[i][1], buildData.path[i][0]]);
          }
          coords.add(LatLng(destinationEntrylat, destinationEntrylng));
          PathState.realWorldCoordinates
              .add([destinationEntrylat, destinationEntrylng]);
          print(coords);
          List<String> key = [PathState.sourceBid, PathState.destinationBid];
          setState(() {
            singleroute.putIfAbsent(buildingAllApi.outdoorID, ()=>Map());
            singleroute[buildingAllApi.outdoorID]!.putIfAbsent(0, () => Set());
            singleroute[buildingAllApi.outdoorID]![0]?.add(gmap.Polyline(
              polylineId: PolylineId(buildData.pathId),
              points: coords,
              color: Colors.red,
              width: 8,
            ));
          });
          // List<Cell> interBuildingPath = [];
          // for(LatLng c in coords){
          //   Map<String,double> local = CoordinateConverter.globalToLocal(c.latitude, c.longitude, building.patchData[buildingAllApi.outdoorID]!.patchData!.toJson());
          //   int node = (local["lng"]!.round()*building.floorDimenssion[buildingAllApi.outdoorID]![1]![0])+local["lat"]!.round() ;
          //   interBuildingPath.add(Cell(node, local["lat"]!.round().toInt(), local["lng"]!.round().toInt(), tools.eightcelltransition, c.latitude, c.longitude, buildingAllApi.outdoorID));
          // }
          // PathState.listofPaths.insert(1, interBuildingPath);
        } //till here
      });
      print("different building detected");

      print(PathState.path.keys);
      print(pathMarkers.keys);
    }
    _isLandmarkPanelOpen = false;
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
      if (PathState.destinationName ==
          "${LocaleData.yourcurrentloc.getString(context)}") {
        speak(
            " ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. ${LocaleData.clickstarttonavigate.getString(context)}",
            _currentLocale);
      } else {
        speak(
            "${PathState.destinationName} ${LocaleData.issss.getString(context)} $distance ${LocaleData.meteraway.getString(context)}. ${LocaleData.clickstarttonavigate.getString(context)}",
            _currentLocale);
      }
    }
    setState(() {
      building.floor[buildingAllApi.selectedBuildingID] = PathState.sourceFloor;
    });
  }

  List<int> beaconCord = [];
  double cordL = 0;
  double cordLt = 0;
  List<List<int>> getPoints = [];
  List<int> getnodes = [];

  List<LatLng> _polylineCoordinates = [];
  Marker? _movingMarker;
  Timer? _polytimer;
  int _currentIndex = 0;
  AnimationController? _animationController;
  Animation<double>? _polyanimation;
  late LatLng sourcePosition;
  late LatLng destinationPosition;
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;

  Future<List<int>> fetchroute(
      int sourceX, int sourceY, int destinationX, int destinationY, int floor,
      {String? bid = null, String? liftName}) async {
    int numRows = building.floorDimenssion[bid]![floor]![1]; //floor breadth
    int numCols = building.floorDimenssion[bid]![floor]![0]; //floor length
    int sourceIndex = calculateindex(sourceX, sourceY, numCols);
    int destinationIndex = calculateindex(destinationX, destinationY, numCols);
    // List<List<int>> offsets = [
    //   [-1, -1], // Top-left
    //   [-1, 0],  // Top
    //   [-1, 1],  // Top-right
    //   [0, -1],  // Left
    //   [0, 1],   // Right
    //   [1, -1],  // Bottom-left
    //   [1, 0],   // Bottom
    //   [1, 1]    // Bottom-right
    // ];
    print("all landmarks");
    // building.landmarkdata!.then((value) {
    //   value.landmarksMap!.forEach((key, value) {
    //     // if(value.properties!.node==null){
    //     //   print("nodenull${value.name}");
    //     //
    //     // }
    //
    //     if(value.doorX==null && value.element!.type!="floor" ){
    //
    //       if(building.nonWalkable[bid]![floor]!.contains(value.coordinateX!+value.coordinateY!*numCols)){
    //         print("${value.name} ${value.coordinateX}");
    //       }
    //     }else{
    //
    //       if(building.nonWalkable[bid]![floor]!.contains(value.doorX!+value.doorY!*numCols)){
    //         print(value.name);
    //       }
    //
    //     }
    //   });
    // });

    if (building.nonWalkable[bid]![floor]!
        .contains(destinationY * numCols + destinationX)) {
      print("DestinationinNonWalkable");
    }
    if (building.nonWalkable[bid]![floor]!
        .contains(sourceY * numCols + sourceX)) {
      print("SourceNonWalkable");
    }
    print("numcol $numCols");

    List<int> path = [];

    PathModel model = Building.waypoint[bid]!
        .firstWhere((element) => element.floor == floor);
    Map<String, List<dynamic>> adjList = model.pathNetwork;
    path = await findShortestPath(adjList, sourceX, sourceY, destinationX, destinationY, building.nonWalkable[bid]![floor]!, numCols, numRows);
    // try {
    //   PathModel model = Building.waypoint[bid]!
    //       .firstWhere((element) => element.floor == floor);
    //   Map<String, List<dynamic>> adjList = model.pathNetwork;
    //   var graph = Graph(adjList);
    //   List<int> path2 = await graph.bfs(
    //       sourceX,
    //       sourceY,
    //       destinationX,
    //       destinationY,
    //       adjList,
    //       numRows,
    //       numCols,
    //       building.nonWalkable[bid]![floor]!);
    //   // if(path2.first==(sourceY*numCols)+sourceX && path2.last == (destinationY*numCols)+destinationX){
    //   //   path = path2;
    //   //   print("path from waypoint $path");
    //   // }else{
    //   //   print("Faulty wayPoint path $path2");
    //   //   throw Exception("wrong path");
    //   // }
    //   path = path2;
    //   print("path from waypoint $path");
    // } catch (e) {
    //   print("inside exception $e");
    //
    //   List<int> path2 = await findPath(
    //     numRows,
    //     numCols,
    //     building.nonWalkable[bid]![floor]!,
    //     sourceIndex,
    //     destinationIndex,
    //   );
    //   path2 = getFinalOptimizedPath(path2, building.nonWalkable[bid]![floor]!,
    //       numCols, sourceX, sourceY, destinationX, destinationY);
    //   path = path2;
    //   print("path from A* $path");
    // }

    try {
      PathModel model = Building.waypoint[bid]!
          .firstWhere((element) => element.floor == floor);
      Map<String, List<dynamic>> adjList = model.pathNetwork;
      List<int>path2 = await findShortestPath(adjList, sourceX, sourceY, destinationX, destinationY, building.nonWalkable[bid]![floor]!, numCols, numRows);
      path = path2;
      print("path from waypoint $path");
    } catch (e) {
      print("inside exception $e");

      List<int> path2 = await findPath(
        numRows,
        numCols,
        building.nonWalkable[bid]![floor]!,
        sourceIndex,
        destinationIndex,
      );
      path2 = getFinalOptimizedPath(path2, building.nonWalkable[bid]![floor]!,
          numCols, sourceX, sourceY, destinationX, destinationY);
      path = path2;
      print("path from A* $path");
    }

    if (path[0] != sourceIndex || path[path.length - 1] != destinationIndex) {
      wsocket.message["path"]["didPathForm"] = false;
    } else {
      wsocket.message["path"]["didPathForm"] = true;
    }

    List<int> turns = tools.getTurnpoints(path, numCols);
    print("turnssss ${turns}");
    int newSourceX = path[0] % numCols;
    int newSourceY = path[0] ~/ numCols;
    getPoints.add([newSourceX, newSourceY]);
    for (int i = 0; i < turns.length; i++) {
      int x = turns[i] % numCols;
      int y = turns[i] ~/ numCols;
      getPoints.add([x, y]);
    }
    getPoints.add([destinationX, destinationY]);
    print("getPointss: ${getPoints}");
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
        PathState.associateTurnWithLandmark.removeWhere((key, value) =>
        value.properties!.polyId == PathState.destinationPolyID);
        // PathState.associateTurnWithLandmark.forEach((key, value) {
        //   print("${key} , ${value.name}");
        // });
        List<direction> directions = [];
        if (liftName != null) {
          directions.add(direction(-1, "Take ${liftName} and Go to ${PathState.destinationFloor} Floor", null, null,
              floor.toDouble(), null, null, floor, bid ?? ""));
        }
        directions.addAll(tools.getDirections(
            path, numCols, value, floor, bid ?? "", PathState, context));
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

    List<Cell> Cellpath = findCorridorSegments(
        path, building.nonWalkable[bid]![floor]!, numCols, bid, floor,building.patchData);
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
      if(building.floor[bid] != PathState.sourceFloor){
        setState(() {
          building.floor[bid] = PathState.sourceFloor;
        });
        await createRooms(building.polyLineData!, PathState.sourceFloor);
      }
      if(floor != 0){
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            building.polylinedatamap[
            bid]!.polyline!.floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(floor),
            building.polylinedatamap[
            bid]!.polyline!.floors!);
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
        print("dvalue in fetchroute $dvalue");
        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
      }else{
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
             building.patchData[bid]);
        dvalue = tools.localtoglobal(destinationX, destinationY,
             building.patchData[bid]);
      } else {
        print("Himanshucheckerpath in else block ");
        svalue = tools.localtoglobal(sourceX, sourceY,null);
        dvalue = tools.localtoglobal(destinationX, destinationY,null);
      }

      setCameraPositionusingCoords([LatLng(svalue[0], svalue[1]),LatLng(dvalue[0], dvalue[1])]);
      List<LatLng> coordinates = [];
      for (var node in path) {
        int row = (node % numCols); //divide by floor length
        int col = (node ~/ numCols); //divide by floor length
        List<double> value =
        tools.localtoglobal(row, col,  building.patchData[bid]);
        coordinates.add(LatLng(value[0], value[1]));
        if(singleroute[bid]==null){
          singleroute.putIfAbsent(bid, () => Map());
        }
        if(singleroute[bid]![floor] != null){
          gmap.Polyline oldPolyline = singleroute[bid]![floor]!.firstWhere(
                (polyline) => polyline.polylineId.value == bid,
          );
          gmap.Polyline updatedPolyline = gmap.Polyline(
            polylineId: oldPolyline.polylineId,
            points: coordinates,
            color: oldPolyline.color,
            width: oldPolyline.width,
          );
          setState(() {
            // Remove the old polyline and add the updated polyline
            singleroute[bid]![floor]!.remove(oldPolyline);
            singleroute[bid]![floor]!.add(updatedPolyline);
          });
        }else{
          setState(() {
            singleroute[bid]!.putIfAbsent(floor, () => Set());
            singleroute[bid]![floor]?.add(gmap.Polyline(
              polylineId: PolylineId("$bid"),
              points: coordinates,
              color: Colors.red,
              width: 8,
            ));
          });
        }
        if(buildingAllApi.getStoredString() == bid && building.floor[bid] == PathState.sourceFloor){
          await Future.delayed(Duration(microseconds: 1500));
        }
      }

      final Uint8List tealtorch =
      await getImagesFromMarker('assets/tealtorch.png', 35);

      Set<Marker> innerMarker = Set();

      setState(() {
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

        PathState.innerMarker[floor] = innerMarker;
        pathMarkers[floor] = innerMarker;
      });

    } else {
      print("No path found.");
    }

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
    return path;
  }
  void animateMarker() {
    Set<Marker> innerMarker = Set();
    double step = 0.0001;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        sourcePosition = LatLng(sourcePosition.latitude + step, sourcePosition.longitude + step);
        innerMarker.add(
            Marker(
            markerId: MarkerId("destination${destinationPosition}"),
            position: destinationPosition,
            icon: sourceIcon));
        innerMarker.add(
          Marker(
            markerId: MarkerId("destination"),
            position: destinationPosition,
            icon: destinationIcon,
          ),
        );

        //setCameraPosition(innerMarker);
        pathMarkers[3] = innerMarker;

      });
      if ((sourcePosition.latitude - destinationPosition.latitude).abs() < step &&
          (sourcePosition.longitude - destinationPosition.longitude).abs() < step) {
        timer.cancel();
      }
    });
  }

  void _initializePolylineAndMarker() {
    setState(() {
      _movingMarker = Marker(
        markerId: MarkerId('moving_marker'),
        position: _polylineCoordinates[0],
      );
    });
  }
  List<LatLng> _visibleWhitePolyline = [];


  void _startAnimation() {
    int currentIndex = 0;
    _polytimer = Timer.periodic(Duration(milliseconds: 50), (Timer timer) {
      setState(() {
        currentIndex++;
        if (currentIndex >= _polylineCoordinates.length) {
          currentIndex = 0;
          _visibleWhitePolyline.clear();
        } else {
          _visibleWhitePolyline.add(_polylineCoordinates[currentIndex]);
        }
      });
    });
  }

  LatLng _getLatLngAlongPath(double fraction) {
    int startIndex = (_polylineCoordinates.length - 1) * fraction ~/ 1;
    int endIndex = startIndex + 1;

    if (endIndex >= _polylineCoordinates.length) {
      endIndex = _polylineCoordinates.length - 1;
    }

    final startPoint = _polylineCoordinates[startIndex];
    final endPoint = _polylineCoordinates[endIndex];

    final lat = _lerp(startPoint.latitude, endPoint.latitude, fraction);
    final lng = _lerp(startPoint.longitude, endPoint.longitude, fraction);

    return LatLng(lat, lng);
  }

  double _lerp(double start, double end, double fraction) {
    return start + (end - start) * fraction;
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
                                bid: buildingAllApi.getStoredString()
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
    try{
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
    }catch(e){

    }


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> directionWidgets = [];
    directionWidgets.clear();
    if (PathState.directions.isNotEmpty) {
      if (PathState.directions[0].distanceToNextTurn != null) {
        directionWidgets.add(directionInstruction(
          direction: '${LocaleData.gostraight.getString(context)}',
          distance: (PathState.directions[0].distanceToNextTurn! * 0.3048)
              .ceil()
              .toString(),
          context: context,
        ));
      }

      for (int i = 1; i < PathState.directions.length; i++) {
        if (!PathState.directions[i].isDestination) {
          if (PathState.directions[i].nearbyLandmark != null) {
            directionWidgets.add(directionInstruction(
              direction: PathState.directions[i].turnDirection == "Straight"
                  ? '${LocaleData.gostraight.getString(context)}'
                  : "${LocaleData.turn.getString(context)} ${LocaleData.getProperty3(PathState.directions[i].turnDirection!, context)} ${LocaleData.from.getString(context)} ${PathState.directions[i].nearbyLandmark!.name!} ${LocaleData.getProperty2(PathState.directions[i].turnDirection!, context)} ${LocaleData.and.getString(context)} ${LocaleData.gostraight.getString(context)}",
              distance: (PathState.directions[i].distanceToNextTurn! * 0.3048)
                  .ceil()
                  .toString(),
              context: context,
            ));
          } else {
            if (PathState.directions[i].node == -1) {
              directionWidgets.add(directionInstruction(
                  direction: "${PathState.directions[i].turnDirection!}",
                  distance:
                      "${LocaleData.and.getString(context)} ${LocaleData.goto.getString(context)} ${PathState.directions[i].distanceToPrevTurn?.toInt() ?? 0.toInt()} ${LocaleData.floor.getString(context)}",
                  context: context));
            } else {
              directionWidgets.add(directionInstruction(
                direction: PathState.directions[i].turnDirection == "Straight"
                    ? '${LocaleData.gostraight.getString(context)}'
                    : "${LocaleData.turn.getString(context)} ${LocaleData.getProperty4(PathState.directions[i].turnDirection!, context)}, ${LocaleData.and.getString(context)} ${LocaleData.gostraight.getString(context)}",
                distance:
                    (PathState.directions[i].distanceToNextTurn ?? 0 * 0.3048)
                        .ceil()
                        .toString(),
                context: context,
              ));
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
            height:
                PathState.sourceFloor != PathState.destinationFloor ? 170 : 130,
            width: screenWidth,
            padding: EdgeInsets.only(top: 15, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
              color: Colors.white,
            ),
            child: Semantics(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: IconButton(
                            onPressed: () {
                              showMarkers();
                              List<double> mvalues = tools.localtoglobal(
                                  PathState.destinationX,
                                  PathState.destinationY, building.patchData[PathState.destinationBid]);
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
                              //realWorldPath.clear();
                              _isBuildingPannelOpen = true;
                              if (user.isnavigating == false) {
                                clearPathVariables();
                              }
                              setState(() {
                                Marker? temp = selectedroomMarker[
                                        buildingAllApi.getStoredString()]
                                    ?.first;

                                selectedroomMarker.clear();
                                selectedroomMarker[
                                        buildingAllApi.getStoredString()]
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
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 12, right: 5),
                                width: 15.0,
                                height: 15.0,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 12, right: 5),
                                width: 5.0,
                                height: 5.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 28, right: 5),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Colors.red,
                                size: 22,
                              ))
                        ],
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
                                        builder: (context) =>
                                            DestinationSearchPage(
                                              hintText: 'Source location',
                                              voiceInputEnabled: false,
                                              userLocalized: user.key,
                                            ))).then((value) async {
                                  // onLandmarkVenueClicked(value,DirectlyStartNavigation: true);
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
                                        builder: (context) =>
                                            DestinationSearchPage(
                                              hintText: 'Destination location',
                                              voiceInputEnabled: false,
                                            ))).then((value) {
                                  _isBuildingPannelOpen = false;
                                  print("onDestinationVenueClicked");
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
                                if (user.isnavigating == false) {
                                  clearPathVariables();
                                }
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
                  PathState.sourceFloor != PathState.destinationFloor
                      ? Container(
                          margin: EdgeInsets.only(top: 8, left: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 112,
                                margin: EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                    onPressed: () {
                                      PathState.accessiblePath = "Stairs";
                                      PathState.clearforaccessiblepath();
                                      building.landmarkdata!.then((value) {
                                        try {
                                          calculateroute(value.landmarksMap!,
                                              accessibleby: "Stairs");
                                        } catch (e) {}
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.greenAccent,
                                        backgroundColor:
                                            PathState.accessiblePath == "Stairs"
                                                ? Color(0xff24B9B0)
                                                : Colors.white,
                                        elevation:
                                            0 // Set the text color to black
                                        ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.stairs,
                                            color: PathState.accessiblePath ==
                                                    "Stairs"
                                                ? Colors.white
                                                : Color(0xff24B9B0),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 3),
                                            child: Text(
                                              "Stairs",
                                              style: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    PathState.accessiblePath ==
                                                            "Stairs"
                                                        ? Colors.white
                                                        : Colors.black,
                                                height: 20 / 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              Container(
                                width: 110,
                                margin: EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                    onPressed: () {
                                      PathState.accessiblePath = "Lifts";
                                      PathState.clearforaccessiblepath();
                                      building.landmarkdata!.then((value) {
                                        try {
                                          calculateroute(value.landmarksMap!,
                                              accessibleby: "Lifts");
                                        } catch (e) {}
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.greenAccent,
                                        backgroundColor:
                                            PathState.accessiblePath == "Lifts"
                                                ? Color(0xff24B9B0)
                                                : Colors.white,
                                        elevation:
                                            0 // Set the text color to black
                                        ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.elevator,
                                            color: PathState.accessiblePath ==
                                                    "Lifts"
                                                ? Colors.white
                                                : Color(0xff24B9B0),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 3),
                                            child: Text(
                                              "Lifts",
                                              style: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    PathState.accessiblePath ==
                                                            "Lifts"
                                                        ? Colors.white
                                                        : Colors.black,
                                                height: 20 / 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              Container(
                                width: 112,
                                margin: EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                    onPressed: () {
                                      PathState.accessiblePath = "ramp";
                                      PathState.clearforaccessiblepath();
                                      building.landmarkdata!.then((value) {
                                        try {
                                          calculateroute(value.landmarksMap!,
                                              accessibleby: "ramp");
                                        } catch (e) {}
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.greenAccent,
                                        backgroundColor:
                                            PathState.accessiblePath == "ramp"
                                                ? Color(0xff24B9B0)
                                                : Colors.white,
                                        elevation:
                                            0 // Set the text color to black
                                        ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.stairs_rounded,
                                            color: PathState.accessiblePath ==
                                                    "ramp"
                                                ? Colors.white
                                                : Color(0xff24B9B0),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 3),
                                            child: Text(
                                              "Ramp",
                                              style: TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    PathState.accessiblePath ==
                                                            "ramp"
                                                        ? Colors.white
                                                        : Colors.black,
                                                height: 20 / 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        )
                      : Container(),
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
                minHeight: 155,
                maxHeight: screenHeight * 0.8,
                panel: PathState.noPathFound
                    ? Container(
                        margin: EdgeInsets.only(top: 36),
                        child: Column(
                          children: [
                            Image.asset("assets/error.png"),
                            Text(
                              "Can't find a way there",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff3f3f46),
                                height: 40 / 14,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    : Semantics(
                        sortKey: const OrdinalSortKey(0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Semantics(
                                    excludeSemantics: true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 6,
                                          margin: EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: Color(0xffd9d9d9),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    padding: EdgeInsets.only(left: 17, top: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                    "${time.toInt()} min Walk ",
                                                    style: const TextStyle(
                                                      color: Color(0xffDC6A01),
                                                      fontFamily: "Roboto",
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 24 / 18,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                Spacer(),
                                                IconButton(
                                                    onPressed: () {
                                                      showMarkers();
                                                      setState(() {
                                                        _isBuildingPannelOpen =
                                                            true;
                                                        _isRoutePanelOpen =
                                                            false;
                                                      });
                                                      widget.directLandID = "";
                                                      selectedroomMarker
                                                          .clear();
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
                                                      PathState.sourcePolyID =
                                                          "";
                                                      PathState
                                                          .destinationPolyID = "";
                                                      PathState.sourceBid = "";
                                                      PathState.destinationBid =
                                                          "";
                                                      singleroute.clear();
                                                      //realWorldPath.clear();
                                                      PathState.directions = [];
                                                      interBuildingPath.clear();
                                                      //  if(user.isnavigating==false){
                                                      clearPathVariables();
                                                      //}
                                                      fitPolygonInScreen(
                                                          patch.first);
                                                      exitNavigation();
                                                    },
                                                    icon: Semantics(
                                                      label: "Close Navigation",
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
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                                child: TextButton(
                                                  onPressed: () async {
                                                    if(PathState.sourceX == PathState.destinationX && PathState.sourceY == PathState.destinationY){
                                                      //HelperClass.showToast("Source and Destination can not be same");
                                                      setState(() {
                                                        _isRoutePanelOpen = false;
                                                      });
                                                      closeNavigation();
                                                      return;
                                                    }
                                                    setState(() {
                                                      circles.clear();
                                                      _markers.clear();
                                                      markerSldShown = false;
                                                    });
                                                    user.onConnection = false;
                                                    PathState.didPathStart = true;

                                                    UserState.cols = building.floorDimenssion[PathState.sourceBid]![PathState.sourceFloor]![0];
                                                    UserState.rows = building.floorDimenssion[PathState.destinationBid]![PathState.destinationFloor]![1];
                                                    UserState.lngCode = _currentLocale;
                                                    UserState.reroute = reroute;
                                                    UserState.closeNavigation = closeNavigation;
                                                    UserState.AlignMapToPath = alignMapToPath;
                                                    UserState.startOnPath = startOnPath;
                                                    UserState.speak = speak;
                                                    UserState.paintMarker = paintMarker;
                                                    UserState.createCircle = updateCircle;

                                                    //detected=false;
                                                    //user.building = building;
                                                    wsocket.message["path"]
                                                            ["source"] =
                                                        PathState.sourceName;
                                                    wsocket.message["path"]
                                                            ["destination"] =
                                                        PathState
                                                            .destinationName;
                                                    // user.ListofPaths = PathState.listofPaths;
                                                    // user.patchData = building.patchData;
                                                    // user.buildingNumber = PathState.listofPaths.length-1;
                                                    buildingAllApi.selectedID =
                                                        PathState.sourceBid;
                                                    buildingAllApi
                                                            .selectedBuildingID =
                                                        PathState.sourceBid;
                                                    UserState.cols = building
                                                                .floorDimenssion[
                                                            PathState
                                                                .sourceBid]![
                                                        PathState
                                                            .sourceFloor]![0];
                                                    UserState.rows = building
                                                                .floorDimenssion[
                                                            PathState
                                                                .sourceBid]![
                                                        PathState
                                                            .sourceFloor]![1];
                                                    user.Bid =
                                                        PathState.sourceBid;
                                                    user.coordX = PathState.sourceX;
                                                    user.coordY = PathState.sourceY;
                                                    user.temporaryExit = false;
                                                    UserState.reroute = reroute;
                                                    UserState.closeNavigation = closeNavigation;
                                                    UserState.AlignMapToPath = alignMapToPath;
                                                    UserState.startOnPath = startOnPath;
                                                    UserState.speak = speak;
                                                    UserState.paintMarker = paintMarker;
                                                    UserState.createCircle = updateCircle;
                                                    //user.realWorldCoordinates = PathState.realWorldCoordinates;
                                                    user.floor =
                                                        PathState.sourceFloor;
                                                    user.pathobj = PathState;
                                                    user.path = PathState
                                                        .singleListPath;
                                                    user.isnavigating = true;
                                                    user.Cellpath = PathState
                                                        .singleCellListPath;
                                                    PathState.singleCellListPath
                                                        .forEach((element) {
                                                      print(
                                                          "debug ${element.x}, ${element.y}   ${element.bid}");
                                                    });
                                                    user
                                                        .moveToStartofPath()
                                                        .then((value) async {
                                                      final Uint8List userloc =
                                                          await getImagesFromMarker(
                                                              'assets/userloc0.png',
                                                              130);
                                                      final Uint8List
                                                          userlocdebug =
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
                                                                    .toInt(), building.patchData[PathState.sourceBid]);

                                                        markers.putIfAbsent(
                                                            user.Bid, () => []);
                                                        markers[user.Bid]
                                                            ?.add(Marker(
                                                          markerId: MarkerId(
                                                              "UserLocation"),
                                                          position: LatLng(
                                                              val[0], val[1]),
                                                          icon: BitmapDescriptor
                                                              .fromBytes(
                                                                  userloc),
                                                          anchor: Offset(
                                                              0.5, 0.829),
                                                        ));

                                                        val =
                                                            tools.localtoglobal(
                                                                user.coordX
                                                                    .toInt(),
                                                                user.coordY
                                                                    .toInt(), building.patchData[PathState.sourceBid]);

                                                        markers[user.Bid]
                                                            ?.add(Marker(
                                                          markerId:
                                                              MarkerId("debug"),
                                                          position: LatLng(
                                                              val[0], val[1]),
                                                          icon: BitmapDescriptor
                                                              .fromBytes(
                                                                  userlocdebug),
                                                          anchor: Offset(
                                                              0.5, 0.829),
                                                        ));
                                                        // circles.add(
                                                        //   Circle(
                                                        //     circleId: CircleId("circle"),
                                                        //     center: LatLng(user.lat,user.lng),
                                                        //     radius: _animation.value,
                                                        //     strokeWidth: 1,
                                                        //     strokeColor: Colors.blue,
                                                        //     fillColor: Colors.lightBlue.withOpacity(0.2),
                                                        //   ),
                                                        // );
                                                      });
                                                      alignMapToPath([
                                                        user.lat,
                                                        user.lng
                                                      ], [
                                                        PathState
                                                            .singleCellListPath[
                                                        user.pathobj
                                                            .index +
                                                            1]
                                                            .lat,
                                                        PathState
                                                            .singleCellListPath[
                                                        user.pathobj
                                                            .index +
                                                            1]
                                                            .lng
                                                      ]);
                                                    });
                                                    _isRoutePanelOpen = false;

                                                    building.selectedLandmarkID =
                                                        null;

                                                    _isnavigationPannelOpen =
                                                        true;

                                                    semanticShouldBeExcluded =
                                                        false;

                                                    StartPDR();

                                                    if(building.floor[PathState.sourceBid] != PathState.sourceFloor){
                                                      building.floor[PathState.sourceBid] = PathState.sourceFloor;
                                                      createRooms(building.polylinedatamap[PathState.sourceBid]!, PathState.sourceFloor);
                                                      building.landmarkdata!.then((value){
                                                        createMarkers(value, PathState.sourceFloor,bid: PathState.sourceBid);
                                                      });
                                                    }
                                                  },
                                                  child: !startingNavigation
                                                      ? Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .assistant_navigation,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              '${LocaleData.start.getString(context)}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                border: Border.all(
                                                    color: Colors.black),
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _routeDetailPannelController
                                                              .isAttached
                                                          ? _routeDetailPannelController
                                                                  .isPanelClosed
                                                              ? Icons
                                                                  .short_text_outlined
                                                              : Icons.map_sharp
                                                          : Icons
                                                              .short_text_outlined,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Semantics(
                                                      sortKey:
                                                          const OrdinalSortKey(
                                                              2),
                                                      onDidGainAccessibilityFocus:
                                                          openRoutePannel,
                                                      child: Text(
                                                        _routeDetailPannelController
                                                                .isAttached
                                                            ? _routeDetailPannelController
                                                                    .isPanelClosed
                                                                ? "${LocaleData.steps.getString(context)}"
                                                                : "${LocaleData.maps.getString(context)}"
                                                            : "${LocaleData.steps.getString(context)}",
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
                                    margin: EdgeInsets.only(
                                        left: 17, top: 12, right: 17),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 25,
                                                        margin: EdgeInsets.only(
                                                            right: 8),
                                                        child: SvgPicture.asset(
                                                            "assets/StartpointVector.svg"),
                                                      ),
                                                      Semantics(
                                                        label:
                                                            "Steps preview,    You are heading from",
                                                        child: Text(
                                                          "${PathState.sourceName}",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "Roboto",
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xff0e0d0d),
                                                            height: 25 / 16,
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
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
                                                      margin: EdgeInsets.only(
                                                          right: 8),
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
                                                            ? "${PathState.destinationName} ${LocaleData.willbe.getString(context)}  ${LocaleData.getProperty(tools.angleToClocks3(angle, context), context)}"
                                                            : PathState
                                                                .destinationName,
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xff0e0d0d),
                                                          height: 25 / 16,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
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

  int _rating = 0;
  String _feedback = '';
  PanelController _feedbackController = PanelController();
  TextEditingController _feedbackTextController = TextEditingController();


  bool showFeedback = false;
  double minHight = 0.0;
  void __feedbackControllerUp(double d) {
    _feedbackController.animatePanelToPosition(d);
  }
  void __feedbackControllerDown() {
    _feedbackController.close();
  }





  Widget feedbackPanel(BuildContext context) {
    minHight = MediaQuery.of(context).size.height/2.5;
    return Visibility(
      visible: showFeedback,
      child: Semantics(
        excludeSemantics: true,
        child: SlidingUpPanel(
          controller: _feedbackController,
          minHeight: minHight,
          maxHeight: MediaQuery.of(context).size.height-20,
          snapPoint: 0.9,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ],
          panel: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    "How was your navigation experience ?",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Your Feedback Helps Us Do Better",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffa1a1aa),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 36),
                  Text(
                    "Rate Your Experience",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            _rating = index + 1;
                            if (_rating >=4) {
                              __feedbackControllerUp(0.3);
                              // _feedbackTextController.clear();
                            } else if (_rating <= 3) {
                              __feedbackControllerUp(0.9);

                            }else if(_rating == 3 || _rating==4){
                              _feedbackTextController.clear();
                            }
                            print("minHight");
                            print(minHight);

                            setState(() {

                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: index < _rating ? SvgPicture.asset('assets/ratingStarFilled.svg', width: 48.0, height: 48.0,) : SvgPicture.asset('assets/ratingStarBorder.svg', width: 48.0, height: 48.0,),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_rating > 0 && _rating < 4) ...[
                    SizedBox(height: 16),
                    Text(
                      "Select the Issues ",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff000000),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    ChipFilterWidget(

                      options: ['Bad map route', 'Wrong turns', 'UI Issue', 'App speed','Search Function','Map Accuracy'],
                      onSelected: (selectedOption) {
                        print('Selected: $selectedOption');
                        // Handle the selection here
                        _feedbackTextController.text = selectedOption;
                        _feedback = _feedbackTextController.text;
                        print(_feedback);
                        setState(() {

                        });
                      },

                    ),
                    SizedBox(height: 20),
                    Text(
                      "Add a Detailed Review",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff000000),
                        height: 24/18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                        controller: _feedbackTextController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Please share your thoughts...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: false,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value)  {
                          _feedback = value;
                          print("onchange--");
                          setState(() {

                          });
                        }
                    ),
                  ],
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_rating > 0 && (_rating >= 4 || _feedback.length >= 5)) ? () {
                        // TODO: Submit feedback
                        print('Rating: $_rating');
                        var signInBox = Hive.box('UserInformation');
                        print(signInBox.keys);
                        var infoBox=Hive.box('SignInDatabase');
                        String accessToken = infoBox.get('accessToken');
                        //print('loadInfoToFile');
                        print(infoBox.get('userId'));
                        //String userId = signInBox.get("sId");
                        //String username = signInBox.get("username");





                        RatingsaveAPI().saveRating(_feedback, _rating,UserCredentials().getUserId(), UserCredentials().getuserName(), PathState.sourcePolyID, PathState.destinationPolyID,"com.iwayplus.navigation");

                        if (_feedback.isNotEmpty) {
                          print('Feedback: $_feedback');
                        }
                        showFeedback= false;
                        _feedbackController.hide();
                        print("_feedbackTextController.clear()");
                        print(_feedbackTextController.text);
                        _feedbackTextController.clear();
                        print(_feedbackTextController.text);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
                              (Route<dynamic> route) => false,
                        );

                      }
                          : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Submit',
                          style: TextStyle(fontSize: 18,color: Colors.white),

                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_rating > 0 && (_rating >= 4 || _feedback.split(' ').where((w) => w.isNotEmpty).length >= 0))
                            ? Color(0xff24B9B0)
                            : Colors.grey,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),

                      ),
                    ),
                  ),
                  SizedBox(height: 36),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitFeedback() {
    String feedbackMessage = 'Rating: $_rating\n';
    if (_feedback.isNotEmpty) {
      feedbackMessage += 'Feedback: $_feedback';
    }

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(feedbackMessage),
    //     duration: Duration(seconds: 3),
    //   ),
    // );
    _feedbackController.close();
    _feedbackTextController.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => VenueSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void alignMapToPath(List<double> A, List<double> B) async {
    print("a------ $A");
    print("b------- $B");
    mapState.tilt = 33.5;
    List<double> val =
        tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt(), building.patchData[user.Bid]);
    mapState.target = LatLng(val[0], val[1]);
    mapState.bearing = tools.calculateBearing(A, B);
    await _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
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
  Timer? _messageTimer;

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
  // void _addCircle(double l1,double l2){
  //   _updateCircle();
  // }

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

    try {
      //implement the turn functionality.
      // if(UserState.reachedLift){
      //    updateCircle(user.lat,user.lng);
      //     UserState.reachedLift=false;
      //
      // }

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

          // print("pointss matchedddd ${getPoints}");
          for (int i = 0; i < getPoints.length; i++) {
            // print("---length  = ${getPoints.length}");
            // print("--- point  = ${getPoints[i]}");
            // print("---- usercoord  = ${user.showcoordX} , ${user.showcoordY}");
            // print("--- val  = $val");
            // print("--- isPDRStop  = $isPdrStop");

            //print("turn corrds");

            //print("${getPoints[i][0]}, ${getPoints[i][1]}");
            if (isPdrStop && val == 0) {
              // print("points unmatchedddd");

              Future.delayed(Duration(milliseconds: 1500))
                  .then((value) => {
                    StartPDR(),


                  });



              setState(() {

                isPdrStop = false;
              });

              break;
            }
            if (getPoints[i][0] == user.showcoordX &&
                getPoints[i][1] == user.showcoordY) {
              // print("points matchedddddddd");

              StopPDR();
              getPoints.removeAt(i);
              break;
            }
          }
        }
      }
    } catch (e) {}

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
                            width: 65,
                            decoration: BoxDecoration(
                              color: Color(0xffDF3535),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: TextButton(
                                onPressed: (){
                                  setState(() {
                                    StopPDR();
                                    PathState.sourceX = user.coordX;
                                    PathState.sourceY = user.coordY;
                                    PathState.sourceFloor = user.floor;
                                    PathState.sourceBid = user.Bid;
                                    PathState.sourceLat = user.lat;
                                    PathState.sourceLng = user.lng;
                                    PathState.sourceName = "Your current location";

                                    user.temporaryExit = true;
                                    user.isnavigating = false;
                                    _isRoutePanelOpen = true;
                                    _isnavigationPannelOpen = false;
                                    print("building floor ${building.floor}");
                                    setCameraPosition(pathMarkers[building.floor[user.Bid]]!);
                                  });
                                },
                                child: Text(
                                  "${LocaleData.exit.getString(context)}",
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
              context: context,
            )
          ],
        ));
  }

  void exitNavigation(){
    setState(() {
      if(PathState.didPathStart){
        showFeedback = true;
        Future.delayed(Duration(seconds: 5));
        _feedbackController.open();
        _feedbackTextController.clear();
      }
    });
    markerSldShown = true;
    focusturnArrow.clear();
    clearPathVariables();
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
            user.showcoordY.toInt(), building.patchData[user.Bid]);
        markers[user.Bid]?[0] = customMarker.move(
            LatLng(lvalue[0], lvalue[1]),
            markers[user.Bid]![0]);
      }
    });
  }

  bool rerouting = false;
  Widget reroutePannel(context) {
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
                                key: rerouteButton,
                                onPressed: () async {
                                  autoreroute();
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
                                              borderRadius: BorderRadius.circular(8.0),
                                              border: Border.all(color: Color(0xff000000))
                                          ),
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
        visible: _isBuildingPannelOpen && !user.isnavigating ,
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
                              "You are near ${user.locationName}, ${LocaleData.floor.getString(context)} ${user.floor}",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff292929),
                                height: 25 / 18,
                              ),
                              textAlign: TextAlign.left,
                              softWrap: true,
                              overflow: TextOverflow.visible,
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
        return (marker.union(Set<Marker>.of(markers[user.Bid] ?? []))) ;
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

    // Existing logic to union polylines
    polylines.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });

    interBuildingPath.forEach((key, value) {
      poly = poly.union(value).union(focusturn);
    });

    // Conditional logic to add additional polylines


    buildingAllApi.allBuildingID.forEach((key,value){
      if (singleroute[key] != null &&
          singleroute[key]![building.floor[key]] != null) {
        poly = poly.union(singleroute[key]![
        building.floor[key]]!);
      }
    });

    return poly;
  }


  void _updateMarkers(double zoom) {
    print(zoom);
    if (building.updateMarkers) {
      Set<Marker> updatedMarkers = Set();
      if (user.isnavigating) {
        setState(() {
          Markers.forEach((marker) {
            List<String> words = marker.markerId.value.split(' ');
            if (marker.markerId.value.contains("Room")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Rest")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Entry")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Building")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (marker.markerId.value.contains("Lift")) {
              Marker _marker = customMarker.visibility(false, marker);
              updatedMarkers.add(_marker);
            }
            if (building.ignoredMarker.contains(words[1])) {
              if (marker.markerId.value.contains("Door")) {
                Marker _marker = customMarker.visibility(false, marker);
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
      } else {
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
    print("close navigation");
    String destname = PathState.destinationName;
    List<int> tv = tools.eightcelltransition(user.theta);
    double angle = tools.calculateAngle2(
        [user.showcoordX, user.showcoordY],[user.showcoordX + tv[0], user.showcoordY + tv[1]],
        [PathState.destinationX, PathState.destinationY]);
    String direction = tools.angleToClocks3(angle, context);
    print("closing navigation $angle ${[user.showcoordX, user.showcoordY]}     ${[user.showcoordX + tv[0], user.showcoordY + tv[1]]}     ${[PathState.destinationX, PathState.destinationY]}");
    flutterTts.pause().then((value){
      speak(
          user.convertTolng("You have reached ${destname}. It is ${direction}",
              "", 0.0, context, angle,
              destname: destname),
          _currentLocale);
    });
    clearPathVariables();
    StopPDR();
    PathState.didPathStart = true;
    _isnavigationPannelOpen = false;
    user.temporaryExit = true;
    user.reset();
    PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, null, 0);
    selectedroomMarker.clear();
    pathMarkers.clear();
    PathState.path.clear();
    PathState.sourcePolyID = "";
    PathState.destinationPolyID = "";
    singleroute.clear();
    fitPolygonInScreen(patch.first);
    Future.delayed(Duration.zero, () async {
      setState(() {
        focusturnArrow.clear();
      });
    });

    // setState(() {
    if (markers.length > 0) {
      List<double> lvalue =
          tools.localtoglobal(user.showcoordX.toInt(), user.showcoordY.toInt(), building.patchData[user.Bid]);
      markers[user.Bid]?[0] = customMarker.move(
          LatLng(lvalue[0], lvalue[1]), markers[user.Bid]![0]);
    }
    // });
    //avigator.push(context, MaterialPageRoute(builder: (context) => UserExperienceRatingScreen()));
    // showFeedback = true;
    // Future.delayed(Duration(seconds: 5));
    // _feedbackController.open();
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
    //       (Route<dynamic> route) => false,
    // );

  }

  void onLandmarkVenueClicked(String ID,
      {bool DirectlyStartNavigation = false}) async {
    print('DirectlyStartNavigation');
    final snapshot = await building.landmarkdata;
    building.selectedLandmarkID = ID;
    
    _isBuildingPannelOpen = false;

    if(!DirectlyStartNavigation) {


        if (snapshot!.landmarksMap![ID]!.floor != 0) {
          List<PolyArray> prevFloorLifts = findLift(
              tools.numericalToAlphabetical(0),
              building.polylinedatamap[
              snapshot!.landmarksMap![ID]!.buildingID!]!.polyline!.floors!);
          List<PolyArray> currFloorLifts = findLift(
              tools.numericalToAlphabetical(
                  snapshot!.landmarksMap![ID]!.floor!),
              building.polylinedatamap[
              snapshot!.landmarksMap![ID]!.buildingID!]!.polyline!.floors!);
          print("print cubicle data");
          for (int i = 0; i < prevFloorLifts.length; i++) {
            print(prevFloorLifts[i].name);
          }
          print("data2");
          for (int i = 0; i < currFloorLifts.length; i++) {
            print(currFloorLifts[i].name);
          }
          List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);
          print("dvalue");
          print(dvalue);
          UserState.xdiff = dvalue[0];
          UserState.ydiff = dvalue[1];
        } else {
          UserState.xdiff = 0;
          UserState.ydiff = 0;
        }







     List<int> value=[snapshot!.landmarksMap![ID]!.coordinateX!,snapshot!.landmarksMap![ID]!.coordinateY!];
      List<double> coords=tools.localtoglobal(value[0], value[1],building.patchData[snapshot!.landmarksMap![ID]!.buildingID]);
      int floor=snapshot!.landmarksMap![ID]!.floor!;

        print("value.landmarksMap![ID]!.floor");
        try{
          List<Nodes>? nodes = building.polylinedatamap[snapshot.landmarksMap![ID]!.buildingID]!.polyline!.floors!.firstWhere((element) => element.floor == tools.numericalToAlphabetical(floor)).polyArray!.firstWhere((element) => element.id == snapshot!.landmarksMap![ID]!.properties!.polyId).nodes;
          List<LatLng>corners = [];
          for (var element in nodes!) {
            List<double> value = tools.localtoglobal(element.coordx!, element.coordy!, building.patchData[snapshot.landmarksMap![ID]!.buildingID]);
            corners.add(LatLng(value[0], value[1]));
          }
          _polygon.add(Polygon(
            polygonId: PolygonId("$ID"),
            points: corners,
            fillColor: Colors.lightBlueAccent.withOpacity(0.4),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ));
        }catch(e){
          
        }



     _googleMapController.animateCamera(
       CameraUpdate.newLatLngZoom(
         LatLng(coords[0], coords[1]),
         22,
       ),
     );

     if(building.floor[snapshot!.landmarksMap![ID]!.buildingID]!=floor){

       building.floor[snapshot!.landmarksMap![ID]!.buildingID!]=floor;
       createRooms(building.polylinedatamap[snapshot!.landmarksMap![ID]!.buildingID]!, floor);
       createMarkers(snapshot!, floor);

     }

      setState(() {
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
        building.selectedLandmarkID = ID;
        building.ignoredMarker.clear();
        building.ignoredMarker.add(ID);
        _isBuildingPannelOpen = false;
        _isRoutePanelOpen = false;
        singleroute.clear();
        _isLandmarkPanelOpen = true;
        PathState.directions = [];
        interBuildingPath.clear();


        addselectedMarker(LatLng(coords[0], coords[1]));
      });
    }else{
    setState(() {
      if (user.coordY != 0 && user.coordX != 0) {
        PathState.sourceX = user.coordX;
        PathState.sourceY = user.coordY;
        PathState.sourceFloor = user.floor;
        PathState.sourcePolyID = user.key;
        print("object ${PathState.sourcePolyID}");
        PathState.sourceName = "Your current location";
        PathState.destinationPolyID =
        building.selectedLandmarkID!;
        PathState.destinationName = snapshot!
            .landmarksMap![
        building.selectedLandmarkID]!
            .name ??
            snapshot!
                .landmarksMap![
            building.selectedLandmarkID]!
                .element!
                .subType!;
        PathState.destinationFloor = snapshot!
            .landmarksMap![building.selectedLandmarkID]!
            .floor!;
        PathState.sourceBid = user.Bid;

        PathState.destinationBid = snapshot!
            .landmarksMap![building.selectedLandmarkID]!
            .buildingID!;

        setState(() {
          print("valuechanged");
          calculatingPath = true;
        });
        Future.delayed(Duration(seconds: 1), () {
          calculateroute(snapshot!.landmarksMap!)
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
        PathState.destinationName = snapshot!.landmarksMap![
        building.selectedLandmarkID]!
            .name ??
            snapshot!.landmarksMap![
            building.selectedLandmarkID]!
                .element!
                .subType!;
        PathState.destinationFloor = snapshot!.landmarksMap![building.selectedLandmarkID]!
            .floor!;
        building.selectedLandmarkID = "";
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SourceAndDestinationPage(
                      DestinationID:
                      PathState.destinationPolyID,
                      user: user,
                    ))).then((value) {
          if (value != null) {
            fromSourceAndDestinationPage(value);
          }
        });
      }
    });
    }
  }

  void fromSourceAndDestinationPage(List<String> value) {
    _isBuildingPannelOpen = false;
    markers.clear();
    building.landmarkdata!.then((land) {
      print("Himanshuchecker ${land.landmarksMap}");
      print("Himanshuchecker ${value[0]}");
      building.selectedLandmarkID =
          land.landmarksMap![value[0]]!.properties!.polyId!;
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
      setState(() {
        calculatingPath = true;
        _isLandmarkPanelOpen = true;
      });
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        calculatingPath = false;
        calculateroute(land.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
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
        PathState.sourceName = user.key == ID ? "Your current location":value.landmarksMap![ID]!.name!;
        PathState.sourceBid = value.landmarksMap![ID]!.buildingID!;
        PathState.path.clear();
        PathState.directions.clear();
        // PathState.sourceBid = user.Bid;
        // PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
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
        // PathState.sourceBid = user.Bid;
        // PathState.destinationBid = value.landmarksMap![ID]!.buildingID!;
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
      final Uint8List greytorch =
          await getImagesFromMarker('assets/previewarrow.png', 75);
      // BitmapDescriptor greytorch = await BitmapDescriptor.fromAssetImage(
      //   ImageConfiguration(size: Size(15, 15)),
      //   'assets/previewarrow.png',
      // );
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
           building.patchData[turn.Bid]);
      List<double> latlng2 = tools.localtoglobal(nextPoint[0], nextPoint[1],
           building.patchData[turn.Bid]);

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
            icon: BitmapDescriptor.fromBytes(greytorch),
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
    LatLng currentLatLng = position.target;
    String closestBuildingId = "";
    double? minDistance;

    Building.allBuildingID.forEach((key, value) {
      if (key != buildingAllApi.outdoorID) {
        num distance = geo.Geodesy().distanceBetweenTwoGeoPoints(
          geo.LatLng(value.latitude, value.longitude),
          geo.LatLng(currentLatLng.latitude, currentLatLng.longitude),
        );

        print("Distance for $key is $distance");

        // Update closestBuildingId if this building is closer
        if (minDistance == null || distance < minDistance!) {
          minDistance = distance.toDouble();
          closestBuildingId = key;
        }
      }
    });

    // Store the nearest building ID
    if (closestBuildingId.isNotEmpty) {
      buildingAllApi.setStoredString(closestBuildingId);
    }

    print("Closest building ID is $closestBuildingId");
  }
  Set<Circle> circles = Set();

  @override
  void dispose() {
    disposed=true;
    flutterTts.stop();
    _googleMapController.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    compassSubscription.cancel();
    flutterTts.cancelHandler;
    btadapter.stopScanning();
    _messageTimer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  List<String> scannedDevices = [];

  Set<gmap.Polyline> finalSet = {};

  bool ispdrStart = false;
  bool semanticShouldBeExcluded = false;
  bool isSemanticEnabled = false;
  bool isLocalized=false;
  IconData _mainIcon = Icons.volume_up_outlined;

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
      child: Scaffold(
        body: Stack(
          children: [
            detected
                ? Semantics(
                excludeSemantics: true,
                child: ExploreModePannel())
                : Semantics(
                excludeSemantics: true, child: Container()),
            Stack(
              children: [Semantics(
                excludeSemantics: true,
                child: Container(
                  child: GoogleMap(
                    padding: EdgeInsets.only(
                        left: 20), // <--- padding added here
                    initialCameraPosition: _initialCameraPosition,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
mapToolbarEnabled: false,
                    polygons: patch
                        .union(getCombinedPolygons())
                        .union(otherpatch)
                        .union(_polygon),
                    polylines: getCombinedPolylines(),
                    markers: getCombinedMarkers()
                        .union(_markers)
                        .union(focusturnArrow),
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
                      zoomWhileWait(buildingAllApi.allBuildingID,controller);
                      print("tumhari galti hai sb saalo");
                      _initMarkers();
                    },
                    onCameraMove: (CameraPosition cameraPosition) {
                      // print("plpl ${cameraPosition.tilt}");
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
                      // _updateMarkers(cameraPosition.zoom);
                      if (cameraPosition.zoom < 17) {
                        _markers.clear();
                        markerSldShown = false;
                      } else {
                        if (user.isnavigating) {
                          _markers.clear();
                          markerSldShown = false;
                        } else {
                          markerSldShown = true;
                        }
                      }
                      if (markerSldShown) {
                        _updateMarkers11(cameraPosition.zoom);
                      } else {
                        print("Notshow");
                      }

                      // _updateEntryMarkers11(cameraPosition.zoom);
                      //_markerLocations.clear();
                      // print("Zoom level: ${cameraPosition.zoom}");
                    },
                    onCameraIdle: () {
                      if (!mapState.interaction) {
                        mapState.interaction2 = true;
                      }
                    },
                    onCameraMoveStarted: () {
                      user.building = building;
                      mapState.interaction2 = false;
                    },
                    circles: circles,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: screenWidth,
                  height: 30,
                  color: Colors.white,
                ),
              )]
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

                    SpeedDial(
                      icon: _mainIcon,
                      backgroundColor: Colors.white,
                      visible: true,
                      curve: Curves.bounceInOut,
                      children: [
                        SpeedDialChild(
                          child: Icon(Icons.volume_up_outlined, color: Colors.black),
                          backgroundColor: Colors.white,
                          onTap: () => {
                            setState(() {
                              _mainIcon=Icons.volume_up_outlined;
                            }),
                            UserState.ttsAllStop=false,
                            UserState.ttsOnlyTurns=false,
                            print('Pressed Read Later')
                          },
                        ),
                        SpeedDialChild(
                          child: Icon(Icons.volume_down_outlined, color: Colors.black),
                          backgroundColor: Colors.white,
                          onTap: () => {
                            setState(() {
                              _mainIcon=Icons.volume_down_outlined;
                            }),
                            UserState.ttsOnlyTurns=true,
                            UserState.ttsAllStop=false,
                          },

                        ),
                        SpeedDialChild(
                          child: Icon(Icons.volume_off_outlined, color: Colors.black),
                          backgroundColor: Colors.white,
                          onTap: () => {
                            setState(() {
                              _mainIcon=Icons.volume_off_outlined;
                            }),
                            UserState.ttsAllStop=true,
                            UserState.ttsOnlyTurns=false,

                          },
                        ),
                      ],
                    ),
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
                                  user.move(context).then((value) {
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
                    // Text("coord [${user.coordX},${user.coordY}] \n"
                    //     "showcoord [${user.showcoordX},${user.showcoordY}] \n"
                    //     "floor ${user.floor}\n"
                    //     "userBid ${user.Bid} \n"
                    //     "index ${user.pathobj.index} \n"
                    //     "node ${user.path.isNotEmpty ? user.path[user.pathobj.index] : ""}"),
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
                          (Building.numberOfFloorsDelhi[buildingAllApi.getStoredString()]??[0]).length, (int i) {
                          //print("building.numberOfFloors[buildingAllApi.getStoredString()]!");
                          List<int> floorList = Building.numberOfFloorsDelhi[buildingAllApi.getStoredString()]??[0];
                          List<int> revfloorList = floorList;
                          revfloorList.sort();
                          // building.numberOfFloors[buildingAllApi
                          //     .getStoredString()];
                          //
                          // print(building.numberOfFloors!);
                          return SpeedDialChild(
                            child: Semantics(
                              label: "${revfloorList[i]}",
                              child: Text(
                                revfloorList[i] == 0 ? 'G' : '${revfloorList[i]}',
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 19 / 16,
                                ),
                              ),
                            ),
                            backgroundColor: pathMarkers[i] == null? Colors.white : Color(0xff24b9b0),
                            onTap: () {
                              _polygon.clear();
                              circles.clear();
                              // _markers.clear();
                              // _markerLocationsMap.clear();
                              // _markerLocationsMapLanName.clear();

                              building.floor[buildingAllApi
                                  .getStoredString()] = revfloorList[i];
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
                              // Markers.clear();
                              building.landmarkdata!
                                  .then((value) {
                                createMarkers(
                                  value,
                                  building.floor[buildingAllApi
                                      .getStoredString()]!,
                                  bid: buildingAllApi
                                      .getStoredString()
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
                        onPressed:() async {
                          if(!user.isnavigating && !isLocalized){

                            btadapter.stopScanning();

                            if(Platform.isAndroid){
                              btadapter.startScanning(apibeaconmap);
                            }else{
                              btadapter.startScanningIOS(apibeaconmap);
                            }
                            setState(() {
                              isLocalized=true;
                              resBeacons = apibeaconmap;
                            });
                            late Timer _timer;
                            _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
                              localizeUser().then((value)=>{
                                setState((){
                                  isLocalized=false;
                                })
                              });
                              print("localize user is calling itself.....");
                              _timer.cancel();
                            });
                          }

                        },
                        child: Semantics(
                          label: "Localize",
                          onDidGainAccessibilityFocus:
                          close_isnavigationPannelOpen,
                          child:(isLocalized)?lott.Lottie.asset(
                            'assets/localized.json', // Path to your Lottie animation
                            width: 70,
                            height: 70,
                          ): Icon(
                            Icons.my_location_sharp,
                            color: Colors.black,
                          ),
                        ),
                        backgroundColor:  Colors
                            .white, // Set the background color of the FAB
                      ),
                    ),
                    SizedBox(height: 28.0),
                    !user.isnavigating
                        ? FloatingActionButton(
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
                              speak(
                                  "${LocaleData.exploremodenabled.getString(context)}",
                                  _currentLocale);
                              isLiveLocalizing = true;
                              HelperClass.showToast(
                                  "Explore mode enabled");
                              _exploreModeTimer =
                                  Timer.periodic(
                                      Duration(
                                          milliseconds: 5000),
                                          (timer) async {
                                            if(Platform.isAndroid){
                                              btadapter.startScanning(apibeaconmap);
                                            }else{
                                              btadapter.startScanningIOS(apibeaconmap);
                                            }
                                        Future.delayed(Duration(
                                            milliseconds: 2000))
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
                    )
                        : Container(), // Adjust the height as needed// Adjust the height as needed
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
                        fromSourceAndDestinationPage, user: user,
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
            feedbackPanel(context),
            navigationPannel(),
            reroutePannel(context),
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
            (!user.initialallyLocalised && !building.qrOpened)?
                Container(
                  height: screenHeight,
                  width: screenWidth,
                  color: Colors.white.withOpacity(0.8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      lott.Lottie.asset(
                        'assets/loding_animation.json', // Path to your Lottie animation
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 56,right: 56 ),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: Colors.grey,valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      )
                    ],
                  ),
                )

            :Container()
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

class CircleAnimation {
  final AnimationController controller;
  final Animation<double> animation;

  CircleAnimation(this.controller, this.animation);
}
