import 'package:flutter/material.dart';
import 'dart:math' show atan2, sqrt;
import 'package:sensors_plus/sensors_plus.dart';

class RippleButton extends StatefulWidget {
  const RippleButton({Key? key}) : super(key: key);

  @override
  State<RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<RippleButton> with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  bool isPressed = false;
  double _angle = 0; // Angle of the torch beam rotation

  @override
  void initState() {
    super.initState();
    // Listen to magnetometer events to calculate rotation
    magnetometerEvents.listen((MagnetometerEvent event) {
      // Calculate angle using atan2 for rotation
      double angle = atan2(event.y, event.x);
      setState(() {
        _angle = angle; // Update the torch angle
      });
    });
  }

  void startAnimation() {
    if (!isPressed) {
      setState(() {
        isPressed = true;
      });
      _addRipple();
    }
  }

  void stopAnimation() {
    setState(() {
      isPressed = false;
    });
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
  }

  void _addRipple() {
    if (!isPressed) return;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    final currentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );

    currentAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animations.remove(currentAnimation);
          _controllers.remove(controller);
        });
        controller.dispose();
      }
    });

    setState(() {
      _controllers.add(controller);
      _animations.add(currentAnimation);
    });

    controller.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (isPressed) {
        _addRipple();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final size = MediaQuery.of(context).size;
    // Calculate the diagonal length of the screen
    final screenDiagonal = sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          onTapDown: (_) => startAnimation(),
          onTapUp: (_) => stopAnimation(),
          onTapCancel: () => stopAnimation(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // OverflowBox to allow ripple animations to go beyond screen bounds
              OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ..._animations.map((animation) => AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Container(
                          width: 50 * (1 + animation.value * screenDiagonal / 25),
                          height: 50 * (1 + animation.value * screenDiagonal / 25),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2 * (1 - animation.value)),
                                Colors.teal.withOpacity(0.2 * (1 - animation.value)),
                                Colors.white.withOpacity(0.2 * (1 - animation.value)),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                  ],
                ),
              ),
              // Torch beam
              if (isPressed)
                Transform.rotate(
                  angle: _angle,
                  child: Image.asset('assets/userloc0.png',scale: 2,),
                ),
              // Main button
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // gradient: const LinearGradient(
                  //   colors: [
                  //     Color(0xFF3B82F6),
                  //     Color(0xFF8B5CF6),
                  //     Color(0xFFEC4899),
                  //   ],
                  // ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(bottom: 12,left: 5,right: 5,top: 5),
                    backgroundColor: Colors.teal,
                    shadowColor: Colors.tealAccent,
                    shape: const CircleBorder(),
                  ),
                  child: Image.asset('assets/real-time-tracking.png',color: Colors.white,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the Torch Beam
class TorchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the torch beam with a gradient
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(0.6), // Bright at the center
          Colors.yellow.withOpacity(0.2), // Fading outward
          Colors.transparent, // Completely faded
        ],
        stops: [0.0, 0.5, 1.0],
        radius: 1.0,
        center: Alignment.center, // Center of the gradient at the button
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Path for the fan-shaped beam
    final path = Path()
      ..moveTo(size.width / 2, size.height / 2) // Start at the center of the button
      ..arcTo(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.height),
        -0.5, // Starting angle in radians (fan spreads to the left)
        1.5, // Sweep angle in radians (fan spreads to the right)
        false,
      )
      ..lineTo(size.width / 2, size.height / 2) // Close path back to center
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
