import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
      double angle = tools.calculateAngleBWUserandPath(
          user, user.path[1], user.pathobj.numCols![user.Bid]![user.floor]!);
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
  BT2 btadapter = new BT2();
  late Timer _timer;
  int c = 0;
  int d = 0;
  @override
  void initState() {
    super.initState();
    widget.getSemanticValue="";
    if(widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor] != null){
      turnPoints = tools.getTurnpoints(widget.user.path, widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
      turnPoints.add(widget.user.path.last);
      btadapter.startScanning(Building.apibeaconmap);
      _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
        c++;
        // print("listen to bin :${listenToBin()}");
        listenToBin();

      });
      List<int> remainingPath = widget.user.path.sublist(widget.user.pathobj.index);
      int nextTurn = findNextTurn(turnPoints, remainingPath);
      widget.distance = tools.distancebetweennodes(nextTurn, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
      double angle = tools.calculateAngleBWUserandPath(widget.user, widget.user.path[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
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

  bool listenToBin(){
    double highestweight = 0;
    String nearestBeacon = "";
    Map<String, double> sumMap = btadapter.calculateAverage();
    print("-90-   ${sumMap.length}");
    widget.direction = "";

    btadapter.emptyBin();
    d++;
    sumMap.forEach((key, value) {

      setState(() {
        widget.direction = "${widget.direction}$key   $value\n";
      });

      print("-90-   $key   $value");

      if(value>highestweight){
        highestweight =  value;
        nearestBeacon = key;
      }
    });

    //print("$nearestBeacon   $highestweight");


    if(nearestBeacon !=""){

      if(widget.user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null){
        if(widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId){

          if(widget.user.floor == Building.apibeaconmap[nearestBeacon]!.floor  && highestweight >9){
            List<int> beaconcoord = [Building.apibeaconmap[nearestBeacon]!.coordinateX!,Building.apibeaconmap[nearestBeacon]!.coordinateY!];
            List<int> usercoord = [widget.user.showcoordX, widget.user.showcoordY];
            double d = tools.calculateDistance(beaconcoord, usercoord);
            if(d < 5){
              //near to user so nothing to do
              return true;
            }else{
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

              if(distanceFromPath>5){
                _timer.cancel();
                widget.repaint(nearestBeacon);
                return false;//away from path
              }else{
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
           
            speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor");
            widget.paint(nearestBeacon); //different floor
            return true;
          }

        }
      }else{
        print("listening");

        print(nearestBeacon);
        _timer.cancel();
        widget.repaint(nearestBeacon);
        return false;
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

      double angle = tools.calculateAngleBWUserandPath(widget.user, widget.user.path[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
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
      child: Container(
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

                Container(

                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(28.0),
                    ),

                    child: getCustomIcon(widget.direction)),

              ],
            ),


          ],
        ),
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