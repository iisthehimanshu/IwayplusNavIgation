import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/polylinedata.dart';
import 'package:iwaymaps/NAVIGATION/MapManager/RenderingElement/Polygon.dart';
import 'package:light/light.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../IWAYPLUS/API/buildingAllApi.dart';
import '../IWAYPLUS/Elements/HelperClass.dart';
import '../NAVIGATION/API/fingerPrintGet.dart';
import '../NAVIGATION/API/fingerPrintingApi.dart';
import '../NAVIGATION/APIMODELS/FingerPrintData.dart' as fp;
import '../NAVIGATION/APIMODELS/SensorFingerprint.dart';
import '../NAVIGATION/APIMODELS/beaconData.dart';
import '../NAVIGATION/APIMODELS/polylinedata.dart' as poly;
import '../NAVIGATION/BluetoothManager/BLEManager.dart';
import '../NAVIGATION/BluetoothScanAndroidClass.dart';
import '../NAVIGATION/GPS.dart';


class Fingerprinting{
  late BuildContext _context;
  Set<Marker> _dotMarkers = {};
  Set<Marker> _Markers = {};
  fp.FingerPrintData? fingerPrintData;
  late Function _updateMarkers;
  Map<String, beacon>? apibeaconmap;
  poly.Nodes? userPosition;
  int? floor;
  Data? data;
  double _x = 0.0, _y = 0.0, _z = 0.0;
  double theta = 0.0;
  final DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'");
  Timer? timer;
  BluetoothScanAndroidClass bluetoothScanAndroidClass = BluetoothScanAndroidClass();
  Fingerprinting() {}
  List<String> predictionHistory = [];
  String lastLocation="";
  set updateMarkers(Function value) {
    _updateMarkers = value;
  }
  set context(BuildContext value) {
    _context = value;
  }


  Future<Map<String, dynamic>> enableFingerprinting(Map<String, beacon> beaconController) async {
    print("inside enabling");
    apibeaconmap = beaconController;
    var fingerPrintData = await fingerPrintingGetApi().Finger_Printing_GET_API(buildingAllApi.selectedBuildingID);
    print("fingerprint data:${fingerPrintData!.fingerPrintData}");
    return computeBeaconStats(fingerPrintData!.fingerPrintData);
  }

  Map<String, dynamic> computeBeaconStats(Map<String, List<fp.SensorData>> locationSensorData) {
    final result = <String, dynamic>{};

    locationSensorData.forEach((locationKey, sensorDataList) {
      final beaconMap = <String, List<int>>{};
      final weakOutlierMap = <String, List<Map<String, dynamic>>>{};
      final deviationOutlierMap = <String, List<Map<String, dynamic>>>{};

      // Step 1: Collect all valid RSSI readings
      for (var data in sensorDataList) {
        for (var beacon in data.beacons ?? []) {
          final macId = beacon.beaconMacId;
          final rssi = beacon.beaconRssi;

          if (macId == null || rssi == null) continue;

          if (rssi >= -90) {
            beaconMap.putIfAbsent(macId, () => []).add(rssi);
          } else {
            weakOutlierMap.putIfAbsent(macId, () => []).add({
              'value': rssi,
              'outlierType': 'weak_signal',
            });
          }
        }
      }

      // Step 2: Compute stats + deviation outliers
      final beaconStats = beaconMap.map((macId, rssiList) {
        final mean = rssiList.reduce((a, b) => a + b) / rssiList.length;
        final variance = rssiList.fold(0.0, (sum, val) => sum + pow(val - mean, 2)) / rssiList.length;
        final stdDev = sqrt(variance);

        final cleanedRssiList = <int>[];
        for (var rssi in rssiList) {
          if (stdDev == 0 || (rssi >= mean - 2 * stdDev && rssi <= mean + 2 * stdDev)) {
            cleanedRssiList.add(rssi);
          } else {
            deviationOutlierMap.putIfAbsent(macId, () => []).add({
              'value': rssi,
              'outlierType': 'deviation_outlier',
            });
          }
        }

        // Recalculate mean and std dev after removing deviation outliers
        final finalMean = cleanedRssiList.isNotEmpty
            ? cleanedRssiList.reduce((a, b) => a + b) / cleanedRssiList.length
            : 0.0;
        final finalVariance = cleanedRssiList.isNotEmpty
            ? cleanedRssiList.fold(0.0, (sum, val) => sum + pow(val - finalMean, 2)) / cleanedRssiList.length
            : 0.0;
        final finalStdDev = sqrt(finalVariance);

        final allOutliers = [
          ...?weakOutlierMap[macId],
          ...?deviationOutlierMap[macId],
        ];

        return MapEntry(macId, {
          'mean': finalMean,
          'stdDev': finalStdDev,
          'outliers': allOutliers,
        });
      });

      result[locationKey] = {
        'beacons': beaconStats,
      };
    });

    return result;
  }

  void disableFingerprinting(){
    _dotMarkers.clear();
    _Markers.clear();

    userPosition = null;
    floor = null;
    apibeaconmap = null; // Reinitialize GPS object if required
    data = null;

    _x = 0.0;
    _y = 0.0;
    _z = 0.0;
    theta = 0.0;


    // Cancel any active subscriptions and reset

    // Cancel the timer if active
    timer?.cancel();
    timer = null;

    _updateMarkers();
  }

  void clearMarkers(){
    _Markers.clear();
  }



  Map<String, dynamic> computeRealtimeBeaconStats(List<SensorFingerprint> realtimeSensorData) {
    final result = <String, dynamic>{};
    final beaconMap = <String, List<int>>{};
    final weakOutlierMap = <String, List<Map<String, dynamic>>>{};
    final deviationOutlierMap = <String, List<Map<String, dynamic>>>{};

    // Step 1: Collect RSSI values and weak signal outliers
    for (var data in realtimeSensorData) {
      for (var beacon in data.beacons ?? []) {
        final macId = beacon.beaconMacId;
        final rssi = beacon.beaconRssi;
        if (macId == null || rssi == null) continue;
        if (rssi >= -90) {
          beaconMap.putIfAbsent(macId, () => []).add(rssi);
        } else {
          weakOutlierMap.putIfAbsent(macId, () => []).add({
            'value': rssi,
            'outlierType': 'weak_signal',
          });
        }
      }
    }
    // Step 2: Compute stats and flag deviation outliers
    final beaconStats = beaconMap.map((macId, rssiList) {
      print("rssilist:${rssiList},${macId}");
      final mean = rssiList.reduce((a, b) => a + b) / rssiList.length;
      final variance = rssiList.fold(0.0, (sum, val) => sum + pow(val - mean, 2)) / rssiList.length;
      final stdDev = sqrt(variance);
      final cleanedRssiList = <int>[];
      for (var rssi in rssiList) {
        if (stdDev == 0 || (rssi >= mean - 2 * stdDev && rssi <= mean + 2 * stdDev)) {
          cleanedRssiList.add(rssi);
        } else {
          deviationOutlierMap.putIfAbsent(macId, () => []).add({
            'value': rssi,
            'outlierType': 'deviation_outlier',
          });
        }
      }

      final finalMean = cleanedRssiList.isNotEmpty
          ? cleanedRssiList.reduce((a, b) => a + b) / cleanedRssiList.length
          : 0.0;
      final finalVariance = cleanedRssiList.isNotEmpty
          ? cleanedRssiList.fold(0.0, (sum, val) => sum + pow(val - finalMean, 2)) / cleanedRssiList.length
          : 0.0;
      final finalStdDev = sqrt(finalVariance);

      final allOutliers = [
        ...?weakOutlierMap[macId],
        ...?deviationOutlierMap[macId],
      ];

      return MapEntry(macId, {
        'mean': finalMean,
        'stdDev': finalStdDev,
        'outliers': allOutliers,
      });
    });
    result['realtime'] = {
      'beacons': beaconStats,
    };
    print("realtime data: $result");

    return result;
  }

  String? previousSmoothedLocation; // Declare this outside the function, as a class-level variable

  String findBestMatchingLocationHybrid({
    Map<String, dynamic>? realTimeData,
    Map<String, dynamic>? preProcessData,
    int historyLimit = 7,
    double cosineWeight = 0.4,
    double distanceWeight = 0.6,
    double confidenceThreshold = 0.4,
  }) {
    final realtimeBeacons = realTimeData!['realtime']?['beacons'] as Map<String, dynamic>;

    // Step 1: Determine max overlapping beacons
    int maxOverlap = 0;
    final Map<String, int> locationOverlapMap = {};

    preProcessData!.forEach((locationKey, data) {
      final preBeacons = data['beacons'] as Map<String, dynamic>;
      final overlapCount = preBeacons.keys
          .where((macId) => realtimeBeacons.containsKey(macId))
          .length;

      locationOverlapMap[locationKey] = overlapCount;
      if (overlapCount > maxOverlap) {
        maxOverlap = overlapCount;
      }
    });

    // Step 2: Compare cosine + distance for locations with max overlap
    String? bestLocation;
    double bestScore = -double.infinity;

    locationOverlapMap.forEach((locationKey, overlap) {
      if (overlap == maxOverlap) {
        final preBeacons = preProcessData[locationKey]['beacons'] as Map<String, dynamic>;

        final List<double> realtimeVector = [];
        final List<double> preprocessedVector = [];

        double distance = 0;

        for (final macId in realtimeBeacons.keys) {
          if (preBeacons.containsKey(macId)) {
            final realMean = realtimeBeacons[macId]['mean'] as double;
            final preMean = preBeacons[macId]['mean'] as double;

            realtimeVector.add(realMean);
            preprocessedVector.add(preMean);

            distance += pow(preMean - realMean, 2);
          }
        }

        distance = sqrt(distance);
        final cosineSimilarity = computeCosineSimilarity(realtimeVector, preprocessedVector);

        final similarityScore =
            (cosineSimilarity * cosineWeight) + ((1 / (1 + distance)) * distanceWeight);

        if (similarityScore > bestScore) {
          bestScore = similarityScore;
          bestLocation = locationKey;
        }
      }
    });

    print("Best location (raw): $bestLocation with score: $bestScore");

    // === History logic with weighting and filtering ===
    if (bestLocation != null && bestScore >= confidenceThreshold) {
      if (!predictionHistory.contains(bestLocation)) {
        predictionHistory.clear();
      }

      predictionHistory.add(bestLocation!);
      if (predictionHistory.length > historyLimit) {
        predictionHistory.removeAt(0);
      }

      final Map<String, double> weightedCounts = {};
      for (int i = 0; i < predictionHistory.length; i++) {
        final loc = predictionHistory[i];
        final weight = (i + 1) / predictionHistory.length;
        weightedCounts[loc] = (weightedCounts[loc] ?? 0) + weight;
      }

      final smoothed = weightedCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
print("previousSmoothedLocation ${previousSmoothedLocation} ${preProcessData.containsKey(previousSmoothedLocation)} ${preProcessData.containsKey(smoothed)}");
      // === Distance Check Logic ===
      // Count how many times the current smoothed location has occurred recently
      final repeatCount = predictionHistory.where((loc) => loc == smoothed).length;

      if (previousSmoothedLocation != null &&
          preProcessData.containsKey(previousSmoothedLocation) &&
          preProcessData.containsKey(smoothed)) {

        // Only check distance if the current smoothed location hasn't occurred enough times
        if (repeatCount <= 3) {
          final prevCoordStr = preProcessData[previousSmoothedLocation]!['coordinates'] as String?;
          final currCoordStr = preProcessData[smoothed]!['coordinates'] as String?;

          if (prevCoordStr != null && currCoordStr != null) {
            final prevParts = prevCoordStr.split(',').map((e) => double.tryParse(e.trim())).toList();
            final currParts = currCoordStr.split(',').map((e) => double.tryParse(e.trim())).toList();

            if (prevParts.length >= 2 && currParts.length >= 2 &&
                prevParts[0] != null && prevParts[1] != null &&
                currParts[0] != null && currParts[1] != null) {

              final double dx = currParts[0]! - prevParts[0]!;
              final double dy = currParts[1]! - prevParts[1]!;
              final double euclideanDistance = sqrt(dx * dx + dy * dy);

              if (euclideanDistance > 15) {
                print("Rejected smoothed: $smoothed due to jump > 25 units. Prev: $previousSmoothedLocation, Distance: $euclideanDistance");
                return previousSmoothedLocation ?? 'unknown';
              }
            }
          }
        }else{
          print("Accepted $smoothed due to repeated detection (${repeatCount}x)");
        }
      }



      previousSmoothedLocation = smoothed; // Update after check passes
      print("Smoothed value: $smoothed | History: $predictionHistory");
      return smoothed;
    }

    realTimeData.clear();
    realtimeBeacons.clear();
    data!.sensorFingerprint!.clear();

    return bestLocation ?? 'unknown';
  }

  double euclideanDistance(String a, String b) {
    final aParts = a.split(',').map((e) => double.tryParse(e) ?? 0).toList();
    final bParts = b.split(',').map((e) => double.tryParse(e) ?? 0).toList();

    final x1 = aParts.length > 0 ? aParts[0] : 0;
    final y1 = aParts.length > 1 ? aParts[1] : 0;
    final x2 = bParts.length > 0 ? bParts[0] : 0;
    final y2 = bParts.length > 1 ? bParts[1] : 0;

    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }

  double computeCosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0;

    double dotProduct = 0, normA = 0, normB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return (normA == 0 || normB == 0) ? 0 : dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<void> addMarker(LatLng _markerPosition) async {
    print("latlng:${_markerPosition.latitude},${_markerPosition.longitude}");
    _Markers.add(
      Marker(
          markerId: MarkerId('${_markerPosition.latitude},${_markerPosition.longitude}'),
          position: _markerPosition,
          onTap: (){
            print("on dot marker");
          }
      ),
    );
    _updateMarkers();
  }

  Set<Marker> getMarkers(){
    return _dotMarkers.union(_Markers);
  }

  BLEManager bleManager = BLEManager();

  Future<void> collectSensorDataEverySecond()async{
    if(apibeaconmap != null){
      bleManager.startScanning(bufferSize: 5, streamFrequency: 5,duration: 5);
      // bluetoothScanAndroidClass.listenToScanUpdates(apibeaconmap!);
    }else{
      HelperClass.showToast("Getting beacon data!!");
    }
    data = Data(position: "${userPosition?.coordx},${userPosition?.coordy},$floor");
    accelerometerEvents.listen((AccelerometerEvent event) {
      _x = event.x;
      _y = event.y;
      _z = event.z;
    });
    FlutterCompass.events!.listen((event){
      theta = event.heading!;
    });
    List<Beacon> beacons = [];
    beacons.clear();
    bleManager.bufferedDeviceStream.listen((data){
      print("datafrom scanning ${data}");
      Map<String, List<int>> beaconWithRssi = {};
      data.forEach((deviceName,deviceRssi){
        List<int> rssiList = [];
        deviceRssi.forEach((key,value){
          rssiList.add(int.parse(value));
        });
        beaconWithRssi[deviceName] = rssiList;
      });
      beaconWithRssi.forEach((key,value){
        if(apibeaconmap != null && apibeaconmap![key] != null){
          Position position = Position(x:(apibeaconmap![key]!.coordinateX??apibeaconmap![key]!.doorX!).toDouble(),y:(apibeaconmap![key]!.coordinateY??apibeaconmap![key]!.doorY!).toDouble());
          beacons.add(setBeacon(key, key, average(value).ceil(),position,apibeaconmap![key]!.floor!.toString(),apibeaconmap![key]!.buildingID));
        }
      });
    });
    timer=Timer.periodic(Duration(seconds: 1), (timer) async {
      // List<Beacon> beacons = await fetchBeaconData();
      print("beaconsvalues $beacons");

      var fingerprint = SensorFingerprint(
          beacons: beacons,
          wifi: null,
          gpsData: null,
          magnetometerData: null,
          accelerometerData: null,
          lux: null,
          timeStamp: dateFormat.format(DateTime.now().toUtc())
      );
      data?.sensorFingerprint ??= [];
      data?.sensorFingerprint?.add(fingerprint);
      print("data.toJson() ${data?.toJson()}");
    });
  }
  Future<bool> stopCollectingData() async {
    timer?.cancel();
    bluetoothScanAndroidClass.stopScan();
    //cancel beacon stream here
    return await fingerPrintingApi().Finger_Printing_API(buildingAllApi.selectedBuildingID, data!);
  }
  Future<bool> stopCollectingRealData() async {
    timer?.cancel();
    timer=null;
    //cancel beacon stream here
    return true;
  }


  Beacon setBeacon(String? beaconMacId, String? beaconName, int? beaconRssi, Position? beaconPosition,   String? beaconFloor,   String? buildingId){
    return Beacon(
        beaconMacId: beaconMacId, beaconName: beaconName, beaconRssi: beaconRssi, beaconPosition: beaconPosition,beaconFloor:beaconFloor,buildingId:buildingId
    );
  }


  Future<MagnetometerData> fetchMagnetometerData() async {
    return MagnetometerData(value: theta);
  }

  Future<AccelerometerData> fetchAccelerometerData() async {
    return AccelerometerData(x: _x, y: _y, z: _z);
  }

  double average(List<int> numbers) {
    if (numbers.isEmpty) return 0.0;
    int sum = numbers.reduce((a, b) => a + b);
    return sum / numbers.length;
  }



}