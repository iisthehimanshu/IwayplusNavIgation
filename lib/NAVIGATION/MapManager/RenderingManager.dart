import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../APIMODELS/patchDataModel.dart';
import '../APIMODELS/polylinedata.dart' as polyline_model;
import '../VenueManager/VenueManager.dart';
import 'InteractionManager.dart';
import 'RenderingElement/Polygon.dart';

class RenderingManager extends ChangeNotifier {

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Polygon> _polygons = {};
  Set<Circle> _circles = {};

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  Set<Polygon> get polygons => _polygons;
  Set<Circle> get circles => _circles;

  Interactionmanager interactionmanager = Interactionmanager();

  Polygons polygonController = Polygons();


  RenderingManager(){
    polygonController.polygonTap = interactionmanager.polygonTap;
  }

  void addMarker(LatLng position, {String? id, String? title}) {
    _markers.add(Marker(
      markerId: MarkerId(id ?? position.toString()),
      position: position,
      infoWindow: InfoWindow(title: title),
    ));
    notifyListeners();
  }

  void addPolyline(List<LatLng> points, {String? id, Color color = const Color(0xFF0000FF)}) {
    _polylines.add(Polyline(
      polylineId: PolylineId(id ?? points.first.toString()),
      points: points,
      color: color,
      width: 4,
    ));
    notifyListeners();
  }

  void addPolygon(List<LatLng> points, {String? id, Color fillColor = const Color(0x2200FF00)}) {
    _polygons.add(Polygon(
      polygonId: PolygonId(id ?? points.first.toString()),
      points: points,
      fillColor: fillColor,
      strokeWidth: 2,
      strokeColor: const Color(0xFF00AA00),
    ));
    notifyListeners();
  }

  void addCircle(LatLng center, double radius, {String? id, Color fillColor = const Color(0x220000FF)}) {
    _circles.add(Circle(
      circleId: CircleId(id ?? center.toString()),
      center: center,
      radius: radius,
      fillColor: fillColor,
      strokeColor: const Color(0xFF0000FF),
      strokeWidth: 2,
    ));
    notifyListeners();
  }

  void clearAll() {
    _markers.clear();
    _polylines.clear();
    _polygons.clear();
    _circles.clear();
    notifyListeners();
  }


  Future<void> createBuildings() async {
    clearAll();
    List<polyline_model.polylinedata>? polylineData = await VenueManager().getPolylinePolygonData();
    List<patchDataModel>? patchData = await VenueManager().getPatchData();

    print("createBuildings data $polylineData");
    if(polylineData == null) return;
    for (var buildingData in polylineData) {
      Set<Polygon>? polygonsCreated = polygonController.createRooms(buildingData, 0);
      if(polygonsCreated != null){
        _polygons = polygonsCreated;
        notifyListeners();
      }
    }
  }

  Future<void> polygonTap(List<LatLng>? coordinates, String id) async {}



}
