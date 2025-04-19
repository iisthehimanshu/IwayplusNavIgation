import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../../IWAYPLUS/Elements/UserCredential.dart';
import '../../IWAYPLUS/Elements/locales.dart';
import '../../IWAYPLUS/FIREBASE NOTIFICATION API/PushNotifications.dart';
import '../BluetoothScanAndroidClass.dart';

import 'package:vibration/vibration.dart';

import '../BluetoothScanIOSClass.dart';
import '../Cell.dart';
import '../UserState.dart';
import '../bluetooth_scanning.dart';
import '../buildingState.dart';
import '../directionClass.dart';
import '../directionClass.dart' as dc;
import '../directionClass.dart';
import '../Navigation.dart';
import '../navigationTools.dart';
import '../singletonClass.dart';


class DirectionHeader extends StatefulWidget {
  String direction;
  int distance;
  bool isRelocalize;
  UserState user;
  String getSemanticValue;
  BuildContext context;
  final  Function(String? nearestBeacon,String? polyID, gmap.LatLng? gpsCoordinates,
      {bool speakTTS, bool render}) paint;
  final Function(String nearestBeacon) repaint;
  final Function() reroute;
  final Function() moveUser;
  final Function() closeNavigation;
  final Function(dc.direction turn) focusOnTurn;
  final Function() clearFocusTurnArrow;

  DirectionHeader({
    this.distance = 0,
    required this.user,
    this.direction = "",
    required this.paint,
    required this.repaint,
    required this.reroute,
    required this.moveUser,
    required this.closeNavigation,
    required this.isRelocalize,
    this.getSemanticValue = '',
    required this.focusOnTurn,
    required this.clearFocusTurnArrow,
    required this.context,
  }) {
    try {
      double angle = tools.calculateAngleBWUserandCellPath(
          user.cellPath[0],
          user.cellPath[1],
          user.pathobj.numCols![user.bid]![user.floor]!,
          user.theta);
      direction = tools.angleToClocks(angle, context);
      if (direction == "Straight") {
        direction = "Go Straight";
      } else {
        direction = "Turn ${direction}, and Go Straight";
      }
    } catch (e) {}
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
  bool disposed = false;
  BluetoothScanAndroidClass bluetoothScanAndroidClass = BluetoothScanAndroidClass();

  Map<String, double> ShowsumMap = Map();
  int DirectionIndex = 1;
  int nextTurnIndex = 0;
  bool isSpeaking = false;
  String? threshold;
  double candorThreshold = 0.0;

  late Timer Device_timer;
  bool isSemanticEnabled = false;




  void initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  void setTTSParams(String lngcode)async{
    try{
      print("get ios voices ${await flutterTts.getVoices}");
      if (lngcode == "hi") {
        if (Platform.isAndroid) {
          await flutterTts.setVoice({"name": "hi-in-x-hia-local", "locale": "hi-IN"});
        } else {
          await flutterTts.setVoice({"name": "Lekha", "locale": "hi-IN"});
        }
      } else {
        await flutterTts.setVoice({"name": "en-US-language", "locale": "en-US"});
      }

      await flutterTts.stop();
      if (Platform.isAndroid) {
        await flutterTts.setSpeechRate(0.7);
      } else {
        await flutterTts.setSpeechRate(0.55);
      }

      await flutterTts.setPitch(1.0);
    }catch(e){

    }
  }

  @override
  void initState() {
    super.initState();


    // initTts();

    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
    setTTSParams(_currentLocale);

    for (int i = 0; i < widget.user.pathobj.directions.length; i++) {
      direction element = widget.user.pathobj.directions[i];
      //DirectionWidgetList.add(scrollableDirection("${element.turnDirection == "Straight"?"Go Straight":"Turn ${element.turnDirection??""}, and Go Straight"}", '${((element.distanceToNextTurn??1)/UserState.stepSize).ceil()} steps', getCustomIcon(element.turnDirection!)));
    }

    // btadapter.emptyBin();
    // for (int i = 0; i < btadapter.BIN.length; i++) {
    //   if (btadapter.BIN[i]!.isNotEmpty) {
    //     btadapter.BIN[i]!.forEach((key, value) {
    //       key = "";
    //       value = 0.0;
    //     });
    //   }
    // }
    if(Platform.isAndroid) {
      Future.delayed(Duration(seconds: 4)).then((_) {
        bluetoothScanAndroidClass.startbin();
        bluetoothScanAndroidClass.emptyBin();
        setState(() {
          bluetoothScanAndroidClass.listenToScanUpdates(Building.apibeaconmap);
        });
      });
    }else if(Platform.isIOS){
      final scannedDevices = BluetoothScanIOSClass.startScan();
    }





    setState(() {});
    //btadapter.startScanning(Building.apibeaconmap);
    if(Platform.isAndroid) {
      _timer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
        // print("widget.user.pathobj.index");
        // print(widget.user.pathobj.index);

        if (widget.user.pathobj.index > 3) {
          listenToBin();
        }
      });
    }else if(Platform.isIOS){
      Device_timer = Timer.periodic(Duration(milliseconds: 1000), (timer)  {
        try {
          listenToBin();
        } catch (e) {
          print("Error getting best device: $e");
        }
      });
    }

    btadapter.numberOfSample.clear();
    btadapter.rs.clear();
    Building.thresh = "";

    widget.getSemanticValue = "";

    if (widget.user.floor != widget.user.pathobj.destinationFloor &&
        widget.user.pathobj.connections[widget.user.bid]?[widget.user.floor] ==
            (widget.user.showcoordY * UserState.cols +
                widget.user.showcoordX)) {
      speak(
          convertTolng(
              "Use this lift and go to ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} floor",
              _currentLocale,
              "",
              "",
              0,
              ""),
          _currentLocale,
          prevpause: true);
    } else if (widget
            .user.pathobj.numCols![widget.user.bid]![widget.user.floor] !=
        null) {
      turnPoints = tools.getTurnpoints_inCell(widget.user.cellPath);
      turnPoints.add(widget.user.cellPath.last);

      (widget.user.cellPath.length % 2 == 0)
          ? turnPoints
              .add(widget.user.cellPath[widget.user.cellPath.length - 2])
          : turnPoints
              .add(widget.user.cellPath[widget.user.cellPath.length - 1]);

      List<Cell> remainingPath =
          widget.user.cellPath.sublist(widget.user.pathobj.index + 1);
      Cell nextTurn = findNextTurn(turnPoints, remainingPath);
      widget.distance = tools.distancebetweennodes_inCell(
          nextTurn, widget.user.cellPath[widget.user.pathobj.index]);
      double angle = 0.0;
      if (widget.user.pathobj.index < widget.user.path.length - 1) {
        //
        angle = tools.calculateAngleBWUserandCellPath(
            widget.user.cellPath[widget.user.pathobj.index],
            widget.user.cellPath[widget.user.pathobj.index + 1],
            widget.user.pathobj.numCols![widget.user.bid]![widget.user.floor]!,
            widget.user.theta);
        //
      }

      //print("angleeeeee $angle")  ;
      setState(() {
        widget.direction = tools.angleToClocks(angle, widget.context) == "None"
            ? "Straight"
            : tools.angleToClocks(angle, widget.context);
        if (widget.direction == "Straight") {
          widget.direction = "Go Straight";
          if (!UserState.ttsOnlyTurns) {
            speak(
                "${LocaleData.getProperty6('Go Straight', widget.context)} ${tools.convertFeet(widget.distance, widget.context)}}",
                _currentLocale,
                prevpause: true);
          }
        } else {
          widget.direction = convertTolng(
              "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}",
              _currentLocale,
              widget.direction,
              "",
              0,
              "");
          if (!UserState.ttsOnlyTurns) {
            speak("${widget.direction}", _currentLocale, prevpause: true);
          }
          widget.getSemanticValue =
              "Turn ${widget.direction}, and Go Straight ${tools.convertFeet(widget.distance, widget.context)}";
        }
      });
    }

    print("direction${widget.direction}");

    try {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white // Set the icon color to dark
          ));
    } catch (e) {}
  }

  @override
  void dispose() {

    if(Platform.isIOS){
      BluetoothScanIOSClass.stopScan();
    }else{
      bluetoothScanAndroidClass.stopScan();
    }
    Device_timer.cancel();
    disposed = true;
    flutterTts.stop();
    _timer.cancel();
    super.dispose();
  }

  String getgetSemanticValue() {
    return widget.getSemanticValue;
  }

  String debuglastNearestbeacon = "";
  String debuglNearestbeacon = "";
  Map<String, double> sortedsumMap = {};
  Map<String, List<double>> sumMap = {};
  Map<String, List<int>> sumRSSI = {};
  Map<String, double> sumMapAvg = {};

  //-------------------------
  Map<String, double> candorAverageDH = {};
  //-------------------------

  var newMap = <String, double>{};
  String displayString = "";
  String? highestKey;
  double highestAverage = double.negativeInfinity;



  double highestweight = Platform.isIOS?2.8 : 3.25;

  String? parseString(String input) {
    final regex = RegExp(r'Optional\("(.+?)"\)\s+(\d+\.\d+)');
    final match = regex.firstMatch(input);

    if (match != null) {
      final device = match.group(1); // Extracts "IW622"
      final value = double.tryParse(match.group(2) ?? '0'); // Extracts 6.0 as a double

      // print("Device: $device");
      // print("Value: $value");
      return device;
    } else {
      print("No match found!");
      return "";
    }
  }

  String? parseStringT(String input) {
    final regex = RegExp(r'Optional\("(.+?)"\)\s+(\d+\.\d+)');
    final match = regex.firstMatch(input);

    if (match != null) {
      final device = match.group(1); // Extracts "IW622"
      final value = double.tryParse(match.group(2) ?? '0'); // Extracts 6.0 as a double

      // print("Device: $device");
      // print("Value: $value");
      return value.toString();
    } else {
      print("No match found!");
      return "";
    }
  }


  List<dynamic> findLastAboveThresholdCandor(Map<String, double> data, double threshold) {
    String? lastKey;
    double? lastValue;

    data.forEach((key, value) {
      if (value > threshold) {
        lastKey = key; // Store the latest key that exceeds the threshold
      }
    });

    return [BluetoothScanAndroidClass().deviceNames[lastKey],lastKey,lastValue]; // Returns the last key that went above the threshold
  }

  Future<bool> listenToBin() async {
    print("widget.user");
    print(widget.user);
    print("-------");
  // String data = """
  //   {"node":7491,"x":71,"y":28,"lat":28.54358368550854,"lng":77.18752284900863,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":7756,"x":71,"y":29,"lat":28.543581203984196,"lng":77.1875215317411,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8021,"x":71,"y":30,"lat":28.54357872245985,"lng":77.18752021447358,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8286,"x":71,"y":31,"lat":28.543576240935504,"lng":77.18751889720606,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8551,"x":71,"y":32,"lat":28.543573759411156,"lng":77.18751757993853,"ttsEnabled":false,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8550,"x":70,"y":32,"lat":28.54357491657873,"lng":77.18751475508282,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8549,"x":69,"y":32,"lat":28.5435760737463,"lng":77.1875119302271,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8548,"x":68,"y":32,"lat":28.543577230913872,"lng":77.18750910537139,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8547,"x":67,"y":32,"lat":28.543578388081446,"lng":77.18750628051568,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8546,"x":66,"y":32,"lat":28.543579545249017,"lng":77.18750345565995,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8545,"x":65,"y":32,"lat":28.543580702416588,"lng":77.18750063080424,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8544,"x":64,"y":32,"lat":28.543581859584158,"lng":77.18749780594852,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8543,"x":63,"y":32,"lat":28.543583016751732,"lng":77.18749498109281,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8542,"x":62,"y":32,"lat":28.543584173919303,"lng":77.1874921562371,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8541,"x":61,"y":32,"lat":28.543585331086874,"lng":77.18748933138139,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8540,"x":60,"y":32,"lat":28.543586488254444,"lng":77.18748650652566,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8539,"x":59,"y":32,"lat":28.54358764542202,"lng":77.18748368166995,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8538,"x":58,"y":32,"lat":28.54358880258959,"lng":77.18748085681423,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8537,"x":57,"y":32,"lat":28.54358995975716,"lng":77.18747803195852,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8536,"x":56,"y":32,"lat":28.543591116924734,"lng":77.1874752071028,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8535,"x":55,"y":32,"lat":28.543592274092305,"lng":77.1874723822471,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8534,"x":54,"y":32,"lat":28.543593431259875,"lng":77.18746955739137,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8533,"x":53,"y":32,"lat":28.543594588427446,"lng":77.18746673253565,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8532,"x":52,"y":32,"lat":28.54359574559502,"lng":77.18746390767994,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8531,"x":51,"y":32,"lat":28.54359690276259,"lng":77.18746108282423,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8530,"x":50,"y":32,"lat":28.54359805993016,"lng":77.18745825796852,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8529,"x":49,"y":32,"lat":28.543599217097736,"lng":77.1874554331128,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8528,"x":48,"y":32,"lat":28.543600374265306,"lng":77.18745260825708,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8527,"x":47,"y":32,"lat":28.543601531432877,"lng":77.18744978340136,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8526,"x":46,"y":32,"lat":28.543602688600448,"lng":77.18744695854565,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8525,"x":45,"y":32,"lat":28.543603845768022,"lng":77.18744413368994,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8524,"x":44,"y":32,"lat":28.543605002935593,"lng":77.18744130883422,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8523,"x":43,"y":32,"lat":28.543606160103163,"lng":77.18743848397851,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8522,"x":42,"y":32,"lat":28.543607317270734,"lng":77.18743565912278,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8521,"x":41,"y":32,"lat":28.543608474438308,"lng":77.18743283426707,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8520,"x":40,"y":32,"lat":28.54360963160588,"lng":77.18743000941136,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8519,"x":39,"y":32,"lat":28.54361078877345,"lng":77.18742718455564,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8518,"x":38,"y":32,"lat":28.543611945941024,"lng":77.18742435969993,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8517,"x":37,"y":32,"lat":28.543613103108594,"lng":77.18742153484422,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8516,"x":36,"y":32,"lat":28.543614260276165,"lng":77.18741870998849,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8515,"x":35,"y":32,"lat":28.543615417443736,"lng":77.18741588513278,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8514,"x":34,"y":32,"lat":28.54361657461131,"lng":77.18741306027707,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8513,"x":33,"y":32,"lat":28.54361773177888,"lng":77.18741023542135,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8512,"x":32,"y":32,"lat":28.54361888894645,"lng":77.18740741056564,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8511,"x":31,"y":32,"lat":28.543620046114025,"lng":77.18740458570993,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8510,"x":30,"y":32,"lat":28.543621203281596,"lng":77.1874017608542,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8509,"x":29,"y":32,"lat":28.543622360449167,"lng":77.18739893599849,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8508,"x":28,"y":32,"lat":28.543623517616737,"lng":77.18739611114277,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8507,"x":27,"y":32,"lat":28.54362467478431,"lng":77.18739328628706,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8506,"x":26,"y":32,"lat":28.543625831951882,"lng":77.18739046143135,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8505,"x":25,"y":32,"lat":28.543626989119453,"lng":77.18738763657564,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8504,"x":24,"y":32,"lat":28.543628146287027,"lng":77.18738481171991,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8503,"x":23,"y":32,"lat":28.543629303454598,"lng":77.1873819868642,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8502,"x":22,"y":32,"lat":28.54363046062217,"lng":77.18737916200848,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8501,"x":21,"y":32,"lat":28.54363161778974,"lng":77.18737633715277,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8500,"x":20,"y":32,"lat":28.543632774957313,"lng":77.18737351229706,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8499,"x":19,"y":32,"lat":28.543633932124884,"lng":77.18737068744134,"ttsEnabled":false,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":8234,"x":19,"y":31,"lat":28.543636413649228,"lng":77.18737200470886,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":7969,"x":19,"y":30,"lat":28.543638895173576,"lng":77.18737332197638,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":7704,"x":19,"y":29,"lat":28.54364137669792,"lng":77.18737463924391,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //   {"node":7439,"x":19,"y":28,"lat":28.543643858222268,"lng":77.18737595651143,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}
  //
  //
  //   Cell curr = Cell.fromJson({"node":8234,"x":19,"y":31,"lat":28.543636413649228,"lng":77.18737200470886,"ttsEnabled":true,"bid":"65d887a5db333f89457145f6","floor":3,"numCols":265,"imaginedCell":false,"imaginedIndex":null,"position":null}, (double angle, {int? currPointer, int? totalCells}) {
  //     // Implement your logic here for the move function
  //     print('Moving with angle: $angle');
  //     // You can use currPointer and totalCells if needed
  //   });
  //   print(curr);
  //   print("-------");
  // widget.user.cellPath.forEach((value){
  //   print(value);
  //   });
  // print("-------");
  //
  //   widget.user.pathobj.path.forEach((key, value){
  //     print("$key $value");
  //   });
  //   print(widget.user.pathobj);
  //   // print(widget.user.lat);
  //   // print(widget.user.lng);
  //   // print(widget.user.cellPath);
  //   // widget.user.cellPath.forEach((value){
  //   //   print(value.)
  //   // });
  //   // print(widget.user.bid);
  //   // print(widget.user.floor);
  //   // print(widget.user.pathobj);
  //   // print(widget.user.coordX);
  //   // print(widget.user.coordY);
  //   // print(widget.user.theta);
  //   // print("listentobin");

    String nearestBeacon = "";

    if(Platform.isAndroid) {
      sumMap.clear();
      nearestBeacon = findNearestBeaconTaksForAndroid();
    }else if(Platform.isIOS){
      nearestBeacon = await findNearestBeaconTaksForIOS();
    }

    sortedsumMap.clear();
    try {
      if (nearestBeacon != "") {
        if (widget.user.pathobj.path[Building.apibeaconmap[nearestBeacon]!.floor] != null) {
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
    } catch (e) {}

    return false;
  }

  String findNearestBeaconTaksForAndroid(){
    String beaconCalculate = "";
    candorAverageDH = bluetoothScanAndroidClass.candorAverage;
    print("candorAverageDH $candorAverageDH");
    List<dynamic> receivedCandorValue = findLastAboveThresholdCandor(candorAverageDH,5.8)??[];
    print("receivedCandorValue $receivedCandorValue");
    beaconCalculate = receivedCandorValue[0]??"";
    candorThreshold = receivedCandorValue[1]??0.0;


    debuglNearestbeacon = beaconCalculate;
    sumMap = bluetoothScanAndroidClass.giveSumMapCallBack();
    sumRSSI = bluetoothScanAndroidClass.rssiValues;

    sumMap.forEach((key, value) {
      if (value.isNotEmpty) {
        double average = value.reduce((a, b) => a + b) / value.length;
        if (average > highestAverage) {
          highestAverage = average;
          highestKey = key;
        }
      } else {
        print("else---");
      }
    });
    return beaconCalculate;
  }

  Future<String> findNearestBeaconTaksForIOS() async {
    String beaconCalculate = "";

    String receivedStringFromIOS = await BluetoothScanIOSClass.getBestDevice();
    beaconCalculate = parseString(receivedStringFromIOS)??"";
    threshold = parseStringT(receivedStringFromIOS)??"";
    debuglNearestbeacon = "${beaconCalculate} ${threshold}";
    return beaconCalculate;
  }

  void setEssentialsForReroute(String nearestBeacon){
    _timer.cancel();
    widget.repaint(nearestBeacon);
    widget.reroute;
    DirectionIndex = 1;
    nextTurnIndex = 1;
  }


  void reacedDestinationEssentials(String nearestBeacon){
    widget.user.onConnection = false;
    widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
    UserState.createCircle(widget.user.lat, widget.user.lng);
    speak("You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor", _currentLocale);
    DirectionIndex = nextTurnIndex;
    //need to render on beacon for aiims jammu
    widget.paint(nearestBeacon, null, null, render: false);
  }

  void moveOnPathEssentials(String nearestBeacon,int? indexOnPath){
    widget.user.key = Building.apibeaconmap[nearestBeacon]!.sId!;
    if (!UserState.ttsOnlyTurns) {
      speak("${widget.direction} ${tools.convertFeet(widget.distance, widget.context)}", _currentLocale);
    }
    widget.user.moveToPointOnPath(indexOnPath!, context);
    widget.moveUser();
    DirectionIndex = nextTurnIndex;
  }

  int insertProjectedPointInIntList(
      List<int> path, int projectedPoint, int numCols) {
    // Helper function to compute x, y for a given element
    List<int> getXY(int element) {
      int x = element % numCols;
      int y = element ~/ numCols;
      return [x, y];
    }

    // Calculate x, y for the projected point
    List<int> projectedXY = getXY(projectedPoint);

    // Find the index to insert the projected point
    int indexToInsert = path.indexWhere((element) {
      List<int> elementXY = getXY(element);

      // Compare first by x, then by y if x is the same
      return (elementXY[0] > projectedXY[0]) ||
          (elementXY[0] == projectedXY[0] && elementXY[1] > projectedXY[1]);
    });

    return indexToInsert;
  }

  int insertProjectedPoint(List<Cell> path, Cell projectedPoint) {
    // Find the index of the next greater point
    int indexToInsert = path.indexWhere((cell) {
      // Compare by some criterion; here we're using the `x` coordinate
      return (cell.x > projectedPoint.x) ||
          (cell.x == projectedPoint.x && cell.y > projectedPoint.y);
    });

    return indexToInsert;
  }

  List<Cell> findTwoNearestPoints(
      List<double> beaconcoord, List<Cell> turnPoints, String userBid) {
    // Sort the list of turn points by distance to the beacon
    print("turnPoints[0].x ${turnPoints.length} ${turnPoints[0].x}");
    List<Cell> filteredPoints = turnPoints
        .where((point) => (point.bid == userBid && point.imaginedCell == false))
        .toList();
    print(
        "filteredPoints[0].x ${filteredPoints.length} ${filteredPoints[0].x}");

    filteredPoints.sort((a, b) => tools
        .calculateAerialDist(beaconcoord[0], beaconcoord[1], a.lat, a.lng)
        .compareTo(tools.calculateAerialDist(
            beaconcoord[0], beaconcoord[1], b.lat, b.lng)));
    print(
        "filteredPoints[0].x ${filteredPoints.length} ${filteredPoints[0].x}");
    // Return the first two points in the sorted list
    return [filteredPoints[0], filteredPoints[1]];
  }

  List<double> projectCellOntoSegment(
      List<double> beaconLatLng, Cell a, Cell b, int numCols) {
    // Vector AB (lat/lng)
    double abLat = b.lat - a.lat;
    double abLng = b.lng - a.lng;
    // Vector AP (lat/lng)
    double apLat = beaconLatLng[0] - a.lat;
    double apLng = beaconLatLng[1] - a.lng;
    // Dot products
    double abDotAb = abLat * abLat + abLng * abLng;
    double apDotAb = apLat * abLat + apLng * abLng;

    // Projection scalar t
    double t = apDotAb / abDotAb;

    // Clamp t to stay within the segment [0, 1]
    t = t.clamp(0.0, 1.0);

    // Projected point P' on the line segment
    double projLat = a.lat + t * abLat;
    double projLng = a.lng + t * abLng;

    // Convert projected lat/lng back to x/y for the Cell object

    return [projLat, projLng];
  }
  FlutterTts flutterTts = FlutterTts();
  Future<void> speak(String msg, String lngcode, {bool prevpause = false}) async {
    print("checkspeak");
    if (!UserState.ttsAllStop) {
      if (disposed) return;
      if (false) {
        await flutterTts.pause();
      }
      try {
        // Check if Semantic Mode is enabled
        if (isSemanticEnabled) {
          PushNotifications.showSimpleNotification(body: "", payload: "", title: msg);
        } else {
          await flutterTts.speak(msg);
        }
      } catch (e) {
        print("Error during TTS: $e");
      }
    }
  }
  Cell findNextTurn(List<Cell> turns, List<Cell> path) {
    // Iterate through the sorted list
    for (int i = 0; i < path.length; i++) {
      for (int j = 0; j < turns.length; j++) {
        if (path[i] == turns[j]) {
          return path[i];
        }
      }
    }

    // If no number is greater than the target, return null
    if (path.length >= widget.user.pathobj.index) {
      return path[widget.user.pathobj.index];
    } else {
      return Cell(
          0,
          0,
          0,
          (double angle, {int? currPointer, int? totalCells}) {},
          0.0,
          0.0,
          "",
          0,
          0);
    }
  }

  String convertTolng(String msg, String lngcode, String direction,
      String direc, int nextTurn, String nearestBeacon) {
    if (msg == "Turn ${direction}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(direction, widget.context)} मुड़ें";
      }
    } else if (msg ==
        "Use this lift and go to ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} floor") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "इस लिफ़्ट का उपयोग करें और ${tools.numericalToAlphabetical(widget.user.pathobj.destinationFloor)} मंज़िल पर जाएँ";
      }
    } else if ((widget.user.pathobj.associateTurnWithLandmark[nextTurn] !=
                null &&
            widget.user.pathobj.associateTurnWithLandmark[nextTurn]!.name !=
                null) &&
        msg ==
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
    } else if (Building.apibeaconmap[nearestBeacon] != null &&
        msg ==
            "You have reached ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} floor") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${tools.numericalToAlphabetical(Building.apibeaconmap[nearestBeacon]!.floor!)} मंजिल पर पहुंच गए हैं";
      }
    } else if (msg ==
        "Turn ${LocaleData.getProperty5(widget.direction, widget.context)}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(widget.direction, widget.context)} मुड़ें";
      }
    } else if (msg == "Turn ${direction}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "${LocaleData.getProperty5(direction, widget.context)} मुड़ें";
      }
    } else if (msg ==
        "You have reached ${widget.user.pathobj.destinationName}") {
      if (lngcode == 'en') {
        return msg;
      } else {
        return "आप ${widget.user.pathobj.destinationName} पर पहुँच गए हैं।";
      }
    }
    return "";
  }

  @override
  void didUpdateWidget(DirectionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    final user = widget.user;
    final pathObj = user.pathobj;
    final currentFloor = user.floor;
    final currentBid = user.bid;
    final showCoordX = user.showcoordX;
    final showCoordY = user.showcoordY;
    final path = user.path;
    final cellPath = user.cellPath;

    // Check if user reached a connection point at the source floor
    if (_isAtSourceConnection(user)) {
      return;
    }

    // Process path updates if there are remaining steps
    if (path.isNotEmpty && cellPath.length - 1 > pathObj.index) {
      _updateDirectionOnPath(oldWidget, user);

      final remainingPath = cellPath.sublist(pathObj.index + 1);
      final nextTurn = findNextTurn(turnPoints, remainingPath);
      nextTurnIndex = pathObj.directions
          .indexWhere((element) => element.node == nextTurn.node);

      _updateDirectionIndexOnTurn(user);

      widget.distance = tools.distancebetweennodes_inCell(
          nextTurn, cellPath[pathObj.index]);

      final angle = _calculateAngle(user);
      final userAngle = tools.calculateAngleBWUserandCellPath(
          cellPath[pathObj.index],
          cellPath[pathObj.index + 1],
          pathObj.numCols![currentBid]![currentFloor]!,
          user.theta);

      final newUserDirection = tools.angleToClocks(userAngle, context);
      widget.direction = (newUserDirection == "None")
          ? oldWidget.direction
          : newUserDirection;

      if (newUserDirection == "Straight") {
        widget.direction = "Straight";
      }
      if (pathObj.index < 3) {
        widget.direction = newUserDirection;
      }
      print("userdirection $newUserDirection");

      if (UserCredentials().getUserPersonWithDisability() == 1 ||
          UserCredentials().getUserPersonWithDisability() == 2) {
        widget.direction = newUserDirection;
      }

      final turnIndex = cellPath.indexOf(nextTurn);
      turnDirection = _calculateTurnDirection(user, turnIndex, newUserDirection);
      print("turnDirection $turnDirection");
      print("widget.direction ${widget.direction}");

      _handleDirectionChange(oldWidget);

      _handleApproachingDestinationOrTurn(nextTurn, user);
    }
  }

  bool _isAtSourceConnection(UserState user) {
    final pathObj = user.pathobj;
    return user.floor == pathObj.sourceFloor &&
        pathObj.connections.isNotEmpty &&
        user.showcoordY * UserState.cols + user.showcoordX ==
            pathObj.connections[user.bid]?[pathObj.sourceFloor];
  }

  void _updateDirectionOnPath(DirectionHeader oldWidget, UserState user) {
    user.pathobj.connections.forEach((key, value) {
      value.forEach((inkey, invalue) {
        if (user.path[user.pathobj.index] == invalue) {
          widget.direction = "You have reached ";
        }
      });
    });
  }

  void _updateDirectionIndexOnTurn(UserState user) {
    if (turnPoints.contains(user.cellPath[user.pathobj.index])) {
      final currentIndex = user.pathobj.directions.indexWhere(
              (element) => element.node == user.cellPath[user.pathobj.index].node);
      if (currentIndex + 1 < user.pathobj.directions.length) {
        DirectionIndex = currentIndex + 1;
      }
      if (DirectionIndex >= user.pathobj.directions.length) {
        DirectionIndex = user.pathobj.directions.length - 1;
      }
    }
  }

  double _calculateAngle(UserState user) {
    final pathObj = user.pathobj;
    final cellPath = user.cellPath;
    final currentBid = user.bid;
    final currentFloor = user.floor;
    double angle = 0.0;
    try {
      angle = tools.calculateAnglefifth(
          cellPath[pathObj.index].node,
          cellPath[pathObj.index + 1].node,
          cellPath[pathObj.index + 2].node,
          pathObj.numCols![currentBid]![currentFloor]!);
    } catch (e) {
      print("error to be solved later $e");
    }
    if (pathObj.index != 0) {
      try {
        angle = tools.calculateAnglefifth(
            cellPath[pathObj.index - 1].node,
            cellPath[pathObj.index].node,
            cellPath[pathObj.index + 1].node,
            pathObj.numCols![currentBid]![currentFloor]!);
      } catch (e) {
        print("problem to be solved later $e");
      }
    }
    return angle;
  }

  String _calculateTurnDirection(UserState user, int turnIndex, String userDirection) {
    final pathObj = user.pathobj;
    final cellPath = user.cellPath;
    final currentBid = user.bid;
    final currentFloor = user.floor;
    double a = 0;
    if (turnIndex + 1 == user.path.length) {
      print("index+1");
      if (cellPath[turnIndex - 2].bid == cellPath[turnIndex - 1].bid &&
          cellPath[turnIndex - 1].bid == cellPath[turnIndex].bid) {
        a = tools.calculateAnglefifth(
            user.path[turnIndex - 2],
            user.path[turnIndex - 1],
            user.path[turnIndex],
            pathObj.numCols![currentBid]![currentFloor]!);
      }
    } else {
      print("index");
      if (cellPath[turnIndex - 1].bid == cellPath[turnIndex].bid &&
          cellPath[turnIndex].bid == cellPath[turnIndex + 1].bid) {
        a = tools.calculateAnglefifth(
            user.path[turnIndex - 1],
            user.path[turnIndex],
            user.path[turnIndex + 1],
            pathObj.numCols![currentBid]![currentFloor]!);
      }
    }
    return userDirection; // Directly using userDirection as it's already calculated
  }

  void _handleDirectionChange(DirectionHeader oldWidget) {
    if (oldWidget.direction != widget.direction) {
      if (oldWidget.direction == "Straight") {
        Vibration.vibrate();
        speak(
            convertTolng(
                "Turn ${LocaleData.getProperty5(widget.direction, context)}",
                _currentLocale,
                widget.direction,
                "",
                0,
                ""),
            _currentLocale,
            prevpause: true);
      } else if (widget.direction == "Straight") {
        Vibration.vibrate();
        UserState.isTurn = false;
        if (!UserState.ttsOnlyTurns) {
          speak(
              "${LocaleData.getProperty6('Go Straight', context)} ${tools.convertFeet(widget.distance, context)}}",
              _currentLocale,
              prevpause: true);
        }
      }
    }
  }

  void _handleApproachingDestinationOrTurn(Cell nextTurn, UserState user) {
    final pathObj = user.pathobj;
    final currentBid = user.bid;
    final currentFloor = user.floor;
    if (nextTurn == turnPoints.last && widget.distance == 7) {
      double angle = 0.0;
      try {
        angle = tools.calculateAngleThird(
            [pathObj.destinationX, pathObj.destinationY],
            user.path[pathObj.index + 1],
            user.path[pathObj.index + 2],
            pathObj.numCols![currentBid]![currentFloor]!);
      } catch (e) {
        print("problem to be solved later $e");
      }
      if (!UserState.ttsOnlyTurns) {
        speak(
            "${widget.direction} ${widget.distance} steps. ${pathObj.destinationName} will be ${tools.angleToClocks2(angle, widget.context)}",
            _currentLocale);
      }
      user.move(context);
    } else if (nextTurn != turnPoints.last &&
        pathObj.connections[currentBid]?[currentFloor] != nextTurn &&
        (widget.distance / UserState.stepSize).ceil() == 7) {
      final turnDirectionLower = turnDirection.toLowerCase();
      if (!turnDirectionLower.contains("slight") &&
          !turnDirectionLower.contains("straight") &&
          pathObj.index > 4) {
        final landmark = pathObj.associateTurnWithLandmark[nextTurn];
        if (landmark != null) {
          if (!UserState.ttsOnlyTurns) {
            speak(
                convertTolng(
                    "You are approaching ${turnDirection} turn from ${landmark.name!}",
                    _currentLocale,
                    '',
                    turnDirection,
                    nextTurn!.node,
                    ""),
                _currentLocale);
          }
          return;
        } else {
          if (!UserState.ttsOnlyTurns) {
            speak(
                convertTolng("You are approaching ${turnDirection} turn",
                    _currentLocale, '', turnDirection, nextTurn!.node, ""),
                _currentLocale);
          }
          user.move(widget.context);
          return;
        }
      }
    }
  }

  static Icon getCustomIcon(String direction) {
    if (direction.toLowerCase().contains("lift")) {
      return Icon(
        Icons.elevator,
        color: Color(0xff01544f),
        size: 32,
      );
    } else if (direction.toLowerCase().contains("stair")) {
      return Icon(
        Icons.stairs,
        color: Color(0xff01544f),
        size: 23,
      );
    } else if (direction == "Straight") {
      return Icon(
        Icons.straight,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Slight Right") {
      return Icon(
        Icons.turn_slight_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Right") {
      return Icon(
        Icons.turn_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Sharp Right") {
      return Icon(
        Icons.turn_sharp_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "U Turn") {
      return Icon(
        Icons.u_turn_right,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Sharp Left") {
      return Icon(
        Icons.turn_sharp_left,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Left") {
      return Icon(
        Icons.turn_left,
        color: Color(0xff01544f),
        size: 40,
      );
    } else if (direction == "Slight Left") {
      return Icon(
        Icons.turn_slight_left,
        color: Color(0xff01544f),
        size: 40,
      );
    } else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Color(0xff01544f),
        size: 40,
      );
    }
  }

  Icon getNextCustomIcon(String direction) {
    if (direction.toLowerCase().contains("lift")) {
      return Icon(
        Icons.elevator,
        color: Colors.white,
        size: 23,
      );
    } else if (direction.toLowerCase().contains("stair")) {
      return Icon(
        Icons.stairs_rounded,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Straight") {
      return Icon(
        Icons.straight,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Slight Right") {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Right") {
      return Icon(
        Icons.turn_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Sharp Right") {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "U Turn") {
      return Icon(
        Icons.u_turn_right,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Sharp Left") {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Left") {
      return Icon(
        Icons.turn_left,
        color: Colors.white,
        size: 23,
      );
    } else if (direction == "Slight Left") {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.white,
        size: 23,
      );
    } else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.white,
        size: 23,
      );
    }
  }

  Color getColor() {
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
    } catch (e) {
      return Color(0xff01544f);
    }
  }

  final Map<int, Map<String, double>> bin = {
    1: {'key1': 1.1, 'key2': 2.2},
    2: {'keyA': 3.3, 'keyB': 4.4},
  };

  @override
  Widget build(BuildContext context) {
    isSemanticEnabled = MediaQuery.of(context).accessibleNavigation;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    // String binString = btadapter.BIN.entries.map((entry) {
    //   int key = entry.key;
    //   Map<String, double> valueMap = entry.value;
    //   String valueString = valueMap.entries.map((e) {
    //     return '${e.key}: ${e.value}';
    //   }).join(', ');
    //   return 'BIN[$key]: {$valueString}';
    // }).join('\n');
    setState(() {});
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight),
      child: Semantics(
        excludeSemantics: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              margin: EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff01544f).withOpacity(0.4),
                      spreadRadius: 5, // How wide the shadow should be
                      blurRadius: 7, // How soft the shadow should be
                      offset: Offset(0, 3),
                    )
                  ],
                  color: getColor()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 44,
                      height: 44,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              if (DirectionIndex - 1 >= 1) {
                                DirectionIndex--;
                                widget.focusOnTurn(widget
                                    .user.pathobj.directions[DirectionIndex]);
                                if (DirectionIndex == nextTurnIndex) {
                                  widget.clearFocusTurnArrow();
                                }
                              }
                            });
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: DirectionIndex - 1 >= 1
                                ? Colors.white
                                : Colors.grey,
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  scrollableDirection(
                      "${widget.direction}",
                      '${tools.convertFeet(widget.distance, widget.context)}',
                      getCustomIcon(widget.direction),
                      DirectionIndex,
                      nextTurnIndex,
                      widget.user.pathobj.directions,
                      widget.user,
                      widget.context),
                  const SizedBox(
                    width: 8,
                  ),
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 44,
                      height: 44,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              if (DirectionIndex + 1 <
                                  widget.user.pathobj.directions.length) {
                                DirectionIndex++;
                                widget.focusOnTurn(widget
                                    .user.pathobj.directions[DirectionIndex]);
                                if (widget.user.pathobj.directions.length -
                                            DirectionIndex ==
                                        2 &&
                                    widget
                                            .user
                                            .pathobj
                                            .directions[DirectionIndex]
                                            .distanceToNextTurnInFeet !=
                                        null &&
                                    widget
                                            .user
                                            .pathobj
                                            .directions[DirectionIndex]
                                            .distanceToNextTurnInFeet! <=
                                        5 &&
                                    DirectionIndex + 1 <
                                        widget.user.pathobj.directions.length) {
                                  DirectionIndex++;
                                }
                                if (DirectionIndex == nextTurnIndex) {
                                  widget.clearFocusTurnArrow();
                                }
                              }
                            });
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: DirectionIndex + 1 <
                                    widget.user.pathobj.directions.length
                                ? Colors.white
                                : Colors.grey,
                            size: 24,
                          )),
                    ),
                  )
                ],
              ),
            ),
            DirectionIndex == nextTurnIndex
                ? Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 98,
                      height: 39,
                      margin: EdgeInsets.only(left: 9, top: 5),
                      padding: EdgeInsets.only(left: 16, right: 16),
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
                              height: 25 / 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          // Text(DirectionIndex.toString()),
                          // Text(nextTurnIndex.toString())
                          getNextCustomIcon(turnDirection)
                        ],
                      ),
                    ),
                  )
                : Container(),

            // Container(
            //   width: screenWidth,
            //   height: 300,
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         //Text("Beacon ${highestKey} - ${highestAverage}"),
            //         // Text(debuglNearestbeacon),
            //         Text(sumMap.entries.map((entry) => '${entry.key}: ${entry.value.join(", ")}').join("\n")),
            //         // //Text(displayString),
            //         // Text("-------"),
            //         Text(sumRSSI.toString()),
            //         Text(BluetoothScanAndroidClass().rssiWeight.toString()),
            //         Text("$debuglNearestbeacon $candorThreshold"),
            //
            //         // Text(Building.apibeaconmap.containsKey(debuglNearestbeacon).toString()),
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

  scrollableDirection(this.Direction, this.steps, this.i, this.DirectionIndex,
      this.nextTurnIndex, this.listOfDirections, this.user, this.context);

  String chooseDirection() {
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
          return angle != null
              ? "${listOfDirections[DirectionIndex].turnDirection} ${LocaleData.willbe.getString(context)} ${LocaleData.getProperty(tools.angleToClocks3(angle, context), context)}"
              : "${listOfDirections[DirectionIndex].turnDirection} ${LocaleData.willbeonyourfront.getString(context)}";
        } else if (nextTurnIndex == -1 || DirectionIndex == nextTurnIndex) {
          return "${Direction == "Straight" ? "${LocaleData.gostraight.getString(context)}" : LocaleData.getProperty(Direction, context)}";
        } else {
          if (DirectionIndex < listOfDirections.length) {
            return "${listOfDirections[DirectionIndex].turnDirection == "Straight" ? "${LocaleData.gostraight.getString(context)}" : "${LocaleData.getProperty(listOfDirections[DirectionIndex].turnDirection!, context)}"}";
          } else {
            return "${listOfDirections[DirectionIndex - 1].turnDirection == "Straight" ? "${LocaleData.gostraight.getString(context)}" : "${LocaleData.getProperty(listOfDirections[DirectionIndex - 1].turnDirection!, context)},"}";
          }
        }
      } else {
        return "${LocaleData.gostraight.getString(context)}";
      }
    } catch (e) {
      return "${LocaleData.gostraight.getString(context)}";
    }
  }

  String chooseSteps() {
    try {
      // print("DirectionIndex $DirectionIndex and $nextTurnIndex");
      if (listOfDirections.isNotEmpty && DirectionIndex < listOfDirections.length) {
        if (listOfDirections[DirectionIndex].isDestination) {
          return "";
        } else if (nextTurnIndex == -1 || DirectionIndex == nextTurnIndex) {
          return '$steps';
        } else {
          return '${tools.convertFeet((listOfDirections[DirectionIndex].distanceToNextTurnInFeet ?? 1).toInt(), context)}';
        }
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Icon chooseIcon() {
    try {
      if (listOfDirections.isNotEmpty &&
          DirectionIndex < listOfDirections.length) {
        if (listOfDirections[DirectionIndex].isDestination) {
          return const Icon(
            Icons.place_rounded,
            color: Colors.blueAccent,
            size: 40,
          );
        } else if (nextTurnIndex == -1 || DirectionIndex == nextTurnIndex) {
          return i;
        } else {
          return _DirectionHeaderState.getCustomIcon(
              listOfDirections[DirectionIndex].turnDirection!);
        }
      } else {
        return const Icon(Icons.straight);
      }
    } catch (e) {
      return const Icon(Icons.straight);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: "${chooseDirection()} ${chooseSteps()}",
              excludeSemantics: true,
              child: Center(
                child: Text(
                  chooseDirection(),
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 30 / 24,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Semantics(
            excludeSemantics: true,
            child: Container(
              width: 85,
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ((chooseDirection().toLowerCase().contains("lift") ||
                      chooseDirection()
                          .toLowerCase()
                          .contains("stair")) ||
                      listOfDirections.isEmpty ||
                      (DirectionIndex > 0 &&
                          listOfDirections.length > DirectionIndex &&
                          listOfDirections[DirectionIndex].isDestination))
                      ? Container()
                      : Text(
                    chooseSteps().replaceAll("meter", "m"),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 26 / 16,
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
                    child:
                    chooseIcon(), // Your icon or widget inside the circle
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
