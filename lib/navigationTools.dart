import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/patchDataModel.dart' as PDM;
import 'API/PatchApi.dart';
import 'APIMODELS/patchDataModel.dart';

class tools{

  static List<PDM.Coordinates>? _cachedCordData;

  static patchDataModel Data = patchDataModel();

  static Future<void> fetchData() async {
    await patchAPI().fetchPatchData().then((value){
      _cachedCordData = value.patchData!.coordinates;
    });
  }

  static  LatLng calculateRoomCenterinLatLng(List<LatLng> roomCoordinates) {
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

  static  List<double> calculateRoomCenterinList(List<LatLng> roomCoordinates) {
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

  static List<double> localtoglobal(int x, int y,){

    int floor = 0;

    List<double> diff = [0,0,0,];


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
    double dist = distance(ref[leastLat], localRef) * 0.3048; // to convert to meter

    double ver = dist * sin(ang * pi / 180.0);
    double hor = dist * cos(ang * pi / 180.0);

    Map<String, double> finalCoords = obtainCoordinates(ref[leastLat], ver, hor);

    return [finalCoords["lat"]!, finalCoords["lon"]!];
  }

  static double getHaversineDistance(Map<String, double> firstLocation, Map<String, double> secondLocation) {
    const earthRadius = 6371; // km
    double diffLat = ((secondLocation["lat"]! - firstLocation["lat"]!) * pi) / 180;
    double difflon = ((secondLocation["lon"]! - firstLocation["lon"]!) * pi) / 180;
    double arc = cos((firstLocation["lat"]! * pi) / 180) *
        cos((secondLocation["lat"]! * pi) / 180) *
        sin(difflon / 2) *
        sin(difflon / 2) +
        sin(diffLat / 2) * sin(diffLat / 2);
    double line = 2 * atan2(sqrt(arc), sqrt(1 - arc));
    double distance = earthRadius * line * 1000;
    return distance;
  }

  static Map<String, double> obtainCoordinates(Map<String, double> reference, double vertical, double horizontal) {
    const double R = 6378137; // Earth’s radius, sphere
    double dLat = vertical / R;
    double dLon = horizontal / (R * cos((pi * reference["lat"]!) / 180));
    double latA = reference["lat"]! + (dLat * 180) / pi;
    double lonA = reference["lon"]! + (dLon * 180) / pi;
    return {"lat": latA, "lon": lonA};
  }

  static double distance(Map<String, double> first, Map<String, double> second) {
    double dist1 = pow((second["localy"]! - first["localy"]!), 2) as double ;
    double dist2 = pow((second["localx"]! - first["localx"]!), 2) as double ;
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
  
  static double calculateAngle(List<int> a, List<int> b, List<int> c) {
    double angle1 = atan2(b[1] - a[1], b[0] - a[0]);
    double angle2 = atan2(c[1] - b[1], c[0] - b[0]);

    double angle = (angle2 - angle1) * 180 / pi;

    if (angle < 0) {
      angle += 360;
    }

    return angle;
  }
  static List<Map<String,int>> getDirections(List<int> path,int columns) {
    List<Map<String,int>> directions = [{"Straight":1}];

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

      double angle = calculateAngle([prevrow,prevrcol],[currrow,currcol],[nextrrow,nextrcol]);
      String dir = angleToClocks(angle);
      if(directions.isNotEmpty){
        if(directions.last.keys.first != dir){
          Map<String,int> innermap = {dir:1};
          directions.add(innermap);
        }else{
          directions.last[dir]  = directions.last[dir]! + 1;
        }
      }else{
        Map<String,int> innermap = {dir:1};
        directions.add(innermap);
      }
    }
    String dir = "Straight";
    if(directions.isNotEmpty){
      if(directions.last.keys.first != dir){
        Map<String,int> innermap = {dir:1};
        directions.add(innermap);
      }else{
        directions.last[dir]  = directions.last[dir]! + 1;
      }
    }else{
      Map<String,int> innermap = {dir:1};
      directions.add(innermap);
    }
    return directions;
  }

  static List<Landmarks> findNearbyLandmark(List<int>path, Map<String, Landmarks> landmarksMap, int distance, int numCols, int floor){
    print("called");
    List<Landmarks> nearbyLandmarks = [];
    for(int node in path){
      landmarksMap.forEach((key, value) {
        if(floor == value.floor){
          List<int> pCoord = computeCellCoordinates(node, numCols);
          double d = 0.0;
          if(value.doorX == null){
            d = calculateDistance(pCoord, [value.coordinateX!,value.coordinateY!]);
          }else{
            d = calculateDistance(pCoord, [value.doorX!,value.doorY!]);
          }
          if(d<distance){
            if(!nearbyLandmarks.contains(value)){
              nearbyLandmarks.add(value);
            }
          }
        }
      });
    }
    return nearbyLandmarks;
  }

  static List<int> computeCellCoordinates(int node, int numCols) {
    int row = (node % numCols);
    int col = (node ~/ numCols);
    return [row,col];
  }

  static double calculateDistance(List<int> p1 , List<int> p2) {
    return sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2));
  }


}