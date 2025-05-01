import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'baseSensorClass.dart';

class MagnetometerSensor implements BaseSensor {
  static const _compassChannel = EventChannel('com.example.navigation/compass');

  static Stream<double> get headingStream {
    return _compassChannel.receiveBroadcastStream().map((event) => event as double);
  }

  final StreamController<double> _controller = StreamController.broadcast();

  @override
  void startListening() {
    headingStream.listen((onData){
      print("events added");
      _controller.add(onData);
    });
  }

  @override
  Future<void> stopListening() async {
   await _controller.close();
    print("magentometer stream closed:${_controller}");
  }

  @override
  Stream<double> get stream => _controller.stream;
}
