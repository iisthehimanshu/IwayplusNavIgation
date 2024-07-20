import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState{
  double zoom = 22.0;
  double bearing = 0.0;
  double tilt = 0.0;
  bool interaction = true;
  bool interaction2 = false;
  LatLng target  = LatLng(60.543833319119475, 77.18729871127312);
  int layer = 1;
}