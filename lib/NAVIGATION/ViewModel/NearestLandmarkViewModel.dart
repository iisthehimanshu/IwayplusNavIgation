import 'package:flutter/material.dart';

class NearestLandmarkViewModel extends ChangeNotifier {
  String _floorText = "";

  String get floorText => _floorText;
  set floorText(String? value){
    _floorText = value??"";
  }
}
