// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwaymaps/NAVIGATION/Cell.dart';
import 'package:iwaymaps/NAVIGATION/UserState.dart';
import 'package:iwaymaps/NAVIGATION/buildingState.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {


  });

  test{
    UserState userState = UserState(floor: 3, coordX: 67, coordY: 32, lat: 28.543578388081446, lng: 77.18750628051568, theta: -96.47811591334427);
    userState.path = [7491,7756,8021,8286,8551,8550,8549,8548,8547,8546,8545,8544,8543,8542,8541,8540,8539,8538,8537,8536,8535,8534,8533,8532,8531,8530,8529,8528,8527,8526,8525,8524,8523,8522,8521,8520,8519,8518,8517,8516,8515,8514,8513,8512,8511,8510,8509,8508,8507,8506,8505,8504,8503,8502,8501,8500,8499,8234,7969,7704,7439];
    userState.pathobj.path = {3:[7491, 7756, 8021, 8286, 8551, 8550, 8549, 8548, 8547, 8546, 8545, 8544, 8543, 8542, 8541, 8540, 8539, 8538, 8537, 8536, 8535, 8534, 8533, 8532, 8531, 8530, 8529, 8528, 8527, 8526, 8525, 8524, 8523, 8522, 8521, 8520, 8519, 8518, 8517, 8516, 8515, 8514, 8513, 8512, 8511, 8510, 8509, 8508, 8507, 8506, 8505, 8504, 8503, 8502, 8501, 8500, 8499, 8234, 7969, 7704, 7439]};

    Cell cell = Cell(node:8234,"x":19,"y":31,"lat":28.543636413649228,"lng":77.18737200470886,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null);
    Cell cell = Cell(8234, 19, 31,(double angle, {int? currPointer, int? totalCells}) {
      // Implement your logic here for the move function
      print('Moving with angle: $angle');
      // You can use currPointer and totalCells if needed
    }, 28.543636413649228,77.18737200470886, "65d887a5db333f89457145f6", 3, 265);
    String nearestBeacon = "";
    if (nearestBeacon != "") {
      if (userState.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null) {
        int beaconCoordinateX = Building.apibeaconmap[nearestBeacon]!.coordinateX!;
        int beaconCoordinateY = Building.apibeaconmap[nearestBeacon]!.coordinateY!;
        List<int> beaconcoord = [beaconCoordinateX,beaconCoordinateY];

        if (widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId) {
          if (widget.user.floor != widget.user.pathobj.destinationFloor && widget.user.pathobj.destinationFloor != widget.user.pathobj.sourceFloor && widget.user.pathobj.destinationFloor == Building.apibeaconmap[nearestBeacon]!.floor) {
            int distanceFromPath = 100000000;
            widget.user.cellPath.forEach((node) {
              if (node.floor == Building.apibeaconmap[nearestBeacon]!.floor || node.bid == Building.apibeaconmap[nearestBeacon]!.buildingID) {
                List<int> pathcoord = [node.x, node.y];
                double d1 = tools.calculateDistance(beaconcoord, pathcoord);
                if (d1 < distanceFromPath) {
                  distanceFromPath = d1.toInt();
                }
              }
            });

            if (distanceFromPath > 25) {
              setEssentialsForReroute(nearestBeacon);
              return false; //away from path
            } else {
              reacedDestinationEssentials(nearestBeacon);
              return true;
            }
          } else if (widget.user.floor == Building.apibeaconmap[nearestBeacon]!.floor && candorThreshold >= highestweight) {
            widget.user.onConnection = false;

            int distanceFromPath = 100000000;
            int? indexOnPath = null;
            List<double> newPoint = [];
            if (widget.user.bid == buildingAllApi.outdoorID) {
              List<double> beaconLatLng = tools.localtoglobal(beaconcoord[0], beaconcoord[1], SingletonFunctionController.building.patchData[Building.apibeaconmap[nearestBeacon]!.buildingID!]);
              List<Cell> nearPoints = findTwoNearestPoints(beaconLatLng, widget.user.cellPath, widget.user.bid);

              newPoint = projectCellOntoSegment(beaconLatLng, nearPoints[0], nearPoints[1], widget.user.pathobj.numCols![widget.user.bid]![Building.apibeaconmap[nearestBeacon]!.floor]!);

              List<int> np = tools.findLocalCoordinates(nearPoints[0], nearPoints[1], newPoint);
              Cell point = Cell((np[1] * nearPoints[0].numCols) + np[0], np[0], np[1], tools.eightcelltransition, newPoint[0], newPoint[1], nearPoints[0].bid, nearPoints[0].floor, nearPoints[0].numCols);

              indexOnPath = insertProjectedPoint(widget.user.cellPath, point);
              widget.user.path.insert(indexOnPath, point.node);
              widget.user.cellPath.insert(indexOnPath, Cell(point.node, point.x, point.y, tools.eightcelltransition, point.lat, point.lng, buildingAllApi.outdoorID, point.floor, point.numCols, imaginedCell: true));

            } else {
              widget.user.cellPath.forEach((node) {
                List<int> pathcoord = [node.x, node.y];
                double d1 = tools.calculateDistance(beaconcoord, pathcoord);
                if (d1 < distanceFromPath) {
                  distanceFromPath = d1.toInt();
                  indexOnPath = widget.user.path.indexOf(node.node);
                }
              });
            }
            if (distanceFromPath > 25) {
              setEssentialsForReroute(nearestBeacon);
              return false; //away from path
            } else {
              moveOnPathEssentials(nearestBeacon,indexOnPath);
              return true; //moved on path
            }
          }
        }
      }else{
        if ((double.parse(threshold!) >= highestweight)){
          _timer.cancel();
          widget.repaint(nearestBeacon);
          widget.reroute;
        }
        return false;
      }
    }

  }
}
