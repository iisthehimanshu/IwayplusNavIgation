import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/BluetoothManager/BLEManager.dart';

import 'GoogleMapManager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapManager mapManager;
  late BLEManager bleManager;
  late final StreamSubscription _bleSubscription;

  @override
  void initState() {
    super.initState();
    mapManager = GoogleMapManager();
    bleManager = BLEManager();

    bleManager.startScanning(
      bufferSize: 8,
      streamFrequency: 8,
      duration: 10,
    );

    // Listen to buffered device stream
    _bleSubscription = BLEManager().bufferedDeviceStream.listen((data) {
      print("🎯 Received buffer data: $data");

      // TODO: You can update UI or other logic here
      // Example: setState(() { myData = data; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reactive Map')),
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
              mapManager.renderManager.addMarker(LatLng(28.61, 77.20), title: 'Marker');
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
