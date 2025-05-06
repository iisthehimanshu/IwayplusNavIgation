import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/pannels/pinLandmark.dart';
import 'basePannel.dart';

class pinLandmarkPannel extends BasePanel {
  final Function(MarkerId) update;
  final Function() localize;
  final Map<MarkerId, Marker> nearbyLandmarks;
  final Landmarks? pinedLandmark;
  final Function() closePanel;

  pinLandmarkPannel({
    required this.update,
    required this.localize,
    required this.nearbyLandmarks,
    required this.pinedLandmark,
    required this.closePanel
  });

  @override
  Widget buildPanelContent(BuildContext context) {
    return pinLandmark(
    update: update,
    localize: localize,
    nearbyLandmarks: nearbyLandmarks,
    pinedLandmark: pinedLandmark,
          );
  }
}
