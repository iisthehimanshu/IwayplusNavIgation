import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../Panel Manager/LandmarkInfoScreen.dart';
import '../Panel Manager/LandmarkInfoTopBarScreen.dart';
import '../Panel Manager/LocalizedScreen.dart';
import '../Panel Manager/PanelManager.dart';
import '../Panel Manager/PanelState.dart';
import 'GoogleMapManager.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<GoogleMapManager, PanelManager>(
        builder: (context, mapViewModel, panelManager, _) {
          Widget? activePanel;
          switch (panelManager.currentPanel) {
            case PanelState.localized:
              activePanel = const LocalizedScreen();
              break;
            case PanelState.landmarkInfo:
              activePanel = const LandmarkInfoScreen();
              break;
            // case PanelState.routeDetail:
            //   activePanel = const DirectionPanel();
            //   break;
            // case PanelState.navigation:
            //   activePanel = const BookingPanel();
            //   break;
            // case PanelState.none:
            default:
              activePanel = null;
          }
          return Stack(
            children: [
              GoogleMap(
                buildingsEnabled: false,
                onMapCreated: mapViewModel.onMapCreated,
                onCameraMove: mapViewModel.onCameraMove,
                initialCameraPosition: mapViewModel.initialPosition,
                markers: mapViewModel.markers,
                polylines: mapViewModel.polylines,
                polygons: mapViewModel.polygons,
                circles: mapViewModel.circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // Example Panel: Nearest Landmark Panel
              if (activePanel != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: activePanel,
                ),
              Positioned(
                bottom: panelManager.isPanelVisible(panelManager.currentPanel) ? panelManager.currentPanel == PanelState.localized? 100 : panelManager.currentPanel == PanelState.landmarkInfo? 220 : 50.0 : 40.0, // Move up if panel shown
                right: 20.0,
                child: SpeedDial(
                  activeIcon: Icons.close,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  children: [
                    SpeedDialChild(
                      child: const Text("G"),
                      backgroundColor: const Color(0xff24b9b0),
                      onTap: () {},
                    ),
                    // Add more SpeedDialChild if needed
                  ],
                  child: const Text("0"),
                ),
              ),
              if (panelManager.currentPanel == PanelState.landmarkInfo) ...[
                const Positioned(
                  top: 40,
                  left: 13,
                  right: 13,
                  child: LandmarkInfoTopBarScreen(),
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LandmarkInfoScreen(),
                ),
              ]
            ],
          );
        },
      ),
      // floatingActionButton: SpeedDial(
      //   activeIcon: Icons.close,
      //   backgroundColor: Colors.blue,
      //   foregroundColor: Colors.white,
      //   children: [
      //     SpeedDialChild(
      //       child: const Text("G"),
      //       backgroundColor: const Color(0xff24b9b0),
      //       onTap: () {
      //         // Floor switch logic (put it in ViewModel)
      //       },
      //     ),
      //     // Add more floors dynamically if needed
      //   ],
      //   child: const Text("0"),
      // ),
    );
  }
}
