// base_panel.dart
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

abstract class BasePanel {
  final PanelController _panelController = PanelController();

  PanelController get controller => _panelController;

  void showPanel() {
    _panelController.open();
  }

  void hidePanel() {
    _panelController.close();
  }

  bool isPanelOpened() {
    try {
      return _panelController.isPanelOpen;
    } catch (_) {
      return false;
    }
  }

  void togglePanel() {
    if (_panelController.isPanelOpen) {
      hidePanel();
    } else {
      showPanel();
    }
  }

  /// Must be overridden to provide actual content of the panel
  Widget buildPanelContent(BuildContext context);

  /// Call this to get the panel widget
  Widget getPanelWidget(BuildContext context) {
    return SlidingUpPanel(
      controller: _panelController,
      panel: buildPanelContent(context),
      minHeight: 0,
      maxHeight: 250,
      backdropOpacity: 0.5,
      isDraggable: false,
    );
  }
}
