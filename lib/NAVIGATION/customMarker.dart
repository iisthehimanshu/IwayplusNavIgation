import 'package:flutter/material.dart';

class CustomMarker extends StatelessWidget {
  final String text;
  final IconData dirIcon;
  CustomMarker({required this.text, required this.dirIcon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xffFFFF00), // Set the background color to yellow
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
            bottomRight: Radius.circular(35),
            bottomLeft: Radius.circular(1)),
        border: Border.all(
          color: Colors.black, // Set the border color to white
          width: 2, // Set the border width (adjust as needed)
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(dirIcon, color: Colors.black, size: 32),
          SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              text,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}