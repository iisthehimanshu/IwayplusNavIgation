import 'package:device_information/device_information.dart';

import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/DataVersion.dart';
import '../APIMODELS/GlobalAnnotationModel.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/landmark.dart';
import '../APIMODELS/outdoormodel.dart';
import '../APIMODELS/patchDataModel.dart';
import '../DATABASE/BOXES/LandMarkApiModelBox.dart';
import '../Encryption/EncryptionService.dart';
import '../config.dart';

class Detail {
  String url;
  String method;
  Map<String, String>? headers;
  bool encryption;
  Map<String, dynamic>? body;
  Function(dynamic)? conversionFunction;
  Function()? dataBaseGetData;

  Detail(this.url, this.method, this.headers, this.encryption, this.body, this.conversionFunction , this.dataBaseGetData);
}

class Apidetails {
  Encryptionservice encryptionService = Encryptionservice();
  Detail landmark(String accessToken, String bid) {
    return Detail(
        "${AppConfig.baseUrl}/secured/landmarks",
        "POST",
        {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
          'Authorization': encryptionService.authorization
        },
        true,
        {"id": bid},
        Landmarks.fromJson,
        LandMarkApiModelBox.getData
    );
  }

  // Detail beacons(String accessToken, String bid) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/building/beacons",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       {"buildingId": bid},
  //       beacon.fromJsonToList
  //   );
  // }
  //
  // Detail buildingByVenueApi(String accessToken, String venueName) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/building/get/venue",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       {"venueName": venueName},
  //       Buildingbyvenue.fromJsonToList
  //   );
  // }
  //
  // Detail dataVersion(String accessToken, String bid) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/data-version",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       {"building_ID": bid},
  //       DataVersion.fromJson
  //   );
  // }
  //
  // Detail globalAnnotation(String accessToken, String id) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/get-global-annotation/$id",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       null,
  //       GlobalModel.fromJson
  //   );
  // }
  //
  // Detail outBuilding(String accessToken, List<String> bids) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/outdoor",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       {"buildingIds": bids},
  //       outdoormodel.fromJson
  //   );
  // }
  //
  // Detail patch(String accessToken, String bid) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/patch/get",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       {
  //         "id": bid,
  //         "manufacturer":DeviceInformation.deviceManufacturer,
  //         "devicemodel": DeviceInformation.deviceModel
  //       },
  //       patchDataModel.fromJson
  //   );
  // }
  //
  // Detail polyline(String accessToken, String bid) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/polyline",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       {
  //         "id": bid
  //       });
  // }
  //
  // Detail refresh(String accessToken, String bid) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/api/refreshToken",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': encryptionService.authorization,
  //       },
  //       true,
  //       {
  //         "id": bid
  //       });
  // }
  //
  // Detail waypoint(String accessToken, String bid) {
  //   return Detail(
  //       "${AppConfig.baseUrl}/secured/indoor-path-network",
  //       "POST",
  //       {
  //         'Content-Type': 'application/json',
  //         'x-access-token': accessToken,
  //         'Authorization': encryptionService.authorization
  //       },
  //       true,
  //       {
  //         "building_ID": bid
  //       });
  // }

}
