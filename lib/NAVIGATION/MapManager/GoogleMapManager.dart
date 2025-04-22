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

  GoogleMapController? get controller => _controller;
  RenderingManager get renderManager => _renderManager;
  CameraPosition get initialPosition => _initialPosition;
}
