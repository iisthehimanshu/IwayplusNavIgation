import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'GoogleMapManager.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GoogleMapManager>(
        builder: (context, viewModel, _) {
          return Stack(
            children: [
              GoogleMap(
                buildingsEnabled: false,
                onMapCreated: viewModel.onMapCreated,
                onCameraMove: viewModel.onCameraMove,
                initialCameraPosition: viewModel.initialPosition,
                markers: viewModel.markers,
                polylines: viewModel.polylines,
                polygons: viewModel.polygons,
                circles: viewModel.circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              if (viewModel.showNearestLandmarkPanel && viewModel.nearestBeacon != null)
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: NearestLandmarkInfoPanel(
                    landmark: viewModel.nearestBeacon!,
                    onClose: viewModel.closeNearestLandmarkPanel,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: SpeedDial(
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Text("G"),
            backgroundColor: const Color(0xff24b9b0),
            onTap: () {
              // Floor switch logic (put it in ViewModel)
            },
          ),
          // Add more floors dynamically if needed
        ],
        child: const Text("0"),
      ),
    );
  }
}

class NearestLandmarkInfoPanel extends StatelessWidget {
  final String landmark;
  final VoidCallback onClose;

  const NearestLandmarkInfoPanel({
    super.key,
    required this.landmark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text('Nearest Landmark: ${landmark}')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

