

import 'SensorFingerprint.dart';
import 'beaconData.dart';

class FingerPrintData {
  String id;
  String buildingID;
  Map<String, List<SensorData>> fingerPrintData;
  int version;

  FingerPrintData({
    required this.id,
    required this.buildingID,
    required this.fingerPrintData,
    required this.version,
  });

  factory FingerPrintData.fromJson(Map<String, dynamic> json) {

    return FingerPrintData(
      id: json['_id'],
      buildingID: json['building_ID'],
      fingerPrintData: (json['fingerPrintData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          (value as List).map((e) => SensorData.fromJson(e)).toList(),
        ),
      ),
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'building_ID': buildingID,
      'fingerPrintData': fingerPrintData.map((key, value) => MapEntry(
        key,
        value.map((e) => e.toJson()).toList(),
      )),
      '__v': version,
    };
  }
}

class SensorData {
  List<Beacon>? beacons;
  GPSData gpsData;
  MagnetometerData magnetometerData;
  AccelerometerData accelerometerData;
  int lux;
  String timeStamp;

  SensorData({
    this.beacons,
    required this.gpsData,
    required this.magnetometerData,
    required this.accelerometerData,
    required this.lux,
    required this.timeStamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      beacons: json['beacons'] != null
          ? (json['beacons'] as List)
          .map((beaconJson) => Beacon.fromJson(beaconJson))
          .toList()
          : null,
      gpsData: GPSData.fromJson(json['gpsData']),
      magnetometerData: MagnetometerData.fromJson(json['magnetometerData']),
      accelerometerData: AccelerometerData.fromJson(json['accelerometerData']),
      lux: json['lux'],
      timeStamp: json['timeStamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beacons': beacons?.map((beacon) => beacon.toJson()).toList(),
      'gpsData': gpsData.toJson(),
      'magnetometerData': magnetometerData.toJson(),
      'accelerometerData': accelerometerData.toJson(),
      'lux': lux,
      'timeStamp': timeStamp,
    };
  }
}

class GPSData {
  double? latitude;
  double? longitude;
  double? accuracy;
  double? altitude;

  GPSData({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
  });

  factory GPSData.fromJson(Map<String, dynamic> json) {
    return GPSData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy:(json['accuracy']!=null)? json['accuracy'].toDouble():json['accuracy'],
      altitude: json['altitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
    };
  }
}

class MagnetometerData {
  double value;

  MagnetometerData({required this.value});

  factory MagnetometerData.fromJson(Map<String, dynamic> json) {
    return MagnetometerData(
      value: (json['value'] != null) ? json['value'].toDouble() : 0.0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class AccelerometerData {
  double x;
  double y;
  double z;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
  });

  factory AccelerometerData.fromJson(Map<String, dynamic> json) {
    return AccelerometerData(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      z: json['z'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }
}