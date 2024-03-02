import 'dart:async';
import 'dart:collection';

import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:iwayplusnav/API/PolyLineApi.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/APIMODELS/landmark.dart';
import 'package:iwayplusnav/Elements/HomepageLandmarkClickedSearchBar.dart';
import 'package:iwayplusnav/Elements/buildingCard.dart';
import 'package:iwayplusnav/Elements/directionInstruction.dart';
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
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'DestinationSearchPage.dart';
import 'Elements/HomepageSearch.dart';
import 'Elements/SearchNearby.dart';
import 'Elements/landmarkPannelShimmer.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigation(
        buildingID: "",
      ),
    );
  }
}

class Navigation extends StatefulWidget {
  String buildingID = '';
  Navigation({required this.buildingID});

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
  Set<gmap.Polyline> polylines = Set();
  Set<Polygon> closedpolygons = Set();
  Set<Marker> Markers = Set();
  Set<Marker> selectedroomMarker = Set();
  Map<int, Set<Marker>> pathMarkers = {};
  List<Marker> markers = [];
  Building building = Building(floor: 0, numberOfFloors: 1);
  Map<int, Set<gmap.Polyline>> singleroute = {};
  BT btadapter = new BT();
  bool _isLandmarkPanelOpen = false;
  bool _isRoutePanelOpen = false;
  bool _isnavigationPannelOpen = false;
  bool _isreroutePannelOpen = false;
  HashMap<String, beacon> apibeaconmap = HashMap();
  late FlutterTts flutterTts;
  double mapbearing = 0.0;
  //UserState user = UserState(floor: 0, coordX: 154, coordY: 94, lat: 28.543406741799892, lng: 77.18761156074972, key: "659001d7e6c204e1eec13e26");
  UserState user = UserState(
      floor: 0, coordX: 0, coordY: 0, lat: 0.0, lng: 0.0, key: "", theta: 0.0);
  pathState PathState = pathState.withValues(-1, -1, -1, -1, -1, -1, 0, 0);

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
  Duration sensorInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    print("widget.buildingID");
    print(widget.buildingID);
    flutterTts = FlutterTts();
    handleCompassEvents();
    DefaultAssetBundle.of(context)
        .loadString("assets/mapstyle.json")
        .then((value) {
      maptheme = value;
    });
    checkPermissions();

    getDeviceManufacturer();
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
          (UserAccelerometerEvent event) {
        final now = DateTime.now();
        setState(() {
          _userAccelerometerEvent = event;
          if (_userAccelerometerUpdateTime != null) {
            final interval = now.difference(_userAccelerometerUpdateTime!);
            if (interval > _ignoreDuration) {
              _userAccelerometerLastInterval = interval.inMilliseconds;
            }
          }
        });
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
    FlutterCompass.events!.listen((event) {
      double? compassHeading = event.heading!;
      setState(() {
        user.theta = compassHeading!;
        if(mapState.interaction2){
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
        }else{
          if (markers.length > 0)
            markers[0] =
                customMarker.rotate(compassHeading! - mapbearing, markers[0]);

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
      onStepCount();
    });
  }

// Function to stop the timer
  void StopPDR() {
    if (PDRTimer != null && PDRTimer!.isActive) {
      PDRTimer!.cancel();
    }
  }

  void onStepCount() {
    setState(() {
      if (_userAccelerometerEvent?.y != null) {
        if (_userAccelerometerEvent!.y > step_threshold ||
            _userAccelerometerEvent!.y < -step_threshold) {
          bool isvalid = MotionModel.isValidStep(
              user,
              building.floorDimenssion[user.floor]![0],
              building.floorDimenssion[user.floor]![1],
              building.nonWalkable[user.floor]!,
              reroute);
          if (isvalid) {
            user.move().then((value) {
              setState(() {
                if (markers.length > 0) {
                  markers[0] = customMarker.move(
                      LatLng(
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt())[0],
                          tools.localtoglobal(user.showcoordX.toInt(),
                              user.showcoordY.toInt())[1]),
                      markers[0]);
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

  void reroute() {
    _isnavigationPannelOpen = false;
    _isRoutePanelOpen = false;
    _isLandmarkPanelOpen = false;
    _isreroutePannelOpen = true;
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

  void apiCalls() async {
    await patchAPI().fetchPatchData().then((value) {
      createPatch(value);
      tools.Data = value;
      for (int i = 0; i < 4; i++) {
        tools.corners.add(math.Point(
            double.parse(value.patchData!.coordinates![i].globalRef!.lat!),
            double.parse(value.patchData!.coordinates![i].globalRef!.lng!)));
      }
      tools.angleBetweenBuildingAndNorth();
    });

    await PolyLineApi().fetchPolyData().then((value) {
      print("object ${value.polyline!.floors!.length}");
      building.polyLineData = value;
      createRooms(value, building.floor);
    });

    building.landmarkdata = landmarkApi().fetchLandmarkData().then((value) {
      Map<int, LatLng> coordinates = {};
      for (int i = 0; i < value.landmarks!.length; i++) {
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
          building.nonWalkable[value.landmarks![i].floor!] = allIntegers;
          building.floorDimenssion[value.landmarks![i].floor!] = [
            value.landmarks![i].properties!.floorLength!,
            value.landmarks![i].properties!.floorBreadth!
          ];
        }
      }
      createARPatch(coordinates);
      createMarkers(value, building.floor);
      return value;
    });

    beaconapi().fetchBeaconData().then((value) {
      building.beacondata = value;
      for (int i = 0; i < value.length; i++) {
        beacon beacons = value[i];
        if (beacons.properties!.macId != null) {
          apibeaconmap[beacons.properties!.macId!] = beacons;
        }
      }
      btadapter.startScanning(apibeaconmap);
      late Timer _timer;
      _timer = Timer.periodic(Duration(milliseconds: 9000), (timer) {
        localizeUser();
        _timer.cancel();
      });
    });
  }

  Future<void> localizeUser() async {
    BitmapDescriptor userloc = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(44, 44)),
      'assets/userloc0.png',
    );

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
    print("nearestBeacon : $nearestBeacon");

    if (apibeaconmap[nearestBeacon] != null) {
      speak(
          "You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor, near ${apibeaconmap[nearestBeacon]!.name!}");
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
      user.coordX = apibeaconmap[nearestBeacon]!.coordinateX!;
      user.coordY = apibeaconmap[nearestBeacon]!.coordinateY!;
      user.lat =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.latitude!);
      user.lng =
          double.parse(apibeaconmap[nearestBeacon]!.properties!.longitude!);
      user.floor = apibeaconmap[nearestBeacon]!.floor!;
      user.key = apibeaconmap[nearestBeacon]!.sId!;
      setState(() {
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId("UserLocation"),
          position: beaconLocation,
          icon: userloc,
          anchor: Offset(0.5, 0.829),
        ));
        building.floor = apibeaconmap[nearestBeacon]!.floor!;
        createRooms(building.polyLineData!, building.floor);
        building.landmarkdata!.then((value) {
          createMarkers(value, building.floor);
        });
      });
    }
    btadapter.stopScanning();
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
            strokeWidth: 2,
            strokeColor: Colors.blue,
            fillColor: Colors.white,
            geodesic: false,
            consumeTapEvents: true,
          ),
        );
      });

      try {
        fitPolygonInScreen(patch.first);
      } catch (e) {}
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
      LinkedHashMap<int, LatLng> sortedCoordinates = LinkedHashMap.fromEntries(entryList);

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
            strokeWidth: 2,
            fillColor: Colors.white,
            geodesic: false,
            consumeTapEvents: true,
          ),
        );
      });
    }
  }

  Future<void> addselectedRoomMarker(List<LatLng> polygonPoints) async {
    selectedroomMarker.clear(); // Clear existing markers
    setState(() {
      selectedroomMarker.add(
        Marker(
          markerId: MarkerId('selectedroomMarker'),
          position: calculateRoomCenter(polygonPoints),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  Future<void> addselectedMarker(LatLng Point) async {
    selectedroomMarker.clear(); // Clear existing markers
    setState(() {
      selectedroomMarker.add(
        Marker(
          markerId: MarkerId('selectedroomMarker'),
          position: Point,
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  LatLng calculateRoomCenter(List<LatLng> polygonPoints) {
    double lat = 0.0;
    double long = 0.0;
    if(polygonPoints.length <= 4){
      for (int i = 0; i < polygonPoints.length; i++) {
        lat = lat + polygonPoints[i].latitude;
        long = long + polygonPoints[i].longitude;
      }
      return LatLng(lat / polygonPoints.length, long / polygonPoints.length);
    }else{
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
    _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(
        bounds,
        0));
  }

  LatLng calculateBoundsCenter(LatLngBounds bounds) {
    double centerLat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    double centerLng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;

    return LatLng(centerLat, centerLng);
  }

  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
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

  void createRooms(polylinedata value, int floor) {
    closedpolygons.clear();
    selectedroomMarker.clear();
    _isLandmarkPanelOpen = false;
    building.selectedLandmarkID = null;
    polylines.clear();
    List<PolyArray>? FloorPolyArray = value.polyline!.floors![0].polyArray;
    for (int j = 0; j < value.polyline!.floors!.length; j++) {
      if (value.polyline!.floors![j].floor ==
          tools.numericalToAlphabetical(floor)) {
        FloorPolyArray = value.polyline!.floors![j].polyArray;
      }
    }
    building.numberOfFloors = value.polyline!.floors!.length;
    setState(() {
      if (FloorPolyArray != null) {
        for (PolyArray polyArray in FloorPolyArray) {
          List<LatLng> coordinates = [];

          for (Nodes node in polyArray.nodes!) {
            //coordinates.add(LatLng(node.lat!,node.lon!));
            coordinates.add(LatLng(
                tools.localtoglobal(node.coordx!, node.coordy!)[0],
                tools.localtoglobal(node.coordx!, node.coordy!)[1]));
          }

          if (polyArray.polygonType == 'Wall' ||
              polyArray.polygonType == 'undefined') {
            if (coordinates.length >= 2) {
              polylines.add(gmap.Polyline(
                polylineId: PolylineId(polyArray.id!),
                points: coordinates,
                color: Colors.black,
                width: 1,
              ));
            }
          } else if (polyArray.polygonType == 'Room') {
            if (coordinates.length > 2) {
              coordinates.add(coordinates.first);
              closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
                  points: coordinates,
                  strokeWidth: 1,
                  // Modify the color and opacity based on the selectedRoomId

                  strokeColor: Colors.black,
                  fillColor: Color(0xff7CFC00),
                  consumeTapEvents: true,
                ));
              }
            }else if (polyArray.cubicleName!.toLowerCase().contains("lift")) {
              if (coordinates.length > 2) {
                coordinates.add(coordinates.first);
                closedpolygons.add(Polygon(
                  polygonId: PolygonId(polyArray.id!),
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
                closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
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
                closedpolygons.add(Polygon(
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
              closedpolygons.add(Polygon(
                polygonId: PolygonId(polyArray.id!),
                points: coordinates,
                strokeWidth: 1,
                // Modify the color and opacity based on the selectedRoomId

                strokeColor: Colors.black,
                fillColor: Color(0xffCCCCCC),
                consumeTapEvents: true,
              ));
            }
          }else {
            polylines.add(gmap.Polyline(
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

  void createMarkers(land _landData, int floor) async {
    Markers.clear();
    List<Landmarks> landmarks = _landData.landmarks!;

    for (int i = 0; i < landmarks.length; i++) {
      if (landmarks[i].floor == floor) {
        if(landmarks[i].element!.type == "Rooms" && landmarks[i].coordinateX != null){
          BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(devicePixelRatio: 2.5),
            'assets/7.png',
          );
          setState(() {
            List<double> value =
            tools.localtoglobal(landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Room ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: customMarker,
                visible: false,
                anchor: Offset(0.5, 0.5),
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
        }
        if (landmarks[i].element!.subType != null &&
            landmarks[i].element!.subType == "room door" &&
            landmarks[i].doorX != null) {
          BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            'assets/dooricon.png',
          );
          setState(() {
            List<double> value =
                tools.localtoglobal(landmarks[i].doorX!, landmarks[i].doorY!);
            Markers.add(Marker(
                markerId: MarkerId("Door ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: customMarker,
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
          BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(44, 44)),
            'assets/6.png',
          );
          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Rest ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: customMarker,
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
          BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(),
            'assets/1.png',
          );
          setState(() {
            List<double> value = tools.localtoglobal(
                landmarks[i].coordinateX!, landmarks[i].coordinateY!);
            Markers.add(Marker(
                markerId: MarkerId("Entry ${landmarks[i].properties!.polyId}"),
                position: LatLng(value[0], value[1]),
                icon: customMarker,
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
  Widget landmarkdetailpannel(BuildContext context, AsyncSnapshot<land> snapshot) {
    pathMarkers.clear();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (!snapshot.hasData ||
        snapshot.data!.landmarksMap == null ||
        snapshot.data!.landmarksMap![building.selectedLandmarkID] == null) {
      print(building.selectedLandmarkID);
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
                      snapshot.data!.landmarksMap![building.selectedLandmarkID]!.name!,
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
                              width: 108,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xff24B9B0),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  _isLandmarkPanelOpen = false;
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
                                    await calculateroute(
                                            snapshot.data!.landmarksMap!)
                                        .then((value) {
                                      _isRoutePanelOpen = true;
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
                                      fromSourceAndDestinationPage(value);
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                    ),
                                  ],
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

  Future<void> calculateroute(Map<String, Landmarks> landmarksMap) async {
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
    if (PathState.sourceFloor == PathState.destinationFloor) {
      print(
          "${PathState.sourceX},${PathState.sourceY}    ${PathState.destinationX},${PathState.destinationY}");
      await fetchroute(
          PathState.sourceX,
          PathState.sourceY,
          PathState.destinationX,
          PathState.destinationY,
          PathState.destinationFloor);
    } else if (PathState.sourceFloor != PathState.destinationFloor) {
      List<CommonLifts> commonlifts = findCommonLifts(
          landmarksMap[PathState.sourcePolyID]!.lifts!,
          landmarksMap[PathState.destinationPolyID]!.lifts!);
      print(
          "mmm ${commonlifts[0].x1},${commonlifts[0].y1}    ${commonlifts[0].x2},${commonlifts[0].y2}");
      print(
          "${PathState.sourceX},${PathState.sourceY}    ${PathState.destinationX},${PathState.destinationY}");
      await fetchroute(
          commonlifts[0].x2!,
          commonlifts[0].y2!,
          PathState.destinationX,
          PathState.destinationY,
          PathState.destinationFloor);
      await fetchroute(PathState.sourceX, PathState.sourceY, commonlifts[0].x1!,
          commonlifts[0].y1!, PathState.sourceFloor);
    }
  }

  Future<List<int>> fetchroute(int sourceX, int sourceY, int destinationX,
      int destinationY, int floor) async {
    int numRows = building.floorDimenssion[floor]![1]; //floor breadth
    int numCols = building.floorDimenssion[floor]![0]; //floor length
    int sourceIndex = calculateindex(sourceX, sourceY, numCols);
    int destinationIndex = calculateindex(destinationX, destinationY, numCols);

    List<int> path = findPath(numRows, numCols, building.nonWalkable[floor]!,
        sourceIndex, destinationIndex);
    PathState.path[floor] = path;
    PathState.numCols = numCols;
    List<Map<String, int>> directions = tools.getDirections(path, numCols);
    directions.forEach((element) {
      PathState.directions.insert(0, element);
    });

    await building.landmarkdata!.then((value) {
      List<Landmarks> nearbyLandmarks = tools.findNearbyLandmark(
          path, value.landmarksMap!, 20, numCols, floor);
    });

    if (path.isNotEmpty) {
      List<double> svalue = tools.localtoglobal(sourceX, sourceY);
      List<double> dvalue = tools.localtoglobal(destinationX, destinationY);
      Set<Marker> innerMarker = Set();
      innerMarker.add(Marker(
          markerId: MarkerId("destination"),
          position: LatLng(dvalue[0], dvalue[1]),
          icon: BitmapDescriptor.defaultMarker));
      innerMarker.add(
        Marker(
          markerId: MarkerId('source'),
          position: LatLng(svalue[0], svalue[1]),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
      pathMarkers[floor] = innerMarker;
      setCameraPosition(innerMarker);
      print("Path found: $path");
    } else {
      print("No path found.");
    }

    List<LatLng> coordinates = [];
    for (int node in path) {
      if (!building.nonWalkable[floor]!.contains(node)) {
        int row = (node % numCols); //divide by floor length
        int col = (node ~/ numCols); //divide by floor length
        List<double> value = tools.localtoglobal(row, col);
        coordinates.add(LatLng(value[0], value[1]));
      }
    }
    setState(() {
      Set<gmap.Polyline> innerset = Set();
      innerset.add(gmap.Polyline(
        polylineId: PolylineId("route"),
        points: coordinates,
        color: Colors.red,
        width: 3,
      ));
      singleroute[floor] = innerset;
    });
    print("$floor    $path");
    building.floor = floor;
    createRooms(building.polyLineData!, building.floor);
    return path;
  }

  PanelController _routeDetailPannelController = new PanelController();
  Widget routeDeatilPannel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> directionWidgets = [];
    directionWidgets.clear();
    for (int i = 0; i < PathState.directions.length; i++) {
      if (PathState.directions[i].keys.first == "Straight") {
        directionWidgets.add(directionInstruction(
            direction: "Go " + PathState.directions[i].keys.first,
            distance: (PathState.directions[i].values.first * 0.3048)
                .toStringAsFixed(0)));
      } else {
        directionWidgets.add(directionInstruction(
            direction: "Turn " +
                PathState.directions[i].keys.first +
                ", and Go Straight",
            distance: (PathState.directions[++i].values.first * 0.3048)
                .toStringAsFixed(0)));
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
                            pathState.withValues(-1, -1, -1, -1, -1, -1, 0, 0);
                        PathState.path.clear();
                        PathState.sourcePolyID = "";
                        PathState.destinationPolyID = "";
                        singleroute.clear();
                        setState(() {
                          Marker temp = selectedroomMarker.first;
                          selectedroomMarker.clear();
                          selectedroomMarker.add(temp);
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
                                        onPressed: () {
                                          user.pathobj = PathState;
                                          user.path = PathState.path.values
                                              .expand((list) => list)
                                              .toList();
                                          user.isnavigating = true;
                                          user
                                              .moveToStartofPath()
                                              .then((value) {
                                            setState(() {
                                              if (markers.length > 0) {
                                                markers[0] = customMarker.move(
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
                                                    markers[0]);
                                              }
                                            });
                                          });
                                          _isRoutePanelOpen = false;
                                          //selectedroomMarker.clear();
                                          //pathMarkers.clear();
                                          building.selectedLandmarkID = null;
                                          _isnavigationPannelOpen = true;
                                        },
                                        child: Row(
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
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 91,
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
                              _isRoutePanelOpen = false;
                              selectedroomMarker.clear();
                              pathMarkers.clear();
                              building.selectedLandmarkID = null;
                              PathState = pathState.withValues(
                                  -1, -1, -1, -1, -1, -1, 0, 0);
                              PathState.path.clear();
                              PathState.sourcePolyID = "";
                              PathState.destinationPolyID = "";
                              singleroute.clear();
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
            distance: (PathState.directions[i].values.first * 0.3048)
                .toStringAsFixed(0)));
      } else {
        directionWidgets.add(directionInstruction(
            direction: "Turn " +
                PathState.directions[i].keys.first +
                ", and Go Straight",
            distance: (PathState.directions[++i].values.first * 0.3048)
                .toStringAsFixed(0)));
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
        visible: _isnavigationPannelOpen,
        child: SlidingUpPanel(
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
                            user.isnavigating = false;
                            user.pathobj = pathState();
                            user.path = [];
                            PathState = pathState.withValues(
                                -1, -1, -1, -1, -1, -1, 0, 0);
                            selectedroomMarker.clear();
                            pathMarkers.clear();
                            PathState.path.clear();
                            PathState.sourcePolyID = "";
                            PathState.destinationPolyID = "";
                            singleroute.clear();
                            fitPolygonInScreen(patch.first);
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
                            onPressed: ()async{
                              PathState.sourceX = user.coordX;
                              PathState.sourceY = user.coordY;
                              user.showcoordX = user.coordX;
                              user.showcoordY = user.coordY;
                              PathState.sourceFloor = user.floor;
                              PathState.sourcePolyID = user.key;
                              print("object ${PathState.sourcePolyID}");
                              PathState.sourceName =
                              "Your current location";
                              building.landmarkdata!.then((value)async{
                                await calculateroute(value.landmarksMap!)
                                    .then((value) {
                                  user.pathobj = PathState;
                                  user.path = PathState.path.values
                                      .expand((list) => list)
                                      .toList();
                                  user.pathobj.index = 0;
                                  user.isnavigating = true;
                                  user
                                      .moveToStartofPath()
                                      .then((value) {
                                    setState(() {
                                      if (markers.length > 0) {
                                        markers[0] = customMarker.move(
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
                                            markers[0]);
                                      }
                                    });
                                  });
                                  _isRoutePanelOpen = false;
                                  building.selectedLandmarkID = null;
                                  _isnavigationPannelOpen = true;
                                  _isreroutePannelOpen = false;
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

  Set<Marker> getCombinedMarkers() {
    if(user.floor == building.floor){
      if (_isLandmarkPanelOpen) {
        return (selectedroomMarker.union(Set<Marker>.of(markers))).union(Markers);
      } else {
        return pathMarkers[building.floor] != null
            ? (pathMarkers[building.floor]!.union(Set<Marker>.of(markers)))
            .union(Markers)
            : (Set<Marker>.of(markers)).union(Markers);
      }
    }else {
      if (_isLandmarkPanelOpen) {
        return (selectedroomMarker).union(Markers);
      } else {
        return pathMarkers[building.floor] != null
            ? (pathMarkers[building.floor]!)
            .union(Markers)
            : Markers;
      }
    }
  }

  void _updateMarkers(double zoom) {
    if(building.updateMarkers){
      Set<Marker> updatedMarkers = Set();
      setState(() {
        Markers.forEach((marker) {
          print(marker);
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
            Marker _marker = customMarker.visibility(zoom > 18.5, marker);
            updatedMarkers.add(_marker);
          }
          if (marker.markerId.value.contains("Building")) {
            Marker _marker = customMarker.visibility(zoom < 16.0, marker);
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

  void hideMarkers(){
    building.updateMarkers = false;
    Set<Marker> updatedMarkers = Set();
    Markers.forEach((marker) {
      Marker _marker = customMarker.visibility(false, marker);
      updatedMarkers.add(_marker);
    });
    Markers = updatedMarkers;
  }


  void showMarkers(){
    building.ignoredMarker.clear();
    building.updateMarkers = true;
  }

  void _updateBuilding(double zoom) {
    Set<Polygon> updatedclosedPolygon = Set();
    Set<Polygon> updatedpatchPolygon = Set();
    Set<gmap.Polyline> updatedpolyline = Set();
    setState(() {
      closedpolygons.forEach((polygon) {
        Polygon _polygon = polygon.copyWith(visibleParam: zoom > 16.0);
        updatedclosedPolygon.add(_polygon);
      });
      patch.forEach((polygon) {
        Polygon _polygon = polygon.copyWith(visibleParam: zoom > 16.0);
        updatedpatchPolygon.add(_polygon);
      });
      polylines.forEach((polyline) {
        gmap.Polyline _polyline = polyline.copyWith(visibleParam: zoom > 16.0);
        updatedpolyline.add(_polyline);
      });
      closedpolygons = updatedclosedPolygon;
      patch = updatedpatchPolygon;
      polylines = updatedpolyline;
    });
  }

  void onLandmarkVenueClicked(String ID) {
    setState(() {
      if (building.selectedLandmarkID != ID) {
        building.landmarkdata!.then((value) {
          building.floor = value.landmarksMap![ID]!.floor!;
          createRooms(building.polyLineData!, building.floor);
          createMarkers(value, building.floor);
          building.selectedLandmarkID = ID;
          _isRoutePanelOpen = false;
          singleroute.clear();
          _isLandmarkPanelOpen = true;
          List<double> pvalues = tools.localtoglobal(
              value.landmarksMap![ID]!.coordinateX!,
              value.landmarksMap![ID]!.coordinateY!);
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
    markers.clear();
    building.landmarkdata!.then((land) {
      PathState.sourceX = land.landmarksMap![value[0]]!.coordinateX!;
      PathState.sourceY = land.landmarksMap![value[0]]!.coordinateY!;
      if (land.landmarksMap![value[0]]!.doorX != null) {
        PathState.sourceX = land.landmarksMap![value[0]]!.doorX!;
        PathState.sourceY = land.landmarksMap![value[0]]!.doorY!;
      }
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
        PathState.path.clear();
        PathState.directions.clear();
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
        PathState.path.clear();
        PathState.directions.clear();
        calculateroute(value.landmarksMap!).then((value) {
          _isRoutePanelOpen = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidthPixels = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
    double screenHeightPixel = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              child: GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                polygons: patch.union(closedpolygons),
                polylines: singleroute[building.floor] != null
                    ? polylines.union(singleroute[building.floor]!)
                    : polylines,
                markers: getCombinedMarkers(),
                onTap: (x) {mapState.interaction = true;},
                mapType: MapType.normal,
                buildingsEnabled: false,
                compassEnabled: true,
                rotateGesturesEnabled: true,
            minMaxZoomPreference: MinMaxZoomPreference(2,30),
                onMapCreated: (controller) {
                  controller.setMapStyle(maptheme);
                  _googleMapController = controller;
                  apiCalls();
                  if (patch.isNotEmpty) {
                    fitPolygonInScreen(patch.first);
                  }
                },
                onCameraMove: (CameraPosition cameraPosition) {
                  //mapState.interaction = true;
                  mapbearing = cameraPosition.bearing;
                  if(!mapState.interaction){
                    mapState.zoom = cameraPosition.zoom;
                  }
                  if (true) {
                    _updateMarkers(cameraPosition.zoom);
                    //_updateBuilding(cameraPosition.zoom);
                  }
                },
                onCameraIdle: (){
                  if(!mapState.interaction){
                    mapState.interaction2 = true;
                  }
                },
                onCameraMoveStarted: (){
                  mapState.interaction2 = false;
                },
              ),
            ),
            Positioned(
              bottom: 150.0, // Adjust the position as needed
              right: 16.0,
              child: Column(
                children: [
                  SpeedDial(
                    child: Text(
                      building.floor == 0 ? 'G' : '${building.floor}',
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
                      for (int i = 0; i < building.numberOfFloors; i++)
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
                            building.floor = i;
                            createRooms(building.polyLineData!, building.floor);
                            if (pathMarkers[i] != null) {
                              setCameraPosition(pathMarkers[i]!);
                            }
                            building.landmarkdata!.then((value) {
                              createMarkers(value, building.floor);
                            });
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 28.0), // Adjust the height as needed
                  FloatingActionButton(
                    onPressed: () {
                      // bool isvalid = MotionModel.isValidStep(
                      //     user,
                      //     building.floorDimenssion[user.floor]![0],
                      //     building.floorDimenssion[user.floor]![1],
                      //     building.nonWalkable[user.floor]!,
                      //     reroute);
                      // if (isvalid) {
                      //   user.move().then((value) {
                      //     setState(() {
                      //       if (markers.length > 0) {
                      //         markers[0] = customMarker.move(
                      //             LatLng(
                      //                 tools.localtoglobal(
                      //                     user.showcoordX.toInt(),
                      //                     user.showcoordY.toInt())[0],
                      //                 tools.localtoglobal(
                      //                     user.showcoordX.toInt(),
                      //                     user.showcoordY.toInt())[1]),
                      //             markers[0]);
                      //       }
                      //     });
                      //   });
                      // } else {
                      //   reroute();
                      //   showToast("You are out of path");
                      // }
                      if (markers.length > 0)
                        markers[0] =
                            customMarker.rotate(0, markers[0]);
                      mapState.interaction = !mapState.interaction;
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
                ],
              ),
            ),
            Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _isLandmarkPanelOpen
                    ? Container()
                    : HomepageSearch(
                        onVenueClicked: onLandmarkVenueClicked,
                        fromSourceAndDestinationPage:
                            fromSourceAndDestinationPage,
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
            reroutePannel()
          ],
        ),
      ),
    );
  }
}
