import 'package:flutter/material.dart';

class PickupLocationPin extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double height;
  final double line;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;

  const PickupLocationPin({
    Key? key,
    this.text = 'Your Location',
    this.onTap,
    this.height = 36.0,
    this.line = 18,
    this.borderRadius = 18.0,
    this.backgroundColor = const Color(0xff24B9B0),
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(bottom: 100,left: 18),
        height: height+18,
        width: 135,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: height,
              width: 135,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1, // Limit to one line
                  overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                ),
              ),
            ),
            Container(height: line,width: 2,color: backgroundColor,)
          ],
        ),
      ),
    );
  }
}