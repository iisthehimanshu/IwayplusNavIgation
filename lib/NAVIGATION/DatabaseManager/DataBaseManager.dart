import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/VenueBeaconAPIModel.dart';
import 'package:upgrader/upgrader.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/BuildingByVenueAPIModel.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import '../DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '../DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '../DATABASE/DATABASEMODEL/GlobalAnnotationAPIModel.dart';
import '../DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../DATABASE/DATABASEMODEL/OutDoorModel.dart';
import '../DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import '../DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import '../DATABASE/DATABASEMODEL/WayPointModel.dart';
import '../DataBaseManager/DBManager.dart';
import '../Network/APIDetails.dart';
import '../Network/NetworkManager.dart';


class DataBaseManager implements DBManager {
  bool greenDataBase = true;


  // Singleton instance
  static final DataBaseManager _instance = DataBaseManager._internal();

  // Private constructor
  DataBaseManager._internal();

  // Factory constructor returning the singleton
  factory DataBaseManager() => _instance;

  @override
  Future<void> delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> updateData() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveData(dynamic dataModel, Detail details, String bID) async {
    final databaseBox = details.dataBaseGetData!();
    databaseBox.put(bID, dataModel);
  }

  @override
  Future<void> saveDataDB2(dynamic dataModel, Detail details, String bID) async {
    final databaseBox = details.dataBaseGetDataDB2!();
    databaseBox.put(bID, dataModel);
  }

  @override
  dynamic getData(Detail details, String bID) {
    final databaseBox = details.dataBaseGetData!();
    final data = databaseBox.get(bID);
    return data;
  }

  @override
  dynamic getDataDB2(Detail details, String bID) {
    final databaseBox = details.dataBaseGetDataDB2!();
    final data = databaseBox.get(bID);
    return data;
  }

  @override
  dynamic getDataBaseKeysDB2(Detail details){
    final databaseBox = details.dataBaseGetDataDB2!();
    return databaseBox.keys;
  }

  @override
  dynamic getDataBaseValuesDB2(Detail details){
    final databaseBox = details.dataBaseGetDataDB2!();
    return databaseBox.values;
  }

  @override
  dynamic getDataBaseKeys(Detail details){
    final databaseBox = details.dataBaseGetData!();
    return databaseBox.keys;
  }

  @override
  dynamic getDataBaseValues(Detail details){
    final databaseBox = details.dataBaseGetData!();
    return databaseBox.values;
  }

  @override
  String getAccessToken() {
    var signInBox = Hive.box('SignInDatabase');
    return signInBox.get("accessToken");
  }

  @override
  void updateAccessToken(String newAccessToken) {
    var signInBox = Hive.box('SignInDatabase');
    signInBox.put("accessToken", newAccessToken);
  }

  @override
  String getRefreshToken() {
    var signInBox = Hive.box('SignInDatabase');
    return signInBox.get("refreshToken");
  }

  @override
  void updateRefreshToken(String newRefreshToken) {
    var signInBox = Hive.box('SignInDatabase');
    signInBox.put("refreshToken", newRefreshToken);
  }


}

