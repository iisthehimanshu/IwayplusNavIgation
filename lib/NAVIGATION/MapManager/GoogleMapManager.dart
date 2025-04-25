import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'RenderingManager.dart';

class GoogleMapManager {
  static final GoogleMapManager _instance = GoogleMapManager._internal();
  factory GoogleMapManager() => _instance;
  GoogleMapManager._internal();

  GoogleMapController? _controller;
  final RenderingManager _renderManager = RenderingManager();

  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14,
  );

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> moveCameraTo(LatLng target, {double zoom = 17}) async {
    if (_controller == null) return;
    await _controller!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: zoom),
    ));
  }

  Future<void> fitPolygonsInView(Set<Polygon> polygons) async {
    if (_controller == null || polygons.isEmpty) return;

    LatLngBounds? bounds;
    for (final polygon in polygons) {
      for (final point in polygon.points) {
        bounds = _extendBounds(bounds, point);
      }
    }

    if (bounds != null) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // 50 is padding
      );
    }
  }

  LatLngBounds _extendBounds(LatLngBounds? bounds, LatLng point) {
    if (bounds == null) {
      return LatLngBounds(southwest: point, northeast: point);
    }

    final south = point.latitude < bounds.southwest.latitude
        ? point.latitude
        : bounds.southwest.latitude;
    final west = point.longitude < bounds.southwest.longitude
        ? point.longitude
        : bounds.southwest.longitude;
    final north = point.latitude > bounds.northeast.latitude
        ? point.latitude
        : bounds.northeast.latitude;
    final east = point.longitude > bounds.northeast.longitude
        ? point.longitude
        : bounds.northeast.longitude;

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }


  GoogleMapController? get controller => _controller;
  RenderingManager get renderManager => _renderManager;
  CameraPosition get initialPosition => _initialPosition;
}
