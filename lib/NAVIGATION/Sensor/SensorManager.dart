import 'package:sensors_plus/sensors_plus.dart';

import 'AccelerometerSensor.dart';
import 'MagnetometerSensor.dart';

class SensorManager {
  final AccelerometerSensor _accelerometer = AccelerometerSensor();
  final MagnetometerSensor _magnetometer = MagnetometerSensor();


  //stream data for accelerometer
  void startAccelerometer() => _accelerometer.startListening();
  void stopAccelerometer() => _accelerometer.stopListening();
  Stream<AccelerometerEvent> get accelerometerStream => _accelerometer.stream;


  //stream data for magnetometer
  void startMagnetometer() => _magnetometer.startListening();
  void stopMagnetometer() => _magnetometer.stopListening();
  Stream<MagnetometerEvent> get magnetometerStream => _magnetometer.stream;
}
