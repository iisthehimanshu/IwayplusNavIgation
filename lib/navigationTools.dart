import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwayplusnav/UserState.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart' as PDM;
import 'API/PatchApi.dart';
import 'APIMODELS/patchDataModel.dart';
import 'Cell.dart';
import 'path.dart';

class tools {
  static List<PDM.Coordinates>? _cachedCordData;
  static List<Point<double>> corners = [];
  static double AngleBetweenBuildingandGlobalNorth = 0.0;

  static patchDataModel globalData = patchDataModel();

  static Future<void> fetchData() async {
    await patchAPI().fetchPatchData().then((value) {
      print("object ${value.patchData!.coordinates.toString()}");
      _cachedCordData = value.patchData!.coordinates;
    });
  }

  static LatLng calculateRoomCenterinLatLng(List<LatLng> roomCoordinates) {
    double latSum = 0.0;
    double lngSum = 0.0;

    for (int i = 0; i < 4; i++) {
      latSum += roomCoordinates[i].latitude;
      lngSum += roomCoordinates[i].longitude;
    }

    double latCenter = latSum / 4;
    double lngCenter = lngSum / 4;
    return LatLng(latCenter, lngCenter);
  }

  static List<double> calculateRoomCenterinList(List<LatLng> roomCoordinates) {
    double latSum = 0.0;
    double lngSum = 0.0;

    for (int i = 0; i < 4; i++) {
      latSum += roomCoordinates[i].latitude;
      lngSum += roomCoordinates[i].longitude;
    }

    double latCenter = latSum / 4;
    double lngCenter = lngSum / 4;
    return [latCenter, lngCenter];
  }

  static String numericalToAlphabetical(int number) {
    switch (number) {
      case 0:
        return 'ground';
      case 1:
        return 'first';
      case 2:
        return 'second';
      case 3:
        return 'third';
      case 4:
        return 'fourth';
      case 5:
        return 'fifth';
      case 6:
        return 'sixth';
      case 7:
        return 'seventh';
      case 8:
        return 'eighth';
      case 9:
        return 'ninth';
      case 10:
        return 'tenth';
      default:
        return 'Invalid number';
    }
  }
  static bool gotBhart = false;

  static List<double> localtoglobal(int x, int y,
      {PDM.patchDataModel? patchData = null}) {
    // x = x - UserState.xdiff;
    // y = y - UserState.ydiff;
    //print("Wilsonlocaltoglobal started");
    PDM.patchDataModel Data = PDM.patchDataModel();
    if (patchData != null) {
      Data = patchData;
      if(patchData.patchData!.fileName == "004ef3cf-9294-4171-adc0-1554759d5400_IITCampus-BhartiSchool-ground_ground.png"){
        gotBhart = true;
      }

    } else {
      Data = globalData;
    }
    int floor = 0;

    List<double> diff = [
      0,
      0,
      0,
    ];

    // {"coordinates" : patchDataApi().fetchedPatchData!.patchData!.coordinates! } ;

    List<Map<String, double>> ref = [
      {
        "lat": double.parse(Data.patchData!.coordinates![2].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![2].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![2].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![2].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![1].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![1].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![1].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![1].localRef!.lat!),
      },
      {
        "lat": double.parse(Data.patchData!.coordinates![0].globalRef!.lat!),
        "lon": double.parse(Data.patchData!.coordinates![0].globalRef!.lng!),
        "localx": double.parse(Data.patchData!.coordinates![0].localRef!.lng!),
        "localy": double.parse(Data.patchData!.coordinates![0].localRef!.lat!),
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

    List<double> lengths = [];
    for (int i = 0; i < ref.length; i++) {
      double temp1;
      if (i == ref.length - 1) {
        temp1 = getHaversineDistance(ref[i], ref[0]);
      } else {
        temp1 = getHaversineDistance(ref[i], ref[i + 1]);
      }
      lengths.add(temp1);
    }

    double b = getHaversineDistance(ref[leastLat], ref[highLon]);
    Map<String, double> horizontal = obtainCoordinates(ref[leastLat], 0, b);

    double c = getHaversineDistance(ref[leastLat], horizontal);
    double a = getHaversineDistance(ref[highLon], horizontal);

    double out = acos((b * b + c * c - a * a) / (2 * b * c)) * 180 / pi;

    Map<String, double> localRef = {"localx": 0, "localy": 0};

    if (diff != null && diff.length > 1) {
      List<double> test = diff.where((d) => d == floor).toList();
      if (test.isNotEmpty) {
        localRef["localx"] = x - test[0];
        localRef["localy"] = y - test[1];
      } else {
        localRef["localx"] = x as double;
        localRef["localy"] = y as double;
      }
    } else {
      localRef["localx"] = x as double;
      localRef["localy"] = y as double;
    }

    double l = distance(ref[leastLat], ref[highLon]);
    double m = distance(localRef, ref[highLon]);
    double n = distance(ref[leastLat], localRef);

    double theta = acos((l * l + n * n - m * m) / (2 * l * n)) * 180 / pi;

    if (((l * l + n * n - m * m) / (2 * l * n) > 1) || m == 0 || n == 0) {
      theta = 0;
    }

    double ang = theta + out;
    double dist =
        distance(ref[leastLat], localRef) * 0.3048; // to convert to meter

    double ver = dist * sin(ang * pi / 180.0);
    double hor = dist * cos(ang * pi / 180.0);

    Map<String, double> finalCoords =
        obtainCoordinates(ref[leastLat], ver, hor);

    return [finalCoords["lat"]!, finalCoords["lon"]!];
  }

  static double getHaversineDistance(
      Map<String, double> firstLocation, Map<String, double> secondLocation) {
    const earthRadius = 6371; // km
    double diffLat =
        ((secondLocation["lat"]! - firstLocation["lat"]!) * pi) / 180;
    double difflon =
        ((secondLocation["lon"]! - firstLocation["lon"]!) * pi) / 180;
    double arc = cos((firstLocation["lat"]! * pi) / 180) *
            cos((secondLocation["lat"]! * pi) / 180) *
            sin(difflon / 2) *
            sin(difflon / 2) +
        sin(diffLat / 2) * sin(diffLat / 2);
    double line = 2 * atan2(sqrt(arc), sqrt(1 - arc));
    double distance = earthRadius * line * 1000;
    return distance;
  }

  static Map<String, double> obtainCoordinates(
      Map<String, double> reference, double vertical, double horizontal) {
    const double R = 6378137; // Earth’s radius, sphere
    double dLat = vertical / R;
    double dLon = horizontal / (R * cos((pi * reference["lat"]!) / 180));
    double latA = reference["lat"]! + (dLat * 180) / pi;
    double lonA = reference["lon"]! + (dLon * 180) / pi;
    return {"lat": latA, "lon": lonA};
  }

  static double distance(
      Map<String, double> first, Map<String, double> second) {
    double dist1 = pow((second["localy"]! - first["localy"]!), 2) as double;
    double dist2 = pow((second["localx"]! - first["localx"]!), 2) as double;
    double dist = dist1 + dist2;
    //  pow((second["localy"] - first["localy"]), 2) as double + pow((second["localx"] - first["localx"]), 2) as double ;
    return sqrt(dist);
  }

  static String angleToClocks(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }

    if (angle >= 337.5 || angle <= 22.5) {
      return "Straight";
    } else if (angle > 22.5 && angle <= 67.5) {
      return "Slight Right";
    } else if (angle > 67.5 && angle <= 112.5) {
      return "Right";
    } else if (angle > 112.5 && angle <= 157.5) {
      return "Sharp Right";
    } else if (angle > 157.5 && angle <= 202.5) {
      return "U Turn";
    } else if (angle > 202.5 && angle <= 247.5) {
      return "Sharp Left";
    } else if (angle > 247.5 && angle <= 292.5) {
      return "Left";
    } else if (angle > 292.5 && angle <= 337.5) {
      return "Slight Left";
    } else {
      return "None";
    }
  }

  static String angleToClocks2(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }

    if (angle >= 337.5 || angle <= 22.5) {
      return "on your front";
    } else if (angle > 22.5 && angle <= 67.5) {
      return "on your Slight Right";
    } else if (angle > 67.5 && angle <= 112.5) {
      return "on your Right";
    } else if (angle > 112.5 && angle <= 157.5) {
      return "on your Sharp Right";
    } else if (angle > 157.5 && angle <= 202.5) {
      return "on your back";
    } else if (angle > 202.5 && angle <= 247.5) {
      return "on your Sharp Left";
    } else if (angle > 247.5 && angle <= 292.5) {
      return "on your Left";
    } else if (angle > 292.5 && angle <= 337.5) {
      return "on your Slight Left";
    } else {
      return "on your None";
    }
  }


  static String angleToClocksForNearestLandmarkToBeacon(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }

    if (angle >= 337.5 || angle <= 22.5) {
      return "Front";
    } else if (angle > 22.5 && angle <= 67.5) {
      return "Slight Right";
    } else if (angle > 67.5 && angle <= 112.5) {
      return "Right";
    } else if (angle > 112.5 && angle <= 157.5) {
      return "Sharp Right";
    } else if (angle > 157.5 && angle <= 202.5) {
      return "Back";
    } else if (angle > 202.5 && angle <= 247.5) {
      return "Sharp Left";
    } else if (angle > 247.5 && angle <= 292.5) {
      return "Left";
    } else if (angle > 292.5 && angle <= 337.5) {
      return "Slight Left";
    } else {
      return "None";
    }
  }

  static double calculateAngle(List<int> a, List<int> b, List<int> c) {
    double angle1 = atan2(b[1] - a[1], b[0] - a[0]);
    double angle2 = atan2(c[1] - b[1], c[0] - b[0]);

    double angle = (angle2 - angle1) * 180 / pi;

    if (angle < 0) {
      angle += 360;
    }

    return angle;
  }

  static double toRadians(double degree) {
    return degree * pi / 180.0;
  }

  static double calculateBearing(List<double> pointA, List<double> pointB) {
    double lat1 = toRadians(pointA[0]);
    double lon1 = toRadians(pointA[1]);
    double lat2 = toRadians(pointB[0]);
    double lon2 = toRadians(pointB[1]);

    double dLon = lon2 - lon1;

    double x = sin(dLon) * cos(lat2);
    double y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearingRadians = atan2(x, y);
    double bearingDegrees = bearingRadians * 180.0 / pi;
    // Normalize the bearing to be within the range 0° to 360°
    bearingDegrees = (bearingDegrees + 360) % 360;

    return bearingDegrees;
  }


  static double calculateAngleSecond(List<int> a, List<int> b, List<int> c) {
    print("A $a");
    print("B $b");
    print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];


    print("ab----${ab}");
    print("ac-----${ac}");

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;

    print(angleInDegrees);

    return angleInDegrees;
  }


  static double calculateAngleBWUserandPath(UserState user, int node , int cols) {
    List<int> a = [user.showcoordX, user.showcoordY];
    List<int> tval = tools.eightcelltransition(user.theta);
    List<int> b = [user.showcoordX+tval[0], user.showcoordY+tval[1]];
    List<int> c = [node % cols , node ~/cols];

    print("A $a");
    print("B $b");
    print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the cross product of the two vectors
    double crossProduct = ab[0] * ac[1].toDouble() - ab[1] * ac[0].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Check the sign of the cross product to determine the orientation
    if (crossProduct < 0) {
      angleInRadians = 2 * pi - angleInRadians;
    }

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;


    return angleInDegrees;
  }

  static double calculateAngleThird(List<int> a, int node2 , int node3 , int cols) {

    List<int> b = [node2 % cols , node2 ~/cols];
    List<int> c = [node3 % cols , node3 ~/cols];

    print("A $a");
    print("B $b");
    print("C $c");
    // Convert the points to vectors
    List<int> ab = [b[0] - a[0], b[1] - a[1]];
    List<int> ac = [c[0] - a[0], c[1] - a[1]];

    // Calculate the dot product of the two vectors
    double dotProduct = ab[0] * ac[0].toDouble() + ab[1] * ac[1].toDouble();

    // Calculate the cross product of the two vectors
    double crossProduct = ab[0] * ac[1].toDouble() - ab[1] * ac[0].toDouble();

    // Calculate the magnitude of each vector
    double magnitudeAB = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    double magnitudeAC = sqrt(ac[0] * ac[0] + ac[1] * ac[1]);

    // Calculate the cosine of the angle between the two vectors
    double cosineTheta = dotProduct / (magnitudeAB * magnitudeAC);

    // Calculate the angle in radians
    double angleInRadians = acos(cosineTheta);

    // Check the sign of the cross product to determine the orientation
    if (crossProduct < 0) {
      angleInRadians = 2 * pi - angleInRadians;
    }

    // Convert radians to degrees
    double angleInDegrees = angleInRadians * 180 / pi;


    return angleInDegrees;
  }

  static List<Map<String, int>> getDirections(List<int> path, int columns) {
    List<Map<String, int>> directions = [
      {"Straight": 1}
    ];

    for (int i = 1; i < path.length - 1; i++) {
      int prev = path[i - 1];
      int current = path[i];
      int next = path[i + 1];

      // Compare current and next nodes' indices to determine direction

      int prevrow = prev % columns;
      int prevrcol = prev ~/ columns;
      int currrow = current % columns;
      int currcol = current ~/ columns;
      int nextrrow = next % columns;
      int nextrcol = next ~/ columns;

      double angle = calculateAngle(
          [prevrow, prevrcol], [currrow, currcol], [nextrrow, nextrcol]);
      String dir = angleToClocks(angle);
      if (directions.isNotEmpty) {
        if (directions.last.keys.first != dir) {
          Map<String, int> innermap = {dir: 1};
          directions.add(innermap);
        } else {
          directions.last[dir] = directions.last[dir]! + 1;
        }
      } else {
        Map<String, int> innermap = {dir: 1};
        directions.add(innermap);
      }
    }
    String dir = "Straight";
    if (directions.isNotEmpty) {
      if (directions.last.keys.first != dir) {
        Map<String, int> innermap = {dir: 1};
        directions.add(innermap);
      } else {
        directions.last[dir] = directions.last[dir]! + 1;
      }
    } else {
      Map<String, int> innermap = {dir: 1};
      directions.add(innermap);
    }
    return directions;
  }

  static int roundToNextInt(double number) {
    int rounded = number.round();
    return number >= 0 ? rounded : rounded - 1;
  }


  static List<Landmarks> findNearbyLandmark(
      List<int> path,
      Map<String, Landmarks> landmarksMap,
      int distance,
      int numCols,
      int floor) {
    print("called");
    List<Landmarks> nearbyLandmarks = [];
    for (int node in path) {
      landmarksMap.forEach((key, value) {
        if (floor == value.floor) {
          List<int> pCoord = computeCellCoordinates(node, numCols);
          double d = 0.0;
          if (value.doorX == null) {
            d = calculateDistance(
                pCoord, [value.coordinateX!, value.coordinateY!]);
          } else {
            d = calculateDistance(pCoord, [value.doorX!, value.doorY!]);
          }
          if (d < distance) {
            print(value.name);
            print(d);
            if (!nearbyLandmarks.contains(value)) {
              nearbyLandmarks.add(value);
            }
          }
        }
      });
    }
    return nearbyLandmarks;
  }


  static nearestLandInfo localizefindNearbyLandmark(beacon Beacon, Map<String, Landmarks> landmarksMap) {
    print("called");

    PriorityQueue<MapEntry<nearestLandInfo, double>> priorityQueue = PriorityQueue<MapEntry<nearestLandInfo, double>>((a, b) => a.value.compareTo(b.value));
    int distance=10;
    landmarksMap.forEach((key, value) {
      if(Beacon.buildingID == value.buildingID && value.element!.subType != "beacons"){
        if (Beacon.floor! == value.floor) {
          List<int> pCoord = [];
          pCoord.add(Beacon.coordinateX!);
          pCoord.add(Beacon.coordinateY!);
          double d = 0.0;

          if (value.doorX != null) {
            d = calculateDistance(
                pCoord, [value.doorX!, value.doorY!]);
            print("distance b/w beacon and location${d}");
            print(value.name);
            if (d<distance) {
              nearestLandInfo currentLandInfo = nearestLandInfo(value.name!,value.buildingName!,value.venueName!,value.floor!.toString());
              priorityQueue.add(MapEntry(currentLandInfo, d));
            }
          }else{
            d = calculateDistance(
                pCoord, [value.coordinateX!, value.coordinateY!]);
            print("distance b/w beacon and location${d}");
            print(value.name);
            if (d<distance) {
              nearestLandInfo currentLandInfo = nearestLandInfo(value.name??"",value.buildingName??"",value.venueName??"",value.floor.toString());
              priorityQueue.add(MapEntry(currentLandInfo, d));
            }
          }
        }
      }
    });
    nearestLandInfo nearestLandmark=nearestLandInfo("","","","");
    if(priorityQueue.isNotEmpty){
      MapEntry<nearestLandInfo, double> entry = priorityQueue.removeFirst();
      print("entry.key");

      print(entry.key.name);
      nearestLandmark = entry.key;
    }else{
      print("priorityQueue.isEmpty");
    }
    return nearestLandmark;
  }
  static List<int> localizefindNearbyLandmarkCoordinated(beacon Beacon, Map<String, Landmarks> landmarksMap) {

    print("called");

    int distance=10;
    List<int> coordinates=[];
    landmarksMap.forEach((key, value) {
      if (Beacon.buildingID == value.buildingID && value.element!.subType != "beacons") {
        List<int> pCoord = [];
        pCoord.add(Beacon.coordinateX!);
        pCoord.add(Beacon.coordinateY!);
        double d = 0.0;
        if (value.doorX != null) {
          d = calculateDistance(pCoord, [value.doorX!, value.doorY!]);
          if (d<distance) {
            coordinates.add(value.doorX!);
            coordinates.add(value.doorY!);
          }
        }else{
          d = calculateDistance(pCoord, [value.coordinateX!, value.coordinateY!]);
          if (d<distance) {
            coordinates.add(value.coordinateX!);
            coordinates.add(value.coordinateY!);
          }
        }
      }
    });

    return coordinates;
  }

  static List<int> computeCellCoordinates(int node, int numCols) {
    int row = (node % numCols);
    int col = (node ~/ numCols);
    return [row, col];
  }

  static double calculateDistance(List<int> p1, List<int> p2) {
    return sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2));
  }

  static double angleBetweenBuildingAndNorth() {
    // Assuming corners is a list of Point objects representing coordinates of the building corners

    // Choose two adjacent corners
    Point<double> corner1 = corners[0];
    Point<double> corner2 = corners[1];

    // Calculate the slope
    double slope = (corner2.y - corner1.y) / (corner2.x - corner1.x);

    // Calculate the angle in radians
    double angleRad = atan(slope);

    // Convert angle to degrees
    double angleDeg = angleRad * (180 / pi);

    // Adjust for the correct quadrant
    if (angleDeg < 0) {
      angleDeg += 360;
    }

    AngleBetweenBuildingandGlobalNorth = angleDeg;
    return angleDeg;
  }

  static List<int> eightcelltransition(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }
    print("angleee-----${angle}");
    print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;

    if (angle >= 337.5 || angle <= 22.5) {
      return [0, -1];
    } else if (angle > 22.5 && angle <= 67.5) {
      return [1, -1];
    } else if (angle > 67.5 && angle <= 112.5) {
      return [1, 0];
    } else if (angle > 112.5 && angle <= 157.5) {
      return [1, 1];
    } else if (angle > 157.5 && angle <= 202.5) {
      return [0, 1];
    } else if (angle > 202.5 && angle <= 247.5) {
      return [-1, 1];
    } else if (angle > 247.5 && angle <= 292.5) {
      return [-1, 0];
    } else if (angle > 292.5 && angle <= 337.5) {
      return [-1, -1];
    } else {
      return [0, 0];
    }
  }


  static List<int> fourcelltransition(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }
    print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle >= 315 || angle <= 45) {
      return [0, -1];
    } else if (angle > 45 && angle <= 135) {
      return [1, 0];
    } else if (angle > 135 && angle <= 225) {
      return [0,1];
    } else if (angle > 225 && angle <= 315) {
      return [-1 , 0];
    } else {
      return [0, 0];
    }
  }


  static List<int> twocelltransitionvertical(double angle) {
    if (angle < 0) {
      angle = angle + 360;
    }
    print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle >= 270 || angle <= 90) {
      return [0, -1];
    } else if (angle > 90 && angle <= 270) {
      return [0,1];
    } else {
      return [0, 0];
    }
  }

  static List<int> twocelltransitionhorizontal(double angle) {
    print("first $angle");
    if (angle < 0) {
      angle = angle + 360;
    }
    print("second $angle");
    print(AngleBetweenBuildingandGlobalNorth);
    angle = angle - AngleBetweenBuildingandGlobalNorth;
    if (angle > 180 && angle <= 360) {
      return [-1,0];
    } else if (angle > 0 && angle <= 180) {
      return [1,0];
    } else {
      return [0, 0];
    }
  }


  static List<int> getTurnpoints(List<int> pathNodes,int numCols){
    List<int> res=[];



    for(int i=1;i<pathNodes.length-1;i++){



      int currPos = pathNodes[i];
      int nextPos=pathNodes[i+1];
      int prevPos=pathNodes[i-1];

      int x1 = (currPos % numCols);
      int y1 = (currPos ~/ numCols);

      int x2 = (nextPos % numCols);
      int y2 = (nextPos ~/ numCols);

      int x3 = (prevPos % numCols);
      int y3 = (prevPos ~/ numCols);

      int prevDeltaX=x1-x3;
      int prevDeltaY=y1-y3;
      int nextDeltaX=x2-x1;
      int nextDeltaY=y2-y1;

      if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){
        if(prevDeltaX==0 && nextDeltaX==0){

        }else if(prevDeltaY==0 && nextDeltaY==0){

        }else{
          res.add(currPos);
        }

      }



    }
    return res;
  }

  static List<Cell> getCellTurnpoints(List<Cell> pathNodes,int numCols){
    List<Cell> res=[];



    for(int i=1;i<pathNodes.length-1;i++){



      Cell currPos = pathNodes[i];
      Cell nextPos=pathNodes[i+1];
      Cell prevPos=pathNodes[i-1];


      int prevDeltaX=currPos.x-prevPos.x;
      int prevDeltaY=currPos.y-prevPos.y;
      int nextDeltaX=nextPos.x-currPos.x;
      int nextDeltaY=nextPos.y-currPos.y;

      if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){
        if(prevDeltaX==0 && nextDeltaX==0){

        }else if(prevDeltaY==0 && nextDeltaY==0){

        }else{
          res.add(currPos);
        }

      }



    }
    return res;
  }

  static List<int> generateCompletePath(List<int> turns, int numCols) {
    List<int> completePath = [];

    // Start with the first point in your path
    int currentPoint = turns[0];
    int x = currentPoint % numCols;
    int y = currentPoint ~/ numCols;
    completePath.add(x+y*numCols);

    // Connect each turn point with a straight line
    for (int i = 1; i < turns.length; i++) {
      int turnPoint = turns[i];
      int turnX = turnPoint % numCols;
      int turnY = turnPoint ~/ numCols;

      // Connect straight line from current point to turn point
      while (x != turnX || y != turnY) {
        if (x < turnX) {
          x++;
        } else if (x > turnX) {
          x--;
        }
        if (y < turnY) {
          y++;
        } else if (y > turnY) {
          y--;
        }
        completePath.add(x+y*numCols);
      }
    }

    return completePath;
  }
  static Map<int,int> getTurnMap(List<int> pathNodes,int numCols){
    Map<int,int> res=new Map();



    for(int i=1;i<pathNodes.length-1;i++){



      int currPos = pathNodes[i];
      int nextPos=pathNodes[i+1];
      int prevPos=pathNodes[i-1];

      int x1 = (currPos % numCols);
      int y1 = (currPos ~/ numCols);

      int x2 = (nextPos % numCols);
      int y2 = (nextPos ~/ numCols);

      int x3 = (prevPos % numCols);
      int y3 = (prevPos ~/ numCols);

      int prevDeltaX=x1-x3;
      int prevDeltaY=y1-y3;
      int nextDeltaX=x2-x1;
      int nextDeltaY=y2-y1;

      if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){

        if(prevDeltaX==0 && nextDeltaX==0){

        }else if(prevDeltaY==0 && nextDeltaY==0){

        }else{
          res[i]=currPos;
        }

      }



    }
    return res;
  }

  static int distancebetweennodes(int node1, int node2, int numCols){
    int x1 = node1 % numCols;
    int y1 = node1 ~/ numCols;

    int x2 = node2 % numCols;
    int y2 = node2 ~/ numCols;

    // print("@@@@@ $x1,$y1");
    // print("&&&&& $x2,$y2");
    int rowDifference = x2 - x1;
    int colDifference = y2 - y1;
    return sqrt(rowDifference * rowDifference + colDifference * colDifference).toInt();
  }

  static bool allElementsAreSame(List list) {
    if (list.isEmpty) return true;  // Consider an empty list as having all elements the same.
    var first = list.first;
    for (var element in list) {
      if (element > first) {
        return false;
      }
    }
    return true;
  }

}
class nearestLandInfo{
  String name;
  String buildingName;
  String venuename;
  String floor;
  nearestLandInfo( this.name, this.buildingName, this.venuename,this.floor);
}
