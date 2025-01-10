import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/pannels/pinLandmark.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  SlidingUpPanel getPanelWidget(BuildContext context, Function(MarkerId) update, Function() localize,Map<MarkerId, Marker> nearbyLandmarks, Landmarks? pinedLandmark) {
    return SlidingUpPanel(
      controller: _panelController,
      panel: pinLandmark(
        update: update, nearbyLandmarks: nearbyLandmarks,pinedLandmark: pinedLandmark, localize: localize,  // Pass the hidePanel method to close the panel
      ),
      minHeight: 0,
      maxHeight: 250,  // Maximum height of the panel
      backdropOpacity: 0.5,
      isDraggable: false,
    );
  }
}
