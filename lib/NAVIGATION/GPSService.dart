import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GPSService {
  static const EventChannel _eventChannel = EventChannel('gps_scan');

  static Stream<Location> get locationStream {
    final stackTrace = StackTrace.current;
    print("locationStream Stack: \n$stackTrace");
    return _eventChannel.receiveBroadcastStream().map((event) {
      final Map<dynamic, dynamic> location = event;
      print("sending gps location");
      return Location(latitude: location["latitude"], longitude: location["longitude"], accuracy: location["accuracy"], timeStamp: DateTime.now());
    });
  }

  static Future<void> checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

}

class Location{
  double latitude;
  double longitude;
  double accuracy;
  DateTime timeStamp;

  Location({required this.latitude,required this.longitude,required this.accuracy, required this.timeStamp});
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timeStamp': timeStamp.toIso8601String(), // Serializing DateTime to string
    };
  }
}
