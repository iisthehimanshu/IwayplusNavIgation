import 'dart:async';

import 'package:geolocator/geolocator.dart';

class GPSStreamHandler {
  StreamSubscription<Position>? _positionStreamSubscription;

  // Start listening to the GPS stream
  Stream<Position>? startStream() {
    if (_positionStreamSubscription != null) {
      print("Stream is already active.");
      return null;
    }

    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    // _positionStreamSubscription = positionStream.listen((Position position) {
    //   print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    // });
    //
    // print("GPS stream started.");
  }



  // Stop listening to the GPS stream
  void stopStream() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
      print("GPS stream stopped.");
    } else {
      print("No active stream to stop.");
    }
  }

  // Check if the stream is active
  bool isStreamActive() {
    return _positionStreamSubscription != null;
  }
}
