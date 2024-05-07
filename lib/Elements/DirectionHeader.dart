import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iwayplusnav/Elements/HelperClass.dart';

import 'package:iwayplusnav/navigationTools.dart';

import '../UserState.dart';
import '../bluetooth_scanning.dart';
import '../buildingState.dart';


class DirectionHeader extends StatefulWidget {
  String direction;
  int distance;
  bool isRelocalize;
  UserState user;
  String getSemanticValue;
  final Function(String nearestBeacon) paint;
  final Function(String nearestBeacon) repaint;
  final Function() reroute;
  final Function() moveUser;
  final Function() closeNavigation;


  DirectionHeader({this.distance = 0, required this.user , this.direction = "", required this.paint, required this.repaint, required this.reroute, required this.moveUser, required this.closeNavigation,required this.isRelocalize,this.getSemanticValue=''}){
    try{
      double angle = tools.calculateAngleBWUserandCellPath(
          user, user.Cellpath[1], user.pathobj.numCols![user.Bid]![user.floor]!);
      direction = tools.angleToClocks(angle);
      if(direction == "Straight"){
        direction = "Go Straight";
      }else{
        direction = "Turn ${direction}, and Go Straight";
      }
    }catch(e){

    }
  }

  @override
  State<DirectionHeader> createState() => _DirectionHeaderState();
}

class _DirectionHeaderState extends State<DirectionHeader> {
  List<int> turnPoints = [];
  BT btadapter = new BT();
  late Timer _timer;


  Map<String, double> ShowsumMap = Map();
  
  @override
  void initState() {
    super.initState();

    btadapter.emptyBin();
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if(btadapter.BIN[i]!.isNotEmpty){
        btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }
    btadapter.numberOfSample.clear();
    btadapter.rs.clear();
    Building.thresh = "";

    widget.getSemanticValue="";
    if(widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor] != null){
      turnPoints = tools.getTurnpoints(widget.user.path, widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
      print("direction header:: ${turnPoints}");
      print(widget.user.path.length);
      (widget.user.path.length%2==0)? turnPoints.add(widget.user.path[widget.user.path.length-2]):turnPoints.add(widget.user.path[widget.user.path.length-1]);
      btadapter.startScanning(Building.apibeaconmap);
      _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
        print("Pathposition");
      print(widget.user.path);

        // print("listen to bin :${listenToBin()}");

        // HelperClass.showToast("Bin cleared");
        if(widget.user.pathobj.index>3) {
          listenToBin();
        }



      });
      List<int> remainingPath = widget.user.path.sublist(widget.user.pathobj.index);
      int nextTurn = findNextTurn(turnPoints, remainingPath);
      widget.distance = tools.distancebetweennodes(nextTurn, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
      double angle = 0.0;
      if(widget.user.pathobj.index<widget.user.path.length-1){
        angle = tools.calculateAngleBWUserandPath(widget.user, widget.user.path[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
      }

      print("angleeeeee $angle")  ;
      setState(() {
        widget.direction = tools.angleToClocks(angle);
        if(widget.direction == "Straight"){
          widget.direction = "Go Straight";
          
          speak("Go Straight ${widget.distance} meter");
        }else{
          widget.direction = "Turn ${widget.direction}, and Go Straight";
         
          speak("${widget.direction} ${(widget.distance/2).toInt()} steps");
          widget.getSemanticValue="${widget.direction} ${(widget.distance/2).toInt()} steps";
        }
      });

    }


  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String getgetSemanticValue(){
    return widget.getSemanticValue;
  }


  String debugNearestbeacon="";
  Map<String, double> sortedsumMap={};

  bool listenToBin(){
    double highestweight = 0;
    String nearestBeacon = "";
    Map<String, double> sumMap = btadapter.calculateAverage();

    sortedsumMap = HelperClass().sortMapByValue(sumMap);
    setState(() {
      ShowsumMap = HelperClass().sortMapByValue(sortedsumMap);
    });
    nearestBeacon = sortedsumMap.entries.first.key;
    highestweight = sortedsumMap.entries.first.value;

    // print("-90---   ${sumMap.length}");
    // print("checkingavgmap   ${sumMap}");
    widget.direction = "";


    // for (int i = 0; i < btadapter.BIN.length; i++) {
    //   if (btadapter.BIN[i]!.isNotEmpty) {
    //
    //     btadapter.BIN[i]!.forEach((key, value) {
    //       print("Wilsonchecker");
    //       print(value.toString());
    //       print(key);
    //
    //       setState(() {
    //             widget.direction = "${widget.direction}$key   $value\n";
    //           });
    //
    //       print("-90-   $key   $value");
    //
    //       if (value > highestweight) {
    //         highestweight = value;
    //         //nearestBeacon = key;
    //       }
    //     });
    //     break;
    //   }
    // }

    // btadapter.emptyBin();
    //

    // sortedsumMap.forEach((key, value) {
    //
    //   setState(() {
    //     widget.direction = "${widget.direction}$key   $value\n";
    //   });
    //
    //   print("-90-   $key   $value");
    //
    //   if(value>highestweight){
    //     highestweight =  value;
    //     nearestBeacon = key;
    //   }
    // });
    setState(() {
      debugNearestbeacon = nearestBeacon;
    });

    //print("$nearestBeacon   $highestweight");


    if(nearestBeacon !=""){
      if(widget.user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null){
        if(widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId){
          if(widget.user.floor == Building.apibeaconmap[nearestBeacon]!.floor  && highestweight >=1.2){
            print("workingg user floor ${widget.user.floor}");
            List<int> beaconcoord = [Building.apibeaconmap[nearestBeacon]!.coordinateX!,Building.apibeaconmap[nearestBeacon]!.coordinateY!];
            List<int> usercoord = [widget.user.showcoordX, widget.user.showcoordY];
            double d = tools.calculateDistance(beaconcoord, usercoord);
            if(d < 5){

              print("workingg 1");
              //near to user so nothing to do
              return true;
            }else{
              print("workingg 2");
              int distanceFromPath = 100000000;
              int? indexOnPath = null;
              int numCols = widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!;
              widget.user.path.forEach((node) {
                List<int> pathcoord = [node % numCols, node ~/ numCols];
                double d1 = tools.calculateDistance(beaconcoord, pathcoord);
                if(d1<distanceFromPath){
                  distanceFromPath = d1.toInt();
                  print("node on path $node");
                  print("distanceFromPath $distanceFromPath");
                  indexOnPath = widget.user.path.indexOf(node);
                  print(indexOnPath);
                }
              });

              if(distanceFromPath>10){
                print("workingg 3");
                _timer.cancel();
                widget.repaint(nearestBeacon);
                widget.reroute;
                return false;//away from path
              }else{
                print("workingg 4");
                widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
              
                speak("You are near ${Building.apibeaconmap[nearestBeacon]!.name}");
                widget.user.moveToPointOnPath(indexOnPath!);
                widget.moveUser();
                return true; //moved on path
              }
            }


            print("d $d");
            print("widget.user.key ${widget.user.key}");
            print("beaconcoord ${beaconcoord}");
            print("usercoord ${usercoord}");
            print(nearestBeacon);
          }else{
            print("workingg 5");
            speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor");
            widget.paint(nearestBeacon); //different floor
            return true;
          }

        }
      }else{
        print("workingg 6");
        print("listening");

        print(nearestBeacon);
        _timer.cancel();
        widget.repaint(nearestBeacon);
        widget.reroute;
        return false;
      }
    }
    // btadapter.emptyBin();
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }

    return false;
  }



  FlutterTts flutterTts = FlutterTts() ;
  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  int findNextTurn(List<int> turns, List<int> path) {
    // Iterate through the sorted list
    for (int i = 0; i < path.length; i++) {
      for(int j = 0; j< turns.length; j++){
        if(path[i] == turns[j]){
          return path[i];
        }
      }
    }

    // If no number is greater than the target, return null
    if(path.length >= widget.user.pathobj.index){
      return path[widget.user.pathobj.index];
    }else{
      return 0;
    }
  }

  @override
  void didUpdateWidget(DirectionHeader oldWidget){
    super.didUpdateWidget(oldWidget);

    print("direction header pointss");

    print(widget.user.path[widget.user.pathobj.index]);
    print(turnPoints.last);
    if(widget.user.path[widget.user.pathobj.index] == turnPoints.last){

      speak("You have reached ${widget.user.pathobj.destinationName}");
      widget.closeNavigation();
    }else{
      widget.user.pathobj.connections.forEach((key, value) {
        value.forEach((inkey, invalue) {
          if(widget.user.path[widget.user.pathobj.index] == invalue){
            widget.direction = "You have reached ";
          }
        });
      });




      List<int> remainingPath = widget.user.path.sublist(widget.user.pathobj.index+1);
      int nextTurn = findNextTurn(turnPoints, remainingPath);
      widget.distance = tools.distancebetweennodes(nextTurn, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);

      double angle = tools.calculateAngleBWUserandCellPath(widget.user, widget.user.Cellpath[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
      widget.direction = tools.angleToClocks(angle);
      if(widget.direction == "Straight"){
        widget.direction = "Go Straight";
      }else{
        widget.direction = "Turn ${widget.direction}, and Go Straight";
      }

      if(nextTurn == turnPoints.last && widget.distance == 5){
        double angle = tools.calculateAngleThird([widget.user.pathobj.destinationX,widget.user.pathobj.destinationY], widget.user.path[widget.user.pathobj.index+1], widget.user.path[widget.user.pathobj.index+2], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
        speak("${widget.direction} ${widget.distance} steps. ${widget.user.pathobj.destinationName} will be ${tools.angleToClocks2(angle)}");
      }

      if(oldWidget.direction != widget.direction){

        if(oldWidget.direction == "Go Straight"){

         // Vibration.vibrate();


          // if(nextTurn == turnPoints.last){
          //   speak("${widget.direction} ${widget.distance} meter then you will reach ${widget.user.pathobj.destinationName}");
          // }else{
          //   speak("${widget.direction} ${widget.distance} meter");
          // }

          speak("${widget.direction} ${(widget.distance/2).toInt()} steps");

        }else if(widget.direction == "Go Straight"){



          //Vibration.vibrate();

          speak("Go Straight ${(widget.distance/2).toInt()} steps");
        }
      }
    }

  }

  Icon getCustomIcon(String direction) {
    if(direction == "Go Straight"){
      return Icon(
        Icons.straight,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Slight Right, and Go Straight"){
      return Icon(
        Icons.turn_slight_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Right, and Go Straight"){
      return Icon(
        Icons.turn_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Sharp Right, and Go Straight"){
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn U Turn, and Go Straight"){
      return Icon(
        Icons.u_turn_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Sharp Left, and Go Straight"){
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Left, and Go Straight"){
      return Icon(
        Icons.turn_left,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Slight Left, and Go Straight"){
      return Icon(
        Icons.turn_slight_left,
        color: Colors.black,
        size: 32,
      );
    }else{
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.black,
        size: 32,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
            height: 95,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xff01544F),
              border: Border.all(
                color: Color(0xff01544F),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.direction}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,

                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(

                          '${(widget.distance/2).toInt()} steps',
                          style: TextStyle(

                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,

                          ),
                        ),

                      ],
                    ),

                    Spacer(),
                    // Text("$c"),
                    // Text("$d",style: TextStyle(
                    //   color: Colors.red
                    // ),),
                    // ElevatedButton(onPressed: (){
                    //   _timer.cancel();
                    //   _timer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
                    //   c++;
                    //   listenToBin();
                    //
                    // });}, child: Icon(Icons.start))




                  ],
                ),

              ],
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Container(
            width: 300,
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ShowsumMap.toString()),
                  Text(ShowsumMap.values.toString()),
                  Text(debugNearestbeacon.toString()),
                  Text("current idx"+widget.user.pathobj.index.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Positioned(
//     top: 13,
//     right: 15,
//     child: IconButton(
//         onPressed: () {
//           showMarkers();
//           _isBuildingPannelOpen = true;
//           _isRoutePanelOpen = false;
//           selectedroomMarker.clear();
//           pathMarkers.clear();
//           building.selectedLandmarkID = null;
//           PathState = pathState.withValues(
//               -1, -1, -1, -1, -1, -1, null, 0);
//           PathState.path.clear();
//           PathState.sourcePolyID = "";
//           PathState.destinationPolyID = "";
//           PathState.sourceBid = "";
//           PathState.destinationBid = "";
//           singleroute.clear();
//           PathState.directions = [];
//           interBuildingPath.clear();
//           fitPolygonInScreen(patch.first);
//         },
//         icon: Icon(
//           Icons.cancel_outlined,
//           size: 25,
//         )))