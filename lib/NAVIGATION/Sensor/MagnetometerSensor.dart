import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'baseSensorClass.dart';

class MagnetometerSensor implements BaseSensor {
  static const _compassChannel = EventChannel('com.example.navigation/compass');

  static Stream<Map<String, dynamic>> get headingStream {
    return _compassChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        // Cast safely to Map<String, dynamic>
        return Map<String, dynamic>.from(event);
      } else {
        throw Exception('Unexpected event type: ${event.runtimeType}');
      }
    });
  }

  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();

  @override
  void startListening() {
    headingStream.listen((onData) {
      _controller.add(onData);
    }, onError: (error) {
      print('Magnetometer error: $error');
    });
  }

  @override
  Future<void> stopListening() async {
    await _controller.close();
    print("Magnetometer stream closed: $_controller");
  }

  @override
  Stream<Map<String, dynamic>> get stream => _controller.stream;
}
