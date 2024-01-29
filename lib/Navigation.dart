
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:iwayplusnav/API/PolyLineApi.dart';
import 'package:iwayplusnav/buildingState.dart';
import 'package:iwayplusnav/navigationTools.dart';
import 'package:iwayplusnav/path.dart';

import 'API/PatchApi.dart';
import 'API/ladmarkApi.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';
import 'Elements/HomepageSearch.dart';
import 'buildingState.dart';
import 'buildingState.dart';
import 'buildingState.dart';

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
  var _initialCameraPosition = CameraPosition(target: LatLng(60.543833319119475, 77.18729871127312), zoom: 20,);
  late GoogleMapController _googleMapController;
  Set<Polygon> patch = Set();
  Set<gmap.Polyline> polylines = Set();
  Set<Polygon> closedpolygons = Set();
  Building building = Building(floor: 0,numberOfFloors: 1);
  Set<gmap.Polyline> singleroute = Set();


  @override
  void initState() {
    super.initState();

    DefaultAssetBundle.of(context)
        .loadString("assets/mapstyle.json")
        .then((value) {
      maptheme = value;
    });
    apiCalls();
  }

  void apiCalls(){

    patchAPI().fetchPatchData().then((value){
      createPatch(value);
    });

    PolyLineApi().fetchPolyData().then((value){
      building.polyLineData = value;
      createRooms(value,building.floor);
    });

    landmarkApi().fetchLandmarkData().then((value){
      building.landmarkdata = value;
      for(int i = 0; i<value.landmarks!.length ; i++){
        if(value.landmarks![i].element!.type == "Floor"){
          List<int> allIntegers = [];
          String jointnonwalkable = value.landmarks![i].properties!.nonWalkableGrids!.join(',');
          RegExp regExp = RegExp(r'\d+');
          Iterable<Match> matches = regExp.allMatches(jointnonwalkable);
          for (Match match in matches) {
            String matched = match.group(0)!;
            allIntegers.add(int.parse(matched));
          }
          building.nonWalkable[value.landmarks![i].floor!] = allIntegers;
        }
      }
    });
  }
  void createPatch(patchDataModel value) {
    if (value.patchData!.coordinates!.isNotEmpty) {
      List<LatLng> polygonPoints = [];
      double latcenterofmap = 0.0;
      double lngcenterofmap = 0.0;

      for (int i = 0; i < 4; i++) {
        latcenterofmap = latcenterofmap + double.parse(value.patchData!.coordinates![i].globalRef!.lat!);
        lngcenterofmap = lngcenterofmap + double.parse(value.patchData!.coordinates![i].globalRef!.lng!);
      }
      latcenterofmap = latcenterofmap / 4;
      lngcenterofmap = lngcenterofmap / 4;

      _initialCameraPosition = CameraPosition(
        target: LatLng(latcenterofmap, lngcenterofmap),
        zoom: 20,
      );

      for(int i = 0;i<4;i++){
        polygonPoints.add(
          LatLng(
              latcenterofmap + 1.1 * (double.parse(value.patchData!.coordinates![i].globalRef!.lat!) - latcenterofmap),
              lngcenterofmap + 1.1 * (double.parse(value.patchData!.coordinates![i].globalRef!.lng!) - lngcenterofmap)
          )
        );
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
    _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    ), 0));
  }

  List<LatLng> getPolygonPoints(Polygon polygon) {
    List<LatLng> polygonPoints = [];

    for (var point in polygon.points) {
      polygonPoints.add(LatLng(point.latitude, point.longitude));
    }

    return polygonPoints;
  }



  void createRooms(polylinedata value, int floor){
    closedpolygons.clear();
    polylines.clear();
    List<PolyArray>? FloorPolyArray = value.polyline!.floors![0].polyArray;
    for (int j = 0; j < value.polyline!.floors!.length; j++) {
      if (value.polyline!.floors![j].floor == tools.numericalToAlphabetical(floor)) {
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
            coordinates.add(LatLng(tools.localtoglobal(node.coordx!,node.coordy!)[0], tools.localtoglobal(node.coordx!,node.coordy!)[1]));
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
          }else{
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false, // Set this property to false
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              color: Colors.white,
              child: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
              ),
            );
          },
        );
      },
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
                onTap: (x) {},
                mapType: MapType.normal,
                buildingsEnabled: false,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                onMapCreated: (controller) {
                  controller.setMapStyle(maptheme);
                  _googleMapController = controller;
                },
              ),
            ),
            Positioned(
              bottom: 95.0, // Adjust the position as needed
              right: 16.0,
              child: Column(
                children: [
                  SpeedDial(
                    child: Text(building.floor == 0 ? 'G' : '${building.floor}',style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff000000),
                      height: 23/16,
                    ),),
                    activeIcon: Icons.close,backgroundColor: Colors.white,
                    children: [
                      for (int i = 0; i < building.numberOfFloors; i++)
                        SpeedDialChild(
                          child: Text(i == 0 ? 'G' : '${i}'),
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
                      _showBottomSheet(context);
                      fitPolygonInScreen(patch.first);
                    },
                    child: Icon(Icons.my_location_sharp,color: Colors.black,),
                    backgroundColor: Colors.white, // Set the background color of the FAB
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,left: 16,right: 16,
              child: HomepageSearch()
            )
          ],
        ),
      ),
    );
  }
}
