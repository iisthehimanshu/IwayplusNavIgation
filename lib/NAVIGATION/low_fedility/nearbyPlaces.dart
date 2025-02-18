import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/low_fedility/searchResult.dart';

import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../API/ladmarkApi.dart';
import '../APIMODELS/landmark.dart';
import '../navigationTools.dart';
import '../singletonClass.dart';

class Nearbyplaces extends StatefulWidget {
  Landmarks? detectedLocation;
  Nearbyplaces({super.key, required this.detectedLocation});

  @override
  State<Nearbyplaces> createState() => _NearbyplacesState();
}

class _NearbyplacesState extends State<Nearbyplaces> {

  List<Widget>? nearbyFacilities = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    nearbyFacilities = await fetchNearbyPlaces(widget.detectedLocation);
    setState(() {});
  }

  Future<List<Widget>?> fetchNearbyPlaces(Landmarks? detectedLocation) async {
    if(detectedLocation == null){
      return null;
    }
    List<Widget>? nearbyFacilities = [];
    await fetchlist();
    try {
      await Future.forEach(landmarkData.landmarksMap!.entries, (MapEntry keyValue) async {
        var value = keyValue.value;
        if (detectedLocation!.sId != value.sId && detectedLocation!.buildingID == value.buildingID && detectedLocation!.floor == value.floor && value.name != null && value.element!.subType != "beacons" && tools.calculateDistance([detectedLocation.coordinateX!,detectedLocation.coordinateY!], [value!.coordinateX!,value!.coordinateY!])<35) {
          nearbyFacilities.add(Searchresult(detectedLocation, Location: value));
        }
      });

      if(nearbyFacilities.isNotEmpty){
        nearbyFacilities.insert(0, Container(
          margin: EdgeInsets.only(left: 13),
          child: Text(
            'Nearby Facilities',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.20,
            ),
          ),));
      }

    } catch (e) {
      print("Error in updating list: $e");
    }

    return nearbyFacilities.isEmpty?null:nearbyFacilities;
  }

  land landmarkData = land();
  Future<void> fetchlist() async {
    land? singletonData =
    await SingletonFunctionController.building.landmarkdata;

    if (singletonData != null) {
      landmarkData = singletonData;
      return;
    }

    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      await landmarkApi().fetchLandmarkData(id: key).then((value) {
        landmarkData.mergeLandmarks(value.landmarks);
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: nearbyFacilities==null?Center(child: Text(
          'No Nearby Items Found',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.20,
          ),
        ),):Container(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {Navigator.pop(context);},
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      elevation: 0, // Zero elevation
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // Square shape with no border radius
                      ),
                    ),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 32, // Icon size 24x24
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Nearby Places',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Expanded(
                // Use Expanded to take up remaining space
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nearbyFacilities!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
