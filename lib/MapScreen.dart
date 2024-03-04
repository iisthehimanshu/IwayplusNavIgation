import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(21.083482,78.4528499),
    zoom: 4.5,
  );

  final List<Marker> myMarker = [];

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

        ),
      ),
    );
  }
}
