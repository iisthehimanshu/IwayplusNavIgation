import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

import 'baseSensorClass.dart';

class MagnetometerSensor implements BaseSensor {
  StreamSubscription? _subscription;
  final StreamController<MagnetometerEvent> _controller = StreamController.broadcast();

  @override
  void startListening() {
    _subscription = magnetometerEvents.listen((event) {
      _controller.add(event);
    });
  }

  @override
  void stopListening() {
    _subscription?.cancel();
  }

  @override
  Stream<MagnetometerEvent> get stream => _controller.stream;
}
