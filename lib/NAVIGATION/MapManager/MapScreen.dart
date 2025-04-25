import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'GoogleMapManager.dart';

class MapScreen extends StatelessWidget {
  final GoogleMapManager mapManager = GoogleMapManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mapManager.renderManager,
        builder: (context, _) {
          return GoogleMap(
            onMapCreated: mapManager.onMapCreated,
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
            onPressed: () {
             mapManager.renderManager.createBuildings();
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
