import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'baseSensorClass.dart';

class MagnetometerSensor implements BaseSensor {
  StreamSubscription? _subscription;
  final StreamController<CompassEvent> _controller = StreamController.broadcast();

  @override
  void startListening() {
    _subscription = FlutterCompass.events!.listen((event) {
      _controller.add(event);
    });
  }

  @override
  void stopListening() {
    _subscription?.cancel();
  }

  @override
  Stream<CompassEvent> get stream => _controller.stream;
}
