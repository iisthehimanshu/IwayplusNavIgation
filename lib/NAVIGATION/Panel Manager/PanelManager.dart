import 'package:flutter/cupertino.dart';
import 'PanelState.dart';

class PanelManager extends ChangeNotifier {
  static final PanelManager _instance = PanelManager._internal();
  factory PanelManager() => _instance;
  PanelManager._internal();
  PanelState _currentPanel = PanelState.none;
  PanelState get currentPanel => _currentPanel;

  void showPanel(PanelState panel) {
    _currentPanel = panel;
    notifyListeners();
  }

  void hidePanel() {
    _currentPanel = PanelState.none;
    notifyListeners();
  }

  bool isPanelVisible(PanelState panel) => _currentPanel == panel;
}
