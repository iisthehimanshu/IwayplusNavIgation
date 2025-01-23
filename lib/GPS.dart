import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GPS {
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  StreamSubscription<Position>? _gpsSubscription;

  // Expose the stream so other classes can listen
  Stream<Position> get positionStream => _positionController.stream;

  Future<void> startGpsUpdates() async {
    // Check and request location permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Start GPS subscription
    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen(
          (Position position) {
        _positionController.add(position); // Forward position updates to the stream
      },
    );
  }

  Future<Position> getCurrentCoordinates() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return Geolocator.getCurrentPosition();
  }

  void stopGpsUpdates() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }

  void dispose() {
    stopGpsUpdates();
    _positionController.close();
  }
}