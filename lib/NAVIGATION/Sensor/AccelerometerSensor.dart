import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

import 'baseSensorClass.dart';

class AccelerometerSensor implements BaseSensor {
  StreamSubscription? _subscription;
  final StreamController<AccelerometerEvent> _controller = StreamController.broadcast();

  @override
  void startListening() {

    _subscription = accelerometerEvents.listen((event) {

      _controller.add(event);
    },onError: (e){
      print("error in starting accelerometer stream $e");
    });
  }

  @override
  void stopListening() {
    _subscription?.cancel();
  }

  @override
  Stream<AccelerometerEvent> get stream => _controller.stream;
}
