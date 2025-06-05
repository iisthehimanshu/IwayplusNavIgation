import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data' as typed_data;
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math' as math;
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:collection/collection.dart' as pac;
import 'package:fluster/fluster.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fuzzy/bitap/bitap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:iwaymaps/NAVIGATION/arScreen.dart';
import 'package:iwaymaps/NAVIGATION/pathState.dart';
import 'package:iwaymaps/NAVIGATION/singletonClass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

import '../IWAYPLUS/API/buildingAllApi.dart';
import '../IWAYPLUS/CLUSTERING/InitMarkerModel.dart';
import '../IWAYPLUS/CLUSTERING/MapHelper.dart';
import '../IWAYPLUS/CLUSTERING/MapMarkers.dart';
import '../IWAYPLUS/Elements/HelperClass.dart';
import '../IWAYPLUS/Elements/locales.dart';
import 'API/ladmarkApi.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'LatLngTween.dart';
import 'MapState.dart';
import 'Sensor/SensorManager.dart';
import 'UserState.dart';
import 'buildingState.dart';
import 'cutommarker.dart';
import 'navigationTools.dart';
import 'package:geodesy/geodesy.dart' as geo;

class ExploreScreen extends StatefulWidget {
  polylinedata poly;
  patchDataModel patchData;
  bool destiPoint;
  String nearestBeacon;
  ExploreScreen({super.key,required this.poly,required this.patchData,required this.destiPoint,required this.nearestBeacon});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin{
  MapState mapState = new MapState();
  Timer? PDRTimer;
  Timer? _exploreModeTimer;
  Timer? _exploreModeTimer2;
  String maptheme = "";
  var _initialCameraPosition = CameraPosition(
    target: LatLng(60.543833319119475, 77.18729871127312),
    zoom: 20,
  );
  late GoogleMapController _googleMapController;
  Set<Polygon> patch = Set();
  Set<Polygon> otherpatch = Set();
  Set<Polygon> blurPatch = Set();
  Map<String, Set<gmap.Polyline>> polylines = Map();
  Set<gmap.Polyline> otherpolylines = Set();
  Set<gmap.Polyline> focusturn = Set();
  Set<Marker> focusturnArrow = Set();
  Map<String, Set<Polygon>> closedpolygons = Map();
  Set<Polygon> otherclosedpolygons = Set();
  Set<Marker> Markers = Set();
  Set<Marker> builidngNameMarker = Set();
  Map<String, Set<Marker>> selectedroomMarker = Map();
  Map<String, Map<int, Set<Marker>>> pathMarkers = {};
  Map<String, List<Marker>> markers = Map();
  // Building SingletonFunctionController.building = Building(floor: Map(), numberOfFloors: Map());
  Map<String, Map<int, Set<gmap.Polyline>>> singleroute = {};
  Map<int, Set<Marker>> dottedSingleRoute = {};
  // BLueToothClass SingletonFunctionController.btadBLueToothClass();
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
  late final typed_data.Uint8List userloc;
  late final typed_data.Uint8List userlocdebug;

  // HashMap<String, beacon> SingletonFunctionController.apibeaconmap = HashMap();
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
  final List<InitMarkerModel> mapMarkerLocationMapAndName = [];
  final Map<LatLng, String> _markerLocationsMap = {};
  final Map<LatLng, String> _markerLocationsMapLanName = {};
  final Map<LatLng, String> _markerLocationsMapLanNameBID = {};
  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  ///
  Set<Polygon> _polygon = Set();
  Set<Polygon> cachedPolygon = {};
  Set<Polygon> getCombinedPolygons() {
    if(cachedPolygon.isEmpty){
      Set<Polygon> polygons = Set();

      closedpolygons.forEach((key, value) {
        polygons = polygons.union(value);
      });
      polygons.union(otherpatch);
      polygons.union(_polygon);
      polygons.union(blurPatch);
      polygons.union(patch);
      cachedPolygon = polygons;
      return polygons;
    }
    return cachedPolygon.union(patch).union(otherpatch).union(blurPatch);
  }
  Set<Marker> getCombinedMarkers() {
    Set<Marker> combinedMarkers = Set();
    if(user.floor ==
        SingletonFunctionController
            .building.floor[buildingAllApi.getStoredString()]){
      if (_isLandmarkPanelOpen) {
        selectedroomMarker.forEach((key, value) {
          combinedMarkers = combinedMarkers.union(value);
        });
      }
    }else{
      if (_isLandmarkPanelOpen) {
        selectedroomMarker.forEach((key, value) {
          combinedMarkers = combinedMarkers.union(value);
        });
      }
    }
    buildingAllApi.allBuildingID.forEach((key, value) {
      if (pathMarkers[key] != null &&
          pathMarkers[key]![SingletonFunctionController.building.floor[key]] !=
              null) {
        combinedMarkers = combinedMarkers.union(pathMarkers[key]![
        SingletonFunctionController.building.floor[key]]!);
      }
      if ((!_isRoutePanelOpen || !_isnavigationPannelOpen) &&
          markers[key] != null &&
          user.floor == SingletonFunctionController.building.floor[key]) {
        combinedMarkers = combinedMarkers.union(Set<Marker>.of(markers[key]!));
      }
    });

    // Always union the general Markers set at the end
    if (SingletonFunctionController.building.floor[user.bid] == user.floor) {
      markers.forEach((key, value) {
        combinedMarkers = combinedMarkers.union(Set<Marker>.of(value));
      });
    }
    return combinedMarkers;
  }



  String lastBeaconValue = "";

  PolygonId matchPolygonId = PolygonId("");
  List<LatLng> matchPolygonPoints = [];
  Future<void> addselectedRoomMarker(List<LatLng> polygonPoints,
      {Color? color}) async {
    selectedroomMarker.clear(); // Clear existing markers
    matchPolygonId = PolygonId("$polygonPoints");
    matchPolygonPoints = polygonPoints;
    _polygon.clear(); // Clear existing markers
    _polygon.add(Polygon(
      polygonId: PolygonId("$polygonPoints"),
      points: polygonPoints,
      fillColor: color != null
          ? color.withOpacity(0.4)
          : Colors.lightBlueAccent.withOpacity(0.4),
      strokeColor: color ?? Colors.blue,
      strokeWidth: 2,
    ));
    cachedPolygon.clear();// Clear existing markers

    List<geo.LatLng> points = [];
    for (var e in polygonPoints) {
      points.add(geo.LatLng(e.latitude, e.longitude));
    }
    Uint8List iconMarker =
    await getImagesFromMarker('assets/IwaymapsDefaultMarker.png', 140);
    setState(() {
      if (selectedroomMarker.containsKey(buildingAllApi.getStoredString())) {
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
              markerId: MarkerId('selectedroomMarker'),
              position: calculateRoomCenter(polygonPoints),
              icon: BitmapDescriptor.fromBytes(iconMarker),
              onTap: () {}),
        );
      } else {
        selectedroomMarker[buildingAllApi.getStoredString()] = Set<Marker>();
        selectedroomMarker[buildingAllApi.getStoredString()]?.add(
          Marker(
              markerId: MarkerId('selectedroomMarker'),
              position: calculateRoomCenter(polygonPoints),
              icon: BitmapDescriptor.fromBytes(iconMarker),
              onTap: () {}),
        );
      }
    });
  }
  Timer? _timer;
  @override
  void initState(){
    flutterTts = FlutterTts();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800), // Adjust for smoother animation
      vsync: this,
    );
    // Create the animation
    _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
      ..addListener(() {
        _updateCircle(user.lat, user.lng);
      });
    magnetoData.startMagnetometer();
    createPatch(widget.patchData);
    createRooms(widget.poly, SingletonFunctionController.building.floor[buildingAllApi.getStoredString()]!.floor()??0);
    paintUser(widget.nearestBeacon,null,null);
    handleCompassEvents();
    startOrientationListener();
      // _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      //   if (Platform.isAndroid) {
      //     SingletonFunctionController.btadapter
      //         .startScanning(
      //         SingletonFunctionController
      //             .apibeaconmap);
      //   }else{
      //     SingletonFunctionController.btadapter
      //         .startScanningIOS(
      //         SingletonFunctionController
      //             .apibeaconmap);
      //   }
      //   Future.delayed(Duration(seconds: 2), () async {
      //    await realTimeReLocalizeUser(SingletonFunctionController.apibeaconmap);
      //   });
      // });
    super.initState();
  }

  @override
  void dispose(){
    magnetoData.stopMagnetometer();
    _accelerometerSub!.cancel();
    _timer?.cancel();
    _controller.dispose();
    _animationController!.dispose();
    _animation.removeListener((){});
    super.dispose();
  }

  StreamSubscription? _accelerometerSub;
  void startOrientationListener() {
    _accelerometerSub = accelerometerEvents.listen((AccelerometerEvent event) {
      double x= event.x;
      double y = event.y;
      double z = event.z;

      // Normalize the vector
      double magnitude = sqrt(x * x + y * y + z * z);
      x /= magnitude;
      y /= magnitude;
      z /= magnitude;

      // Threshold to detect if device is upright (portrait, screen vertical)
      // When held vertically facing forward: z ≈ 0, y ≈ 1, x ≈ 0
      print("_cameraOpened ${x.abs()} ${_cameraOpened}");
      if ((z.abs() < 0.4) && (y > 0.8)){
        print("Device held vertically!");
        openCamera();
      }else if(x.abs() > 0.13 && _cameraOpened){
        // Held horizontally - Landscape
        _cameraOpened = false;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) Navigator.of(context).pop();
        });
        // Closes AR screen and goes back to Explore Mode
        print('Device is held horizontally — returning to Explore Mode');
      }
    });
  }
  bool _cameraOpened = false;

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 700),
    );
  }


  void openCamera() {
    if (!_cameraOpened) {
      _cameraOpened = true;
      print("Opening AR Camera...");
      Navigator.of(context).push(_fadeRoute(const ArScreen()));
      // Navigate to AR screen or initialize camera
      // Future.delayed(Duration(seconds: 5), () {
      //   _cameraOpened = false; // Allow retrigger after delay
      // });
    }
  }



  Future<void> speak(String msg, String lngcode, {bool prevpause = false}) async {
    if(kIsWeb){
      return;
    }
    if (!UserState.ttsAllStop){
      if (prevpause) {
        await flutterTts.pause();
      }
      try {
        if (lngcode == "hi") {
          if (Platform.isAndroid) {
            await flutterTts.setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
          } else {
            await flutterTts.setVoice({"name": "Lekha", "locale": "hi-IN"});
          }
        } else {
          await flutterTts.setVoice({"name": "en-US-language", "locale": "en-US"});
        }
        await flutterTts.stop();
        if (Platform.isAndroid) {
          await flutterTts.setSpeechRate(0.7);
        } else {
          await flutterTts.setSpeechRate(0.55);
        }
        await flutterTts.setPitch(1.0);
        // Check if Semantic Mode is enabled
          await flutterTts.speak(msg);
      } catch (e) {
        print("Error during TTS: $e");
      }
    }
  }
  String firstValue = "";
  LatLng lastExplorePosition = LatLng(0.0, 0.0);
  List<int> currentBinSIze = [];
  Map<String, double> sumMap = new Map();
  Map<String, double> sortedsumMapfordebug = new Map();
  String EM_lastBeaconValue = "";
  List<Landmarks> EM_NearLandmarks = [];
  Set<Marker> _exploreModeMarker = Set();
  List<String> finalDirections = [];

  List<String> calcDirectionsExploreMode(List<int> userCords, List<int> newUserCord, List<nearestLandInfo> nearbyLandmarkCoords) {

    List<String> finalDirections = [];
    for (int i = 0; i < nearbyLandmarkCoords.length; i++) {
      double value = tools.calculateAngle2(userCords, newUserCord, [
        nearbyLandmarkCoords[i].coordinateX!,
        nearbyLandmarkCoords[i].coordinateY!
      ]);

      //
      //
      String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value, context);
      //
      finalDirections.add(finalvalue);
    }
    return finalDirections;
  }

  Map<String, double> sortMapByValue(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort(
              (a, b) => b.value.compareTo(a.value)); // Sorting in descending order

    return Map.fromEntries(sortedEntries);
  }
  Future<void> realTimeReLocalizeUser(HashMap<String, beacon> apibeaconmap) async {
    sumMap.clear();
    setState(() {
      sumMap = SingletonFunctionController.btadapter.calculateAverage();
    });
    final Uint8List iconMarker = await getImagesFromMarker('assets/dot.png', 30);
    sumMap.forEach((key, value) {
      List<double> position = [];
      if(SingletonFunctionController.apibeaconmap[key]! != null ) {
        if (SingletonFunctionController.apibeaconmap[key]!.coordinateX! != null) {
          position = tools.localtoglobal(
              SingletonFunctionController.apibeaconmap[key]!.coordinateX!, SingletonFunctionController.apibeaconmap[key]!.coordinateY!,
              SingletonFunctionController.building.patchData[SingletonFunctionController.apibeaconmap[key]!.sId! ??
                  buildingAllApi.getStoredString()]);
          if(lastExplorePosition.latitude != position[0] && lastExplorePosition.longitude != position[1]) {
            // _exploreModeDebugBeaconMarker.add(
            //   Marker(
            //     markerId: MarkerId(
            //         "${SingletonFunctionController.apibeaconmap[key]!
            //             .name!}${position[0]}, ${position[1]}"),
            //     position: LatLng(position[0], position[1]),
            //     icon: BitmapDescriptor.fromBytes(iconMarker),
            //     onTap: () {},
            //   ),
            // );
            lastExplorePosition = LatLng(position[0], position[1]) ;
            setState(() {});
          }
        }
      }
    });
    setState(() {});
    firstValue = "";
    if (sumMap.isNotEmpty){
      Map<String, double> sortedsumMap = sortMapByValue(sumMap);
      firstValue = sortedsumMap.entries.first.key;
      print("wilsonsortedsumMap $sortedsumMap");
      final Uint8List iconMarker = await getImagesFromMarker('assets/EM_CurrentLocationMarker.png', 85);
      if (lastBeaconValue != firstValue && sortedsumMap.entries.first.value >= 5.5){
        SingletonFunctionController.btadapter.stopScanning();
        _exploreModeMarker.clear();
        await SingletonFunctionController.building.landmarkdata!.then((value){
          getallnearestInfo = tools.localizefindAllNearbyLandmark(apibeaconmap[firstValue]!, value.landmarksMap!);
          getallnearestInfo.forEach((landmark){
            List<double> value = [];
            if(landmark.coordinateX != null) {
              value = tools.localtoglobal(landmark.coordinateX!, landmark.coordinateY!, SingletonFunctionController.building.patchData[landmark.buildingID ?? buildingAllApi.getStoredString()]);
            }
            print("wilsonvalues $value getallnearestInfo ${landmark.name}");
            // _exploreModeMarker.add(
            //   Marker(
            //     markerId: MarkerId("${landmark.name}${value[0]}, ${value[1]}"),
            //     position: LatLng(value[0], value[1]),
            //     icon: BitmapDescriptor.fromBytes(iconMarker),
            //     onTap: () {},
            //   ),
            // );
            setState((){});
          });
          if(getallnearestInfo.isNotEmpty && _exploreModeTimer==null){
            _exploreModeTimer = Timer.periodic(Duration(seconds:2), (Timer t) {
              identifyFrontLandmark();
          });
          }
        });

        // List<int> tv = tools.eightcelltransition(user.theta);
        // finalDirections = calcDirectionsExploreMode([
        //   apibeaconmap[firstValue]!.coordinateX!,
        //   apibeaconmap[firstValue]!.coordinateY!
        // ],[
        //   apibeaconmap[firstValue]!.coordinateX! + tv[0],
        //   apibeaconmap[firstValue]!.coordinateY! + tv[1]
        // ],getallnearestInfo);
        print("nearestBeacon:${firstValue}");
        paintUser(firstValue,null,null);
        setState(() {
          lastBeaconValue = firstValue;
        });
        SingletonFunctionController.btadapter.emptyBin();
      } else {
        //HelperClass.showToast("Beacon Already scanned");
      }
    }
  }
  Future<List<Landmarks>> getNearbyServices(String service) async{
    List<Landmarks> nearbyServices=[];
    await SingletonFunctionController.building.landmarkdata!.then((value){
      value.landmarks?.forEach((landmarks){
        if(user.floor==landmarks.floor && user.bid==landmarks.buildingID){
          if(landmarks.name!=null && landmarks.name!.toLowerCase().contains(service.toLowerCase()))
            {
              nearbyServices.add(landmarks);
            }
        }
      });
    });
    if(nearbyServices.isNotEmpty){
      List<double> userCoords=[user.lat,user.lng];
      List<double> landCoords=[];
      double maxDistance=-1;

      final Uint8List iconMarker = await getImagesFromMarker('assets/EM_CurrentLocationMarker.png', 85);
      _exploreModeMarker.clear();
      for(int i=0;i<nearbyServices.length;i++){
        List<double> value=[];
        if(nearbyServices[i].coordinateX != null) {
          value = tools.localtoglobal(nearbyServices[i].coordinateX!, nearbyServices[i].coordinateY!, SingletonFunctionController.building.patchData[nearbyServices[i].buildingID ?? buildingAllApi.getStoredString()]);
          _exploreModeMarker.add(
            Marker(
              markerId: MarkerId("${nearbyServices[i].name}EM_CurrentLocationMarker"??""),
              position: LatLng(value[0],value[1]),
              icon: BitmapDescriptor.fromBytes(iconMarker),
            ),
          );
          setState(() {});
          double distance = tools.calculateAerialDist(userCoords[0], userCoords[1], value[0], value[1]);
          if (distance > maxDistance) {
            maxDistance = distance;
            landCoords = [value[0], value[1]];
          }
        }

      }
      setCameraPositionusingCoords([LatLng(userCoords[0], userCoords[1])],selectedRoomMarker2:[LatLng(landCoords[0], landCoords[1])]);
    }
    return nearbyServices;
  }
  bool _isCameraAnimating = false;
  Future<void> setCameraPositionusingCoords(
      List<LatLng> selectedRoomMarker1, {
        List<LatLng>? selectedRoomMarker2,
      }) async {
    if (_isCameraAnimating || _googleMapController == null){
      return; // If already animating or controller is null, exit
    }
    setState((){
      _isCameraAnimating = true;
    });
    try {
      List<LatLng> allMarkers = [...selectedRoomMarker1];
      if (selectedRoomMarker2 != null) {
        allMarkers.addAll(selectedRoomMarker2);
      }
      // Calculate bounds
      double minLat = double.infinity;
      double minLng = double.infinity;
      double maxLat = double.negativeInfinity;
      double maxLng = double.negativeInfinity;
      for(LatLng marker in allMarkers){
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
      // Adjust bounds for top and bottom UI panels
      final double paddingFactor = 0.2; // Adjust as per your UI layout
      bounds = _adjustBoundsForPanels(bounds, paddingFactor);
      // Calculate zoom level dynamically
      final double distance = _calculateDistance(bounds.southwest, bounds.northeast);
      final double targetZoom = _calculateZoomLevel(bounds, distance);
      // Animate camera movement
      const int steps = 60;
      const Duration stepDuration = Duration(microseconds: 200);
      final currentZoom = await _googleMapController.getZoomLevel();
      LatLng center = LatLng(
        (minLat + maxLat) / 2,
        (minLng + maxLng) / 2,
      );
      // for (int i = 0; i <= steps; i++) {
      //   final t = i / steps; // Progress from 0 to 1
      //   final interpolatedLat = _lerp(center.latitude, bounds.northeast.latitude, t);
      //   final interpolatedLng = _lerp(center.longitude, bounds.northeast.longitude, t);
      //   final interpolatedZoom = _lerp(currentZoom, targetZoom, t);
      //
      //   // Delay for smooth animation
      //   await Future.delayed(stepDuration);
      // }
      await _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:LatLng(user.lat, user.lng),
            zoom: targetZoom
          ),
        ),
      );
    }finally{
      setState(() {
        _isCameraAnimating = false;
      });
    }
  }
  LatLngBounds _adjustBoundsForPanels(LatLngBounds bounds, double paddingFactor) {
    final double latDiff = bounds.northeast.latitude - bounds.southwest.latitude;
    final double lngDiff = bounds.northeast.longitude - bounds.southwest.longitude;
    return LatLngBounds(
      southwest: LatLng(
        bounds.southwest.latitude + (latDiff * paddingFactor),
        bounds.southwest.longitude + (lngDiff * paddingFactor),
      ),
      northeast: LatLng(
        bounds.northeast.latitude - (latDiff * paddingFactor),
        bounds.northeast.longitude - (lngDiff * paddingFactor),
      ),
    );
  }
// Calculate zoom level dynamically
  double _calculateZoomLevel(LatLngBounds bounds, double distance){
    if (distance < 0.05){
      return 20.0; // High zoom for very close points
    }else if (distance < 0.5){
      return 19.0; // Moderate zoom for nearby points
    }else{
      return 18.0; // Default zoom for larger distances
    }
  }
// Calculate distance between two LatLng points
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371.0; // Radius of Earth in kilometers
    final double dLat = _toRadians(point2.latitude - point1.latitude);
    final double dLng = _toRadians(point2.longitude - point1.longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(point1.latitude)) *
            math.cos(_toRadians(point2.latitude)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }
// Helper to convert degrees to radians
  double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }
// Linear interpolation helper
  double _lerp(double start, double end, double t){
    return start + (end - start) * t;
  }
  List<nearestLandInfo> getallnearestInfo = [];
  String officeName="";
  String lastExploredLoc="";
  String lastService="";
  bool isMarkerAnimating = false;
  Set<String> recentlyTriggeredServices = {};
  Duration cooldownDuration = Duration(seconds: 5);


  Future<void> identifyFrontLandmark() async {
    print("landmark function running");
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    List<int> newUserCord = [
      user.coordX + transitionValue[0],
      user.coordY + transitionValue[1]
    ];
    for (var landmark in getallnearestInfo) {
      double value = tools.calculateAngle2(
          [user.coordX, user.coordY],
          newUserCord,
          [
            landmark.coordinateX!,
            landmark.coordinateY!
          ]);
      if (value < 45) {
        value = value + 45;
      }

      final Uint8List iconMarker = await getImagesFromMarker('assets/dot.png', 30);
      if ((value >= 315 && value <= 360) || (value >= 0 && value <= 45)){
        print("animateSelectedMarker:${lastExploredLoc} ${value}");
         if(!landmark.sId!.contains(lastExploredLoc)){
          lastExploredLoc=landmark.sId!;
          Vibration.vibrate();
          speak("${landmark.name}", _currentLocale);
          _exploreModeMarker.clear();
          List<double> latlngs=tools.localtoglobal(landmark.coordinateX!,landmark.coordinateY!, SingletonFunctionController.building.patchData[landmark.sId ?? buildingAllApi.getStoredString()]);
          animateSelectedMarker(landmark.name!,latlngs).then((_){
            setState((){
              officeName=landmark.name!;
              _isBuildingPannelOpen=true;
            });
          });
          showPanel(landmark.name!,landmark.name!);
        }
        else{
          lastExploredLoc=landmark.sId!;
        }

        // createAnimatedMarker(landmark.name!,latlngs,iconMarker);
        // speak("${landmark.name} is on your front", _currentLocale);
      }
    }
  }
  Future<void> identifyFrontService(List<Landmarks> resList) async {
    print("service function running");
    List<int> transitionValue = tools.eightcelltransition(user.theta);
    List<int> newUserCord = [
      user.coordX + transitionValue[0],
      user.coordY + transitionValue[1]
    ];

    double minDistance = double.infinity;
    Landmarks? closestLandmark;
    List<double> closestLatLng = [];

    for (var landmark in resList) {
      if (landmark.coordinateX == null || landmark.coordinateY == null) continue;

      // Skip if already triggered recently
      if (recentlyTriggeredServices.contains(landmark.sId)) continue;

      double angle = tools.calculateAngle2(
        [user.coordX, user.coordY],
        newUserCord,
        [landmark.coordinateX!, landmark.coordinateY!],
      );

      if (angle < 45) angle += 45;

      if ((angle >= 315 && angle <= 360) || (angle >= 0 && angle <= 45)) {
        List<double> latlngs = tools.localtoglobal(
          landmark.coordinateX!,
          landmark.coordinateY!,
          SingletonFunctionController.building.patchData[
          landmark.sId ?? buildingAllApi.getStoredString()
          ],
        );

        double distance = tools.calculateAerialDist(
          user.lat,
          user.lng,
          latlngs[0],
          latlngs[1],
        );

        // Select only closest one in front
        if (distance < 50 && distance < minDistance) {
          minDistance = distance;
          closestLandmark = landmark;
          closestLatLng = latlngs;
        }
      }
    }
    if (closestLandmark != null) {
      final Uint8List iconMarker = await getImagesFromMarker('assets/dot.png', 30);
      lastExploredLoc = closestLandmark.sId!;
      lastService = closestLandmark.sId!;
      recentlyTriggeredServices.add(closestLandmark.sId!);
      // Start cooldown timer
      Future.delayed(cooldownDuration, () {
        recentlyTriggeredServices.remove(closestLandmark!.sId!);
      });
      Vibration.vibrate();
      speak("${options[lastValueStored]} is ${minDistance.toStringAsFixed(0)} meters away", "EN");
      animateSelectedMarker("${minDistance.toStringAsFixed(0)} mtr", closestLatLng);
      setCameraPositionusingCoords(
        [LatLng(user.lat, user.lng)],
        selectedRoomMarker2: [LatLng(closestLatLng[0], closestLatLng[1])],
      );

      // Optional: speak("${closestLandmark.name} is in front of you", _currentLocale);
    }
  }


  void showLandmarkBottomSheet(BuildContext context, String name, String desc) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(16),
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(desc, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }


  Future<void> animateSelectedMarker(
      String name,
      List<double> polygonPoints,
      ) async {
    if (isMarkerAnimating) return;
    isMarkerAnimating = true;
    _exploreModeMarker.clear();
    _polygon.clear();
    final LatLng center = calculateRoomCenter([
      LatLng(polygonPoints[0], polygonPoints[1]),
    ]);

    // Clear any existing marker with the same ID
    _exploreModeMarker.removeWhere((m) => m.markerId.value == name);

    // Base icon asset path and base size
    const String assetPath = 'assets/Generic Marker.png';
    const int baseSize = 100;

    // Load base icon once
    BitmapDescriptor baseIcon = await bitmapDescriptorFromTextAndImage(name,assetPath,imageSize: const Size(50,50));

    // Setup animation controller
    AnimationController controller = AnimationController(
      vsync: this, // make sure this method is in a State class with TickerProviderStateMixin
      duration: Duration(milliseconds: 700),
    );

    Animation<double> scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    void updateMarker() async {
      double scale = scaleAnimation.value;
      BitmapDescriptor scaledIcon = await bitmapDescriptorFromTextAndImage(name,assetPath,imageSize: Size((baseSize * scale),(baseSize * scale)));

      setState(() {
        _exploreModeMarker.removeWhere((m) => m.markerId.value == name);
        _exploreModeMarker.add(
          Marker(
            markerId: MarkerId(name),
            position: center,
            icon: scaledIcon,
          ),
        );
        _polygon.add(
          Polygon(
            polygonId: PolygonId("$polygonPoints"),
            points: [LatLng(polygonPoints[0], polygonPoints[1])],
            fillColor: Colors.lightBlueAccent.withOpacity(0.4),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        );
      });
    }

    controller.addListener(updateMarker);
    controller.repeat(reverse: true);
    // Let it animate for 5 seconds, then stop
    await Future.delayed(Duration(milliseconds: 1500));
    controller.stop();
    controller.dispose();

    // Set final base icon
    setState(() {
      _exploreModeMarker.removeWhere((m) => m.markerId.value == name);
      _exploreModeMarker.add(
        Marker(
          markerId: MarkerId(name),
          position: center,
          icon: baseIcon,
        ),
      );
    });

    isMarkerAnimating = false;
    print("Animation done for $name");
  }


  SensorManager magnetoData = SensorManager();
  void handleCompassEvents(){
    magnetoData.magnetometerStream.listen((event){
      double? compassHeading = event.heading;
      // print("compassheading:${compassHeading}");
      // if(mounted) return;
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
          );
        }else{
          if(markers.isNotEmpty && markers[user.bid] != null){
            markers[user.bid]![0] = customMarker.rotate(compassHeading! - mapbearing, markers[user.bid]![0]);
          }
        }
      });
    },onError:(error){
      if (!mounted) return;
    });
  }

  void paintUser(
      String? nearestBeacon,
      String? polyID,
      LatLng? gpsCoordinates,
      {bool speakTTS = true, bool render = true, bool providePinSelection = false}
      ) async {
    print("paintuser $nearestBeacon $polyID $gpsCoordinates");
    // If nearestBeacon is provided, localize the user to it
    if (nearestBeacon != null && nearestBeacon.isNotEmpty){
      await _handleBeaconLocalization(nearestBeacon!, speakTTS, render,providePinSelection);
    }
  }


  Future<void> _handleBeaconLocalization(
      String nearestBeacon, bool speakTTS, bool render, bool providePinSelection) async {
    // final stackTrace = StackTrace.current;
    // print("_handleBeaconLocalization Stack: \n$stackTrace");
    List<Future<void>> apiCalls = [];
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) {
      apiCalls.add(landmarkApi().fetchLandmarkData(id: key, outdoor: key == buildingAllApi.outdoorID).then((value) {}));
    });
    // Wait for all API calls to complete
    await Future.wait(apiCalls);

    try {
      print("got into beacon localization");
      final landmarkData = await SingletonFunctionController.building.landmarkdata;
      Map<String, Landmarks>? landmarksMapAll = {};
      buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
        print("getStoredAllBuildingID $key");
        // await landmarkApi().fetchLandmarkData(id: key).then((value) {
        //   print("key $key $value");
        //   landmarksMapAll!.addAll(value.landmarksMap!);
        // });
      });
      //networkManager.ws.updateInitialization(localizedOn: nearestBeacon);
      final beaconData = SingletonFunctionController.apibeaconmap[nearestBeacon];
        final userSetLocation = tools.localizefindNearbyLandmark(beaconData!, landmarkData!.landmarksMap!);
        if (userSetLocation != null) {
          initializeUser(userSetLocation, beaconData, speakTTS: speakTTS, render: render);
        }
    } catch (e, stackTrace) {
      print("Error during beacon localization: $e\n$stackTrace");

    }
  }
  Set<Circle> circles = Set();
  Future<void> initializeMarkers() async {
    try {
      userloc = await getImagesFromMarker('assets/userloc0.png', 130);
      if (!kIsWeb && kDebugMode) {
        userlocdebug = await getImagesFromMarker('assets/tealtorch.png', 35);
      }
    }catch(e){
      print("user markers are already defined");
    }
  }
  late AnimationController _controller;
  late Animation<double> _animation;
  void _updateCircle(double lat, double lng) {
    // Create a new Tween with the provided begin and end values
    // Optionally update UI or logic with animation value
    if (!mounted) return;
    final Circle updatedCircle = Circle(
        circleId: CircleId("circle"),
        center: LatLng(lat, lng),
        radius: _animation.value,
        strokeWidth: 0,
        strokeColor: Colors.blue,
        fillColor: Colors.lightBlue.withOpacity(0.2),
        zIndex: 2
    );
    if (mounted) {
      setState(() {
        circles.removeWhere((circle) => circle.circleId == CircleId("circle"));
        circles.add(updatedCircle);
      });
    }
  }
  void setCameraPosition(Set<Marker> selectedroomMarker1,
      {Set<Marker>? selectedroomMarker2 = null}){
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;
    if (selectedroomMarker2 == null){
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
  Animation<LatLng>? _markerAnimation;
  AnimationController? _animationController;
  void initializeUser(Landmarks userSetLocation,beacon? localizedBeacon,{bool speakTTS = true, bool render = true})async{
     // final stackTrace = StackTrace.current;
     // print("_handleBeaconLocalization Stack: \n$stackTrace");
    tools.setBuildingAngle(SingletonFunctionController.building
        .patchData[userSetLocation.buildingID]!.patchData!.buildingAngle!);

    setState(() {
      buildingAllApi.selectedID = userSetLocation!.buildingID!;
      buildingAllApi.selectedBuildingID = userSetLocation!.buildingID!;
    });

    List<int> localBeconCord = [];
    localBeconCord.add(userSetLocation.coordinateX!);
    localBeconCord.add(userSetLocation.coordinateY!);

    pathState().beaconCords = localBeconCord;

    List<double> values = [];

    //floor alignment
    await SingletonFunctionController.building.landmarkdata!.then((land) {
      if (userSetLocation.floor != 0) {
        List<PolyArray> prevFloorLifts = findLift(
            tools.numericalToAlphabetical(0),
            SingletonFunctionController
                .building
                .polylinedatamap[userSetLocation.buildingID!]!
                .polyline!
                .floors!);
        List<PolyArray> currFloorLifts = findLift(
            tools.numericalToAlphabetical(userSetLocation.floor!),
            SingletonFunctionController
                .building
                .polylinedatamap[userSetLocation.buildingID!]!
                .polyline!
                .floors!);
        for (int i = 0; i < prevFloorLifts.length; i++) {}

        for (int i = 0; i < currFloorLifts.length; i++) {}
        List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

        UserState.xdiff = dvalue[0];
        UserState.ydiff = dvalue[1];
        values = tools.localtoglobal(
            userSetLocation.coordinateX!,
            userSetLocation.coordinateY!,
            SingletonFunctionController
                .building.patchData[userSetLocation.buildingID!]);
      } else {
        UserState.xdiff = 0;
        UserState.ydiff = 0;
        values = tools.localtoglobal(
            userSetLocation.coordinateX!,
            userSetLocation.coordinateY!,
            SingletonFunctionController
                .building.patchData[userSetLocation.buildingID!]);
      }
    });

    mapState.target = LatLng(values[0], values[1]);
    user.bid = userSetLocation.buildingID!;
    print("setting userbid ${user.bid}");
    user.locationName = userSetLocation.name;
    //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.latitude!);
    //double.parse(SingletonFunctionController.apibeaconmap[nearestBeacon]!.properties!.longitude!);
    //did this change over here UDIT...
    user.coordX = userSetLocation.coordinateX!;
    user.coordY = userSetLocation.coordinateY!;
    List<double> ls = tools.localtoglobal(
        user.coordX,
        user.coordY,
        SingletonFunctionController
            .building.patchData[userSetLocation.buildingID]);
    user.lat = ls[0];
    user.lng = ls[1];
    if (userSetLocation!.doorX != null) {
      print("usercoord fetched ${user.coordX},${user.coordY}       ${userSetLocation!.doorX!} ${userSetLocation!.doorY!}");
      user.coordX = userSetLocation!.doorX!;
      user.coordY = userSetLocation!.doorY!;
      List<double> latlng = tools.localtoglobal(
          userSetLocation!.doorX!,
          userSetLocation!.doorY!,
          SingletonFunctionController
              .building.patchData[userSetLocation!.buildingID]);

      user.lat = latlng[0];
      user.lng = latlng[1];
      user.locationName = userSetLocation!.name ??
          userSetLocation!.element!.subType;

    } else if (userSetLocation!.doorX == null) {
      user.coordX = userSetLocation!.coordinateX!;
      user.coordY = userSetLocation!.coordinateY!;
      List<double> latlng = tools.localtoglobal(
          userSetLocation!.coordinateX!,
          userSetLocation!.coordinateY!,
          SingletonFunctionController
              .building.patchData[userSetLocation!.buildingID]);

      user.lat = latlng[0];
      user.lng = latlng[1];
      user.locationName = userSetLocation!.name ??
          userSetLocation!.element!.subType;
    }
    user.showcoordX = user.coordX;
    user.showcoordY = user.coordY;

    UserState.cols = SingletonFunctionController.building.floorDimenssion[userSetLocation.buildingID]![userSetLocation.floor]![0];
    UserState.rows = SingletonFunctionController.building.floorDimenssion[userSetLocation.buildingID]![userSetLocation.floor]![1];
    UserState.lngCode = _currentLocale;
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
    await initializeMarkers();
    setState(() {
      markers.clear();
      //List<double> ls=tools.localtoglobal(user.coordX, user.coordY,patchData: SingletonFunctionController.building.patchData[SingletonFunctionController.apibeaconmap[nearestBeacon]!.buildingID]);
      if (render) {
        print("entered here");
        markers.putIfAbsent(user.bid, () => []);
        markers[user.bid]?.add(Marker(
          markerId: MarkerId("UserLocation"),
          position: LatLng(user.lat, user.lng),
          icon: BitmapDescriptor.fromBytes(userloc),
          anchor: Offset(0.5, 0.829),
        ));
        if (!kIsWeb && kDebugMode) {
          markers[user.bid]?.add(Marker(
            markerId: MarkerId("debug"),
            position: LatLng(user.lat, user.lng),
            icon: BitmapDescriptor.fromBytes(userlocdebug),
            anchor: Offset(0.5, 0.829),
          ));
        }
        circles.add(
          Circle(
              circleId: CircleId("circle"),
              center: LatLng(user.lat, user.lng),
              radius: _animation.value,
              strokeWidth: 1,
              strokeColor: Colors.blue,
              fillColor: Colors.lightBlue.withOpacity(0.2),
              zIndex: 2
          ),
        );
      } else {
        user.moveToFloor(userSetLocation.floor!);
      }
        SingletonFunctionController.building.floor[userSetLocation.buildingID!] = userSetLocation.floor!;
        createRooms(SingletonFunctionController.building.polyLineData!,
            userSetLocation.floor!);
      // SingletonFunctionController.building.landmarkdata!.then((value) {
      //  // createMarkers(value, userSetLocation!.floor!, bid: user.bid);
      // });
    });
    _animation = Tween<double>(begin: 2, end: 5).animate(_controller)
      ..addListener(() {
        _updateCircle(user.lat, user.lng);
      });
    List<nearestLandInfo> getallnearbylandmark=[];
    if(localizedBeacon!=null){
      await SingletonFunctionController.building.landmarkdata!.then((value) {
        getallnearbylandmark = tools.localizefindAllNearbyLandmark(
            localizedBeacon!, value.landmarksMap!);
      });
    }
    double value = 0;
    double value2 = 0;
    if (userSetLocation != null){
      value = tools.calculateAngle2(
          [user.coordX, user.coordY],
          newUserCord,
          [
            userSetLocation!.coordinateX!,
            userSetLocation!.coordinateY!
          ]);
    }
    double distBetweenLandmarks=0.0;
    if(getallnearbylandmark.length>2){
      distBetweenLandmarks=tools.calculateDistance([user.coordX,user.coordY], [getallnearbylandmark[1].coordinateX!,getallnearbylandmark[1].coordinateY!]);
      value2 = tools.calculateAngle2(
          [user.coordX, user.coordY],
          newUserCord,
          [
            getallnearbylandmark[1].coordinateX!,
            getallnearbylandmark[1].coordinateY!
          ]);
    }
    mapState.zoom = 22;
    if (value < 45) {
      value = value + 45;
    }

    if(value2<45){
      value2=value2+45;
    }
    String? finalvalue = value == 0
        ? null
        : tools.angleToClocksForNearestLandmarkToBeacon(value, context);

    String? finalvalue2 = value2 == 0
        ? null
        : tools.angleToClocksForNearestLandmarkToBeacon(value2, context);

    // double value =
    //     tools.calculateAngleSecond(newUserCord,userCords,landCords);
    //
    // String finalvalue = tools.angleToClocksForNearestLandmarkToBeacon(value);
    //
    //
    if (user.isnavigating == false && speakTTS) {
      detected = true;
      // if (!_isExploreModePannelOpen && speakTTS) {
      //   _isBuildingPannelOpen = true;
      // }
      // nearestLandmarkNameForPannel = nearestLandmarkToBeacon;
    }
    String name = userSetLocation!.name!;
    if (userSetLocation == null) {
      //updating user pointer
      SingletonFunctionController
          .building.floor[buildingAllApi.getStoredString()] = user.floor;
      createRooms(
          SingletonFunctionController.building.polyLineData!,
          SingletonFunctionController
              .building.floor[buildingAllApi.getStoredString()]!);
      if (pathMarkers[user.bid] != null &&
          pathMarkers[user.bid]![user.floor] != null) {
        setCameraPosition(pathMarkers[user.bid]![user.floor]!);
      }
      if (markers.length > 0)
        markers[user.bid]?[0] =
            customMarker.rotate(0, markers[user.bid]![0]);
      if (user.initialallyLocalised) {
        mapState.interaction = !mapState.interaction;
      }
      print("patchfirst $patch");

      fitPolygonInScreen(patch.first);
      if (speakTTS) {
        if (finalvalue == null) {
          speak(
                  "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",

              _currentLocale);
        } else {
          if(getallnearbylandmark.length>2 && distBetweenLandmarks<=20 && finalvalue2!=null){
            speak(
                "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)} and ${getallnearbylandmark[1].name} is on your ${LocaleData.properties5[finalvalue2]?.getString(context)}",
                _currentLocale);
          }else{
            speak(
                    "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)}",
                _currentLocale);
          }
        }
      }
    } else {
      if (speakTTS) {
        if (finalvalue == null) {
          speak(
                  "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName}",

              _currentLocale);
        } else {
          if(getallnearbylandmark.length>2 && distBetweenLandmarks<=20 && finalvalue2!=null){
            speak(
                "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)} and ${getallnearbylandmark[1].name} is on your ${LocaleData.properties5[finalvalue2]?.getString(context)}",
                _currentLocale);
          }else{
            speak(
                    "You are on ${tools.numericalToAlphabetical(user.floor)} floor,${user.locationName} is on your ${LocaleData.properties5[finalvalue]?.getString(context)}",

                _currentLocale);
          }
        }
      }
    }


    if (speakTTS) {
      List<double> lvalue = tools.localtoglobal(
          (userSetLocation.doorX??userSetLocation.coordinateX!).toInt(),
          (userSetLocation.doorY??userSetLocation.coordinateY!).toInt(),
          SingletonFunctionController.building.patchData[user.bid]
      );
      if(SingletonFunctionController.apibeaconmap[lastBeaconValue] != null){
        List<double> uvalue = tools.localtoglobal(
            SingletonFunctionController.apibeaconmap[lastBeaconValue]!.coordinateX!.toInt(),
            SingletonFunctionController.apibeaconmap[lastBeaconValue]!.coordinateY!.toInt(),
            SingletonFunctionController.building.patchData[user.bid]
        );
        LatLng currentMarkerPosition = LatLng(lvalue[0], lvalue[1]);
        LatLng newMarkerPosition = LatLng(uvalue[0], uvalue[1]);

        _markerAnimation = LatLngTween(
          begin: currentMarkerPosition,
          end: newMarkerPosition,
        ).animate(CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeInOut,
        ));
        // Start the animation
        _animationController!.forward(from: 0);
        _animationController!.addListener(() {
          setState(() {
            // Update marker position as animation progresses
            markers[user.bid]?[0] = customMarker.move(
              _markerAnimation!.value,
              markers[user.bid]![0],
            );
          });
        });
      }
      mapState.zoom = 22.0;
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lvalue[0], lvalue[1]), // Use the last known target
            zoom: 22,     // Use the last known zoom
            bearing: user.theta,               // Update the bearing
          ),
        ),
      );

    }
  }


  Set<Marker> restBuildingMarker = Set();
  void _updateMarkers(double zoom) {
    if (SingletonFunctionController.building.updateMarkers) {
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
            if (SingletonFunctionController.building.ignoredMarker
                .contains(words[1])) {
              if (marker.markerId.value.contains("Door")) {
                Marker _marker = customMarker.visibility(false, marker);

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
      }else{
        setState((){
          Markers.forEach((marker){
            List<String> words = marker.markerId.value.split(' ');
            if (SingletonFunctionController.building.ignoredMarker.contains(words[1])) {
              if (marker.markerId.value.contains("Door")) {
                Marker _marker = customMarker.visibility(true, marker);

                updatedMarkers.add(_marker);
              }
              if (marker.markerId.value.contains("Room")) {
                Marker _marker = customMarker.visibility(false, marker);
                updatedMarkers.add(_marker);
              }
            }else if (marker.markerId.value.contains("toppriority")) {
              Marker _marker = customMarker.visibility(zoom > 19, marker);
              updatedMarkers.add(_marker);
            }else if (marker.markerId.value.contains("Room")) {
              Marker _marker = customMarker.visibility(zoom > 20.5, marker);
              updatedMarkers.add(_marker);
            }else if (marker.markerId.value.contains("Rest")) {
              Marker _marker = customMarker.visibility(zoom > 19, marker);
              updatedMarkers.add(_marker);
            }else if (marker.markerId.value.contains("Entry")) {
              Marker _marker = customMarker.visibility(
                  (zoom > 18.5 && zoom < 19) || zoom > 20.3, marker);
              updatedMarkers.add(_marker);
            }else if (marker.markerId.value.contains("Building")) {
              Marker _marker = customMarker.visibility(zoom < 16.0, marker);
              updatedMarkers.add(_marker);
            }else if (marker.markerId.value.contains("Lift")) {
              Marker _marker = customMarker.visibility(zoom > 19, marker);
              updatedMarkers.add(_marker);
            }
          });
          Markers = updatedMarkers;
        });
      }
    }
  }
  Future<void> zoomWhileWait(
      Map<String, LatLng> allBuildingID, GoogleMapController controller) async {
    print("allbuilding id ${allBuildingID}");

    if (allBuildingID.length > 1) {
      while (!SingletonFunctionController.building.destinationQr &&
          !user.initialallyLocalised &&
          !SingletonFunctionController.building.qrOpened) {
        for (var entry in allBuildingID.entries) {
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: entry.value, zoom: 16),
          ));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await Future.delayed(Duration(milliseconds: 500));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: entry.value, zoom: 20),
          ));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await Future.delayed(Duration(seconds: 3));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: entry.value, zoom: 16),
          ));
          if (SingletonFunctionController.building.destinationQr ||
              user.initialallyLocalised ||
              SingletonFunctionController.building.qrOpened) {
            return;
          }
        }

        // Check the conditions before starting the next loop iteration
        if (user.initialallyLocalised ||
            SingletonFunctionController.building.qrOpened){
          return; // Exit the function if conditions are met
        }
      }
    } else {
      if (patch.isNotEmpty){
        fitPolygonInScreen(patch.first);
      }
    }
  }
  List<LatLng> tappedPolygonCoordinates = [];
  Future<void> moveCameraSmoothly({
    required GoogleMapController controller,
    required CameraPosition targetPosition,
    required LatLng currTarget,
    Duration duration = const Duration(milliseconds: 100),
    int steps = 50,
  }) async {
    try {
      print("Running moveCameraSmoothly...");

      final LatLng currentTarget;
      if (tappedPolygonCoordinates.isNotEmpty) {
        currentTarget =
            tools.calculateRoomCenterinLatLng(tappedPolygonCoordinates);
      } else {
        currentTarget = currTarget;
      }

      double currentZoom = await controller.getZoomLevel();

      final double latIncrement =
          (targetPosition.target.latitude - currentTarget.latitude) / steps;
      final double lngIncrement =
          (targetPosition.target.longitude - currentTarget.longitude) / steps;
      final double zoomIncrement = (targetPosition.zoom - currentZoom) / steps;

      for (int i = 1; i <= steps; i++) {
        final LatLng intermediateTarget = LatLng(
          currentTarget.latitude + (latIncrement * i),
          currentTarget.longitude + (lngIncrement * i),
        );
        final double intermediateZoom = currentZoom + (zoomIncrement * i);

        await controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: intermediateTarget,
              zoom: intermediateZoom,
            ),
          ),
        );

        await Future.delayed(duration ~/ steps);
      }
    } catch (e, stackTrace) {
      print("Error in moveCameraSmoothly: $e");
      print("Stack trace: $stackTrace");
    }
  }
  String closestBuildingId = "";
  Future<typed_data.Uint8List> getImagesFromMarker(String path, int width) async {
    typed_data.ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
  void createPatch(patchDataModel value) async {
    print("patchformation $value");
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
        zoom: 21,
      );
      Map<int, LatLng> coordinates = {};
      for (int i = 0; i < 4; i++) {
        coordinates[i] = LatLng(
            latcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lat!) -
                        latcenterofmap),
            lngcenterofmap +
                1.1 *
                    (double.parse(
                        value.patchData!.coordinates![i].globalRef!.lng!) -
                        lngcenterofmap));
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
      SingletonFunctionController.building
          .ARCoordinates[buildingAllApi.selectedBuildingID] = coordinates;
      setState(() {
        patch.add(
          Polygon(
              polygonId: PolygonId('patch'),
              points: polygonPoints,
              strokeWidth: 1,
              strokeColor: Color(0xffC0C0C0),
              fillColor: Color(0xffffffff),
              geodesic: false,
              consumeTapEvents: true,
              zIndex:-1),
        );
        cachedPolygon.clear();
      });
      try {
        fitPolygonInScreen(patch.first);
      } catch (e) {}
    }
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
  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
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
      if (point.latitude > maxLat){
        maxLat = point.latitude;
      }
      if (point.longitude < minLng){
        minLng = point.longitude;
      }
      if (point.longitude > maxLng){
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
      updatedMarkers.forEach((currentMarker){
        if (currentMarker.markerId.toString().contains(closestBuildingId)) {
          currentMarker.visible = true;
        } else {
          currentMarker.visible = false;
        }
      });
      _markers
        ..clear()
        ..addAll(updatedMarkers);

      setState(() {
        _areMarkersLoading = false;
      });
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
            l1.name!.length > 4 &&
            l1.name == l2.name) {
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
        }
      }
    }
    return diff;
  }
  // callMarkers(){
  //   SingletonFunctionController.building.landmarkdata!.then((value) {
  //     createMarkers(value,0);
  //   });
  // }
  Future<BitmapDescriptor> bitmapDescriptorFromTextAndImage(
      String text, String? imagePath,
      {Size imageSize = const Size(50, 50), Color? color}) async {
    // Set the text style and layout
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 30.0, // Increased font size
        color: color??Color(0xff000000),
      ),
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );

    // Calculate the text size
    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;

    // Variables for canvas size, depending on whether the image is used
    double canvasWidth = textWidth > imageSize.width ? textWidth : imageSize.width;
    double canvasHeight = textHeight + (imagePath != null ? imageSize.height + 20.0 : 0.0); // Increased padding if image is present

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Draw the text centered on the canvas
    final double textX = (canvasWidth - textWidth) / 2;
    final double textY = 0.0;
    textPainter.paint(canvas, Offset(textX, textY));

    // If an imagePath is provided, draw the image below the text
    if (imagePath != null) {
      // Load the base marker image
      final ByteData baseImageBytes = await rootBundle.load(imagePath);
      final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
          baseImageBytes.buffer.asUint8List(),
          targetWidth: imageSize.width.toInt(),
          targetHeight: imageSize.height.toInt());
      final ui.FrameInfo markerImageFrame = await markerImageCodec.getNextFrame();
      final ui.Image markerImage = markerImageFrame.image;

      // Draw the base marker image below the text
      final double imageX = (canvasWidth - imageSize.width) / 2;
      final double imageY = textHeight + 10.0; // Padding between text and image
      canvas.drawImage(markerImage, Offset(imageX, imageY), Paint());
    }

    // Generate the final image
    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );

    final ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes!);
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
  // void createMarkers(land _landData, int floor, {String? bid}) async {
  //   _markers.clear();
  //   _markerLocationsMap.clear();
  //   _markerLocationsMapLanName.clear();
  //   Markers.removeWhere((marker) => marker.markerId.value
  //       .contains(bid ?? buildingAllApi.selectedBuildingID));
  //   List<Landmarks> landmarks = _landData.landmarks!;
  //   try {
  //     for (int i = 0; i < landmarks.length; i++) {
  //       if (landmarks[i].floor == floor &&
  //           landmarks[i].buildingID ==
  //               (bid ?? buildingAllApi.selectedBuildingID)) {
  //         if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "Classroom" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           BitmapDescriptor textMarker;
  //
  //           String markerText;
  //           List<String> parts = landmarks[i].name!.split('-');
  //           markerText = parts.isNotEmpty ? parts[0].trim() : '';
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText, 'assets/Classroom.png',imageSize: const Size(95, 95),color: Color(0xff544551));
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " + (landmarks[i].priority! > 1 ? "toppriority" : "")),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         }else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "Cafeteria" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           BitmapDescriptor textMarker;
  //           String markerText;
  //           List<String> parts = landmarks[i].name!.split('-');
  //           markerText = parts.isNotEmpty ? parts[0].trim() : '';
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText, 'assets/cutlery.png',imageSize: const Size(95, 95),color: Color(0xfffb8c00));
  //
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " + (landmarks[i].priority! > 1 ? "toppriority" : "")),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         }else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "Point of Interest" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //
  //           BitmapDescriptor textMarker;
  //           String markerText;
  //           markerText = landmarks[i].name??"";
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText,null,imageSize: const Size(85, 85));
  //
  //
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         }else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "Counter" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //
  //           BitmapDescriptor textMarker;
  //           String markerText;
  //           markerText = landmarks[i].name??"";
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText,null,imageSize: const Size(85, 85));
  //
  //
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         }else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "Point of Interest" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //
  //           BitmapDescriptor textMarker;
  //           String markerText;
  //           markerText = landmarks[i].name??"";
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText,null,imageSize: const Size(85, 85));
  //
  //
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         }else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "ATM" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //
  //           BitmapDescriptor textMarker;
  //
  //           String markerText;
  //           List<String> parts = landmarks[i].name!.split('-');
  //           markerText = parts.isNotEmpty ? parts[0].trim() : '';
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText, 'assets/ATM.png',imageSize: const Size(100, 100),color: Color(0xffd32f2f));
  //
  //
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " + (landmarks[i].priority! > 1 ? "toppriority" : "")),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         }else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "Consultation Room" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //
  //           BitmapDescriptor textMarker;
  //
  //           String markerText;
  //           List<String> parts = landmarks[i].name!.split('-');
  //           markerText = parts.isNotEmpty ? parts[0].trim() : '';
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText, 'assets/Consultation Room.png',imageSize: const Size(85, 85),color: Color(0xff544551));
  //
  //
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " + (landmarks[i].priority! > 1 ? "toppriority" : "")),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         }else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType == "Office" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //
  //           BitmapDescriptor textMarker;
  //
  //           String markerText;
  //           List<String> parts = landmarks[i].name!.split('-');
  //           markerText = parts.isNotEmpty ? parts[0].trim() : '';
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText, 'assets/Office.png',imageSize: const Size(85, 85),color: Color(0xff544551));
  //
  //
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " + (landmarks[i].priority! > 1 ? "toppriority" : "")),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         } else if (landmarks[i].element!.type == "Rooms" &&
  //             landmarks[i].element!.subType != "main entry" &&
  //             landmarks[i].coordinateX != null &&
  //             !landmarks[i].wasPolyIdNull!) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //           BitmapDescriptor textMarker;
  //           String markerText;
  //           List<String> parts = landmarks[i].name!.split('-');
  //           markerText = parts.isNotEmpty ? parts[0].trim() : '';
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText, 'assets/Generic Marker.png',imageSize: const Size(85, 85));
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID} " + (landmarks[i].priority! > 1 ? "toppriority" : "")),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 1.0),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         } else if (landmarks[i].element!.subType != null &&
  //             landmarks[i].element!.subType == "room door" &&
  //             landmarks[i].doorX != null) {
  //           final Uint8List iconMarker =
  //           await getImagesFromMarker('assets/dooricon.png', 45);
  //           setState(() {
  //             List<double> value = tools.localtoglobal(
  //                 landmarks[i].coordinateX!,
  //                 landmarks[i].coordinateY!,
  //                 SingletonFunctionController.building
  //                     .patchData[bid ?? buildingAllApi.getStoredString()]);
  //             Markers.add(Marker(
  //                 markerId: MarkerId(
  //                     "Door ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
  //                 position: LatLng(value[0], value[1]),
  //                 icon: BitmapDescriptor.fromBytes(iconMarker),
  //                 visible: false,
  //                 infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: 'Additional Information',
  //                   // Replace with additional information
  //                   onTap: () {
  //                     if (SingletonFunctionController
  //                         .building.selectedLandmarkID !=
  //                         landmarks[i].properties!.polyId) {
  //                       SingletonFunctionController
  //                           .building.selectedLandmarkID =
  //                           landmarks[i].properties!.polyId;
  //                       _isRoutePanelOpen = false;
  //                       singleroute.clear();
  //                       //realWorldPath.clear();
  //                       _isLandmarkPanelOpen = true;
  //                       addselectedMarker(LatLng(value[0], value[1]));
  //                     }
  //                   },
  //                 )));
  //           });
  //         } else if (landmarks[i].name != null &&
  //             landmarks[i].element!.type == ("FloorConnection") &&
  //             landmarks[i].element!.subType == "lift") {
  //           final Uint8List iconMarker =
  //           await getImagesFromMarker('assets/entry.png', 75);
  //
  //           setState(() {
  //             List<double> value = tools.localtoglobal(
  //                 landmarks[i].coordinateX!,
  //                 landmarks[i].coordinateY!,
  //                 SingletonFunctionController.building
  //                     .patchData[bid ?? buildingAllApi.getStoredString()]);
  //
  //             // _markerLocations[LatLng(value[0], value[1])] = '1';
  //             mapMarkerLocationMapAndName.add(InitMarkerModel(
  //                 'Lift',
  //                 landmarks[i].name!,
  //                 LatLng(value[0], value[1]),
  //                 landmarks[i].buildingID!));
  //             _markerLocationsMap[LatLng(value[0], value[1])] = 'Lift';
  //             _markerLocationsMapLanName[LatLng(value[0], value[1])] =
  //             landmarks[i].name!;
  //             _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
  //             landmarks[i].buildingID!;
  //           });
  //         } else if (landmarks[i].name != null &&
  //             landmarks[i].name!.toLowerCase().contains("pharmacy")) {
  //           setState(() {
  //             List<double> value = tools.localtoglobal(
  //                 landmarks[i].coordinateX!,
  //                 landmarks[i].coordinateY!,
  //                 SingletonFunctionController.building
  //                     .patchData[bid ?? buildingAllApi.getStoredString()]);
  //             mapMarkerLocationMapAndName.add(InitMarkerModel(
  //                 'Pharmacy',
  //                 landmarks[i].name!,
  //                 LatLng(value[0], value[1]),
  //                 landmarks[i].buildingID!));
  //
  //             _markerLocationsMap[LatLng(value[0], value[1])] = 'Pharmacy';
  //             _markerLocationsMapLanName[LatLng(value[0], value[1])] =
  //             landmarks[i].name!;
  //             _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
  //             landmarks[i].buildingID!;
  //           });
  //         }
  //         // else if (landmarks[i].name != null &&
  //         //     landmarks[i].name!.toLowerCase().contains("kitchen")) {
  //         //
  //         //   setState(() {
  //         //     List<double> value = tools.localtoglobal(
  //         //         landmarks[i].coordinateX!, landmarks[i].coordinateY!,
  //         //         SingletonFunctionController.building.patchData[bid ?? buildingAllApi.getStoredString()]);
  //         //     _markerLocationsMap[LatLng(value[0], value[1])] = 'Kitchen';
  //         //     _markerLocationsMapLanName[LatLng(value[0], value[1])] =
  //         //     landmarks[i].name!;
  //         //   });
  //         // }
  //         else if (landmarks[i].properties!.washroomType != null &&
  //             landmarks[i].properties!.washroomType == "Male") {
  //           final Uint8List iconMarker =
  //           await getImagesFromMarker('assets/6.png', 65);
  //           setState(() {
  //             List<double> value = tools.localtoglobal(
  //                 landmarks[i].coordinateX!,
  //                 landmarks[i].coordinateY!,
  //                 SingletonFunctionController.building
  //                     .patchData[bid ?? buildingAllApi.getStoredString()]);
  //             mapMarkerLocationMapAndName.add(InitMarkerModel(
  //                 'Male',
  //                 landmarks[i].name!,
  //                 LatLng(value[0], value[1]),
  //                 landmarks[i].buildingID!));
  //
  //             _markerLocationsMap[LatLng(value[0], value[1])] = 'Male';
  //             _markerLocationsMapLanName[LatLng(value[0], value[1])] =
  //             landmarks[i].name!;
  //             _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
  //             landmarks[i].buildingID!;
  //
  //             // Markers.add(Marker(
  //             //     markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
  //             //     position: LatLng(value[0], value[1]),
  //             //     icon: BitmapDescriptor.fromBytes(iconMarker),
  //             //     visible: false,
  //             //     infoWindow: InfoWindow(
  //             //       title: landmarks[i].name,
  //             //       snippet: 'Additional Information',
  //             //       // Replace with additional information
  //             //       onTap: () {
  //             //         if (SingletonFunctionController.building.selectedLandmarkID !=
  //             //             landmarks[i].properties!.polyId) {
  //             //           SingletonFunctionController.building.selectedLandmarkID =
  //             //               landmarks[i].properties!.polyId;
  //             //           _isRoutePanelOpen = false;
  //             //           singleroute.clear();
  //             //           _isLandmarkPanelOpen = true;
  //             //           addselectedMarker(LatLng(value[0], value[1]));
  //             //         }
  //             //       },
  //             //     )));
  //           });
  //         } else if (landmarks[i].properties!.washroomType != null &&
  //             landmarks[i].properties!.washroomType == "Female") {
  //           final Uint8List iconMarker =
  //           await getImagesFromMarker('assets/4.png', 65);
  //
  //           setState(() {
  //             List<double> value = tools.localtoglobal(
  //                 landmarks[i].coordinateX!,
  //                 landmarks[i].coordinateY!,
  //                 SingletonFunctionController.building
  //                     .patchData[bid ?? buildingAllApi.getStoredString()]);
  //             mapMarkerLocationMapAndName.add(InitMarkerModel(
  //                 'Female',
  //                 landmarks[i].name!,
  //                 LatLng(value[0], value[1]),
  //                 landmarks[i].buildingID!));
  //
  //             _markerLocationsMap[LatLng(value[0], value[1])] = 'Female';
  //             _markerLocationsMapLanName[LatLng(value[0], value[1])] =
  //             landmarks[i].name!;
  //             _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
  //             landmarks[i].buildingID!;
  //
  //             // Markers.add(Marker(
  //             //     markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
  //             //     position: LatLng(value[0], value[1]),
  //             //     icon: BitmapDescriptor.fromBytes(iconMarker),
  //             //     visible: false,
  //             //     infoWindow: InfoWindow(
  //             //       title: landmarks[i].name,
  //             //       snippet: 'Additional Information',
  //             //       // Replace with additional information
  //             //       onTap: () {
  //             //         if (SingletonFunctionController.building.selectedLandmarkID !=
  //             //             landmarks[i].properties!.polyId) {
  //             //           SingletonFunctionController.building.selectedLandmarkID =
  //             //               landmarks[i].properties!.polyId;
  //             //           _isRoutePanelOpen = false;
  //             //           singleroute.clear();
  //             //           _isLandmarkPanelOpen = true;
  //             //           addselectedMarker(LatLng(value[0], value[1]));
  //             //         }
  //             //       },
  //             //     )));
  //           });
  //         } else if (landmarks[i].element!.subType != null &&
  //             landmarks[i].element!.subType == "main entry") {
  //           final Uint8List iconMarker =
  //           await getImagesFromMarker('assets/1.png', 90);
  //
  //           setState(() {
  //             List<double> value = tools.localtoglobal(
  //                 landmarks[i].coordinateX!,
  //                 landmarks[i].coordinateY!,
  //                 SingletonFunctionController.building
  //                     .patchData[bid ?? buildingAllApi.getStoredString()]);
  //             // _markerLocations[LatLng(value[0], value[1])] = '1';
  //             mapMarkerLocationMapAndName.add(InitMarkerModel(
  //                 landmarks[i].buildingID == buildingAllApi.outdoorID
  //                     ? "Campus Entry"
  //                     : 'Entry',
  //                 landmarks[i].name!,
  //                 LatLng(value[0], value[1]),
  //                 landmarks[i].buildingID!));
  //
  //             _markerLocationsMap[LatLng(value[0], value[1])] =
  //             landmarks[i].buildingID == buildingAllApi.outdoorID
  //                 ? "Campus Entry"
  //                 : 'Entry';
  //             _markerLocationsMapLanName[LatLng(value[0], value[1])] =
  //             landmarks[i].name!;
  //             _markerLocationsMapLanNameBID[LatLng(value[0], value[1])] =
  //             landmarks[i].buildingID!;
  //
  //             // _markers!.add(Marker(
  //             //   markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
  //             //   position: LatLng(value[0], value[1]),
  //             //   icon: BitmapDescriptor.fromBytes(iconMarker),
  //             // ));
  //
  //             // Markers.add(Marker(
  //             //     markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
  //             //     position: LatLng(value[0], value[1]),
  //             //     icon: BitmapDescriptor.fromBytes(iconMarker),
  //             //     visible: true,
  //             //     infoWindow: InfoWindow(
  //             //       title: landmarks[i].name,
  //             //       snippet: 'Additional Information',
  //             //       // Replace with additional information
  //             //       onTap: () {
  //             //         if (SingletonFunctionController.building.selectedLandmarkID !=
  //             //             landmarks[i].properties!.polyId) {
  //             //           SingletonFunctionController.building.selectedLandmarkID =
  //             //               landmarks[i].properties!.polyId;
  //             //           _isRoutePanelOpen = false;
  //             //           singleroute.clear();
  //             //           _isLandmarkPanelOpen = true;
  //             //           addselectedMarker(LatLng(value[0], value[1]));
  //             //         }
  //             //       },
  //             //     ),
  //             //     onTap: () {
  //             //       if (SingletonFunctionController.building.selectedLandmarkID !=
  //             //           landmarks[i].properties!.polyId) {
  //             //         SingletonFunctionController.building.selectedLandmarkID =
  //             //             landmarks[i].properties!.polyId;
  //             //         _isRoutePanelOpen = false;
  //             //         singleroute.clear();
  //             //         _isLandmarkPanelOpen = true;
  //             //         addselectedMarker(LatLng(value[0], value[1]));
  //             //       }
  //             //     }));
  //           });
  //         } else if (landmarks[i].element!.type == "Services" &&
  //             landmarks[i].element!.subType == "kiosk" &&
  //             landmarks[i].coordinateX != null) {
  //           // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
  //           //   ImageConfiguration(size: Size(44, 44)),
  //           //   getImagesFromMarker('assets/location_on.png',50),
  //           // );
  //           final Uint8List iconMarker =
  //           await getImagesFromMarker('assets/pin.png', 50);
  //           List<double> value = tools.localtoglobal(
  //               landmarks[i].coordinateX!,
  //               landmarks[i].coordinateY!,
  //               SingletonFunctionController.building
  //                   .patchData[bid ?? buildingAllApi.getStoredString()]);
  //           //_markerLocations.add(LatLng(value[0],value[1]));
  //           BitmapDescriptor textMarker;
  //           String markerText;
  //           try {
  //             if (landmarks[i].name != "kiosk") {
  //               List<String> parts = landmarks[i].name!.split(' ');
  //               markerText = parts.isNotEmpty ? parts[1].trim() : '';
  //             } else {
  //               markerText = "Kiosk";
  //             }
  //           } catch (e) {
  //             markerText = "Kiosk";
  //           }
  //
  //           textMarker = await bitmapDescriptorFromTextAndImage(
  //               markerText, 'assets/check-in.png');
  //
  //           Markers.add(Marker(
  //               markerId: MarkerId(
  //                   "Room ${landmarks[i].properties!.polyId} ${landmarks[i].buildingID}"),
  //               position: LatLng(value[0], value[1]),
  //               icon: textMarker,
  //               anchor: Offset(0.5, 0.5),
  //               visible: false,
  //               onTap: () {},
  //               infoWindow: InfoWindow(
  //                   title: landmarks[i].name,
  //                   // snippet: '${landmarks[i].properties!.polyId}',
  //                   // Replace with additional information
  //                   onTap: () {})));
  //         } else {}
  //       }
  //     }
  //   } catch (e) {}
  //   setState(() {
  //     // Markers.add(Marker(
  //     //   markerId: MarkerId("Building marker"),
  //     //   position: _initialCameraPosition.target,
  //     //   icon: BitmapDescriptor.defaultMarker,
  //     //   visible: false,
  //     // ));
  //   });
  //
  // }
  Future<void> createRooms(polylinedata value, int floor) async {
    if (closedpolygons[buildingAllApi.getStoredString()] == null) {
      closedpolygons[buildingAllApi.getStoredString()] = Set();
    }

    closedpolygons[value.polyline!.buildingID!]?.clear();

    // if (widget.directLandID.length < 2) {
    //   selectedroomMarker.clear();
    //   _isLandmarkPanelOpen = false;
    //   SingletonFunctionController.building.selectedLandmarkID = null;
    // }
    polylines[value.polyline!.buildingID!]?.clear();

    if (floor != 0) {
      List<PolyArray> prevFloorLifts =
      findLift(tools.numericalToAlphabetical(0), value.polyline!.floors!);
      List<PolyArray> currFloorLifts = findLift(
          tools.numericalToAlphabetical(floor), value.polyline!.floors!);
      List<int> dvalue = findCommonLift(prevFloorLifts, currFloorLifts);

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
    setState((){
      if (FloorPolyArray != null) {
        for (PolyArray polyArray in FloorPolyArray){
          if (polyArray.visibilityType == "visible" &&
              polyArray.polygonType != "Waypoints"){
            List<LatLng> coordinates = [];
            for (Nodes node in polyArray.nodes!){
              //coordinates.add(LatLng(node.lat!,node.lon!));
              coordinates.add(LatLng(
                  tools.localtoglobal(
                      node.coordx!,
                      node.coordy!,
                      SingletonFunctionController
                          .building.patchData[value.polyline!.buildingID])[0],
                  tools.localtoglobal(
                      node.coordx!,
                      node.coordy!,
                      SingletonFunctionController
                          .building.patchData[value.polyline!.buildingID])[1]));
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
                        : Color(0xffC0C0C0),
                    width: 1,
                    onTap: () {}));
              }
            }else if(polyArray.polygonType == 'Room' ){
              print("polyArray.name");
              print(polyArray.name);
              if(polyArray.name!.toLowerCase().contains('lr') || polyArray.name!.toLowerCase().contains('lab') || polyArray.name!.toLowerCase().contains('office') || polyArray.name!.toLowerCase().contains('pantry') || polyArray.name!.toLowerCase().contains('reception')) {
                print("COntaining LA");
                if (coordinates.length > 2){
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId:PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray
                              .id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      strokeColor: Color(0xffA38F9F),
                      fillColor: Color(0xffE8E3E7),
                      consumeTapEvents: true,
                      onTap:(){
                        print("polyid::${polyArray.id}");
                        setState((){
                          tappedPolygonCoordinates=coordinates;
                        });
                        moveCameraSmoothly(controller: _googleMapController, targetPosition:  CameraPosition(
                            target: tools.calculateRoomCenterinLatLng(coordinates),zoom:22), currTarget: LatLng(user.lat,user.lng));
                        setState((){
                          if (SingletonFunctionController.building
                              .selectedLandmarkID != polyArray.id) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1,
                                -1,
                                -1,
                                -1,
                                -1,
                                -1,
                                null,
                                0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();
                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController.building
                                .selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            addselectedRoomMarker(coordinates);
                            // Future.delayed(Duration(milliseconds: 500)).then((onValue){
                            //   Navigator.pop(context, SingletonFunctionController.building.selectedLandmarkID);
                            // });

                          }
                        });
                      }));
                }
              }else if(polyArray.name!.toLowerCase().contains('atm') || polyArray.name!.toLowerCase().contains('health')) {
                print("COntaining LA");
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray
                              .id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffE99696),
                      fillColor: Color(0xffFBEAEA),
                      consumeTapEvents: true,
                      onTap: () {
                        print("polyid::${polyArray.id}");
                        setState((){
                          tappedPolygonCoordinates=coordinates;
                        });

                        moveCameraSmoothly(controller: _googleMapController, targetPosition:  CameraPosition(
                            target: tools.calculateRoomCenterinLatLng(coordinates),zoom:22), currTarget: LatLng(user.lat,user.lng));
                        setState(() {
                          if (SingletonFunctionController.building
                              .selectedLandmarkID != polyArray.id) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1,
                                -1,
                                -1,
                                -1,
                                -1,
                                -1,
                                null,
                                0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController.building
                                .selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];

                            addselectedRoomMarker(coordinates);
                            // Future.delayed(Duration(milliseconds: 500)).then((onValue){
                            //   Navigator.pop(context, SingletonFunctionController.building.selectedLandmarkID);
                            // });
                          }
                        });
                      }));
                }
              } else{
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Room ${polyArray
                              .id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffA38F9F),
                      fillColor: Color(0xffE8E3E7),
                      consumeTapEvents: true,
                      onTap: () {
                        print("polyid::${polyArray.id}");
                        setState((){
                          tappedPolygonCoordinates=coordinates;
                        });

                        moveCameraSmoothly(controller: _googleMapController, targetPosition:  CameraPosition(
                            target: tools.calculateRoomCenterinLatLng(coordinates),zoom:22), currTarget: LatLng(user.lat,user.lng));

                        setState(() {
                          if (SingletonFunctionController.building
                              .selectedLandmarkID != polyArray.id) {
                            user.reset();
                            PathState = pathState.withValues(
                                -1,
                                -1,
                                -1,
                                -1,
                                -1,
                                -1,
                                null,
                                0);
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();

                            user.isnavigating = false;
                            _isnavigationPannelOpen = false;
                            SingletonFunctionController.building
                                .selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            addselectedRoomMarker(coordinates);
                            // Future.delayed(Duration(milliseconds: 500)).then((onValue){
                            //   Navigator.pop(context, SingletonFunctionController.building.selectedLandmarkID);
                            // });
                          }
                        });
                      }));
                }
              }
            } else if (polyArray.polygonType == 'Cubicle') {
              if (polyArray.cubicleName == "Green Area" ||
                  polyArray.cubicleName == "Green Area | Pots" || polyArray.name!.toLowerCase().contains('auditorium') || polyArray.name!.toLowerCase().contains('basketball') || polyArray.name!.toLowerCase().contains('cricket') || polyArray.name!.toLowerCase().contains('football') || polyArray.name!.toLowerCase().contains('gym') || polyArray.name!.toLowerCase().contains('swimming') || polyArray.name!.toLowerCase().contains('tennis')) {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffADFA9E),
                      fillColor: Color(0xffE7FEE9),
                      onTap: () {

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
                      strokeColor: Color(0xffB5CCE3),
                      consumeTapEvents: true,
                      fillColor: Color(0xffDAE6F1),
                      onTap: () {
                        print("polyid::${polyArray.id}");
                        setState((){
                          tappedPolygonCoordinates=coordinates;
                        });
                        moveCameraSmoothly(controller: _googleMapController, targetPosition:  CameraPosition(
                            target: tools.calculateRoomCenterinLatLng(coordinates),zoom:22), currTarget: LatLng(user.lat,user.lng));
                        setState(() {
                          if (SingletonFunctionController
                              .building.selectedLandmarkID !=
                              polyArray.id) {
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
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            addselectedRoomMarker(coordinates,
                                color: Colors.greenAccent);
                            // Future.delayed(Duration(milliseconds: 500)).then((onValue){
                            //   Navigator.pop(context, SingletonFunctionController.building.selectedLandmarkID);
                            // });

                          }
                        });
                      }));
                }
              } else if (polyArray.cubicleName == "Male Washroom"){
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: Color(0xFFE7F4FE),
                      onTap: () {
                        print("polyid::${polyArray.id}");
                        setState((){
                          tappedPolygonCoordinates=coordinates;
                        });
                        moveCameraSmoothly(controller: _googleMapController, targetPosition:  CameraPosition(
                            target: tools.calculateRoomCenterinLatLng(coordinates),zoom:22), currTarget: LatLng(user.lat,user.lng));
                        setState(() {
                          if (SingletonFunctionController
                              .building.selectedLandmarkID !=
                              polyArray.id) {
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
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];

                            addselectedRoomMarker(coordinates,
                                color: Colors.white);
                            // Future.delayed(Duration(milliseconds: 500)).then((onValue){
                            //   Navigator.pop(context, SingletonFunctionController.building.selectedLandmarkID);
                            // });
                          }
                        });
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
                      consumeTapEvents: true,
                      strokeColor: Color(0xff6EBCF7),
                      fillColor: Color(0xFFE7F4FE),
                      onTap: () {
                        print("polyid::${polyArray.id}");
                        setState((){
                          tappedPolygonCoordinates=coordinates;
                        });
                        moveCameraSmoothly(controller: _googleMapController, targetPosition:  CameraPosition(
                            target: tools.calculateRoomCenterinLatLng(coordinates),zoom:22), currTarget: LatLng(user.lat,user.lng));
                        setState(() {
                          if (SingletonFunctionController
                              .building.selectedLandmarkID !=
                              polyArray.id) {
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
                            SingletonFunctionController
                                .building.selectedLandmarkID = polyArray.id;
                            SingletonFunctionController.building.ignoredMarker
                                .clear();
                            SingletonFunctionController.building.ignoredMarker
                                .add(polyArray.id!);
                            _isBuildingPannelOpen = false;
                            _isRoutePanelOpen = false;
                            singleroute.clear();
                            _isLandmarkPanelOpen = true;
                            PathState.directions = [];
                            addselectedRoomMarker(coordinates,
                                color: Colors.white);
                            // Future.delayed(Duration(milliseconds: 500)).then((onValue){
                            //   Navigator.pop(context, SingletonFunctionController.building.selectedLandmarkID);
                            // });
                          }
                        });
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
                          : Color(0xffF21D0D),
                      onTap: () {}));
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

                      strokeColor: Color(0xff6EBCF7),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE7F4FE),
                      onTap: () {}));
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
                      strokeColor: Color(0xffC0C0C0),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffffffff),
                      onTap: () {}));
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

                      strokeColor: Color(0xffCCCCCC),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE6E6E6),
                      onTap: () {}));
                }
              }else if (polyArray.cubicleName == "Non Walkable Area") {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                      polygonId: PolygonId(
                          "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                      points: coordinates,
                      strokeWidth: 1,
                      // Modify the color and opacity based on the selectedRoomId

                      strokeColor: Color(0xffcccccc),
                      fillColor: polyArray.cubicleColor != null &&
                          polyArray.cubicleColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                          : Color(0xffE6E6E6),
                      onTap: () {}));
                }
              } else {
                if (coordinates.length > 2) {
                  coordinates.add(coordinates.first);
                  closedpolygons[value.polyline!.buildingID!]!.add(Polygon(
                    polygonId: PolygonId(
                        "${value.polyline!.buildingID!} Cubicle ${polyArray.id!}"),
                    points: coordinates,
                    strokeWidth: 1,
                    strokeColor: Color(0xffD3D3D3),
                    onTap: (){},
                    fillColor: polyArray.cubicleColor != null &&
                        polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                        '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Colors.white,
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
                    strokeColor: Color(0xffD3D3D3),
                    fillColor: polyArray.cubicleColor != null &&
                        polyArray.cubicleColor != "undefined"
                        ? Color(int.parse(
                        '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                        : Colors.white,
                    consumeTapEvents: true,
                    onTap: () {}));
              }
            } else {
              polylines[value.polyline!.buildingID!]!.add(gmap.Polyline(
                  polylineId: PolylineId(polyArray.id!),
                  points: coordinates,
                  color: polyArray.cubicleColor != null &&
                      polyArray.cubicleColor != "undefined"
                      ? Color(int.parse(
                      '0xFF${(polyArray.cubicleColor)!.replaceAll('#', '')}'))
                      : Color(0xffE6E6E6),
                  width: 1,
                  onTap: () {}));
            }
          }
        }
      }
    });
    cachedPolygon.clear();
    return;
  }

  bool _isPanelVisible = false;
  String? landmarkName;
  String? landmarkDesc;
  int lastValueStored = 0;


  void showPanel(String name, String desc) {
    setState(() {
      landmarkName = name;
      landmarkDesc = desc;
      _isPanelVisible = true;
    });
  }

  void hidePanel() {
    setState(() => _isPanelVisible = false);
  }
  int vall = 0;
  List<String> options = [
    'Washroom', 'Entry',
    'Reception', 'Lift',
  ];
  List<Landmarks> resList=[];
  bool _isService=false;
  bool _isExplored=false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4, // Adds elevation for a shadow effect
        shadowColor: Colors.black.withOpacity(0.7), // Shadow color with opacity
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed:(){
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Explore Mode",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4), // Spacing between texts
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              padding:
              EdgeInsets.only(left: 20), // <--- padding added here
              initialCameraPosition: _initialCameraPosition,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              mapToolbarEnabled: false,
              // circles: _userLocation != null && _accuracy != null
              //     ? {
              //   Circle(
              //     circleId: CircleId('accuracyCircle'),
              //     center: _userLocation!,
              //     radius: _accuracy!,  // Draw accuracy circlex
              //     strokeColor: Colors.blueAccent,
              //     fillColor: Colors.blueAccent.withOpacity(0.2),
              //     strokeWidth: 1,
              //   )
              // }
              //     : {},
              polygons: getCombinedPolygons(),
              markers: getCombinedMarkers()
                  .union(_markers)
                  .union(focusturnArrow)
                  .union(Markers)
                  .union(restBuildingMarker).union(_exploreModeMarker),
              buildingsEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: true,
              minMaxZoomPreference: MinMaxZoomPreference(2, 30),
              onMapCreated: (controller){
                controller.setMapStyle(maptheme);
                _googleMapController = controller;
               // zoomWhileWait(buildingAllApi.allBuildingID, controller);
              },
              onCameraMove: (CameraPosition cameraPosition) {
                mapState.cameraposition = cameraPosition;
                if (cameraPosition.target.latitude.toStringAsFixed(5) !=
                    mapState.target.latitude.toStringAsFixed(5)) {
                  mapState.aligned = false;
                } else {
                  mapState.aligned = true;
                }
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

                }

                // _updateEntryMarkers11(cameraPosition.zoom);
                //_markerLocations.clear();
                //
              },
              onCameraIdle:(){
              },
              onCameraMoveStarted: () {
                user.building = SingletonFunctionController.building;
                mapState.interaction2 = false;
              },
            ),
          ),
          Container(
            width: screenWidth,
            child: ChipsChoice<int>.single(
              value: vall,
              onChanged: (val) async {
                setState(() => vall = val);
                lastValueStored = val;
                print("wilsonchecker");
                print(val);
                print(_exploreModeTimer2);
                resList.clear();
                _exploreModeTimer?.cancel();
                _exploreModeMarker.clear();
                setState((){
                  _isPanelVisible = false;
                  _isService=true;
                });
               resList=await getNearbyServices(options[val]);
               _exploreModeTimer2= Timer.periodic(Duration(seconds: 2), (_){
                   identifyFrontService(resList);
                 });


               print("getNearbyServices ${resList}");
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
              choiceBuilder: (item, i) {
              },
              direction: Axis.horizontal,
            ),
          ),
          //debug----
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 16,
            right: 16,
            bottom: _isPanelVisible ? 30 : -200, // Off-screen when hidden
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(landmarkName ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(landmarkDesc ?? '', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 300.0, // Adjust the position as needed
            right: 16.0,
            child: Semantics(
              label: "Change floor",
              child: SpeedDial(
                child: Text(
                  SingletonFunctionController.building.floor == 0
                      ? 'G'
                      : '${SingletonFunctionController.building.floor[buildingAllApi.getStoredString()]}',
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff24b9b0),
                    height: 19 / 16,

                  ),
                ),
                activeIcon: Icons.close,
                backgroundColor: Colors.white,
                children: List.generate(
                  (Building.numberOfFloorsDelhi[
                  buildingAllApi.getStoredString()] ??
                      [0])
                      .length,
                      (int i){
                    List<int> floorList=Building
                        .numberOfFloorsDelhi[
                    buildingAllApi.getStoredString()] ??
                        [0];
                    List<int> revfloorList = floorList;
                    revfloorList.sort();
                    return SpeedDialChild(
                      child: Semantics(
                        label: "${revfloorList[i]}",
                        child: Text(
                          revfloorList[i] == 0
                              ? 'G'
                              : '${revfloorList[i]}',
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 19 / 16,
                          ),
                        ),
                      ),
                      backgroundColor:SingletonFunctionController.building.floor[buildingAllApi.getStoredString()]==revfloorList[i] ? Colors.blue[400]:Colors.white,
                      onTap: () {
                        _polygon.clear();
                        cachedPolygon.clear();
                        _markers.clear();
                        _markerLocationsMap.clear();
                        _markerLocationsMapLanName.clear();
                        SingletonFunctionController
                            .building.floor[
                        buildingAllApi
                            .getStoredString()] =
                        revfloorList[i];
                        createRooms(
                          SingletonFunctionController
                              .building.polylinedatamap[
                          buildingAllApi.getStoredString()]!,
                          SingletonFunctionController
                              .building.floor[
                          buildingAllApi.getStoredString()]!,
                        );
                        if (pathMarkers[i] != null) {
                          //setCameraPosition(pathMarkers[i]!);
                        }
                        // Markers.clear();
                        // SingletonFunctionController
                        //     .building.landmarkdata!
                        //     .then((value) {
                        //   createMarkers(
                        //       value,
                        //       SingletonFunctionController
                        //           .building.floor[
                        //       buildingAllApi
                        //           .getStoredString()]!,
                        //       bid: buildingAllApi
                        //           .getStoredString());
                        // });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200.0, // Adjust the position as needed
            right: 18.0,
            child: Visibility(
              visible:_isExplored,
              child: FloatingActionButton(
                backgroundColor:(_isExplored)? Colors.red:Colors.cyan,
                onPressed:(){
                  if(_isExplored){
                    HelperClass.showToast("Explore Mode Disabled");
                    setState(() {
                      _isExplored=true;
                    });
                    _exploreModeTimer!.cancel();
                  }else{
                    if(_exploreModeTimer==null){
                      _exploreModeTimer=Timer.periodic(Duration(seconds: 2),(_){
                        identifyFrontLandmark();
                      });
                      setState((){
                        _isExplored=false;
                      });
                    }
                  }
                },child:Icon(CupertinoIcons.antenna_radiowaves_left_right,color: Colors.white,),),
            ),
          ),
          Positioned(
            bottom: 200.0, // Adjust the position as needed
            right: 18.0,
            child: Visibility(
              visible: _isService,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: (){
                setState((){
                  _isService=false;
                  _isExplored=true;
                });
                recentlyTriggeredServices.clear();
                lastService="";
                _exploreModeMarker.clear();
                _exploreModeTimer2!.cancel();
                _exploreModeTimer = Timer.periodic(Duration(seconds:2), (Timer t) {
                  identifyFrontLandmark();
                });
              },child: Icon(Icons.cancel,color: Colors.white,),),
            ),
          )
        ],
      ),
    );
  }
}
