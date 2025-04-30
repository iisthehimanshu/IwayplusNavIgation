import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/BluetoothManager/BLEManager.dart';

import 'GoogleMapManager.dart';


class MapScreen extends StatelessWidget {
  final GoogleMapManager mapManager = GoogleMapManager();
  String maptheme = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mapManager.renderManager,
        builder: (context, _) {
          return GoogleMap(
            onMapCreated: (controller){
              mapManager.onMapCreated(controller, context);
            },
            initialCameraPosition: mapManager.initialPosition,
            markers: mapManager.renderManager.markers,
            polylines: mapManager.renderManager.polylines,
            polygons: mapManager.renderManager.polygons,
            circles: mapManager.renderManager.circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'marker',
            onPressed: () async {
             await mapManager.renderManager.createBuildings();
             mapManager.fitPolygonsInView(mapManager.renderManager.polygons);
            },
            child: Icon(Icons.add_location),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'cam',
            onPressed: () {
              mapManager.moveCameraTo(LatLng(28.61, 77.20));
            },
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
