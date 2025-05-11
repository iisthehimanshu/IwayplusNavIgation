import 'package:device_information/device_information.dart';
import 'package:flutter/foundation.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/DB2BeaconAPIModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/DB2DataVersionLocalModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/DB2LandMarkApiModelBox.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/DB2PatchAPIModelBox.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/DB2PolylineAPIModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/VenueBeaconAPIModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/VenueBeaconAPIModel.dart';

import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/DataVersion.dart';
import '../APIMODELS/GlobalAnnotationModel.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/landmark.dart';
import '../APIMODELS/outdoormodel.dart';
import '../APIMODELS/patchDataModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../APIMODELS/refresh.dart';
import '../DATABASE/BOXES/BeaconAPIModelBOX.dart';
import '../DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import '../DATABASE/BOXES/LandMarkApiModelBox.dart';
import '../DATABASE/BOXES/OutDoorModelBOX.dart';
import '../DATABASE/BOXES/PatchAPIModelBox.dart';
import '../DATABASE/BOXES/PolyLineAPIModelBOX.dart';
import '../DATABASE/BOXES/WayPointModelBOX.dart';
import '../DatabaseManager/DataBaseManager.dart';
import '../Encryption/EncryptionService.dart';
import '../config.dart';
import '../waypoint.dart';

class Detail {
  String url;
  String method;
  Map<String, String>? headers;
  bool encryption;
  Map<String, dynamic>? body;
  Function(dynamic) conversionFunction;
  Function()? dataBaseGetData;
  String? getPreLoadPrefix;
  Function()? dataBaseGetDataDB2;


  Detail(this.url, this.method, this.headers, this.encryption, this.body, this.conversionFunction, this.dataBaseGetData,this.getPreLoadPrefix,[this.dataBaseGetDataDB2]);

  updateAccessToken(String newAccessToken){
    headers?['x-access-token'] = newAccessToken;
  }

}

class Apidetails {
  Encryptionservice encryptionService = Encryptionservice();
  Detail landmark(String accessToken, String bid) {
    return Detail(
        "${AppConfig.baseUrl}/secured/landmarks?format=v2",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {"id": bid},
        land.fromJson,
        LandMarkApiModelBox.getData,
        "Landmark",
        DB2LandMarkApiModelBox.getData
    );
  }

  Detail buildingBeacons(String accessToken, String bid) {
    return Detail(
        "${AppConfig.baseUrl}/secured/building/beacons",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {"buildingId": bid},
        beacon.fromJsonToList,
        BeaconAPIModelBOX.getData,
        "Beacon",
        DB2BeaconAPIModelBOX.getData
    );
  }

  Detail venueBeacons(String accessToken, String venueName) {
    print("venuename  = $venueName");
    return Detail(
        "${AppConfig.baseUrl}/secured/venue/beacons",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {"venueName": venueName},
        beacon.fromJsonToList,
        VenueBeaconAPIModelBOX.getData,
        "VenueBeacon"
    );
  }

  Detail buildingByVenueApi(String accessToken, String venueName) {
    return Detail(
        "${AppConfig.baseUrl}/secured/building/get/venue",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {"venueName": venueName},
        Buildingbyvenue.fromJsonToList,
      null,
      "BuildingByVenue"
    );
  }

  Detail dataVersion(String accessToken, String bid) {
    return Detail(
        "${AppConfig.baseUrl}/secured/data-version",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
        },
        false,
        {"building_ID": bid},
        DataVersion.fromJson,
        DataVersionLocalModelBOX.getData,
        "DataVersion",
      DB2DataVersionLocalModelBOX.getData
    );
  }

  Detail globalAnnotation(String accessToken, String id) {
    return Detail(
        "${AppConfig.baseUrl}/secured/get-global-annotation/$id",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        null,
        GlobalModel.fromJson,
      null,
      "GlobalAnnotation"
    );
  }

  Detail outBuilding(String accessToken, List<String> bids) {
    return Detail(
        "${AppConfig.baseUrl}/secured/outdoor",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {"buildingIds": bids},
        outdoormodel.fromJson,
        OutDoorModeBOX.getData,
        "OutBuilding"
    );
  }

  Future<Detail> patch(String accessToken, String bid) async {
    return Detail(
        "${AppConfig.baseUrl}/secured/patch/get?format=v2",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {
          "id": bid,
          "manufacturer":kIsWeb?"WEB":await DeviceInformation.deviceManufacturer,
          "devicemodel": kIsWeb?"WEB":await DeviceInformation.deviceModel
        },
        patchDataModel.fromJson,
        PatchAPIModelBox.getData,
        "Patch",
      DB2PatchAPIModelBOX.getData
    );
  }

  Detail polyline(String accessToken, String bid) {
    return Detail(
        "${AppConfig.baseUrl}/secured/polyline?format=v2",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {
          "id": bid
        },
        polylinedata.fromJson,
        PolylineAPIModelBOX.getData,
        "Polyline",
      DB2PolylineAPIModelBOX.getData
    );
  }

  static Detail refreshToken() {
    return Detail(
        "${AppConfig.baseUrl}/api/refreshToken",
        "POST",
        {
          'Content-Type': 'application/json'
        },
        false,
        {
          "refreshToken": DataBaseManager().getRefreshToken()
        },
        refresh.fromJson,
      null,
        null
    );
  }

  Detail waypoint(String accessToken, String bid) {
    return Detail(
        "${AppConfig.baseUrl}/secured/indoor-path-network",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {
          "building_ID": bid
        },
        PathModel.fromJsonToList,
        WayPointModeBOX.getData,
        "WayPoint"
    );
  }

}
