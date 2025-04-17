import 'package:flutter_test/flutter_test.dart';
import 'package:iwaymaps/NAVIGATION/ELEMENTS/DirectionHeader.dart';
import 'package:iwaymaps/NAVIGATION/UserState.dart';
import 'package:iwaymaps/NAVIGATION/pathState.dart';
import 'package:mockito/mockito.dart';
import 'dart:io' show Platform;


void main() {



  setUp(() {
    user = UserState(floor: floor, coordX: coordX, coordY: coordY, lat: lat, lng: lng, theta: theta)

  });

  test('listenToBin returns true when on path and within threshold', () async {
    // Platform mocking needs some trick — isolate the platform check into a service if needed
    // Otherwise use conditional logic in production to simplify unit testing
    // For this example, we'll assume Android path

    
  });
}
