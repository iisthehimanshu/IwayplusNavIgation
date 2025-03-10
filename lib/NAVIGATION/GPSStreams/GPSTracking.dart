import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../../GPS.dart';
import '../../IWAYPLUS/websocket/UserLog.dart';

class GpsService {
  final GPS gps = GPS();
  StreamSubscription<Position>? _subscription;

  Future<void> startTracking() async {
    await gps.startGpsUpdates();
    _subscription = gps.positionStream.listen((position) {
      print("New Lat ${position.latitude} ${position.longitude}");
      wsocket.message["userPosition"]["latitude"] = position.latitude;
      wsocket.message["userPosition"]["longitude"] = position.longitude;
    });
  }

  void stopTracking() {
    _subscription?.cancel();
  }
}
