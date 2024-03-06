import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwayplusnav/MainScreen.dart';
import 'API/PolyLineApi.dart';
import 'API/buildingAllApi.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/buildingAll.dart';
import 'APIMODELS/polylinedata.dart';
import 'Elements/HomepageSearch.dart';
import 'package:iwayplusnav/buildingState.dart';
import "package:google_maps_flutter_platform_interface/src/types/polyline.dart" as gmap;
import 'package:iwayplusnav/APIMODELS/polylinedata.dart' as ply;
import 'package:google_maps_flutter_platform_interface/src/types/polyline.dart' as gmappol;

import 'MODELS/GMapIconNameModel.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(21.083482,78.4528499),
    zoom: 5.5,
  );
  final Set<Marker> myMarker = Set<Marker>();

  late List<buildingAll> getting_buildingAllApi_List=[];
  List<buildingAll> uniqueVenuesList = [];
  Set<String> uniqueVenueNames = Set<String>();
  List<GMapIconNameModel> GMapIconList = [];
  final List<LatLng> GMapLatLngForIcons = <LatLng>[];
  polylinedata? polyLineData = null;
  ply.Polyline? polyLine = null;
  Set<gmap.Polyline> _myPolyLine = {};
  List<LatLng> poly = <LatLng>[];

  @override
  void initState(){
    super.initState();
    apiCall();
    createPolyArray();
  }

  void apiCall() async {
    await buildingAllApi().fetchBuildingAllData().then((value) {
      setState(() {
        getting_buildingAllApi_List = value;
      });
    });
    print("MAPSCREEN INIT");
    createVenueListForGMIconList();
    //buildingAllApi.setStoredVenue("65d8825cdb333f89456d0562");

    await PolyLineApi().fetchPolyData().then((value) {
      print("object ${value.polylineExist}");
      polyLineData = value;
      print(polyLineData?.polyline);
      print(polyLineData?.polylineExist);
      //createRooms(value, building.floor);
    });
    //createPolyArray();
    print("roomPolylibe");
    print(roomPolylibe2);

  }
  
  void createVenueListForGMIconList(){
    for (buildingAll venue in getting_buildingAllApi_List) {
      if (!uniqueVenueNames.contains(venue.venueName)) {
        uniqueVenuesList.add(venue);
        uniqueVenueNames.add(venue.venueName!);
      }
    }
    // Display the filtered list
    // uniqueVenues.forEach((venue) {
    //   print('Venue Name: ${venue.venueName}, Building Name: ${venue.venueCategory}, Coordinates: ${venue.coordinates}');
    //   // Add more properties if needed
    // });
    createGMAPIconList();
  }
  void createGMAPIconList(){
    for(buildingAll venue in uniqueVenuesList){
      if(venue.venueCategory=='Academic'){
        GMapIconList.add(GMapIconNameModel(buildingName: venue.venueName!, IconAddress: 'assets/Academic.png'));
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else if(venue.venueCategory=='Hospital') {
        GMapIconList.add(GMapIconNameModel(buildingName: venue.venueName!, IconAddress: 'assets/Hospital.png'));
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else if(venue.venueCategory=='Tech Park') {
        GMapIconList.add(GMapIconNameModel(buildingName: venue.venueName!, IconAddress: 'assets/IT park.png'));
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else if(venue.venueCategory=='Event') {
        GMapIconList.add(GMapIconNameModel(buildingName: venue.venueName!, IconAddress: 'assets/Events.png'));
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else{
        GMapIconList.add(GMapIconNameModel(buildingName: venue.venueName!, IconAddress: 'assets/Landmark.png'));
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }
    }
    print(GMapIconList);
    print(GMapLatLngForIcons);
    packData();
  }

  Future<Uint8List> getImagesFromMarker(String path ,int width) async{
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetHeight:width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  packData() async{
    for(int a=0 ; a<GMapIconList.length ; a++){
      final Uint8List iconMarker = await getImagesFromMarker(GMapIconList[a].IconAddress,90);
      myMarker.add(
        Marker(
          markerId: MarkerId(a.toString()),
          position: GMapLatLngForIcons[a],
          icon: BitmapDescriptor.fromBytes(iconMarker),
            onTap: (){
              print("Info Window ");
            },
          infoWindow: InfoWindow(
            title:'${GMapIconList[a].buildingName}',
            onTap: (){
              print("Info Window ");
            }
          )
        ),
      );
      setState(() {

      });
      _myPolyLine.add(
        gmap.Polyline(polylineId: PolylineId("First"),
          points: GMapLatLngForIcons,
          color: Colors.black12
        )
      );
    }
  }
  // final List<LatLng> building3Points = [
  //   LatLng(37.7758, -122.4192),
  //   LatLng(37.7756, -122.4198),
  //   // Add more points as needed
  // ];
  //
  Set<gmap.Polyline> roomPolylibe = {};
  Set<gmap.Polyline> roomPolylibe2 = {};
  Set<gmap.Polyline> testroomPolylibe2 = {};
  // // Create a set of polylines for the three buildings
  // final Set<Polyline> buildingPolylines = {
  //   Polyline(
  //     polylineId: PolylineId('building1'),
  //     points: building1Points,
  //     color: Colors.blue,
  //     width: 5,
  //   ),
  // };

  void createPolyArray() {
    var PY = polyLineData?.polyline;
    print("PY!.polylineMap");
    //print(PY!.polylineMap?.values);

    // for (ply.PolyArray dd in PY.polylineMap!.values){
    //   // print(dd!.);
    //   List<LatLng> buildingNodesPoints = [];
    //   for(ply.Nodes ddNodes in dd.nodes!){
    //     building1Points.add(new LatLng(ddNodes.lat!,ddNodes.lon!));
    //   }
    //   testroomPolylibe2.add(
    //     new gmappol.Polyline(
    //           polylineId: PolylineId('building3'),
    //           points: buildingNodesPoints,
    //           color: Colors.green,
    //           width: 5,
    //         )
    //   );
    // }

    // for(int j=0 ; j<polyLineData!.polyline!.floors![0].polyArray!.length ; j++){
    //   List<LatLng> nodes = [];
    //   for(int k=0 ; k<polyLineData!.polyline!.floors![0].polyArray![j].nodes!.length ; k++){
    //     print("Polyline${k}");
    //     print(polyLineData!.polyline!.floors![0].polyArray![j].nodes![k].lat);
    //     nodes.add(
    //         LatLng(polyLineData!.polyline!.floors![0].polyArray![j].nodes![k].lat!, polyLineData!.polyline!.floors![0].polyArray![j].nodes![k].lon!)
    //     );
    //     // poly.add(
    //     //     LatLng(polyLineData!.polyline!.floors![0].polyArray![j].nodes![k].lat!, polyLineData!.polyline!.floors![0].polyArray![j].nodes![k].lon!)
    //     // );
    //   }
    //   roomPolylibe.add(
    //     new gmap.Polyline(
    //         polylineId: PolylineId('${polyLineData!.polyline!.floors![0]}'),
    //       points: nodes,
    //       color: Colors.black12,
    //       width: 10,
    //     ),
    //   );
    // }
    print("Polyttttt");
    print(poly);
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building1'),
        points: building1Points,
        color: Colors.black,
        width: 1,
      ),
    );
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building2'),
        points: building2Points,
        color: Colors.black,
        width: 1,
      ),
    );
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building3'),
        points: building3Points,
        color: Colors.black,
        width: 1,
      ),
    );
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building4'),
        points: building21Points,
        color: Colors.black,
        width: 1,
      ),
    );
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building5'),
        points: building22Points,
        color: Colors.black,
        width: 1,
      ),
    );
    roomPolylibe2.add(
        new gmap.Polyline(
          polylineId: PolylineId('building6'),
          points: building31Points,
          color: Colors.black,
          width: 1,
        ),
      );
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building7'),
        points: building31Points,
        color: Colors.black,
        width: 1,
      ),
    );
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building8'),
        points: building32Points,
        color: Colors.black,
        width: 1,
      ),
    );
    roomPolylibe2.add(
      new gmap.Polyline(
        polylineId: PolylineId('building9'),
        points: building41Points,
        color: Colors.black,
        width: 1,
      ),
    );
    print(roomPolylibe2);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
              },
              markers: myMarker,
              polylines: roomPolylibe2,
              ),
            ),
            Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  width: 23,
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
                              onPressed: () {},
                              icon: Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => DestinationSearchPage(hintText: 'Destination location',))
                              // ).then((value){
                              //   widget.onVenueClicked(value);
                              // });
                            },
                            child: Container(
                                child: Text(
                                  "",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff8e8d8d),
                                    height: 25 / 16,
                                  ),
                                )),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 48,
                          child: Center(
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.mic_none_sharp,
                                color: Color(0xff8E8C8C),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 48,
                          width: 1,
                          margin: EdgeInsets.only(right: 4),
                          child: Center(
                            child: Container(
                              height: 20.5,
                              width: 1,
                              color: Color(0xff8E8C8C),
                            ),
                          ),
                        ),
                        Container(
                          height: 48,
                          width: 47,
                          child: Center(
                            child: InkWell(
                              child: Icon(
                                Icons.directions,
                                color: Color(0xff24B9B0),
                                size: 24,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                )

            ),
        ]
        ),

      ),
    );
  }

  List<LatLng> building1Points = [
    LatLng(28.946807108420224, 77.10240023349384),
    LatLng(28.946771333539516, 77.10162341992492),
    LatLng(28.94528375398357, 77.10171371156895),
    LatLng(28.9453180178885, 77.10249170054986),
    LatLng(28.946812387912427, 77.10255897751944),
    LatLng(28.945333701382303, 77.10249469750464),
  ];
  List<LatLng> building2Points = [
    LatLng(28.94758159627567, 77.10187742076033),
    LatLng(28.94756502954852, 77.101613315484),
    LatLng(28.94695255984797, 77.10165083340246),
    LatLng(28.946966639651855, 77.1019107789804),
    LatLng(28.94754625658468, 77.1019482968989),
  ];

  List<LatLng> building3Points = [
    LatLng(28.947856871175023, 77.10091528634611),
    LatLng(28.947239668896962, 77.10097700482592),
    LatLng(28.94728425777793, 77.10189473178647),
    LatLng(28.947903806559008, 77.1018598474283),
    LatLng(28.947934314547194, 77.10098237165022),
  ];
  List<LatLng> building21Points = [
    LatLng(28.54504245860697, 77.19003055826083),
    LatLng(28.54475493570298, 77.19016748839225),
    LatLng(28.544990610272432, 77.1908628786675),
    LatLng(28.54528284600625, 77.19073400324967),

    LatLng(28.5450104953636, 77.18993357809752),
    LatLng(28.544959825385234, 77.18995371488157),
    LatLng(28.54499399816404, 77.19005037144491),
  ];
  List<LatLng> building22Points = [
    LatLng(28.543833319119475, 77.18729871127312),
    LatLng(28.54314073334607, 77.18695033060165),
    LatLng(28.542810928996282, 77.18774356659209),
    LatLng(28.543505872671684, 77.18809998681755),

    LatLng(28.54390169863704, 77.1873419496217),
    LatLng(28.543879319250493, 77.187411625756),
    LatLng(28.543809825335625, 77.18736472835792),
  ];
  List<LatLng> building31Points = [
    LatLng(28.716152844633058, 77.10992677715875),
    LatLng(28.71574820854187, 77.11053793831083),
    LatLng(28.716717450516096, 77.11146004110172),
    LatLng(28.717103262783066, 77.11083815782416),
    LatLng(28.715861171347132, 77.1096903401304),

  ];
  List<LatLng> building32Points = [
    LatLng(15.49291812533953, 73.81538123411657),
    LatLng(15.492773418532117, 73.81554228730947),
    LatLng(15.49235996995271, 73.81607913128579),
    LatLng(15.492515013266894, 73.81635829015349),
    LatLng(15.492308288822144, 73.81625092135823),
    LatLng(15.492308288822144, 73.81625092135823),
  ];
  List<LatLng> building41Points = [
    LatLng(12.99156999333836, 80.2418149932776),
    LatLng(12.989875069982592, 80.24184720391621),
    LatLng(12.990000620257467, 80.24383352662865),
    LatLng(12.99168508030733, 80.24374763159244),

    LatLng(12.991789704778292, 80.24194383583196),
      LatLng(12.99165369295745, 80.24204046774767),
  ];

}

class CustomInfoWindow extends StatelessWidget {
  final String title;
  final String snippet;

  CustomInfoWindow({required this.title, required this.snippet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add an image here
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage('your_image_path_here'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          // Add a title here
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(snippet),
        ],
      ),
    );
  }
}
