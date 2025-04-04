import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/pannels/pinLandmark.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../APIMODELS/landmark.dart';

class pinLandmarkPannel {
  final PanelController _panelController = PanelController();

  // Method to show the panel
  void showPanel() {
    _panelController.open();
  }

  // Method to hide the panel
  void hidePanel() {
    _panelController.close();
  }

  bool isPanelOpened(){
    try {
      return _panelController.isPanelOpen;
    }catch(e){
      return false;
    }
  }

  // Method to toggle panel visibility
  void togglePanel() {
    if (_panelController.isPanelOpen) {
      hidePanel();
    } else {
      showPanel();
    }
  }

  // Method to get the SlidingUpPanel widget
  Widget getPanelWidget(BuildContext context, Function(MarkerId) update, Function() localize, Function() closePanel, Map<MarkerId, Marker> nearbyLandmarks, Landmarks? pinedLandmark) {
    return Stack(
      children: [
        Visibility(
          visible: isPanelOpened(),
          child: Positioned(
            left: 10,
            top: 24,
            child: ElevatedButton(
              onPressed: closePanel,
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(), // Make the button circular
                padding: EdgeInsets.all(8), // Adjust the size of the circle
                elevation: 5, // Add elevation for the raised effect
                backgroundColor: Color(0xff24B9B0), // Background color of the button
                foregroundColor: Colors.white, // Icon color
              ),
              child: Icon(
                Icons.arrow_back, // Back arrow icon
                size: 32, // Adjust the size of the icon
              ),
            ),
          ),
        ),
        SlidingUpPanel(
        controller: _panelController,
        panel: pinLandmark(
          update: update, nearbyLandmarks: nearbyLandmarks,pinedLandmark: pinedLandmark, localize: localize,  // Pass the hidePanel method to close the panel
        ),
        minHeight: 0,
        maxHeight: 250,  // Maximum height of the panel
        backdropOpacity: 0.5,
        isDraggable: false,
      )
      ],
    );
  }
}
