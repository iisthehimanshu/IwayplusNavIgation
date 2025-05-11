
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SwitchDataBase{

  static final SwitchDataBase _instance = SwitchDataBase._internal();

  SwitchDataBase._internal();

  factory SwitchDataBase() {
    return _instance;
  }

  var switchDatabaseBox = Hive.box('SwitchingDatabaseInfo');
  bool newDataFromServerDBShouldBeCreated = false;

  bool isGreenDataBaseActive(){
    return switchDatabaseBox.get('greenDataBase');
  }

  void switchGreenDataBase(bool value){
    switchDatabaseBox.put('greenDataBase', value);
    if(kDebugMode) print("SWITCHING DB1 DATABASE TO $value");
  }
}