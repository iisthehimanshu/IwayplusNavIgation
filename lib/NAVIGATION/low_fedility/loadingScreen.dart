import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' as lott;

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff003366),
      child: Center(
        child: lott.Lottie.asset(
          'assets/loding_animation.json', // Path to your Lottie animation
        ),
      ),
    );
  }
}
