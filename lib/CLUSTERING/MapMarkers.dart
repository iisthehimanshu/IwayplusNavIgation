import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  BitmapDescriptor? icon;
  String Landmarkname;
  MapMarker({required this.id, required this.position, this.icon,required this.Landmarkname, isCluster = false, clusterId, pointsSize, childMarkerId,}) : super(
    markerId: id,
    latitude: position.latitude,
    longitude: position.longitude,
    isCluster: isCluster,
    clusterId: clusterId,
    pointsSize: pointsSize,
    childMarkerId: childMarkerId,
  );
  Marker toMarker() => Marker(
      markerId: MarkerId(id),
      position: LatLng(
        position.latitude,
        position.longitude,
      ),
      icon: icon!,
      infoWindow: InfoWindow(
          title: isCluster == true? "$pointsSize landmarks" : "$Landmarkname",

          onTap: () {
            print("Info Window ");
          })
  );
}