import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:iwayplusnav/API/PolyLineApi.dart';
import 'package:iwayplusnav/APIMODELS/landmark.dart';
import 'package:iwayplusnav/Elements/HomepageLandmarkClickedSearchBar.dart';
import 'package:iwayplusnav/UserState.dart';
import 'package:iwayplusnav/buildingState.dart';
import 'package:iwayplusnav/navigationTools.dart';
import 'package:iwayplusnav/path.dart';
import 'package:iwayplusnav/pathState.dart';
import 'package:iwayplusnav/pathState.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'API/PatchApi.dart';
import 'API/beaconapi.dart';
import 'API/ladmarkApi.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'Elements/HomepageSearch.dart';
import 'Elements/landmarkPannelShimmer.dart';
import 'bluetooth_scanning.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'cutommarker.dart';
import 'dart:math' as math;


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
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  String maptheme = "";
  var _initialCameraPosition = CameraPosition(
    target: LatLng(60.543833319119475, 77.18729871127312),
    zoom: 20,
  );
  late GoogleMapController _googleMapController;
  Set<Polygon> patch = Set();
  Set<gmap.Polyline> polylines = Set();
  Set<Polygon> closedpolygons = Set();
  Set<Marker> selectedroomMarker = Set();
  List<Marker> markers = [];
  Building building = Building(floor: 0, numberOfFloors: 1);
  Set<gmap.Polyline> singleroute = Set();
  BT btadapter = new BT();
  bool _isLandmarkPanelOpen = false;
  bool _isRoutePanelOpen = false;
  HashMap<String, beacon> apibeaconmap = HashMap();
  late FlutterTts flutterTts;
  double mapbearing = 0.0;
  UserState user = UserState(floor: -1, coordX: 154, coordY: 94, lat: 28.543406741799892, lng: 77.18761156074972);
  pathState PathState = pathState(-1, -1, -1, -1, -1, -1);

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    handleCompassEvents();
    DefaultAssetBundle.of(context)
        .loadString("assets/mapstyle.json")
        .then((value) {
      maptheme = value;
    });
    checkPermissions();
    apiCalls();
  }

  void handleCompassEvents() {
    FlutterCompass.events!.listen((event) {
      double? compassHeading = event.heading;
      setState(() {
        if (markers.length > 0)
          markers[0] = customMarker.rotate(compassHeading! - mapbearing, markers[0]);
      });
    });
  }

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  void checkPermissions() async {
    await requestLocationPermission();
    await requestBluetoothConnectPermission();
    //  await requestActivityPermission();
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

  void apiCalls()async{
    await patchAPI().fetchPatchData().then((value) {
      createPatch(value);
    });

    await PolyLineApi().fetchPolyData().then((value) {
      building.polyLineData = value;
      createRooms(value, building.floor);
    });
    print("going to call land");
    building.landmarkdata = landmarkApi().fetchLandmarkData();
    building.landmarkdata!.then((value) {

      for (int i = 0; i < value.landmarks!.length; i++) {
        if (value.landmarks![i].element!.type == "Floor") {
          List<int> allIntegers = [];
          String jointnonwalkable = value.landmarks![i].properties!.nonWalkableGrids!.join(',');
          RegExp regExp = RegExp(r'\d+');
          Iterable<Match> matches = regExp.allMatches(jointnonwalkable);
          for (Match match in matches) {
            String matched = match.group(0)!;
            allIntegers.add(int.parse(matched));
          }
          building.nonWalkable[value.landmarks![i].floor!] = allIntegers;
          building.floorDimenssion[value.landmarks![i].floor!] = [value.landmarks![i].properties!.floorLength!, value.landmarks![i].properties!.floorBreadth!];
        }
      }
    });

    // beaconapi().fetchBeaconData().then((value){
    //   building.beacondata = value;
    //   for (int i = 0; i < value.length; i++) {
    //     beacon beacons = value[i];
    //     if (beacons.properties!.macId != null) {
    //       apibeaconmap[beacons.properties!.macId!] = beacons;
    //     }
    //   }
    //   btadapter.startScanning(apibeaconmap);
    //   late Timer _timer;
    //   _timer = Timer.periodic(Duration(milliseconds: 9000), (timer) {
    //     localizeUser();
    //     _timer.cancel();
    //   });
    // });
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
      speak("You are on ${tools.numericalToAlphabetical(apibeaconmap[nearestBeacon]!.floor!)} floor, near ${apibeaconmap[nearestBeacon]!.name!}");
      List<double> values = tools.localtoglobal(
          apibeaconmap[nearestBeacon]!.coordinateX!,
          apibeaconmap[nearestBeacon]!.coordinateY!);
      LatLng beaconLocation = LatLng(values[0], values[1]);
      _googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(values[0], values[1]),
          20, // Specify your custom zoom level here
        ),
      );
      setState(() {
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId(nearestBeacon),
          position: beaconLocation,
          icon: userloc,
          anchor: Offset(0.5, 0.829),
        ));
        building.floor = apibeaconmap[nearestBeacon]!.floor!;

        createRooms(building.polyLineData!, building.floor);
      });
    }
    btadapter.stopScanning();
  }


  void createPatch(patchDataModel value) {
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
      fitPolygonInScreen(patch.first);
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

  LatLng calculateRoomCenter(List<LatLng> polygonPoints){
    double lat = 0.0;
    double long = 0.0;
    for(int i = 0 ; i<polygonPoints.length ; i++){
      lat = lat + polygonPoints[i].latitude;
      long = long + polygonPoints[i].longitude;
    }
    return LatLng(lat/polygonPoints.length, long/polygonPoints.length);
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
    _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        0));
  }

  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
  }

  void setCameraPosition(Set<Marker> selectedroomMarker) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;

    for (Marker marker in selectedroomMarker) {
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
                      if(building.selectedLandmarkID != polyArray.id){
                        building.selectedLandmarkID = polyArray.id;
                        _isLandmarkPanelOpen = true;
                        addselectedRoomMarker(coordinates);
                      }
                    });
                  }));
            }
          } else if (polyArray.polygonType == 'Cubicle') {
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
          } else {
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

  void toggleLandmarkPanel() {
    setState(() {
      _isLandmarkPanelOpen = !_isLandmarkPanelOpen;
      selectedroomMarker.clear();
      building.selectedLandmarkID = null;
      _googleMapController.animateCamera(CameraUpdate.zoomOut());
    });
  }

  PanelController _landmarkPannelController = new PanelController();
  Widget landmarkdetailpannel(
      BuildContext context, AsyncSnapshot<land> snapshot) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (!snapshot.hasData ||
        snapshot.data!.landmarksMap == null ||
        snapshot.data!.landmarksMap![building.selectedLandmarkID] == null) {
      // If the data is not available, return an empty container
      _isLandmarkPanelOpen = false;
      selectedroomMarker.clear();
      building.selectedLandmarkID = null;
      return Container();

    }
    return Stack(
      children: [Positioned(
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
                  offset:
                  Offset(0, 2), // Offset of the shadow
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
                      onPressed: () {toggleLandmarkPanel();},
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
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 6,
                          margin:EdgeInsets.only(top: 8),
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
                            snapshot.data!.landmarksMap![building.selectedLandmarkID]!.name!,
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
                              onPressed: ()async{
                                _isLandmarkPanelOpen = false;
                                PathState.destinationX = snapshot.data!.landmarksMap![building.selectedLandmarkID]!.coordinateX!;
                                PathState.destinationY = snapshot.data!.landmarksMap![building.selectedLandmarkID]!.coordinateY!;
                                if(snapshot.data!.landmarksMap![building.selectedLandmarkID]!.doorX != null){
                                   PathState.destinationX = snapshot.data!.landmarksMap![building.selectedLandmarkID]!.doorX!;
                                   PathState.destinationY = snapshot.data!.landmarksMap![building.selectedLandmarkID]!.doorY!;
                                }
                                PathState.sourceX = user.coordX;
                                PathState.sourceY = user.coordY;
                                print(PathState.destinationX);
                                print(PathState.destinationY);
                                await fetchroute(PathState.sourceX, PathState.sourceY, PathState.destinationX, PathState.destinationY, snapshot.data!.landmarksMap![building.selectedLandmarkID]!.floor!).then((value){
                                  List<double> mvalue = tools.localtoglobal(user.coordX, user.coordY);
                                  selectedroomMarker.add(
                                    Marker(
                                      markerId: MarkerId('source'),
                                      position: LatLng(mvalue[0], mvalue[1]),
                                      icon: BitmapDescriptor.defaultMarker,
                                    ),
                                  );
                                  setCameraPosition(selectedroomMarker);
                                  PathState.path.add(value);
                                  PathState.destinationPolyID = building.selectedLandmarkID!;
                                  PathState.destinationName = snapshot.data!.landmarksMap![building.selectedLandmarkID]!.name!;
                                  _isRoutePanelOpen = true;
                                });
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
                    Container(height: 1,width: screenWidth,color: Color(0xffebebeb),),
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
                          snapshot.data!.landmarksMap![building.selectedLandmarkID]!.properties!.contactNo != null?Container(
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
                          ) :Container(),
                          snapshot.data!.landmarksMap![building.selectedLandmarkID]!.properties!.email != "" && snapshot.data!.landmarksMap![building.selectedLandmarkID]!.properties!.email != null ?Container(
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
                          ):Container(),
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

  int calculateindex ( int x , int y , int fl){
    return(y*fl)+x;
  }


  PanelController _routeDetailPannelController = new PanelController();

  Future<List<int>> fetchroute(int sourceX, int sourceY, int destinationX, int destinationY, int floor)async{
    int numRows = building.floorDimenssion[floor]![1]; //floor breadth
    int numCols = building.floorDimenssion[floor]![0]; //floor length
    int sourceIndex = calculateindex(sourceX, sourceY, numCols);
    int destinationIndex = calculateindex(destinationX, destinationY, numCols);

    List<int> path = findPath(
      numRows,
      numCols,
      building.nonWalkable[floor]!,
      sourceIndex,
      destinationIndex,
    );



    if (path.isNotEmpty) {
      print("Path found: $path");
    } else {
      print("No path found.");
    }

    List<LatLng> coordinates = [];
    for (int node in path) {
      if(!building.nonWalkable[floor]!.contains(node)){
        int row = (node % numCols); //divide by floor length
        int col = (node ~/ numCols); //divide by floor length
        print("[$row,$col]");
        List<double> value = tools.localtoglobal(row, col);
        coordinates.add(LatLng(value[0], value[1]));
      }

    }
    setState(() {
      singleroute.add(gmap.Polyline(
        polylineId: PolylineId("route"),
        points: coordinates,
        color: Colors.red,
        width: 1,
      ));
    });

    return path;
  }

  Widget routeDeatilPannel(){
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double time = 0;
    double distance = 0;
    DateTime currentTime = DateTime.now();
    DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));
    if(PathState.path.isNotEmpty){
      if(PathState.sourcePolyID == ""){
        PathState.sourceName = "Your current location";
      }
      for(int i = 0 ; i<PathState.path.length; i++){
        time = time + PathState.path[i].length/120;
        distance = distance + PathState.path[i].length;
      }
      time = double.parse(time.toStringAsFixed(1));
      distance = distance*0.3048;
      distance = double.parse(distance.toStringAsFixed(2));
    }
    return Visibility(
      visible: _isRoutePanelOpen,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16,top: 16),
            height: 119,
            width: screenWidth-32,

            padding: EdgeInsets.only(top: 15,right: 16),
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
                IconButton(onPressed: (){
                  List<double> mvalues = tools.localtoglobal(PathState.destinationX, PathState.destinationY);
                  _googleMapController.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(mvalues[0], mvalues[1]),
                      20, // Specify your custom zoom level here
                    ),
                  );
                  _isRoutePanelOpen = false;
                  _isLandmarkPanelOpen = true;
                  PathState = pathState(-1, -1, -1, -1, -1, -1);
                  PathState.path = [];
                  PathState.sourcePolyID = "";
                  PathState.destinationPolyID = "";
                  singleroute.clear();
                  setState(() {
                    Marker temp = selectedroomMarker.first;
                    selectedroomMarker.clear();
                    selectedroomMarker.add(temp);
                    print(selectedroomMarker);
                  });

                  }, icon: Icon(Icons.arrow_back_ios_new,size: 28,)),
                Expanded(
                  child: Column(
                    children: [
                      Container(height:40,width:double.infinity,margin:EdgeInsets.only(bottom: 8),decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Color(0xffE2E2E2)),
                      ),
                        padding: EdgeInsets.only(left: 8,top: 7,bottom: 8),
                      child: Text(
                        PathState.sourceName,
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff24b9b0),
                        ),
                        textAlign: TextAlign.left,
                      ),),
                      Container(height:40,width:double.infinity,decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Color(0xffE2E2E2)),
                      ),
                        padding: EdgeInsets.only(left: 8,top: 7,bottom: 8),
                        child: Text(
                          PathState.destinationName,
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff282828),
                          ),
                          textAlign: TextAlign.left,
                        ),),
                    ],
                  ),
                )
              ],
            ),
          ),
          SlidingUpPanel(
              controller: _routeDetailPannelController,
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20.0,
                  color: Colors.grey,
                ),
              ],
              minHeight: 163,
              maxHeight: 163,
              snapPoint: 0.6,
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
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 6,
                              margin:EdgeInsets.only(top: 8),
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
                                    "$time min ",
                                    style: const TextStyle(
                                      color: Color(0xffDC6A01),
                                      fontFamily: "Roboto",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      height: 24/18,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    "(${distance} m)",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      height: 24/18,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                ],
                              ),
                              Text(
                                "via",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff4a4545),
                                  height: 25/16,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                "ETA- ${newTime.hour}:${newTime.minute}",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff8d8c8c),
                                  height: 20/14,
                                ),
                                textAlign: TextAlign.left,
                              ),
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
                                  onPressed: () {},
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(top:13,right:15,child: IconButton(onPressed: (){
                    _isRoutePanelOpen = false;
                    selectedroomMarker.clear();
                    building.selectedLandmarkID = null;
                    PathState = pathState(-1, -1, -1, -1, -1, -1);
                    PathState.path = [];
                    PathState.sourcePolyID = "";
                    PathState.destinationPolyID = "";
                    singleroute.clear();
                    fitPolygonInScreen(patch.first);
                    }, icon: Icon(Icons.cancel_outlined,size: 25,)))],
              )
          ),
        ],
      ),
    );



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
                polylines: polylines.union(singleroute),
                markers: selectedroomMarker.union(Set<Marker>.of(markers)),
                onTap: (x) {},
                mapType: MapType.normal,
                buildingsEnabled: false,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                onMapCreated: (controller) {
                  controller.setMapStyle(maptheme);
                  _googleMapController = controller;
                },
                onCameraMove: (CameraPosition cameraPosition){
                  mapbearing = cameraPosition.bearing;
                },
              ),
            ),
            Positioned(
              bottom: 95.0, // Adjust the position as needed
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
                        height: 19/16,
                      ),
                    ),
                    activeIcon: Icons.close,
                    backgroundColor: Colors.white,
                    children: [
                      for (int i = 0; i < building.numberOfFloors; i++)
                        SpeedDialChild(
                          child: Text(i == 0 ? 'G' : '${i}',style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 19/16,
                          ),),
                          onTap: () {
                            building.floor = i;
                            createRooms(building.polyLineData!, building.floor);
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 28.0), // Adjust the height as needed
                  FloatingActionButton(
                    onPressed: () {
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
            Positioned(top: 16, left: 16, right: 16, child: _isLandmarkPanelOpen?Container():HomepageSearch()),
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
            routeDeatilPannel()
          ],
        ),
      ),
    );
  }
}
