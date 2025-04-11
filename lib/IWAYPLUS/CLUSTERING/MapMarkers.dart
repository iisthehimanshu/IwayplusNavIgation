import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  BitmapDescriptor? icon;
  String Landmarkname;
  List<double> offset;
  GoogleMapController? mapController;

  MapMarker({required this.id, required this.position, this.icon,required this.Landmarkname, isCluster = false, clusterId, pointsSize, childMarkerId,this.mapController, this.offset = const [0.5,0.5]}) : super(
    markerId: id,
    latitude: position.latitude,
    longitude: position.longitude,
    isCluster: isCluster,
    clusterId: clusterId,
    pointsSize: pointsSize,
    childMarkerId: childMarkerId,
  );
  Marker toMarker() => Marker(
    anchor: Offset(offset[0], offset[1]),
      markerId: MarkerId(id),
      position: LatLng(
        position.latitude,
        position.longitude,
      ),
      icon: icon!,
      infoWindow: InfoWindow(
          title: isCluster == true? "$pointsSize landmarks" : "$Landmarkname",

          onTap: () {
            // if (mapController != null) {
            //   mapController!.animateCamera(CameraUpdate.newLatLngZoom(position, 16.0));
            // }
            print("MarkerInfo Window ");
          }),
    onTap: (){
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(position, 21.0));
      }
        print("WilsonMarkerTapper");
    },
    onDrag: (e){
        print("Drag");
        print(e);
    }


  );
}