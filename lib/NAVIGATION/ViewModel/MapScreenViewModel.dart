
import 'package:flutter/cupertino.dart';

class MapScreenViewModel with ChangeNotifier{
  bool _showNearestLandmarkPanelVar = false;

  bool get showNearestLandmarkPanel => _showNearestLandmarkPanelVar;

}