import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'GoogleMapManager.dart';


class MapScreen extends StatelessWidget {
  final GoogleMapManager mapManager = GoogleMapManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mapManager,
        builder: (context, _) {
          return GoogleMap(
            onMapCreated: mapManager.onMapCreated,
            onCameraMove: mapManager.onCameraMove,
            initialCameraPosition: mapManager.initialPosition,
            markers: mapManager.markers,
            polylines: mapManager.polylines,
            polygons: mapManager.polygons,
            circles: mapManager.circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          );
        },
      ), 
        floatingActionButton: AnimatedBuilder(
          animation: mapManager.venueManager,
          builder: (context, _){
            return SpeedDial(
              activeIcon: Icons.close,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              children: List.generate(mapManager.venueManager.focusedBuildingFloors.length,
                    (int i) {
                  return SpeedDialChild(
                    child: Semantics(
                      label: "$i",
                      child: Text(
                        i == 0
                            ? 'G'
                            : '$i',
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 19 / 16,
                        ),
                      ),
                    ),
                    backgroundColor: Color(0xff24b9b0),
                    onTap: () {
                        mapManager.changeFloorOfBuilding(mapManager.venueManager.focusedBuilding!, i);
                    },
                  );
                },
              ),
              child: Text("${mapManager.venueManager.focusedBuildingCurrentFloor}"),
            );
          },
        )
    );
  }
}
