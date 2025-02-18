import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';

class Locationdetected extends StatelessWidget {
  Landmarks landmark;
  Locationdetected({super.key, required this.landmark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 386,
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(8), // Rounded corners
        border: Border.all(color: Colors.white, width: 1), // Optional border
      ),
      padding: EdgeInsets.all(16), // Optional padding inside container
      child: const Column(
        children: [
          Text(
              "Location Detected",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              )
          )
        ],
      ),
    );
  }
}
