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
    DateTime time = DateTime.now();
    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
    ).listen(
          (Position position) {
            print("got gps position in ${time.difference(DateTime.now()).inSeconds} seconds");
            time = DateTime.now();
        _positionController.add(position); // Forward position updates to the stream
      },
    );
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