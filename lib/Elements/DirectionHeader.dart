import 'dart:async';
import 'dart:io';


import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';

import 'package:iwaymaps/navigationTools.dart';
import 'package:vibration/vibration.dart';

import '../Cell.dart';
import '../UserState.dart';
import '../bluetooth_scanning.dart';
import '../buildingState.dart';
import '../directionClass.dart';
import '../directionClass.dart' as dc;
import '../directionClass.dart';
import '../Navigation.dart';
import 'UserCredential.dart';
import 'locales.dart';


class DirectionHeader extends StatefulWidget {
  String direction;
  int distance;
  bool isRelocalize;
  UserState user;
  String getSemanticValue;
  BuildContext context;
  final Function(String nearestBeacon, {bool render}) paint;
  final Function(String nearestBeacon) repaint;
  final Function() reroute;
  final Function() moveUser;
  final Function() closeNavigation;
  final Function(dc.direction turn) focusOnTurn;
  final Function()clearFocusTurnArrow;




  DirectionHeader({this.distance = 0, required this.user , this.direction = "", required this.paint, required this.repaint, required this.reroute, required this.moveUser, required this.closeNavigation,required this.isRelocalize,this.getSemanticValue='', required this.focusOnTurn,required this.clearFocusTurnArrow,required this.context,}){
    try{
      double angle = tools.calculateAngleBWUserandCellPath(
          user.Cellpath[0], user.Cellpath[1], user.pathobj.numCols![user.Bid]![user.floor]!,user.theta);
      direction = tools.angleToClocks(angle,context);
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
  List<Cell> turnPoints = [];
  BLueToothClass btadapter = new BLueToothClass();
  late Timer _timer;
  String turnDirection = "";
  List<Widget> DirectionWidgetList = [];
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale = '';
  bool disposed=false;


  Map<String, double> ShowsumMap = Map();
  int DirectionIndex = 1;
  int nextTurnIndex = 0;
  bool isSpeaking=false;

  void initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }






  @override
  void initState() {
    super.initState();

   // initTts();

    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;


    for(int i = 0; i<widget.user.pathobj.directions.length ; i++){
      direction element = widget.user.pathobj.directions[i];
      //DirectionWidgetList.add(scrollableDirection("${element.turnDirection == "Straight"?"Go Straight":"Turn ${element.turnDirection??""}, and Go Straight"}", '${((element.distanceToNextTurn??1)/UserState.stepSize).ceil()} steps', getCustomIcon(element.turnDirection!)));

    }


    btadapter.emptyBin();
    for (int i = 0; i < btadapter.BIN.length; i++) {
      if(btadapter.BIN[i]!.isNotEmpty){
        btadapter.BIN[i]!.forEach((key, value) {
          key = "";
          value = 0.0;
        });
      }
    }
    btadapter.startScanning(Building.apibeaconmap);
    _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      //
      //
      // //
      // HelperClass.showToast("Bin cleared");
      if(widget.user.pathobj.index>1) {

        listenToBin();

      }



    });

    btadapter.numberOfSample.clear();
    btadapter.rs.clear();
    Building.thresh = "";

    widget.getSemanticValue="";

    if(widget.user.floor!=widget.user.pathobj.destinationFloor &&  widget.user.pathobj.connections[widget.user.Bid]?[widget.user.floor] == (widget.user.showcoordY*UserState.cols + widget.user.showcoordX)){
      speak(convertTolng(
          "Use this lift and go to ${tools.numericalToAlphabetical(
              widget.user.pathobj.destinationFloor)} floor",_currentLocale, "", "", 0, "")
          , _currentLocale, prevpause:true);
    }else if(widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor] != null){

      turnPoints = tools.getTurnpoints_inCell(widget.user.Cellpath);
      turnPoints.add(widget.user.Cellpath.last);

      

      (widget.user.Cellpath.length%2==0)? turnPoints.add(widget.user.Cellpath[widget.user.Cellpath.length-2]):turnPoints.add(widget.user.Cellpath[widget.user.Cellpath.length-1]);

      List<Cell> remainingPath = widget.user.Cellpath.sublist(widget.user.pathobj.index+1);
      Cell nextTurn = findNextTurn(turnPoints, remainingPath);
        widget.distance = tools.distancebetweennodes_inCell(nextTurn, widget.user.Cellpath[widget.user.pathobj.index]);
      double angle = 0.0;
      if(widget.user.pathobj.index<widget.user.path.length-1){
        //
        angle = tools.calculateAngleBWUserandCellPath(widget.user.Cellpath[widget.user.pathobj.index], widget.user.Cellpath[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!,widget.user.theta);
        //
      }

      //print("angleeeeee $angle")  ;
      setState(() {

        widget.direction = tools.angleToClocks(angle,widget.context) == "None"?"Straight":tools.angleToClocks(angle,widget.context);
        if(widget.direction == "Straight"){
          widget.direction = "Go Straight";
          if(!UserState.ttsOnlyTurns) {
            speak(
                "${LocaleData.getProperty6(
                    'Go Straight', widget.context)} ${tools.convertFeet(
                    widget.distance, widget.context)}}",
                _currentLocale, prevpause: true);
          }
        }else{
          
          widget.direction = convertTolng("Turn ${LocaleData.getProperty5(widget.direction, widget.context)}", _currentLocale, widget.direction,"",0, "");
         if(!UserState.ttsOnlyTurns) {
            speak(
                "${widget.direction}",
                _currentLocale, prevpause: true);
          }
        widget.getSemanticValue =
        "Turn ${widget.direction}, and Go Straight ${tools.convertFeet(widget.distance,widget.context)}";

        }
      });

    }


  }

  @override
  void dispose() {
    disposed=true;
    flutterTts.stop();
    _timer.cancel();
    super.dispose();
  }

  String getgetSemanticValue(){
    return widget.getSemanticValue;
  }


  String debuglastNearestbeacon="";
  String debuglNearestbeacon="";
  Map<String, double> sortedsumMap={};
  Map<String, double> sumMap = {};
  Map<String, double> sumMapAvg = {};

  var newMap = <String, double>{};

  bool listenToBin(){
    double highestweight = 0;
    String nearestBeacon = "";
    sumMap.clear();
    sumMap = btadapter.calculateAverage();
    //
    sortedsumMap.clear();
    //


    sumMap.forEach((key, value) {
      if(highestweight<=value){
        nearestBeacon = key;
        highestweight = value;
      }
    });


    setState(() {
      sumMap;
      ShowsumMap = HelperClass().sortMapByValue(sumMap);
    });

    btadapter.emptyBin();
    btadapter.priorityQueue.clear();
    // btadapter.stopScanning();
     btadapter.startScanning(Building.apibeaconmap);

    // sortedsumMap.entries.forEach((element) {
    //   if(Building.apibeaconmap[element.key]!.floor == widget.user.pathobj.destinationFloor && element.value >= 0.05){
    //     nearestBeacon = element.key;
    //     highestweight = element.value;
    //   }
    // });
    // //
    // //


    // for (int i = 0; i < btadapter.BIN.length; i++) {
    //   if (btadapter.BIN[i]!.isNotEmpty) {
    //
    //     btadapter.BIN[i]!.forEach((key, value) {
    //       //
    //       //
    //       //
    //
    //       setState(() {
    //             widget.direction = "${widget.direction}$key   $value\n";
    //           });
    //
    //       //
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
    //   //
    //
    //   if(value>highestweight){
    //     highestweight =  value;
    //     nearestBeacon = key;
    //   }
    // });
    setState(() {
      debuglNearestbeacon = nearestBeacon;
      if(debuglastNearestbeacon != nearestBeacon){
        debuglastNearestbeacon = nearestBeacon;
      }

    });

    ////

  // 
    if(nearestBeacon !=""){
      

      if(widget.user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null) {
        
        
        
        if (widget.user.key != Building.apibeaconmap[nearestBeacon]!.sId) {
          

          //widget.user.pathobj.destinationFloor
          if (widget.user.floor != widget.user.pathobj.destinationFloor && widget.user.pathobj.destinationFloor!=widget.user.pathobj.sourceFloor && widget.user.pathobj.destinationFloor == Building.apibeaconmap[nearestBeacon]!.floor) {
            widget.user.onConnection = false;
            
            widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
            UserState.createCircle(widget.user.lat,widget.user.lng);
            speak(
                "You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor",
                _currentLocale
            );
            DirectionIndex = nextTurnIndex;
            //need to render on beacon for aiims jammu
            widget.paint(nearestBeacon,render: false);
            return true;
          }

          // else if(widget.user.floor != Building.apibeaconmap[nearestBeacon]!.floor &&  highestweight >= 1.1){
          //   widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
          //   speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor");
          //   widget.paint(nearestBeacon,render: false);
          //   return true;
          // }

          else if (widget.user.floor ==
              Building.apibeaconmap[nearestBeacon]!.floor &&

              highestweight >= 5) {

            widget.user.onConnection = false;
            //
            List<int> beaconcoord = [
              Building.apibeaconmap[nearestBeacon]!.coordinateX!,
              Building.apibeaconmap[nearestBeacon]!.coordinateY!
            ];
            List<int> usercoord = [
              widget.user.showcoordX,
              widget.user.showcoordY
            ];
            double d = tools.calculateDistance(beaconcoord, usercoord);
            int distanceFromPath = 100000000;
            int? indexOnPath = null;
            int numCols = widget.user.pathobj.numCols![widget.user
                .Bid]![widget.user.floor]!;
            widget.user.path.forEach((node) {
              List<int> pathcoord = [node % numCols, node ~/ numCols];
              double d1 = tools.calculateDistance(beaconcoord, pathcoord);
              if (d1 < distanceFromPath) {
                distanceFromPath = d1.toInt();
                //
                //
                indexOnPath = widget.user.path.indexOf(node);
                //
              }
            });

            if (distanceFromPath > 10) {
              
              _timer.cancel();
              widget.repaint(nearestBeacon);
              widget.reroute;
              DirectionIndex = 1;
              return false; //away from path
            } else {
              double dis = tools.calculateDistance([widget.user.showcoordX,widget.user.showcoordY], beaconcoord);
              
              widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
              if(!UserState.ttsOnlyTurns) {
                speak(
                    "${widget.direction} ${tools.convertFeet(
                        widget.distance, widget.context)}",
                    _currentLocale
                );
              }
              widget.user.moveToPointOnPath(indexOnPath!);

              widget.moveUser();
              DirectionIndex = nextTurnIndex;
              return true; //moved on path
            }
            // if (d < 5) {
            //   
            //   //near to user so nothing to do
            //   return true;
            // } else {
            //   //
            //   int distanceFromPath = 100000000;
            //   int? indexOnPath = null;
            //   int numCols = widget.user.pathobj.numCols![widget.user
            //       .Bid]![widget.user.floor]!;
            //   widget.user.path.forEach((node) {
            //     List<int> pathcoord = [node % numCols, node ~/ numCols];
            //     double d1 = tools.calculateDistance(beaconcoord, pathcoord);
            //     if (d1 < distanceFromPath) {
            //       distanceFromPath = d1.toInt();
            //       //
            //       //
            //       indexOnPath = widget.user.path.indexOf(node);
            //       //
            //     }
            //   });
            //
            //   if (distanceFromPath > 10) {
            //     
            //     _timer.cancel();
            //     widget.repaint(nearestBeacon);
            //     widget.reroute;
            //     DirectionIndex = 1;
            //     return false; //away from path
            //   } else {
            //     
            //     widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
            //     speak(
            //         "${widget.direction} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}",
            //         _currentLocale
            //     );
            //     widget.user.moveToPointOnPath(indexOnPath!);
            //     widget.moveUser();
            //     DirectionIndex = nextTurnIndex;
            //     return true; //moved on path
            //   }
            // }


            //
            //
            //
            //
            //
          }
        }


      }else{
        

        
        //
        //

        //
        if(highestweight>1.2){
          _timer.cancel();
          widget.repaint(nearestBeacon);
          widget.reroute;
        }
        return false;
      }
    }

    // btadapter.emptyBin();


    return false;
  }


  FlutterTts flutterTts = FlutterTts();
  Future<void> speak(String msg,String lngcode,{bool prevpause = false}) async {
    if(!UserState.ttsAllStop){
      if(disposed)return;

      // if (isSpeaking) {
      //   await flutterTts.stop();
      // }
      // setState(() {
      //   isSpeaking = true;
      // });
      if(prevpause){
        await flutterTts.pause();
      }
      if(Platform.isAndroid)
      {
        if(lngcode == "hi"){
          if(Platform.isAndroid){
            await flutterTts
                .setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
          }else{
            await flutterTts
                .setVoice({"name": "Lekha", "locale": "hi-IN"});
          }
        }else{
          await flutterTts.setVoice({"name": "en-US-language", "locale": "en-US"});
        }
      }
      if(isSpeaking){
        await flutterTts.stop();
      }
      if(Platform.isAndroid){
        await flutterTts.setSpeechRate(0.7);
      }else{
        // await flutterTts.setSharedInstance(true);
        // await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        //     [
        //       IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        //       IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        //       IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        //       IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        //     ],
        //     IosTextToSpeechAudioMode.defaultMode
        // );
        await flutterTts.setSpeechRate(0.55);
      }

      await flutterTts.setPitch(1.0);
      await flutterTts.speak(msg);

      setState(() {
        isSpeaking =!isSpeaking;
      });
    }

  }

  Cell findNextTurn(List<Cell> turns, List<Cell> path) {
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
      return Cell(0, 0, 0, (double angle, {int? currPointer,int? totalCells}){}, 0.0, 0.0, "", 0,0);
    }
  }

  String convertTolng(String msg, String lngcode,String direction,String direc,int nextTurn
      ,String nearestBeacon) {
    if (msg == "Turn ${direction}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(direction, widget.context)} मुड़ें";
      }
    }else if(msg=="Use this lift and go to ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} floor"){
      if(lngcode=='en'){
        return msg;
      }else{
        return "इस लिफ़्ट का उपयोग करें और ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} मंज़िल पर जाएँ";
      }
    } else if ((widget.user.pathobj.associateTurnWithLandmark[nextTurn]!=null && widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!=null) && msg ==
        "You are approaching ${direc} turn from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!} से ${LocaleData.getProperty5(direc, widget.context)} मोड़ के करीब पहुंच रहे हैं।";
      }
    } else if (msg == "You are approaching ${direc} turn") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${LocaleData.getProperty5(direc, widget.context)} मोड़ के करीब पहुंच रहे हैं";
      }
    } else if (msg ==
        "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}, and ${LocaleData.getProperty6('Go Straight', widget.context)} ${(widget.distance / UserState.stepSize).ceil()} ${LocaleData.steps.getString(widget.context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(widget.direction, widget.context)} मुड़ें और सीधे ${(widget.distance / UserState.stepSize).ceil()} कदम चलें";
      }
    } else if (Building.apibeaconmap[nearestBeacon]!=null && msg ==
        "You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} मंजिल पर पहुंच गए हैं";
      }
    }else if (msg == "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(widget.direction, widget.context)} मुड़ें";
      }
    }
    else if(msg=="Turn ${direction}"){
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(direction, widget.context)} मुड़ें";
      }
    }else if(msg=="You have reached ${widget.user.pathobj.destinationName}"){
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${widget.user.pathobj.destinationName} पर पहुँच गए हैं।";
      }
    }
    return "";
  }

  @override
  void didUpdateWidget(DirectionHeader oldWidget){
    super.didUpdateWidget(oldWidget);

    if(widget.user.floor == widget.user.pathobj.sourceFloor && widget.user.pathobj.connections.isNotEmpty && widget.user.showcoordY*UserState.cols + widget.user.showcoordX  == widget.user.pathobj.connections[widget.user.Bid]?[widget.user.pathobj.sourceFloor]){

    }else if (widget.user.path.isNotEmpty && widget.user.Cellpath.length-1>widget.user.pathobj.index){
      
        widget.user.pathobj.connections.forEach((key, value) {
          value.forEach((inkey, invalue) {
            if(widget.user.path[widget.user.pathobj.index] == invalue){
              widget.direction = "You have reached ";
            }
          });
        });
        List<Cell> remainingPath = widget.user.Cellpath.sublist(widget.user.pathobj.index+1);
        // 
        // 
        Cell nextTurn = findNextTurn(turnPoints, remainingPath);
        // 
        // 

        nextTurnIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == nextTurn.node);
        // 

        if(turnPoints.contains(widget.user.Cellpath[widget.user.pathobj.index])){
          if(DirectionIndex + 1 < widget.user.pathobj.directions.length) {
            DirectionIndex = widget.user.pathobj.directions.indexWhere((element) => element.node == widget.user.Cellpath[widget.user.pathobj.index].node)+1;
          }
          if(DirectionIndex >= widget.user.pathobj.directions.length){
            DirectionIndex = widget.user.pathobj.directions.length -1;
          }
        }
          widget.distance = tools.distancebetweennodes_inCell(nextTurn, widget.user.Cellpath[widget.user.pathobj.index]);
        double angle = 0.0;
        try{
          angle = tools.calculateAnglefifth(widget.user.Cellpath[widget.user.pathobj.index].node, widget.user.Cellpath[widget.user.pathobj.index+1].node, widget.user.Cellpath[widget.user.pathobj.index+2].node,widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
        }catch(e){
          print("error to be solved later $e");
        }
        if(widget.user.pathobj.index != 0){
           angle = tools.calculateAnglefifth(widget.user.Cellpath[widget.user.pathobj.index-1].node, widget.user.Cellpath[widget.user.pathobj.index].node, widget.user.Cellpath[widget.user.pathobj.index+1].node,widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
        }
        double userangle = tools.calculateAngleBWUserandCellPath(widget.user.Cellpath[widget.user.pathobj.index], widget.user.Cellpath[widget.user.pathobj.index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!,widget.user.theta);

        widget.direction = tools.angleToClocks(angle,widget.context) == "None"?oldWidget.direction:tools.angleToClocks(angle,widget.context);
        String userdirection = tools.angleToClocks(userangle,widget.context) == "None"?oldWidget.direction:tools.angleToClocks(userangle,widget.context);
        if(userdirection == "Straight"){
          widget.direction = "Straight";
        }
      if(widget.user.pathobj.index<3){
        widget.direction = userdirection;
      }

      if(UserCredentials().getUserPersonWithDisability()==1 || UserCredentials().getUserPersonWithDisability()==2){
        widget.direction = userdirection;
      }



      int index = widget.user.Cellpath.indexOf(nextTurn);
        //
        double a =0;
        if(index+1 == widget.user.path.length){
          if(widget.user.Cellpath[index-2].bid == widget.user.Cellpath[index-1].bid && widget.user.Cellpath[index-1].bid == widget.user.Cellpath[index].bid){
            a = tools.calculateAnglefifth(widget.user.path[index-2], widget.user.path[index-1], widget.user.path[index], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
          }
        }else{
          if(widget.user.Cellpath[index-1].bid == widget.user.Cellpath[index].bid && widget.user.Cellpath[index].bid == widget.user.Cellpath[index+1].bid){
            a = tools.calculateAnglefifth(widget.user.path[index-1], widget.user.path[index], widget.user.path[index+1], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
          }
        }
      
      
        String direc = tools.angleToClocks(a,widget.context);
        turnDirection = direc;

      if(oldWidget.direction != widget.direction){

        if(oldWidget.direction == "Straight"){
          

          Vibration.vibrate();


          // if(nextTurn == turnPoints.last){
          //   speak("${widget.direction} ${widget.distance} meter then you will reach ${widget.user.pathobj.destinationName}");
          // }else{
          //   speak("${widget.direction} ${widget.distance} meter");
          // }
          


            speak(convertTolng(
                "Turn ${LocaleData.getProperty5(widget.direction, context)}",
                _currentLocale, widget.direction, "", 0, ""),
                _currentLocale, prevpause: true);

          //speak("Turn ${widget.direction}, and Go Straight ${(widget.distance/UserState.stepSize).ceil()} steps");


        }else if(widget.direction == "Straight"){
          Vibration.vibrate();
          if(!UserState.ttsOnlyTurns) {
            speak(
                "${LocaleData.getProperty6('Go Straight', context)} ${tools
                    .convertFeet(widget.distance, context)}}",
                _currentLocale, prevpause: true);
          }
        }
      }

        if(nextTurn == turnPoints.last && widget.distance == 7){
          double angle = 0.0;
          try{
            angle = tools.calculateAngleThird([widget.user.pathobj.destinationX,widget.user.pathobj.destinationY], widget.user.path[widget.user.pathobj.index+1], widget.user.path[widget.user.pathobj.index+2], widget.user.pathobj.numCols![widget.user.Bid]![widget.user.floor]!);
          }catch(e){
            print("problem to be solved later $e");
          }
          if(!UserState.ttsOnlyTurns) {
            speak("${widget.direction} ${widget.distance} steps. ${widget.user
                .pathobj.destinationName} will be ${tools.angleToClocks2(
                angle, widget.context)}", _currentLocale);
          }
            widget.user.move(context);
        }else if(nextTurn != turnPoints.last && widget.user.pathobj.connections[widget.user.Bid]?[widget.user.floor] != nextTurn && (widget.distance/UserState.stepSize).ceil() == 7){

          if((!direc.toLowerCase().contains("slight") && !direc.toLowerCase().contains("straight")) && widget.user.pathobj.index > 4){

            if(widget.user.pathobj.associateTurnWithLandmark[nextTurn] != null){
              if(!UserState.ttsOnlyTurns){
                speak(
                    convertTolng(
                        "You are approaching ${direc} turn from ${widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name!}",
                        _currentLocale,
                        '',
                        direc,
                        nextTurn!.node,""),
                    _currentLocale);
              }

              return;
              //widget.user.pathobj.associateTurnWithLandmark.remove(nextTurn);
            }else{
              if(!UserState.ttsOnlyTurns) {
                speak(
                    convertTolng("You are approaching ${direc} turn",
                        _currentLocale, '', direc, nextTurn!.node, ""),
                    _currentLocale);
              }
              widget.user.move(widget.context);
              return;
            }


          }
        }

    }
  }

  static Icon getCustomIcon(String direction) {
    if(direction.toLowerCase().contains("lift")){
      return Icon(
        Icons.elevator,
        color: Color(0xff01544f),
        size: 23,
      );
    }else if(direction.toLowerCase().contains("stair")){
      return Icon(
        Icons.stairs,
        color: Color(0xff01544f),
        size: 23,
      );
    }else if(direction == "Straight"){
      return Icon(
        Icons.straight,
        color: Color(0xff01544f),
        size: 40,
      );
    }else if(direction == "Slight Right"){
      return Icon(
        Icons.turn_slight_right,
        color: Color(0xff01544f),
        size: 40,
      );
    }else if(direction == "Right"){
      return Icon(
        Icons.turn_right,
        color: Color(0xff01544f),
        size: 40,
      );
    }else if(direction == "Sharp Right"){
      return Icon(
        Icons.turn_sharp_right,
        color: Color(0xff01544f),
        size: 40,
      );
    }else if(direction == "U Turn"){
      return Icon(
        Icons.u_turn_right,
        color: Color(0xff01544f),
        size: 40,
      );
    }else if(direction == "Sharp Left"){
      return Icon(
        Icons.turn_sharp_left,
        color: Color(0xff01544f),
        size: 40,
      );
    }else if(direction == "Left"){
      return Icon(
        Icons.turn_left,
        color: Color(0xff01544f),
        size: 40,
      );
    }else if(direction == "Slight Left"){
      return Icon(
        Icons.turn_slight_left,
        color: Color(0xff01544f),
        size: 40,
      );
    }else{
      return Icon(
        Icons.check_box_outline_blank,
        color: Color(0xff01544f),
        size: 40,
      );
    }
  }

  Icon getNextCustomIcon(String direction) {
    if(direction.toLowerCase().contains("lift")){
      return Icon(
        Icons.elevator,
        color: Colors.white,
        size: 23,
      );
    }else if(direction.toLowerCase().contains("stair")){
      return Icon(
        Icons.stairs_rounded,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Straight"){
      return Icon(
        Icons.straight,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Slight Right"){
      return Icon(
        Icons.turn_slight_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Right"){
      return Icon(
        Icons.turn_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Sharp Right"){
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "U Turn"){
      return Icon(
        Icons.u_turn_right,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Sharp Left"){
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Left"){
      return Icon(
        Icons.turn_left,
        color: Colors.white,
        size: 23,
      );
    }else if(direction == "Slight Left"){
      return Icon(
        Icons.turn_slight_left,
        color: Colors.white,
        size: 23,
      );
    }else{
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.white,
        size: 23,
      );
    }
  }

  Color getColor(){
    try {
      if (widget.user.pathobj.directions.isNotEmpty) {
        if (DirectionIndex < widget.user.pathobj.directions.length &&
            widget.user.pathobj.directions[DirectionIndex].isDestination) {
          return Colors.blue;
        } else {
          if (DirectionIndex == nextTurnIndex) {
            return Color(0xff01544f);
          } else {
            return Color(0xff01544f);
          }
        }
      } else {
        return Color(0xff01544f);
      }
    }catch(e){
      return Color(0xff01544f);
    }
  }
  final Map<int, Map<String, double>> bin = {
    1: {'key1': 1.1, 'key2': 2.2},
    2: {'keyA': 3.3, 'keyB': 4.4},
  };

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // String binString = btadapter.BIN.entries.map((entry) {
    //   int key = entry.key;
    //   Map<String, double> valueMap = entry.value;
    //   String valueString = valueMap.entries.map((e) {
    //     return '${e.key}: ${e.value}';
    //   }).join(', ');
    //   return 'BIN[$key]: {$valueString}';
    // }).join('\n');
    setState(() {

    });
    return Semantics(
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 8,bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight: Radius.circular(16)),
              color:getColor()

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  child: IconButton(onPressed: (){setState(() {
                    if(DirectionIndex - 1 >=1){
                      DirectionIndex--;
                      widget.focusOnTurn(widget.user.pathobj.directions[DirectionIndex]);
                      if(DirectionIndex == nextTurnIndex){
                        widget.clearFocusTurnArrow();
                      }
                    }
                  });}, icon: Icon(Icons.arrow_back_ios_new,color: DirectionIndex - 1 >=1?Colors.white:Colors.grey,)),
                ),
                const SizedBox(width: 8,),
                scrollableDirection("${widget.direction}", '${tools.convertFeet(widget.distance,widget.context)}', getCustomIcon(widget.direction),DirectionIndex,nextTurnIndex,widget.user.pathobj.directions,widget.user,widget.context),
                const SizedBox(width: 8,),
                Container(
                  width: 44,
                  height: 44,
                  child: IconButton(onPressed: (){setState(() {
                    if(DirectionIndex + 1 < widget.user.pathobj.directions.length){
                      DirectionIndex++;
                      widget.focusOnTurn(widget.user.pathobj.directions[DirectionIndex]);
                      if(widget.user.pathobj.directions.length-DirectionIndex == 2 && widget.user.pathobj.directions[DirectionIndex].distanceToNextTurn != null && widget.user.pathobj.directions[DirectionIndex].distanceToNextTurn!<=5 && DirectionIndex + 1 < widget.user.pathobj.directions.length){
                        DirectionIndex++;
                      }
                      if(DirectionIndex == nextTurnIndex){
                        widget.clearFocusTurnArrow();
                      }
                    }
                  });}, icon: Icon(Icons.arrow_forward_ios_outlined,color: DirectionIndex + 1 < widget.user.pathobj.directions.length?Colors.white:Colors.grey,size: 24,)),
                )
              ],
            ),
          ),
          DirectionIndex == nextTurnIndex?Container(
            width: 98,
            height: 39,
            margin: EdgeInsets.only(left: 9,top: 5),
            padding: EdgeInsets.only(left: 16,right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: Color(0xff013633),
            ),
            child: Row(
              children: [
                Text(
                  "${LocaleData.then.getString(context)}",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffFFFFFF),
                    height: 25/16,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(width: 6,),
                // Text(DirectionIndex.toString()),
                // Text(nextTurnIndex.toString())
                getNextCustomIcon(turnDirection)
              ],
            ),
          ):Container(),

          // Container(
          //   width: 300,
          //   height: 100,
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(sumMap.toString()),
          //         Text(binString),
          //       ],
          //     ),
          //   ),
          // ),

          // Container(
          //   width: 300,
          //   height: 100,
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //
          //         Text(sumMap.toString()),
          //
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class scrollableDirection extends StatelessWidget {
  String Direction;
  String steps;
  Icon i;
  int DirectionIndex;
  int nextTurnIndex;
  List<direction> listOfDirections;
  UserState user;
  BuildContext context;

  scrollableDirection(this.Direction,this.steps,this.i,this.DirectionIndex,this.nextTurnIndex,this.listOfDirections,this.user,this.context);

  String chooseDirection(){
    
    try {
      if (listOfDirections.isNotEmpty &&
          listOfDirections.length > DirectionIndex) {
        if (DirectionIndex < listOfDirections.length &&
            listOfDirections[DirectionIndex].isDestination) {
          double? angle;
          if (user.pathobj.singleCellListPath.isNotEmpty) {
            int l = user.pathobj.singleCellListPath.length;
            angle = tools.calculateAngle([
              user.pathobj.singleCellListPath[l - 2].x,
              user.pathobj.singleCellListPath[l - 2].y
            ], [
              user.pathobj.singleCellListPath[l - 1].x,
              user.pathobj.singleCellListPath[l - 1].y
            ], [
              user.pathobj.destinationX,
              user.pathobj.destinationY
            ]);
          }
          return angle != null ? "${listOfDirections[DirectionIndex]
              .turnDirection} ${LocaleData.willbe.getString(
              context)} ${LocaleData
              .getProperty(tools.angleToClocks3(angle, context), context) }" :
          "${listOfDirections[DirectionIndex].turnDirection} ${LocaleData
              .willbeonyourfront.getString(context)}";
        } else if (DirectionIndex == nextTurnIndex) {
          return "${Direction == "Straight" ? "${LocaleData.gostraight
              .getString(
              context)}" : LocaleData.getProperty(Direction, context)}";
        } else {
          if (DirectionIndex < listOfDirections.length) {
            return "${listOfDirections[DirectionIndex].turnDirection ==
                "Straight"
                ? "${LocaleData.gostraight.getString(context)}"
                : "${LocaleData.getProperty(
                listOfDirections[DirectionIndex].turnDirection!, context)}"}";
          } else {
            return "${listOfDirections[DirectionIndex - 1].turnDirection ==
                "Straight"
                ? "${LocaleData.gostraight.getString(context)}"
                : "${LocaleData.getProperty(
                listOfDirections[DirectionIndex - 1].turnDirection!,
                context)},"}";
          }
        }
      } else {
        return "${LocaleData.gostraight.getString(context)}";
      }
    }catch(e){
      return "${LocaleData.gostraight.getString(context)}";
    }
  }

  String chooseSteps(){
    try {
      if (listOfDirections.isNotEmpty &&
          DirectionIndex < listOfDirections.length) {
        if (listOfDirections[DirectionIndex].isDestination) {
          return "";
        } else if (DirectionIndex == nextTurnIndex) {
          return '$steps';
        } else {
          return '${tools.convertFeet((listOfDirections[DirectionIndex].distanceToNextTurn ??
              1).toInt(),context)}';
        }
      } else {
        return "";
      }
    }catch(e){
      return "";
    }
  }

  Icon chooseIcon(){
    try {
      if (listOfDirections.isNotEmpty &&
          DirectionIndex < listOfDirections.length) {
        if (listOfDirections[DirectionIndex].isDestination) {
          return const Icon(
            Icons.place_rounded, color: Colors.blueAccent, size: 40,);
        } else if (DirectionIndex == nextTurnIndex) {
          return i;
        } else {
          return _DirectionHeaderState.getCustomIcon(
              listOfDirections[DirectionIndex].turnDirection!);
        }
      } else {
        return const Icon(Icons.straight);
      }
    }catch(e){
      return const Icon(Icons.straight);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return  Expanded(

      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                chooseDirection(),
                style: const TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 30/24,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Container(
            width: 85,
            height: 75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ((chooseDirection().toLowerCase().contains("lift") || chooseDirection().toLowerCase().contains("stair")) || listOfDirections.isEmpty || (DirectionIndex>0 && listOfDirections.length>DirectionIndex && listOfDirections[DirectionIndex].isDestination))?Container():Text(
                  chooseSteps().replaceAll("meter", "m"),
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 26/16,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white, // Set background color to white
                    shape: BoxShape.circle, // Make the container a circle
                  ),
                  child: chooseIcon(), // Your icon or widget inside the circle
                )

              ],
            ),
          )],
      ),
    );
  }
}

