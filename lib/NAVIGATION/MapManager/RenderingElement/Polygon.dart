import '../../APIMODELS/patchDataModel.dart';
import '../../APIMODELS/polylinedata.dart';
import '../../navigationTools.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class Polygons {
  late Function(List<LatLng>? coordinates, String id) _polygonTap;

  Function(List<LatLng>? coordinates, String id) get polygonTap => _polygonTap;

  set polygonTap(Function(List<LatLng>? coordinates, String id) value) {
    _polygonTap = value;
  }

  Set<Polygon>? createRooms(polylinedata data, int floor, {patchDataModel? patchData}) {
    Set<Polygon> polygons = Set();
    final floorKey = tools.numericalToAlphabetical(floor);
    List<PolyArray>? floorData;
    for (int j = 0; j < data.polyline!.floors!.length; j++) {
      if (data.polyline!.floors![j].floor == floorKey) {
        floorData = data.polyline!.floors![j].polyArray;
      }
    }

    if (floorData == null) return null;

    for (var polyArray in floorData) {
      if (polyArray.visibilityType != "visible" || polyArray.polygonType == "Waypoints") continue;

      final coordinates = polyArray.nodes!
          .map((node) => LatLng(
          node.lat!,node.lon!))
          .toList();

      switch (polyArray.polygonType??"".toLowerCase()) {
        case 'Wall':
          polygons.add(_handleWall(polyArray, coordinates));
          break;
        case 'Room':
          polygons.add(_handleRoom(polyArray, coordinates));
          break;
        case 'Cubicle':
          polygons.add(_handleCubicle(polyArray, coordinates));
          break;
      }
    }

    return polygons;
  }

  Polygon _handleRoom(PolyArray poly, List<LatLng> coords) {
    final name = poly.name?.toLowerCase() ?? "";
    if (name.contains("lr") || name.contains("lab") || name.contains("office") ||
        name.contains("pantry") || name.contains("reception")) {
      return _createPolygon(poly, coords, Color(0xffA38F9F), Color(0xffE8E3E7));
    } else if (name.contains("atm") || name.contains("health")) {
      return _createPolygon(poly, coords, Color(0xffE99696), Color(0xffFBEAEA));
    } else {
      return _createPolygon(poly, coords, Color(0xffA38F9F), Color(0xffE8E3E7));
    }
  }

  Polygon _handleCubicle(PolyArray poly, List<LatLng> coords) {
    final name = poly.name?.toLowerCase() ?? "";
    final cubicle = poly.cubicleName?.toLowerCase() ?? "";

    if (poly.cubicleName == "Green Area" || poly.cubicleName == "Green Area | Pots" ||
        name.contains('auditorium') || name.contains('gym') || name.contains('swimming') ||
        name.contains('basketball') || name.contains('football') || name.contains('tennis') ||
        name.contains('cricket')) {
      return _createPolygon(poly, coords, Color(0xffADFA9E), Color(0xffE7FEE9), tap: false);
    }

    if (cubicle.contains("lift")) {
      return _createPolygon(poly, coords, Color(0xffB5CCE3), Color(0xffDAE6F1));
    } else if (cubicle.contains("washroom")) {
      return _createPolygon(poly, coords, Color(0xff6EBCF7), Color(0xFFE7F4FE), tap: false);
    } else if (cubicle.contains("fire")) {
      return _createPolygon(poly, coords, Colors.black, _parseColor(poly.cubicleColor, fallback: Color(0xffF21D0D)), tap: false);
    } else if (cubicle.contains("water")) {
      return _createPolygon(poly, coords, Color(0xff6EBCF7), _parseColor(poly.cubicleColor, fallback: Color(0xffE7F4FE)), tap: false);
    } else if (poly.cubicleName == "Restricted Area" || poly.cubicleName == "Non Walkable Area") {
      return _createPolygon(poly, coords, Color(0xffCCCCCC), _parseColor(poly.cubicleColor, fallback: Color(0xffE6E6E6)), tap: false);
    } else if (poly.cubicleName!.toLowerCase().contains("wall")){
      return _handleWall(poly, coords);
    } else {
      return _createPolygon(poly, coords, Color(0xffCCCCCC), _parseColor(poly.cubicleColor, fallback: Color(0xffE6E6E6)), tap: false);
    }
  }

  Polygon _handleWall(PolyArray poly, List<LatLng> coords) {
    return _createPolygon(poly, coords, Color(0xffD3D3D3), _parseColor(poly.cubicleColor, fallback: Colors.white), tap: false);
  }

  Polygon _createPolygon(
      PolyArray poly,
      List<LatLng> coords,
      Color stroke,
      Color fill, {
        bool tap = true,
      }) {
    return Polygon(
      polygonId: PolygonId(poly.id!),
      points: coords,
      strokeWidth: 1,
      strokeColor: stroke,
      fillColor: fill,
      consumeTapEvents: tap,
      onTap: tap ? () => polygonTap(coords, poly.id!) : null,
    );
  }

  Color _parseColor(String? hex, {required Color fallback}) {
    if (hex != null && hex != "undefined") {
      try {
        return Color(int.parse('0xFF${hex.replaceAll('#', '')}'));
      } catch (_) {}
    }
    return fallback;
  }

  Set<Polygon>? createPatch(patchDataModel patchData){
    Set<Polygon> patch = Set();

    final coords = patchData.patchData?.coordinates;
    if (coords == null || coords.length < 4) return null;

    double latSum = 0.0;
    double lngSum = 0.0;

    // Calculate the center of the 4 coordinates
    for (int i = 0; i < 4; i++) {
      final lat = double.tryParse(coords[i].globalRef?.lat ?? '') ?? 0.0;
      final lng = double.tryParse(coords[i].globalRef?.lng ?? '') ?? 0.0;
      latSum += lat;
      lngSum += lng;
    }

    final centerLat = latSum / 4;
    final centerLng = lngSum / 4;

    List<LatLng> polygonPoints = [];
    Map<int, LatLng> adjustedCoordinates = {};

    // Adjust each point slightly away from the center to enhance visibility
    for (int i = 0; i < 4; i++) {
      final lat = double.tryParse(coords[i].globalRef?.lat ?? '') ?? 0.0;
      final lng = double.tryParse(coords[i].globalRef?.lng ?? '') ?? 0.0;

      final adjustedLat = centerLat + 1.1 * (lat - centerLat);
      final adjustedLng = centerLng + 1.1 * (lng - centerLng);
      final adjustedPoint = LatLng(adjustedLat, adjustedLng);

      polygonPoints.add(adjustedPoint);
      adjustedCoordinates[i] = adjustedPoint;
    }

      patch.add(
        Polygon(
          polygonId: PolygonId('patch ${patchData.patchData?.buildingID}'),
          points: polygonPoints,
          strokeWidth: 1,
          strokeColor: Color(0xffC0C0C0),
          fillColor: Color(0xffffffff),
          geodesic: false,
          consumeTapEvents: true,
          zIndex: -1,
        ),
      );

    return patch;
  }

}
