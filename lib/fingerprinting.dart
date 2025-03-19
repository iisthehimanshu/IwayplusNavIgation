import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light/light.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../GPS.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'IWAYPLUS/API/buildingAllApi.dart';
import 'IWAYPLUS/Elements/HelperClass.dart';
import 'NAVIGATION/API/PolyLineApi.dart';
import 'NAVIGATION/API/fingerPrintGet.dart';
import 'NAVIGATION/APIMODELS/FingerPrintData.dart' as fp;
import 'NAVIGATION/APIMODELS/beaconData.dart';
import 'NAVIGATION/APIMODELS/polylinedata.dart';
import 'NAVIGATION/APIMODELS/polylinedata.dart' as poly;
import 'NAVIGATION/BluetoothScanAndroidClass.dart';
import 'NAVIGATION/SensorFingerprint.dart';
import 'NAVIGATION/buildingState.dart';
import 'NAVIGATION/navigationTools.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

import 'NAVIGATION/singletonClass.dart';

class Fingerprinting{
  late BuildContext _context;
  Set<Marker> _dotMarkers = {};
  Set<Marker> nearestPointMarker={};
  Set<Marker> _Markers = {};
  fp.FingerPrintData? fingerPrintData;
  late Function _updateMarkers;
  Map<String, beacon>? apibeaconmap;
  poly.Nodes? userPosition;
  int? floor;
  GPS gps = GPS();
  Data? data;
  geo.Position? gpsPosition;
  double _x = 0.0, _y = 0.0, _z = 0.0;
  double theta = 0.0;
  int _lightValue = 0;
  StreamSubscription? _Lightsubscription;
  final DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'");
  Timer? timer;
  BluetoothScanAndroidClass bluetoothScanAndroidClass = BluetoothScanAndroidClass();
  List<WiFiAccessPoint> accessPoints = [];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  Light _light = Light();
  Fingerprinting(){}
  set updateMarkers(Function value){
    _updateMarkers = value;
  }
  set context(BuildContext value){
    _context = value;
  }
 fp.FingerPrintData? calculatedData;
  Future<void> enableFingerprinting()async{
    var fingerPrintData = await fingerPrintingGetApi().Finger_Printing_GET_API("676171576711e89104527934");
    calculatedData=fingerPrintData;
    print("calculated data::${calculatedData}");
  }
  // Future<void> showNearestPoint(PolygonController polygonController,String nearestPoint) async {
  //   _Markers.clear();
  //   print("inside enabling");
  //   List<int> nearestpoint=parsePoint(nearestPoint);
  //   print(nearestPoint);
  //   List<poly.Nodes> waypoints = await polygonController.extractFromAllWaypoints();
  //   for (var point in waypoints){
  //     if(point.coordx==nearestpoint[0] && point.coordy==nearestpoint[1]){
  //       await showDeafultMarker(point);
  //     }
  //   }
  //   print("enabled");
  // }

  List<int> parsePoint(String point) {
    return point.split(',').map(int.parse).toList();
  }
  double calculateAverage<T extends num>(List<T> values) {
    if (values.isEmpty) return 0.0;
    return values.map((e) => e.toDouble()).reduce((a, b) => a + b) / values.length;
  }
  polylinedata? polydata;
  Future<List<Nodes>> extractWaypoints() async {
    print("called");
    polydata ??= await PolyLineApi().fetchPolyData(id: buildingAllApi.selectedBuildingID);
    List<Nodes> waypoints = [];
    for (var floors in polydata!.polyline!.floors!){
      for (var polys in floors.polyArray!) {
        if (polys.polygonType == "Waypoints" && floor == tools.alphabeticalToNumerical(polys.floor!)) {
          for (var node in polys.nodes!) {
            // Check if node is at least 2 meters away from all nodes in waypoints
            bool isFarEnough = waypoints.every((existingNode) =>
            tools.calculateAerialDist(
                existingNode.lat!, existingNode.lon!, node.lat!, node.lon!) >= 1.4);
            if (isFarEnough) {
              waypoints.add(node);
            }
          }
        }
      }
    }
    print("waypoints ${waypoints.length}");
    return waypoints;
  }
  Future<List<Nodes>> extractFromAllWaypoints()async{
    print("called");
    polydata ??= await PolyLineApi().fetchPolyData(id:"676171576711e89104527934");
    List<Nodes> waypoints = [];
    for (var floors in polydata!.polyline!.floors!){
      for (var polys in floors.polyArray!){
        if (polys.polygonType == "Waypoints" && floor == tools.alphabeticalToNumerical(polys.floor!)) {
          for (var node in polys.nodes!) {
            // Check if node is at least 2 meters away from all nodes in waypoints
            bool isFarEnough = waypoints.every((existingNode) =>
            tools.calculateAerialDist(
                existingNode.lat!, existingNode.lon!, node.lat!, node.lon!) >= 1.2);
            if (isFarEnough){
              waypoints.add(node);
            }
          }
        }
      }
    }
    print("waypoints ${waypoints.length}");
    return waypoints;
  }
  Future<Nodes?> nearestNode(String nearestLocation)async{
    List<int> nearestList = parsePoint(nearestLocation);
    List<Nodes> wayNodes = await extractFromAllWaypoints();
    print("Waypoint nodes::$wayNodes");
    Nodes? nearestNode = wayNodes.firstWhere(
          (node) => node.coordx == nearestList[0] && node.coordy == nearestList[1],
       // Returns null if no match is found
    );
    print("Nearest waypoint details: $nearestNode");
    return nearestNode;
  }
  String findNearestLocation(
      Map<String, Map<String, double>> realTimeData,
      Map<String, Map<String, dynamic>> processedPools,
      ) {
    String closestPool = "";
    double minDistance = double.infinity;
    int maxMatchingBeacons = 0;
    print("processedPools::${processedPools}");
    print("realTimeData::${realTimeData}");
    // Iterate through each processed pool
    processedPools.forEach((poolName, poolData){
      int matchingBeacons = 0;
      double distance = 0.0;
      // Compare real-time data against this pool's beacons
      realTimeData.forEach((beaconId, realStats){
        if (poolData.containsKey(beaconId)){
          matchingBeacons++; // Increment count of matching beacons
          final processedStats = poolData[beaconId]!;
          double avgDiff = realStats["average"]! - processedStats["average"]!;
          // Use mean difference (squared) for comparison
          distance += pow(avgDiff, 2);
        }
      });
      // Check if this pool has more matching beacons or the same but smaller distance
      if (matchingBeacons > maxMatchingBeacons ||
          (matchingBeacons == maxMatchingBeacons && distance < minDistance)) {
        maxMatchingBeacons = matchingBeacons;
        minDistance = distance;
        closestPool = poolName;
        // Print the selected pool details
        print("Current Closest Pool: $closestPool");
        print("Pool Data: $poolData");
        print("Matching Beacons: $matchingBeacons");
        print("Distance: $distance");
      }
    });

    return closestPool;
  }

  // Map<String, dynamic> getAverageData(fp.FingerPrintData fingerprintModel) {
  //   final fingerPrintData = fingerprintModel.fingerPrintData;
  //   // Initialize a map to store the processed data
  //   Map<String, dynamic> processedData = {};
  //   // Iterate over each header (e.g., "100,240,1", "79,30,3")
  //   for (var header in fingerPrintData.keys) {
  //     final fingerPrintArray = fingerPrintData[header]!;
  //     // Initialize maps and lists for each field
  //     Map<String, double> beaconAverages = {};
  //     List<double> latitudes = [];
  //     List<double> longitudes = [];
  //     List<double> accuracies = [];
  //     List<double> altitudes = [];
  //     List<double> magnetometerValues = [];
  //     List<double> accelerometerMagnitudes = [];
  //     List<int> luxValues = [];
  //     // Collect data for each object under this header
  //     for (var item in fingerPrintArray) {
  //       if (item.beacons != null) {
  //         for (var beacon in item.beacons!) {
  //           if (beacon.beaconRssi != null) {
  //             final beaconId = beacon.beaconName ?? "Unknown Beacon";
  //             beaconAverages[beaconId] = (beaconAverages[beaconId] ?? 0) + beacon.beaconRssi!;
  //           }
  //         }
  //       }
  //
  //       if (item.gpsData != null) {
  //         if (item.gpsData.latitude != null) latitudes.add(item.gpsData.latitude!);
  //         if (item.gpsData.longitude != null) longitudes.add(item.gpsData.longitude!);
  //         if (item.gpsData.accuracy != null) accuracies.add(item.gpsData.accuracy!);
  //         if (item.gpsData.altitude != null) altitudes.add(item.gpsData.altitude!);
  //       }
  //
  //       if (item.magnetometerData != null && item.magnetometerData.value.isFinite) {
  //         magnetometerValues.add(item.magnetometerData.value);
  //       }
  //
  //       if (item.accelerometerData != null) {
  //         double x = item.accelerometerData.x;
  //         double y = item.accelerometerData.y;
  //         double z = item.accelerometerData.z;
  //         double magnitude = sqrt(x * x + y * y + z * z);
  //         if (magnitude.isFinite) {
  //           accelerometerMagnitudes.add(magnitude);
  //         }
  //       }
  //
  //       if (item.lux != null) {
  //         luxValues.add(item.lux);
  //       }
  //     }
  //
  //     // Calculate averages for beacons
  //     beaconAverages.forEach((key, value) {
  //       beaconAverages[key] = value / fingerPrintArray.length;
  //     });
  //
  //     // Calculate averages for other data
  //     double? latitudeAverage = latitudes.isNotEmpty ? calculateAverage(latitudes) : null;
  //     double? longitudeAverage = longitudes.isNotEmpty ? calculateAverage(longitudes) : null;
  //     double? accuracyAverage = accuracies.isNotEmpty ? calculateAverage(accuracies) : null;
  //     double? altitudeAverage = altitudes.isNotEmpty ? calculateAverage(altitudes) : null;
  //     double? magnetometerAverage = magnetometerValues.isNotEmpty ? calculateAverage(magnetometerValues) : null;
  //     double? accelerometerAverage = accelerometerMagnitudes.isNotEmpty ? calculateAverage(accelerometerMagnitudes) : null;
  //     double? luxAverage = luxValues.isNotEmpty ? calculateAverage(luxValues) : null;
  //
  //     // Add the processed averages for this header to the map
  //     processedData[header] = {
  //       "Beacons": beaconAverages,
  //       if (latitudeAverage != null) "Latitude": latitudeAverage,
  //       if (longitudeAverage != null) "Longitude": longitudeAverage,
  //       if (accuracyAverage != null) "Accuracy": accuracyAverage,
  //       if (altitudeAverage != null) "Altitude": altitudeAverage,
  //       if (magnetometerAverage != null) "Magnetometer Value": magnetometerAverage,
  //       if (accelerometerAverage != null) "Accelerometer Magnitude": accelerometerAverage,
  //       if (luxAverage != null) "Average Lux": luxAverage,
  //     };
  //   }
  //
  //   print("Processed Data: ${processedData}");
  //
  //   return processedData;
  // }

  Map<String, Map<String, dynamic>> getAverageData(fp.FingerPrintData fingerprintModel) {
    final fingerPrintData = fingerprintModel.fingerPrintData;
    // Store the processed pools
    Map<String, Map<String, dynamic>> processedPools = {};
    for (var header in fingerPrintData.keys) {
      final fingerPrintArray = fingerPrintData[header]!;
      Map<String, List<int>> beaconGroups = {};
      // Group RSSI values by beacons
      for (var item in fingerPrintArray) {
        if (item.beacons != null) {
          for (var beacon in item.beacons!) {
            String beaconId = beacon.beaconName ?? "Unknown Beacon";
            int rssi = beacon.beaconRssi ?? 0;
            if (!beaconGroups.containsKey(beaconId)) {
              beaconGroups[beaconId] = [];
            }
            beaconGroups[beaconId]!.add(rssi.abs());
          }
        }
      }
      // Calculate average and variance for each beacon after removing outliers
      Map<String, Map<String, double>> beaconStats = {};
      beaconGroups.forEach((beaconId, rssiValues) {
        List<int> filteredValues = rssiValues; // You can add outlier removal logic here if needed
        if (filteredValues.isNotEmpty) {
          double avg = calculateAverage(filteredValues);
          double variance = calculateVariance(filteredValues, avg);
          // Only include beacons with an average RSSI ≤ 95
          if (avg < 90) {
            beaconStats[beaconId] = {
              "average": avg,
              "variance": variance,
            };
          }else{
           // print("Beacon $beaconId excluded due to high average RSSI from pool ${header}");
          }
        }else {
          // Handle case where all values are filtered out

          beaconStats[beaconId] = {
            "average": 0,
            "variance": 0,
          };
        }
      });

      // Assign beacons to predefined pools (example logic, modify as needed)
      processedPools[header] = beaconStats;
    }

    print("processed data::${processedPools}");
    return processedPools;
  }

  Map<String, dynamic> getHeaderDetails(fp.FingerPrintData fingerprintModel, String header){
    final fingerPrintData = fingerprintModel.fingerPrintData;
    if (!fingerPrintData.containsKey(header)){
      print("Header $header not found in fingerprint data.");
      return {};
    }
    final fingerPrintArray = fingerPrintData[header]!;
    // Extract coordinates (assuming they are stored in the fingerprint model)
    Map<String, dynamic> headerDetails = {
      "coordinates": "fingerprintModel.headerCoordinates?[header] ?? {}",
      "beaconData": "getBeaconData(fingerPrintArray)", // Call separate function for beacons
    };
    print("Header Details for $header: ${fingerPrintArray[0]}");
    return headerDetails;
  }

  Map<String, dynamic> getPoolDataByHeader(Map<String, Map<String, dynamic>> processedPools, String poolHeader){
    // Check if the pool header exists in the processedPools map
    if (processedPools.containsKey(poolHeader)){
      return processedPools[poolHeader]!;
    } else {
      // If the header is not found, return an empty map or handle it accordingly
      print("Pool header '$poolHeader' not found in processedPools.");
      return {};
    }
  }



  double calculateVariance(List<int> values, double mean){
    double variance = 0.0;
    for (var value in values){
      variance += pow(value - mean, 2);
    }
    return variance / values.length;
  }
  // Map<String, dynamic> getAverageRealData(Data data) {
  //   // Collect sensor fingerprints
  //   final List<SensorFingerprint>? fingerprints = data.sensorFingerprint;
  //
  //   if (fingerprints == null || fingerprints.isEmpty) {
  //     print('No sensor data available.');
  //     return {}; // Return an empty map indicating no data
  //   }
  //
  //   // Initialize maps and lists to collect values
  //   Map<String, List<double>> beaconRssiValues = {}; // Grouped by beacon names
  //   List<double> latitudes = [];
  //   List<double> longitudes = [];
  //   List<double> accuracies = [];
  //   List<double> altitudes = [];
  //   List<double> magnetometerValues = [];
  //   List<double> accelerometerMagnitudes = [];
  //   List<double> luxValues = [];
  //
  //   for (var fingerprint in fingerprints) {
  //     // Beacons
  //     if (fingerprint.beacons != null) {
  //       for (var beacon in fingerprint.beacons!) {
  //         if (beacon.beaconRssi != null && beacon.beaconName != null) {
  //           String beaconName = beacon.beaconName!;
  //           // Add RSSI values grouped by beacon name
  //           beaconRssiValues.putIfAbsent(beaconName, () => []);
  //           beaconRssiValues[beaconName]!.add(beacon.beaconRssi!.toDouble());
  //         }
  //       }
  //     }
  //
  //     // GPS Data
  //     if (fingerprint.gpsData != null) {
  //       final gpsData = fingerprint.gpsData!;
  //       if (gpsData.latitude != null) latitudes.add(gpsData.latitude!);
  //       if (gpsData.longitude != null) longitudes.add(gpsData.longitude!);
  //       if (gpsData.accuracy != null) accuracies.add(gpsData.accuracy!);
  //       if (gpsData.altitude != null) altitudes.add(gpsData.altitude!);
  //     }
  //
  //     // Magnetometer
  //     if (fingerprint.magnetometerData != null) {
  //       if (fingerprint.magnetometerData!.value != null) {
  //         magnetometerValues.add(fingerprint.magnetometerData!.value!);
  //       }
  //     }
  //
  //     // Accelerometer
  //     if (fingerprint.accelerometerData != null) {
  //       final accelData = fingerprint.accelerometerData!;
  //       if (accelData.x != null && accelData.y != null && accelData.z != null) {
  //         double magnitude = sqrt(accelData.x! * accelData.x! +
  //             accelData.y! * accelData.y! +
  //             accelData.z! * accelData.z!);
  //         accelerometerMagnitudes.add(magnitude);
  //       }
  //     }
  //
  //     // Lux
  //     if (fingerprint.lux != null) {
  //       luxValues.add(fingerprint.lux!);
  //     }
  //   }
  //
  //   // Calculate averages for each beacon by name
  //   Map<String, double> averagedBeacons = {};
  //   beaconRssiValues.forEach((name, rssiValues) {
  //     averagedBeacons[name] = calculateAverage(rssiValues) ?? 0;
  //   });
  //
  //   // Calculate other averages using a helper function
  //   double? latitudeAverage = calculateAverage(latitudes);
  //   double? longitudeAverage = calculateAverage(longitudes);
  //   double? accuracyAverage = calculateAverage(accuracies);
  //   double? altitudeAverage = calculateAverage(altitudes);
  //   double? magnetometerAverage = calculateAverage(magnetometerValues);
  //   double? accelerometerAverage = calculateAverage(accelerometerMagnitudes);
  //   double? luxAverage = calculateAverage(luxValues);
  //
  //   // Create the output map
  //   Map<String, dynamic> realTimeData = {
  //     "Beacons": averagedBeacons, // Averaged RSSI per beacon name
  //     "Latitude": latitudeAverage ?? 0,
  //     "Longitude": longitudeAverage ?? 0,
  //     "Accuracy": accuracyAverage ?? 0,
  //     "Altitude": altitudeAverage ?? 0,
  //     "Magnetometer Value": magnetometerAverage ?? 0,
  //     "Accelerometer Magnitude": accelerometerAverage ?? 0,
  //     "Average Lux": luxAverage ?? 0,
  //   };
  //
  //   // Print the result
  //   print('Real-Time Data: $realTimeData');
  //
  //   return realTimeData;
  // }
  Map<String, dynamic> getAverageRealData(Data data) {
    // Collect sensor fingerprints
    final List<SensorFingerprint>? fingerprints = data.sensorFingerprint;

    if (fingerprints == null || fingerprints.isEmpty) {
      print('No sensor data available.');
      return {}; // Return an empty map indicating no data
    }

    // Initialize map to collect RSSI values grouped by beacon names
    Map<String, List<double>> beaconRssiValues = {};

    for (var fingerprint in fingerprints) {
      // Beacons
      if (fingerprint.beacons != null) {
        for (var beacon in fingerprint.beacons!) {
          if (beacon.beaconRssi != null && beacon.beaconMacId != null) {
            String beaconName = beacon.beaconMacId!;
            // Add RSSI values grouped by beacon name
            beaconRssiValues.putIfAbsent(beaconName, () => []);
            beaconRssiValues[beaconName]!.add(beacon.beaconRssi!.toDouble().abs());
          }
        }
      }
    }

    // Calculate averages and variances for each beacon by name
    Map<String, Map<String, double>> processedBeacons = {};
    beaconRssiValues.forEach((name, rssiValues) {
      // Calculate average and variance for RSSI values
      List<double> filteredValues = rssiValues; // Optionally filter outliers here
      double average = calculateAverageReal(filteredValues) ?? 0;
      double variance = calculateVarianceReal(filteredValues) ?? 0;

      // Exclude beacons whose average RSSI is above 95
      if (average < 90) {
        processedBeacons[name] = {
          "average": average,
          "variance": variance,
        };
      } else {
        print("Beacon $name excluded due to high average RSSI: $average");
      }
    });

    // Create the output map for beacons
    Map<String, dynamic> realTimeData = {
      "Beacons": processedBeacons, // Includes average and variance for each beacon
    };

    // Print the result
    print('Real-Time Data (Average and Variance): $realTimeData');

    return realTimeData;
  }

// Helper Function to Remove Outliers
//   List<double> removeOutliers(List<double> values, {double iqrMultiplier = 1.5}) {
//     if (values.isEmpty || values.length < 3){r
//       // If the list is empty or has fewer than 3 elements, return the original list (no outliers possible)
//       return values;
//     }
//     // Sort the values
//     values.sort();
//     // Calculate Q1 and Q3 with proper clamping
//     int q1Index = (values.length * 0.25).floor().clamp(0, values.length - 1);
//     int q3Index = (values.length * 0.75).floor().clamp(0, values.length - 1);
//
//     double q1 = values[q1Index];
//     double q3 = values[q3Index];
//     double iqr = q3 - q1;
//
//     // Adjust bounds with the IQR multiplier
//     double lowerBound = q1 - iqrMultiplier * iqr;
//     double upperBound = q3 + iqrMultiplier * iqr;
//
//     // Filter values within the bounds
//     return values.where((value) => value >= lowerBound && value <= upperBound).toList();
//   }

  double? calculateAverageReal(List<double> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
  double? calculateVarianceReal(List<double> values) {
    if (values.isEmpty) return null;
    double mean = calculateAverage(values)!;
    double variance = 0.0;
    for (var value in values){
      print("value $value  mean $mean");
      variance += pow(value - mean, 2);
    }
    print("returning variance ${variance / values.length}");
    return variance / values.length;
  }

  void disableFingerprinting(){
    _dotMarkers.clear();
    _Markers.clear();
    accessPoints = [];
    subscription = null;
    userPosition = null;
    floor = null;
    apibeaconmap = null;
    gps = GPS(); // Reinitialize GPS object if required
    data = null;
    gpsPosition = null;
    _x = 0.0;
    _y = 0.0;
    _z = 0.0;
    theta = 0.0;
    _lightValue = 0;
    // Cancel any active subscriptions and reset
    _Lightsubscription?.cancel();
    _Lightsubscription = null;
    // Cancel the timer if active
    timer?.cancel();
    timer = null;
    _updateMarkers();
  }
  // Future<void> addDotMarker(poly.Nodes point, fp.FingerPrintData? fingerPrintData) async {
  //   print("dotmarker");
  //   var svgIcon = await _svgToBitmapDescriptor('assets/dot.svg', Size(40, 40));
  //   if(fingerPrintData != null && fingerPrintData.fingerPrintData["${point.coordx},${point.coordy},$floor"] != null){
  //     print("already collected point");
  //     svgIcon = await _svgToBitmapDescriptor('assets/exitservice.svg', Size(40, 40));
  //   }
  //   _dotMarkers.add(
  //     Marker(
  //         markerId: MarkerId('${point.lat!},${point.lon!}'),
  //         position: LatLng(point.lat!, point.lon!),
  //         icon: svgIcon,
  //         onTap:(){
  //           _Markers.clear();
  //           // FingerPrintingPannel.showPanel();
  //           userPosition = point;
  //           addMarker(LatLng(point.lat!, point.lon!));
  //         }
  //     ),
  //   );
  //   _updateMarkers();
  // }

  Future<void> showDeafultMarker(poly.Nodes point) async {
    print("dotmarker");
    addMarker(LatLng(point.lat!, point.lon!));
    _updateMarkers();
  }

  // Future<void> updatePoint(fp.FingerPrintData? fingerPrintData,PolygonController polygonController) async {
  //   List<poly.Nodes> waypoints = await polygonController.extractWaypoints();
  //   for (var points in waypoints){
  //     print("pointss::${points}");
  //     await addDotMarker(points, fingerPrintData);
  //   }
  //   print("dotmarker");
  //   var svgIcon = await _svgToBitmapDescriptor('assets/dot.svg', Size(40, 40));
  //   if(fingerPrintData != null && fingerPrintData.fingerPrintData["${point.coordx},${point.coordy},$floor"] != null){
  //     svgIcon = await _svgToBitmapDescriptor('assets/exitservice.svg', Size(40, 40));
  //   }
  //   _dotMarkers.add(
  //     Marker(
  //         markerId: MarkerId('${point.lat!},${point.lon!}'),
  //         position: LatLng(point.lat!, point.lon!),
  //         icon: svgIcon,
  //         onTap:(){
  //           _Markers.clear();
  //           // FingerPrintingPannel.showPanel();
  //           userPosition = point;
  //           addMarker(LatLng(point.lat!, point.lon!));
  //         }
  //     ),
  //   );
  //   _updateMarkers();
  // }
  Future<void> addMarker(LatLng _markerPosition) async {
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
  // Future<BitmapDescriptor> _svgToBitmapDescriptor(String svgAsset, Size size,) async {
  //   // Load SVG data
  //   String svgString = await DefaultAssetBundle.of(_context).loadString(svgAsset);
  //   // Render SVG to picture
  //   DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, svgString);
  //   final picture = svgDrawableRoot.toPicture(
  //     size: size, // Define the size of the SVG
  //   );
  //   // Convert to image
  //   final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  //   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   final Uint8List bytes = byteData!.buffer.asUint8List();
  //
  //   return BitmapDescriptor.fromBytes(bytes);
  //}
  Set<Marker> getMarkers(){
    return _dotMarkers.union(_Markers);
  }
  Future<void> collectSensorDataEverySecond()async{
    // if(SingletonFunctionController.apibeaconmap != null){
    //   bluetoothScanAndroidClass.listenToScanInitialLocalization(SingletonFunctionController.apibeaconmap);
    // }else{
    //   HelperClass.showToast("Getting beacon data!!");
    // }
    _startListeningToScannedResults();
    data = Data(position: "${userPosition?.coordx},${userPosition?.coordy},$floor");
    gps.startGpsUpdates();
    gps.positionStream.listen((position){
      gpsPosition = position;
    });
    accelerometerEvents.listen((AccelerometerEvent event) {
      _x = event.x;
      _y = event.y;
      _z = event.z;
    });
    FlutterCompass.events!.listen((event){
      theta = event.heading!;
    });
    _Lightsubscription = _light.lightSensorStream.listen((value){
      _lightValue = value;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      print("apibeaconmap:: ${SingletonFunctionController.apibeaconmap}");
      List<Beacon> beacons = await fetchBeaconData(SingletonFunctionController.apibeaconmap);
      print(beacons);
      var gpsData = await fetchGpsData();
      var wifi = await fetchWifiData();
      var magnetometerData = await fetchMagnetometerData();
      var accelerometerData = await fetchAccelerometerData();
      var lux = await fetchLux();
      var fingerprint = SensorFingerprint(
        beacons: beacons,
        wifi: wifi,
        gpsData: gpsData,
        magnetometerData: magnetometerData,
        accelerometerData: accelerometerData,
        lux: lux,
        timeStamp: dateFormat.format(DateTime.now().toUtc())
      );
      data?.sensorFingerprint ??= [];
      data?.sensorFingerprint?.add(fingerprint);
      print("data.toJson() ${data?.toJson()}");
      
    });
  }
  Future<bool> stopCollectingData()async{
    timer?.cancel();
    bluetoothScanAndroidClass.stopScan();
    //cancel beacon stream here
    print("realtime data tht we got::${data!.toJson()}");
    print("realtime averaged out data:: ${getAverageRealData(data!)}");
    //await fingerPrintingApi().Finger_Printing_API(buildingAllApi.selectedBuildingID, data!);
    return true;
  }
  Map<String,dynamic> getRealData(){
    return getAverageRealData(data!);
  }
  Map<String, Map<String, dynamic>> getProcessedData(){
    return getAverageData(calculatedData!);
  }
  void _startListeningToScannedResults()async{
    // check platform support and necessary requirements
    final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    if(can == CanGetScannedResults.yes){
      subscription = WiFiScan.instance.onScannedResultsAvailable.listen((results) {
        accessPoints = results;
      });
    }
  }
  Future<List<Beacon>> fetchBeaconData(Map<String, beacon>? apibeaconmap)async{
    Map<String, List<int>> beaconvalues = await BluetoothScanAndroidClass.getDeviceWithRssi();
    Map<String, double> averageValue = await bluetoothScanAndroidClass.getDeviceWithAverage();
    Map<String, String> deviceNames = await bluetoothScanAndroidClass.getDeviceName();
    print("beaconvalues ${beaconvalues}");
    print("beaconvalues ${apibeaconmap}");
    List<Beacon> beacons = [];
    beaconvalues.forEach((key,value){
      if(apibeaconmap![key]!=null){
        print("inif");
        Position position = Position(x:(apibeaconmap![key]!.coordinateX??apibeaconmap![key]!.doorX!).toDouble(),y:(apibeaconmap![key]!.coordinateY??apibeaconmap![key]!.doorY!).toDouble());
        beacons.add(setBeacon(key, deviceNames[key], value.last,position,apibeaconmap![key]!.floor!.toString(),apibeaconmap![key]!.buildingID));
      }else{
        print("else");
      }
    });
    beacons.forEach((beacon){
      print("Hiamshu ${beacon.toJson()}");
    });
    //call this line for every beacon scanned using a for loop
    // beacons.add(setBeacon(null,null,null));
    return beacons;
  }
  Beacon setBeacon(String? beaconMacId, String? beaconName, int? beaconRssi, Position? beaconPosition,   String? beaconFloor,   String? buildingId){
    return Beacon(
        beaconMacId: beaconMacId, beaconName: beaconName, beaconRssi: beaconRssi, beaconPosition: beaconPosition,beaconFloor:beaconFloor,buildingId:buildingId
    );
  }
  Future<GpsData> fetchGpsData() async {
    if(gpsPosition == null){
      return GpsData(latitude: null, longitude: null, accuracy: null, altitude: null);
    }
    return GpsData(latitude: gpsPosition!.latitude, longitude: gpsPosition!.longitude, accuracy: gpsPosition!.accuracy,altitude: gpsPosition!.altitude);
  }
  Future<MagnetometerData> fetchMagnetometerData() async {
    return MagnetometerData(value: theta);
  }
  Future<List<Wifi>> fetchWifiData() async {
    List<Wifi> wifilist = [];
    for (var wifi in accessPoints) {
      wifilist.add(Wifi(wifiName: wifi.bssid, wifiStrength: wifi.level));
    }
    return wifilist;
  }
  Future<AccelerometerData> fetchAccelerometerData() async {
    return AccelerometerData(x: _x, y: _y, z: _z);
  }

  Future<double> fetchLux() async {
    return _lightValue.toDouble();
  }


}