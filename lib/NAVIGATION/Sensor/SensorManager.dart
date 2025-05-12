import 'package:flutter_compass/flutter_compass.dart';
import 'package:iwaymaps/NAVIGATION/GPSService.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'AccelerometerSensor.dart';
import 'GlobalPositioningSensor.dart';
import 'MagnetometerSensor.dart';

class SensorManager {
  final AccelerometerSensor _accelerometer = AccelerometerSensor();
  final MagnetometerSensor _magnetometer = MagnetometerSensor();
  final GpsSensor _gpsSensor = GpsSensor();

  //stream data for accelerometer
  void startAccelerometer() => _accelerometer.startListening();
  void stopAccelerometer() => _accelerometer.stopListening();
  Stream<AccelerometerEvent> get accelerometerStream => _accelerometer.stream;

  //stream data for magnetometer
  void startMagnetometer() => _magnetometer.startListening();
  void stopMagnetometer() => _magnetometer.stopListening();
  Stream<Map<String, dynamic>> get magnetometerStream => _magnetometer.stream;

  // stream data for GPS
  void startGps() => _gpsSensor.startListening();
  void stopGps() => _gpsSensor.stopListening();
  Stream<Location> get gpsStream => _gpsSensor.stream;
}
