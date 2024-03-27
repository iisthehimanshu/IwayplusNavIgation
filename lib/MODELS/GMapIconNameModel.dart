import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class GMapIconNameModel{
  String buildingName;
  String IconAddress;
  gmap.LatLng latLng;

  GMapIconNameModel({required this.buildingName,required this.IconAddress, required this.latLng});
}