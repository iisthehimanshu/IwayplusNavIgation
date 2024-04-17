import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:iwayplusnav/navigationTools.dart';

import '../UserState.dart';
import '../bluetooth_scanning.dart';
import '../buildingState.dart';


class DirectionHeader extends StatefulWidget {
  String direction;
  int distance;
  UserState user;
  final Function(String nearestBeacon) paint;
  final Function(String nearestBeacon) repaint;
  final Function() reroute;
  final Function() moveUser;


  DirectionHeader({this.distance = 0, required this.user , this.direction = "", required this.paint, required this.repaint, required this.reroute, required this.moveUser}){
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
  BT btadapter = new BT();
  late Timer _timer;
  bool intialized = false;
  @override
  void initState() {
    super.initState();
    if(!intialized){
      if(widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor] != null){
        turnPoints = tools.getTurnpoints(widget.user.path, widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
        turnPoints.sort();
        btadapter.startScanning(Building.apibeaconmap);
        _timer = Timer.periodic(Duration(milliseconds: 9000), (timer) {
          listenToBin();
        });
        intialized = !intialized;
      }
    }


  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void listenToBin(){
    print("listentobin");
    double highestweight = 0;
    String nearestBeacon = "";
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if (btadapter.BIN[i]!.isNotEmpty) {
        btadapter.BIN[i]!.forEach((key, value) {
          if (value > highestweight) {
            highestweight = value;
            nearestBeacon = key;
          }
        });
        break;
      }
    }
    if(widget.user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null){
      if(widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId){

        if(widget.user.floor == Building.apibeaconmap[nearestBeacon]!.floor){
          List<int> beaconcoord = [Building.apibeaconmap[nearestBeacon]!.coordinateX!,Building.apibeaconmap[nearestBeacon]!.coordinateY!];
          List<int> usercoord = [widget.user.showcoordX, widget.user.showcoordY];
          double d = tools.calculateDistance(beaconcoord, usercoord);
          if(d < 5){
            //near to user so nothing to do
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
              widget.repaint(nearestBeacon);   //away from path
            }else{
              widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
              widget.user.moveToPointOnPath(indexOnPath!);
              widget.moveUser();                                 //moved on path
            }
          }


          print("d $d");
          print("widget.user.key ${widget.user.key}");
          print("beaconcoord ${beaconcoord}");
          print("usercoord ${usercoord}");
          print(nearestBeacon);
        }else{
          widget.paint(nearestBeacon); //different floor
        }

      }
    }else{
      print("listening");
      print(nearestBeacon);
      _timer.cancel();
      widget.repaint(nearestBeacon);
    }


  }



  FlutterTts flutterTts = FlutterTts() ;
  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }

  int findNextGreater(List<int> numbers, int target) {
    // Iterate through the sorted list
    for (int i = 0; i < numbers.length; i++) {
      // If the current number is greater than the target, return it
      if (numbers[i] > target) {
        return numbers[i];
      }
    }

    // If no number is greater than the target, return null
    return target;
  }

  @override
  void didUpdateWidget(DirectionHeader oldWidget){
    super.didUpdateWidget(oldWidget);
    // int nextTurn = findNextGreater(turnPoints, widget.user.path[widget.user.pathobj.index]);
    // widget.distance = tools.distancebetweennodes(nextTurn, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
    // double angle = tools.calculateAngleBWUserandPath(widget.user, widget.user.path[widget.user.pathobj.index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
    // if(!angle.isNaN){
    //   widget.direction = tools.angleToClocks(angle);
    //   if(widget.direction == "Straight"){
    //     widget.direction = "Go Straight";
    //   }else{
    //     widget.direction = "Turn ${widget.direction}, and Go Straight";
    //   }
    //   if(oldWidget.direction != widget.direction){
    //
    //     if(oldWidget.direction == "Go Straight"){
    //
    //       Vibration.vibrate();
    //       speak("${widget.direction} ${widget.distance} meter");
    //
    //     }else if(widget.direction == "Go Straight"){
    //
    //       Vibration.vibrate();
    //       speak("Go Straight ${widget.distance} meter");
    //     }
    //   }
    // }else{
    //
    // }
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
    return Container(
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
                    widget.direction,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,

                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(

                    '${widget.distance} m',
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
    );
  }
}