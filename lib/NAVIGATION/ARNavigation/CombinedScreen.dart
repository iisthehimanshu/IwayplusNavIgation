import 'package:flutter/material.dart';

import '../Navigation.dart';

class CombinedScreen extends StatefulWidget {
  @override
  _CombinedScreenState createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNavigationOverlay();
    });
  }

  void _showNavigationOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        right: 5.0,
        left: 5,
        bottom: 2.0,
        child: Material(
          elevation: 4.0,
          color: Colors.transparent, // Ensure transparency for shadow
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(200.0),
            topRight: Radius.circular(200.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(200.0),
              topRight: Radius.circular(200.0),
            ),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: 200,
              color: Colors.white,
              child: Navigation(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ARView occupies the entire screen
          Container(
            color: Colors.blueAccent,
            child: Center(
              child: Text(
                'AR View',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
