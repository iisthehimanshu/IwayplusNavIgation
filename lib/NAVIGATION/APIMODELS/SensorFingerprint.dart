class Data {
  String? position;
  List<SensorFingerprint>? sensorFingerprint;

  Data({this.position, this.sensorFingerprint});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      position: json['position'],
      sensorFingerprint: json['sensorFingerprint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'sensorFingerprint': sensorFingerprint?.map((fingerPrint) => fingerPrint.toJson()).toList(),
    };
  }
}

class SensorFingerprint {
  List<Beacon>? beacons;
  List<Wifi>? wifi;
  GpsData? gpsData;
  MagnetometerData? magnetometerData;
  AccelerometerData? accelerometerData;
  double? lux;
  String? timeStamp;

  SensorFingerprint({
    this.beacons,
    this.wifi,
    this.gpsData,
    this.magnetometerData,
    this.accelerometerData,
    this.lux,
    this.timeStamp
  });

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'beacons': beacons?.map((beacon) => beacon.toJson()).toList(),
      'wifi': wifi?.map((wifi) => wifi.toJson()).toList(),
      'gpsData': gpsData?.toJson(),
      'magnetometerData': magnetometerData?.toJson(),
      'accelerometerData': accelerometerData?.toJson(),
      'lux': lux,
      'timeStamp': timeStamp,
    };
  }

  // Deserialize from JSON
  factory SensorFingerprint.fromJson(Map<String, dynamic> json) {
    return SensorFingerprint(
      beacons: json['beacons'] != null
          ? (json['beacons'] as List)
          .map((beaconJson) => Beacon.fromJson(beaconJson))
          .toList()
          : null,
      wifi: json['wifi'] != null
          ? (json['wifi'] as List)
          .map((wifiJson) => Wifi.fromJson(wifiJson))
          .toList()
          : null,
      gpsData: json['gpsData'] != null ? GpsData.fromJson(json['gpsData']) : null,
      magnetometerData: json['magnetometerData'] != null
          ? MagnetometerData.fromJson(json['magnetometerData'])
          : null,
      accelerometerData: json['accelerometerData'] != null
          ? AccelerometerData.fromJson(json['accelerometerData'])
          : null,
      lux: json['lux'],
      timeStamp: json['timeStamp'],
    );
  }
}

class Beacon {
  String? beaconMacId;
  String? beaconName;
  int? beaconRssi;
  Position? beaconPosition;
  String? beaconFloor;
  String? buildingId;

  Beacon({
    this.beaconMacId,
    this.beaconName,
    this.beaconRssi,
    this.beaconPosition,
    this.beaconFloor,
    this.buildingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'beaconMacId': beaconMacId,
      'beaconName': beaconName,
      'beaconRssi': beaconRssi,
      'beaconPosition': beaconPosition?.toJson(),
      'beaconFloor': beaconFloor,
      'buildingId': buildingId,
    };
  }

  factory Beacon.fromJson(Map<String, dynamic> json) {
    return Beacon(
      beaconMacId: json['beaconMacId'],
      beaconName: json['beaconName'],
      beaconRssi: json['beaconRssi'],
      beaconPosition: json['beaconPosition'] != null
          ? Position.fromJson(json['beaconPosition'])
          : null,
      beaconFloor: json['beaconFloor'],
      buildingId: json['buildingId'],
    );
  }
}

class Wifi {
  String? wifiName;
  int? wifiStrength;

  Wifi({
    this.wifiName,
    this.wifiStrength,
  });

  Map<String, dynamic> toJson() {
    return {
      'wifiName': wifiName,
      'wifiStrength': wifiStrength,
    };
  }

  factory Wifi.fromJson(Map<String, dynamic> json) {
    return Wifi(
      wifiName: json['wifiName'],
      wifiStrength: json['wifiStrength'],
    );
  }
}

class Position {
  double? x;
  double? y;

  Position({this.x, this.y});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

class GpsData {
  double? latitude;
  double? longitude;
  double? accuracy;
  double? altitude;

  GpsData({this.latitude, this.longitude, this.accuracy, this.altitude});

  factory GpsData.fromJson(Map<String, dynamic> json) {
    return GpsData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      altitude: json['altitude']
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
  double? value;

  MagnetometerData({this.value});

  factory MagnetometerData.fromJson(Map<String, dynamic> json) {
    return MagnetometerData(
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class AccelerometerData {
  double? x;
  double? y;
  double? z;

  AccelerometerData({this.x, this.y, this.z});

  factory AccelerometerData.fromJson(Map<String, dynamic> json) {
    return AccelerometerData(
      x: json['x'],
      y: json['y'],
      z: json['z'],
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
