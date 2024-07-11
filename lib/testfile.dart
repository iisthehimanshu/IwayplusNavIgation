
import 'APIMODELS/patchDataModel.dart' as PDM;
import 'UserState.dart';
import 'dart:math';

class testfile{

  static PDM.patchDataModel globalData = PDM.patchDataModel.fromJson({
    "patchExist": true,
    "patchData": {
      "_id": "65d98a58db333f89457d675b",
      "building_ID": "65d8835adb333f89456e687f",
      "breadth": "223",
      "fileName": "db3b8de5-b6ac-406f-bae0-48f81c275989_AshokaUniversity-ACFOURE-ground_AC04_Ground.png",
      "length": "295",
      "coordinates": [
        {
          "localRef": {
            "lat": "0",
            "lng": "0"
          },
          "globalRef": {
            "lat": "28.947872016788782",
            "lng": "77.10090317468223"
          }
        },
        {
          "localRef": {
            "lat": "223",
            "lng": "0"
          },
          "globalRef": {
            "lat": "28.947253965971328",
            "lng": "77.10095257428588"
          }
        },
        {
          "localRef": {
            "lat": "223",
            "lng": "295"
          },
          "globalRef": {
            "lat": "28.947284532557024",
            "lng": "77.10187105074749"
          }
        },
        {
          "localRef": {
            "lat": "0",
            "lng": "295"
          },
          "globalRef": {
            "lat": "28.947904519752957",
            "lng": "77.10184852798841"
          }
        }
      ],
      "parkingCoords": [
        {
          "lat": "28.947934314547194",
          "lon": "77.10098237165022"
        },
        {
          "lat": "28.947948395154132",
          "lon": "77.10133121523172"
        },
        {
          "lat": "28.947892072715028",
          "lon": "77.10133389864389"
        }
      ],
      "pickupCoords": [],
      "createdAt": "2024-02-24T06:19:04.942Z",
      "updatedAt": "2024-07-06T04:32:59.639Z",
      "__v": 0,
      "walkingCoords": [],
      "buildingAngle": "266.00"
    }
  });

  static     double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  static double getHaversineDistance(Map<String, double> point1, Map<String, double> point2) {
    const R = 6371e3; // Earth radius in meters
    double phi1 = degreesToRadians(point1["lat"]!);
    double phi2 = degreesToRadians(point2["lat"]!);
    double deltaPhi = degreesToRadians(point2["lat"]! - point1["lat"]!);
    double deltaLambda = degreesToRadians(point2["lon"]! - point1["lon"]!);

    double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // in meters
  }

  static double getBearing(Map<String, double> point1, Map<String, double> point2) {
    double phi1 = degreesToRadians(point1["lat"]!);
    double phi2 = degreesToRadians(point2["lat"]!);
    double lambda1 = degreesToRadians(point1["lon"]!);
    double lambda2 = degreesToRadians(point2["lon"]!);

    double y = sin(lambda2 - lambda1) * cos(phi2);
    double x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(lambda2 - lambda1);
    return radiansToDegrees(atan2(y, x));
  }

  static Map<String, double> calculateLocalCoordinates(double distance, double bearing) {
    double x = distance * cos(degreesToRadians(bearing));
    double y = distance * sin(degreesToRadians(bearing));
    return {"localx": x, "localy": y};
  }



  static Map<String, double> globalToLocal(double lat, double lon, {PDM.patchDataModel? patchData = null}) {
    PDM.patchDataModel Data = PDM.patchDataModel();
    if (patchData != null) {
      Data = patchData;
    } else {
      Data = globalData;
    }

    List<Map<String, double>> ref = [
      {
        "lat": double.parse(Data.patchData!.coordinates![0].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![0].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![0].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![0].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![1].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![1].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![1].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![1].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![2].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![2].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![2].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![2].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![3].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![3].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![3].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![3].localRef!.lat!),
      },
    ];

    int leastLat = 0;
    for (int i = 0; i < ref.length; i++) {
      if (ref[i]["lat"] == ref[leastLat]["lat"]) {
        if (ref[i]["lon"]! > ref[leastLat]["lon"]!) {
          leastLat = i;
        }
      } else if (ref[i]["lat"]! < ref[leastLat]["lat"]!) {
        leastLat = i;
      }
    }

    int c1 = (leastLat == 3) ? 0 : (leastLat + 1);
    int c2 = (leastLat == 0) ? 3 : (leastLat - 1);
    int highLon = (ref[c1]["lon"]! > ref[c2]["lon"]!) ? c1 : c2;

    double b = getHaversineDistance(ref[leastLat], ref[highLon]);
    double out = getBearing(ref[leastLat], ref[highLon]);

    double distance = getHaversineDistance(ref[leastLat], {"lat": lat, "lon": lon});
    double bearing = getBearing(ref[leastLat], {"lat": lat, "lon": lon});

    double adjustedBearing = bearing - out;
    Map<String, double> localCoords = calculateLocalCoordinates(distance, adjustedBearing);

    localCoords["localx"] = localCoords["localx"]! + UserState.xdiff;
    localCoords["localy"] = localCoords["localy"]! + UserState.ydiff;

    return {"x": localCoords["localx"]!, "y": localCoords["localy"]!};
  }

}