import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/low_fedility/searchBar.dart';
import 'package:iwaymaps/NAVIGATION/low_fedility/searchResult.dart';
import '../../IWAYPLUS/API/buildingAllApi.dart';
import '../API/ladmarkApi.dart';
import '../APIMODELS/landmark.dart';
import '../navigationTools.dart';
import '../singletonClass.dart';
import 'header.dart';
import 'loadingScreen.dart';
import 'nearbyPlaces.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  static Function relocalize=() {};
  static final GlobalKey<_HomepageState> homePageKey = GlobalKey<_HomepageState>();

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool loading = true;
  Landmarks? detectedLocation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchlist();
  }

  List<Widget> nearbyFacilities = [];

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

  void hideLoading() {
    setState(() {
      loading = false;
    });
  }

  Future<void> locationDetected(Landmarks landmark) async {
    detectedLocation = landmark;
    await fetchNearbyFacilities(detectedLocation, landmarkData) ?? [];
  }

  Future<List<Widget>?> fetchNearbyFacilities(Landmarks? detectedLocation, land landmarkData) async {
    if(detectedLocation == null){
      return null;
    }
    try {
      nearbyFacilities.clear();
      // Create a map to store the nearest facility for each type
      Map<String, Searchresult> nearestFacilities = {};

      await Future.forEach(landmarkData.landmarksMap!.entries, (MapEntry keyValue) async {
        var value = keyValue.value;
        print("landmarks");
        // Check if the value has a valid name and subType matches the specified types
        if (value.name != null &&
            (value.element!.subType == "restRoom" ||
                value.element!.subType == "Cafeteria" ||
                value.element!.subType == "main entry" ||
                value.element!.subType == "Help Desk | Reception" ||
                value.element!.subType == "lift" ||
                value.element!.subType == "ATM" ||
                value.element!.subType == "Drinking Water")) {
          // Check if the landmark is within 20 meters of the detected location and belongs to the same building and floor
          if (detectedLocation!.buildingID == value.buildingID && detectedLocation!.floor == value.floor) {
            // Get the current subType of the landmark
            String subType = value.element!.subType!;

            // If the subType is not already added or if the current facility is closer, update it in the map
            if (!nearestFacilities.containsKey(subType) ||
                tools.calculateDistance([detectedLocation!.coordinateX!, detectedLocation!.coordinateY!],
                    [value.coordinateX!, value.coordinateY!]) <
                    tools.calculateDistance([detectedLocation!.coordinateX!, detectedLocation!.coordinateY!],
                        [nearestFacilities[subType]!.Location.coordinateX!, nearestFacilities[subType]!.Location.coordinateY!])) {

              // Add the nearest facility of this type to the map
              print("adding landmark");
              nearestFacilities[subType] = Searchresult(detectedLocation, Location: value);
            }
          }
        }
      });

      // Add the nearest facilities to the nearbyFacilities list
      nearestFacilities.forEach((key, value) {
        nearbyFacilities.add(value);
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Prevents Material effects from showing
      child: SafeArea(
        child: loading
            ? LoadingScreen()
            : Stack(
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header(detectedLocation),
                        searchBar(),
                        Expanded(
                          // Use Expanded to take up remaining space
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: nearbyFacilities,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                      child: Container(
                        width: 413,
                        height: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Nearbyplaces(detectedLocation: detectedLocation,),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Color(0xffFFD700),
                            elevation: 0, // Zero elevation
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // Square shape with no border radius
                            ),
                          ),
                          child: const SizedBox(
                            width: 385,
                            height: 56,
                            child: Center(
                              child: Text(
                                'SEARCH NEARBY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),))
                ],
              ),
      ),
    );
  }
}
