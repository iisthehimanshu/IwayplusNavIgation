
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/beaconData.dart';
import 'package:iwaymaps/NAVIGATION/MapManager/GoogleMapManager.dart';
import 'package:iwaymaps/NAVIGATION/MapManager/RenderingManager.dart';
import 'package:iwaymaps/NAVIGATION/VenueManager/VenueManager.dart';

import '../APIMODELS/landmark.dart';
import '../BluetoothManager/BLEManager.dart';
import '../Panel Manager/PanelManager.dart';
import '../Panel Manager/PanelState.dart';
import '../navigationTools.dart';

class LocalizedScreenViewModel with ChangeNotifier{
  String _nearestBeacon = "";
  String? get nearestBeacon => _nearestBeacon;
  late beacon _localizedBeaconDetails;



  set setNearestBeacon(String value){
    _nearestBeacon = value;
    print("_nearestBeacon $_nearestBeacon");
    doTastTOOPen();
    notifyListeners();
  }

  void doTastTOOPen() async {
    await BLEManager().waitForBufferEmitCompletion().then((_) async {
      print("timerCompleted");
      PanelManager().showPanel(PanelState.localized);
      BLEManager().stopScanning();
      List<dynamic>? allBeaconData = await VenueManager().getBeaconDataAllBuildings();

      print("allBeaconData $allBeaconData");

      if(allBeaconData!.isNotEmpty){
        for(int i=0 ; i<allBeaconData.length ; i++){
          if(allBeaconData[i].name == nearestBeacon){
            _localizedBeaconDetails = allBeaconData[i] as beacon;
            if(VenueManager().focusedBuilding!=null){
              VenueManager().focusedBuilding = allBeaconData[i].buildingID;
            }
            List<double> localToGlobalBeaconXY = tools.localtoglobal(_localizedBeaconDetails.coordinateX!, _localizedBeaconDetails.coordinateY!, await VenueManager().getPatchData(VenueManager().focusedBuilding!));
            print("localToGlobalBeaconXY $localToGlobalBeaconXY");
            GoogleMapManager(PanelManager()).moveCameraTo(LatLng(localToGlobalBeaconXY[0],localToGlobalBeaconXY[1]),zoom: 22);
            GoogleMapManager(PanelManager()).changeFloorOfBuilding(allBeaconData[i].buildingID, allBeaconData[i].floor);
            RenderingManager().addNewMarker(_localizedBeaconDetails, localToGlobalBeaconXY);

            break;
          }
        }
      }
      notifyListeners();
    });
  }

  final List<land> _nearestLandmark = [];
  List<land> get nearestLandmark => _nearestLandmark;
  void foundNearestLandmark(){}

  void resetBeaconState() {
    _nearestBeacon = "";
    PanelManager().showPanel(PanelState.none);
  }
}