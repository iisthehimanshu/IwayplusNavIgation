import 'package:google_maps_flutter/google_maps_flutter.dart';

class InitMarkerModel{
  String tag;
  String landMarkName;
  LatLng latLng;
  String specBuildingID;

  InitMarkerModel(
      this.tag, this.landMarkName, this.latLng, this.specBuildingID);
}