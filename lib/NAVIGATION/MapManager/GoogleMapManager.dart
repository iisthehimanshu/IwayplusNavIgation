import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/BluetoothManager/BLEManager.dart';
import 'package:iwaymaps/NAVIGATION/DatabaseManager/SwitchDataBase.dart';
import 'package:iwaymaps/NAVIGATION/VenueManager/VenueManager.dart';
import '../APIMODELS/beaconData.dart';
import 'RenderingManager.dart';
import 'package:flutter/foundation.dart';

class GoogleMapManager extends RenderingManager with ChangeNotifier {
  static final GoogleMapManager _instance = GoogleMapManager._internal();
  factory GoogleMapManager() => _instance;
  GoogleMapManager._internal();

  GoogleMapController? _controller;

  GoogleMapController? get controller => _controller;
  CameraPosition get initialPosition => _initialPosition;

  String _nearestBeacon = "";
  bool _showNearestLandmarkPanelVar = false;

  String? get nearestBeacon => _nearestBeacon;
  bool get showNearestLandmarkPanel => _showNearestLandmarkPanelVar;

  void setNearestLandmark(String beaconValue) {
    _nearestBeacon = beaconValue;
  }

  void showNearestLandmarkPanelIfBeaconExists() {
    if (_nearestBeacon.isNotEmpty) {
      _showNearestLandmarkPanelVar = true;
      BLEManager().stopScanning();
      notifyListeners();
    }
  }

  void closeNearestLandmarkPanel() {
    _showNearestLandmarkPanelVar = false;
    notifyListeners();
  }

  void resetBeaconState() {
    _nearestBeacon = "";
    _showNearestLandmarkPanelVar = false;
  }

  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14,
  );

  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    final style = await rootBundle.loadString('assets/mapstyle.json');
    _controller?.setMapStyle(style);
    await createMap();
    notifyListeners();

    fitPolygonsInView(polygons);

    VenueManager().startDataFechFromServerCycle();
    showNearestLandmarkPanelIfBeaconExists();
  }

  void onCameraMove(CameraPosition position) {
    updateZoomLevel(position.zoom);
    venueManager.changeFocusedBuilding(position);
    notifyListeners();
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
        CameraUpdate.newLatLngBounds(bounds, 50),
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

  @override
  void clearAll() {
    super.clearAll();
    notifyListeners();
  }

  @override
  Future<void> changeFloorOfBuilding(String buildingID, int floor) async {
    super.changeFloorOfBuilding(buildingID, floor);
    notifyListeners();
  }
}
