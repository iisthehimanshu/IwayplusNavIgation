import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'APIMODELS/buildingAll.dart';
import 'CLUSTERING/MapMarkers.dart';
import 'CLUSTERING/MapHelper.dart';
import 'MODELS/GMapIconNameModel.dart';

class GoogleMap extends StatefulWidget {
  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> {
  final Completer<gmap.GoogleMapController> _mapController = Completer();

  /// Set of displayed markers and cluster markers on the map
  final Set<gmap.Marker> _markers = Set();
  List<GMapIconNameModel> GMapIconList = [];
  List<buildingAll> uniqueVenuesList = [];
  final List<LatLng> GMapLatLngForIcons = <LatLng>[];

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
    }
  }


  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker>? _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 5.5;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Url image used on normal markers
  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';

  /// Color of the cluster circle
  final Color _clusterColor = Colors.blue;

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  /// Example marker coordinates
  final List<gmap.LatLng> _markerLocations = [
    gmap.LatLng(41.147125, -8.611249),
    gmap.LatLng(41.145599, -8.610691),
    gmap.LatLng(41.145645, -8.614761),
    gmap.LatLng(41.146775, -8.614913),
    gmap.LatLng(41.146982, -8.615682),
    gmap.LatLng(41.140558, -8.611530),
    gmap.LatLng(41.138393, -8.608642),
    gmap.LatLng(41.137860, -8.609211),
    gmap.LatLng(41.138344, -8.611236),
    gmap.LatLng(41.139813, -8.609381),
  ];

  /// Called when the Google Map widget is created. Updates the map loading state
  /// and inits the markers.
  void _onMapCreated(gmap.GoogleMapController controller) {
    _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  Future<Uint8List> getImagesFromMarker(String path ,int width) async{
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetHeight:width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }


  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    final List<MapMarker> markers = [];
    final Uint8List iconMarker = await getImagesFromMarker('assets/IT park.png',90);


    for (gmap.LatLng markerLocation in _markerLocations) {
      final gmap.BitmapDescriptor markerImage =
      BitmapDescriptor.fromBytes(iconMarker);

      markers.add(
        MapMarker(
          id: _markerLocations.indexOf(markerLocation).toString(),
          position: markerLocation,
          icon: markerImage,
        ),
      );
    }

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );

    await _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers([double? updatedZoom]) async {
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
      80,
    );

    _markers
      ..clear()
      ..addAll(updatedMarkers);

    setState(() {
      _areMarkersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markers ClustersTesting'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Google Map widget
            Opacity(
              opacity: _isMapLoading ? 0 : 1,
              child: gmap.GoogleMap(
                mapToolbarEnabled: true,
                zoomGesturesEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(21.083482,78.4528499),
                  zoom: _currentZoom,
                ),
                markers: _markers,
                onMapCreated: (controller) => _onMapCreated(controller),
                onCameraMove: (position) => _updateMarkers(position.zoom),
              ),
            ),
            // Map loading indicator
            Opacity(
              opacity: _isMapLoading ? 1 : 0,
              child: Center(child: CircularProgressIndicator()),
            ),
        
            // Map markers loading indicator
            if (_areMarkersLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    elevation: 2,
                    color: Colors.grey.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'Loading',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}