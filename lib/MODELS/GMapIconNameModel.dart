import 'dart:collection';

import 'package:geodesy/geodesy.dart';




class GMapIconNameModel{
  String id;
  String buildingName;
  String IconAddress;
  HashMap<String, LatLng> buildingId;
  GMapIconNameModel({required this.buildingName,required this.IconAddress,required this.id,required this.buildingId});
}