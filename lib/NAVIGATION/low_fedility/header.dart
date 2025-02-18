import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iwaymaps/NAVIGATION/low_fedility/homepage.dart';

import '../APIMODELS/landmark.dart';
import '../Navigation.dart';
class Header extends StatelessWidget {
  Landmarks? detectedLocation;
  Header(this.detectedLocation,{super.key});
  FlutterTts flutterTts = FlutterTts();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      margin: EdgeInsets.only(top: 16,bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {Navigator.pop(context);},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.black,
              shape: const CircleBorder(), // Makes it circular
            ),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          )
          ,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your location',
                  style: TextStyle(
                    color: Color(0xFF003366),
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    height: 1.20,
                  ),
                ),
                Text(
                  '${detectedLocation?.name}',
                  style: TextStyle(
                    color: Color(0xFF003366),
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              flutterTts.speak("Relocalizing");
              Homepage.relocalize();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              elevation: 0, // Zero elevation
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Square shape with no border radius
              ),
            ),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xffCA1619),
                  size: 32, // Icon size 24x24
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
