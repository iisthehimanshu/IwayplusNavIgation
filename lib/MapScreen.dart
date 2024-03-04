import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwayplusnav/MainScreen.dart';

import 'API/buildingAllApi.dart';
import 'APIMODELS/buildingAll.dart';

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
  List<String> GMapIconList = [];
  final List<LatLng> GMapLatLngForIcons = <LatLng>[];


  


  @override
  void initState(){
    super.initState();
    apiCall();
  }


  void apiCall() async {
    await buildingAllApi().fetchBuildingAllData().then((value) {
      setState(() {
        getting_buildingAllApi_List = value;
      });
    });
    print("MAPSCREEN INIT");
    print(getting_buildingAllApi_List);
    // for(buildingAll b in getting_buildingAllApi_List){
    //   print(b.venueName);
    //   print(b.coordinates![0]);
    //   print(b.coordinates![1]);
    // }
    createVenueListForGMIconList();

    
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
        GMapIconList.add('assets/Academic.png');
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else if(venue.venueCategory=='Hospital') {
        GMapIconList.add('assets/Hospital.png');
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else if(venue.venueCategory=='Tech Park') {
        GMapIconList.add('assets/IT park.png');
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else if(venue.venueCategory=='Event') {
        GMapIconList.add('assets/Events.png');
        GMapLatLngForIcons.add(LatLng(venue.coordinates![0], venue.coordinates![1]));
      }else{
        GMapIconList.add('assets/Landmark.png');
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
      final Uint8List iconMarker = await getImagesFromMarker(GMapIconList[a],90);
      myMarker.add(
        Marker(
            markerId: MarkerId(a.toString()),
          position: GMapLatLngForIcons[a],
          icon: BitmapDescriptor.fromBytes(iconMarker),
          infoWindow: InfoWindow(
            title:'$a',
          )
        ),
      );
      setState(() {

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
          },
          markers: myMarker,

        ),
      ),
    );
  }
}
