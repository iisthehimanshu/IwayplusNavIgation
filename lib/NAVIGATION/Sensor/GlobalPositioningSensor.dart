import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwaymaps/NAVIGATION/Sensor/baseSensorClass.dart';

import '../GPSService.dart';

class GpsSensor extends BaseSensor{
  static const EventChannel _eventChannel = EventChannel('gps_scan');
  final StreamController<Location> _controller = StreamController.broadcast();
  StreamSubscription<Location>? _subscription;


  static Stream<Location> get locationStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final Map<dynamic, dynamic> location = event;
      print("sending gps location");
      return Location(latitude: location["latitude"], longitude: location["longitude"], accuracy: location["accuracy"], timeStamp: DateTime.now());
    });
  }

  // Future<Position> getCurrentCoordinates() async {
  //   // return Geolocator.getCurrentPosition();
  //
  // }

  Future<bool> checkPermission() async {
    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    // }
    //
    // return permission == LocationPermission.always ||
    //     permission == LocationPermission.whileInUse;
    return false;
  }



 @override
 Future<void> startListening() async {
    if(kIsWeb){
      return;
    }
   bool isGranted = await checkPermission();
   if (!isGranted) {
     print("GPS permission not granted");
     return;
   }

   _subscription = GPSService.locationStream.listen((location) {
     _controller.add(location);
   });
 }

 @override
 void stopListening() {
    _subscription?.cancel();
  }

  @override
  Stream<Location> get stream => _controller.stream;
}
