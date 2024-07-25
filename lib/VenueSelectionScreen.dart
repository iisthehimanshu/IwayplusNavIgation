





import 'dart:collection';

import 'dart:math';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/API/BuildingAPI.dart';
import 'package:iwaymaps/API/RefreshTokenAPI.dart';
import 'package:iwaymaps/API/UsergetAPI.dart';
import 'package:iwaymaps/DATABASE/BOXES/WayPointModelBOX.dart';
import 'package:iwaymaps/Elements/UserCredential.dart';
import 'package:iwaymaps/Elements/buildingCard.dart';
import 'package:iwaymaps/MODELS/VenueModel.dart';
import 'package:permission_handler/permission_handler.dart';

import 'API/buildingAllApi.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/buildingAll.dart';
import 'APIMODELS/patchDataModel.dart';
import 'BuildingInfoScreen.dart';
import 'DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'DATABASE/BOXES/PatchAPIModelBox.dart';
import 'DATABASE/BOXES/PolyLineAPIModelBOX.dart';
import 'HomeNestedSearch.dart';

class VenueSelectionScreen extends StatefulWidget{

  VenueSelectionScreen({super.key});
  @override
  State<VenueSelectionScreen> createState() => _VenueSelectionScreenState();
}

class _VenueSelectionScreenState extends State<VenueSelectionScreen>{
  late List<buildingAll> buildingList=[];
  late List<buildingAll> newbuildingList=[];
  bool isLoading_buildingList = true;
  List<Widget> BuildingCard = [];
  late List<VenueModel> venueList=[];
  late Map<String, List<buildingAll>> venueHashMap = new HashMap();
  // Replace with your actual document ID
  bool checkedForBuildingAllUpdated = false;
  bool isLocating=false;


  @override
  void initState(){
    super.initState();
    getLocs();
    apiCall();

    print("venueHashMap");
    print(venueHashMap);





  }

  void loadInfoToFile(){
    var infoBox=Hive.box('SignInDatabase');
    String accessToken = infoBox.get('accessToken');
    print('loadInfoToFile');
    print(infoBox.get('userId'));

    UsergetAPI().getUserDetailsApi(infoBox.get('userId'));

  }


  void getLocs()async{
    setState(() {
      isLocating=true;
    });
    userLoc= await getUsersCurrentLatLng();
    if(mounted){
      setState(() {
        isLocating=false;

      });
    }

  }
  var locBox=Hive.box('LocationPermission');
  Position? userLoc;
  Future<Position?> getUsersCurrentLatLng()async{

    if ((locBox.get('location')==null)?false:locBox.get('location')) {

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


      return position;


    }else{
      Position pos=Position(longitude: 77.1852061, latitude:  28.5436197, timestamp: DateTime.now(), accuracy: 100, altitude: 1, altitudeAccuracy: 100, heading: 10, headingAccuracy: 100, speed: 100, speedAccuracy: 100);
      return pos;
    }





  }

  void apiCall() async  {
    // print('Running api');
    //await Future.delayed(Duration(milliseconds: 1300));
    await buildingAllApi().fetchBuildingAllData().then((value) {
      print(value);
      setState(() {
        buildingList = value;
        newbuildingList = value;
        createBuildingCards(buildingList);
        isLoading_buildingList = false; // Set loading to false when data is loaded
      });
    });

    print("print after");
    //filterVenueList(buildingList);
    print(venueList);
    venueHashMap = createVenueHashMap(buildingList);


    print(venueHashMap.keys);
    //venueList = venueHashMap.keys
    venueList = createVenueList(venueHashMap);
    for(int i=0;i<venueList.length;i++)
    {
      buildingsPos.add(venueList[i]);
    }

    loadInfoToFile();

  }
  int getDistanceFromLatLonInKm(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the earth in km
    double dLat = deg2rad(lat2 - lat1); // deg2rad below
    double dLon = deg2rad(lon2 - lon1);
    double a = pow(sin(dLat / 2), 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = R * c; // Distance in km
    return d.toInt();
  }

  double deg2rad(double deg) {
    return deg * (pi / 180);
  }

  List<VenueModel> createVenueList(Map<String, List<buildingAll>> venueHashMap){
    List<VenueModel> newList = [];
    for (var entry in venueHashMap.entries) {
      String key = entry.key;
      List<buildingAll> value = entry.value;
      newList.add(VenueModel(venueName: key, distance: 190, buildingNumber: value.length, imageURL: value[0].venuePhoto??"", Tag: value[0].venueCategory??"", address: value[0].address,description: value[0].description,phoneNo: value[0].phone,website: value[0].website,coordinates: value[0].coordinates!, dist: 0));
      // print('Key: $key');
      // print('Value: $value');
    }
    return newList;
  }

  Map<String, List<buildingAll>> createVenueHashMap(List<buildingAll> buildingList) {
    Map<String, List<buildingAll>> dummyVenueHashMap = HashMap<String, List<buildingAll>>();

    for (buildingAll building in buildingList) {
      // Check if the venueName is already a key in the HashMap
      if (dummyVenueHashMap.containsKey(building.venueName)) {
        // If yes, add the building to the existing list
        dummyVenueHashMap[building.venueName]!.add(building);
      } else {
        // If no, create a new list with the building and add it to the HashMap
        dummyVenueHashMap[building.venueName??""] = [building];
      }
    }
    return dummyVenueHashMap;
  }

  void createBuildingCards(List<buildingAll> buildingList){
    setState(() {

      BuildingCard.add(SizedBox(height: 12,));
      for(int i = 0; i<buildingList.length; i++){
        BuildingCard.add(buildingCard(imageURL: buildingList[i].venuePhoto != null? buildingList[i].venuePhoto!:"", Name: buildingList[i].buildingName!, Tag: buildingList[i].venueCategory != null?buildingList[i].venueCategory!:"", Address: buildingList[i].address!, Distance: 119, NumberofBuildings: 3, bid: buildingList[i].sId!,));
      }
    });
  }

  void showToast(String mssg) {
    Fluttertoast.showToast(
      msg: mssg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // calcDistanceFromUser(List<VenueModel> buildingsPos,Position userLoc){
  //   // buildingsPos.clear();
  //   // finalDist.clear();

  //   print(buildingsPos[0].coordinates);

  //   for(int i=0;i<buildingsPos.length;i++){
  //     int dist=getDistanceFromLatLonInKm(buildingsPos[i].coordinates[0],buildingsPos[i].coordinates[1],userLoc.latitude,userLoc.longitude);
  //     buildingsPos[i].dist=dist;
  //     finalDist.add(dist);


  //   }
  //   // print("finalDist");
  //   // print(finalDist);
  // }
  List<VenueModel> buildingsPos=[];
  List<int> finalDist=[];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            label: "Iwayplus",
            child: InkWell(
              onTap: (){
                RefreshTokenAPI.refresh();
              },
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Iwayplus",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff000000),
                  ),
                ),
              ),
            ),
          ),
          centerTitle: true,
          leading: ExcludeSemantics(
            child: EasterEggTrigger(
              child: Container(
                alignment: Alignment.centerRight,
                width: 60,
                child: SvgPicture.asset("assets/MainScreen_IwayplusLogo.svg"),
              ),codes: [
              EasterEggTriggers.SwipeDown,
              EasterEggTriggers.LongPress,
            ],
              action: (){
                final BeaconBox = BeaconAPIModelBOX.getData();
                final BuildingAllBox = BuildingAllAPIModelBOX.getData();
                final LandMarkBox = LandMarkApiModelBox.getData();
                final PatchBox = PatchAPIModelBox.getData();
                final PolyLineBox = PolylineAPIModelBOX.getData();
                final WayPointBox = WayPointModeBOX.getData();

                BeaconBox.clear();
                BuildingAllBox.clear();
                LandMarkBox.clear();
                PatchBox.clear();
                PolyLineBox.clear();
                WayPointBox.clear();
                showToast("Database Cleared ${BeaconBox.length},${BuildingAllBox.length},${LandMarkBox.length},${PatchBox.length},${PolyLineBox.length},${WayPointBox.length}");

              },
            ),
          ),

          actions: [
            Container(
                margin: EdgeInsets.only(right: 20),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8.0),
                //   border: Border.all(
                //     color: Color(0x204A4545),
                //   ),
                // ),
                child: IconButton(
                  icon: Semantics(
                      label: "Search",
                      child: Icon(Icons.search,color: Colors.black,)),
                  color: Color(0xff000000),
                  onPressed: () {
                    showSearch(context: context, delegate: HomeNestedSearch(newbuildingList));
                  },
                ))
          ],
          backgroundColor: Colors.transparent, // Set the background color to transparent
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], // Set your gradient colors
              ),
            ),
          ),
        ),
        body:(isLocating)? Center(
            child: Animate(
                effects: [FadeEffect(), ScaleEffect()],
                child: Text("Loading Data. . .",style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 30,
                  color: Color(0xFF666870),
                  height: 1,
                  letterSpacing: -1,
                ),)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                    .animate() // this wraps the previous Animate in another Animate
                    .fade(duration: 1200.ms, curve: Curves.ease)
                    .slide()
            )
          // Show linear loading indicator
        ):isLoading_buildingList
            ? Center(
            child: Animate(
                effects: [FadeEffect(), ScaleEffect()],
                child: Text("Loading Data. . .",style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 30,
                  color: Color(0xFF666870),
                  height: 1,
                  letterSpacing: -1,
                ),)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                    .animate() // this wraps the previous Animate in another Animate
                    .fade(duration: 1200.ms, curve: Curves.ease)
                    .slide()
            )
          // Show linear loading indicator
        )
            : DefaultTabController(

            length: 4,
            child: Column(
              children: [
                Material(
                  child: Container(
                    height: 55,
                    color: Color(0xffFFFFFF),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], // Set your gradient colors
                        ),
                      ),
                      child: TabBar(
                        unselectedLabelColor: Color(0xffB3B3B3),
                        isScrollable: false,
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        tabs: [
                          Tab(
                            child: Container(
                              height: 35,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("All"),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              height: 35,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Academic"),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              height: 35,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Hospital"),
                              ),
                            ),
                          ),
                          // Tab(child: Container(
                          //   height: 35,
                          //   child: Align(
                          //     alignment: Alignment.center,
                          //     child: Text("Mall"),
                          //   ),
                          // ),
                          // ),
                          Tab(child: Container(
                            height: 35,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Event"),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          itemBuilder: (context,index){

                             var currentData = venueList[index];


                            // calcDistanceFromUser(buildingsPos,userLoc!);
                            // buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            //var currentData = buildingsPos[index];



                            return GestureDetector(
                              onTap: () {
                                // Handle onTap for the specific item here
                                // For example, you can navigate to a new screen or perform some action
                                // print("Tapped on item at index $index");
                                buildingAllApi.setStoredVenue(currentData.venueName!);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc,),
                                  ),
                                );
                              },
                              child: buildingCard(
                                imageURL: "",
                                Name: currentData.venueName ?? "",
                                Tag: currentData.Tag ?? "Null",
                                Address: currentData.address ?? "",
                                Distance:buildingsPos[index].dist,
                                NumberofBuildings: currentData.buildingNumber ?? 0,
                                bid: currentData.venueName ?? "",

                              ),
                            );
                          },
                          itemCount: venueList.length,
                        ),
                        ListView.builder(
                          itemBuilder: (context, index) {

                            // calcDistanceFromUser(buildingsPos,userLoc!);
                            // buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            var currentData = buildingsPos[index];
                            if (currentData.Tag == "Academic") {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc),
                                    ),
                                  );
                                },
                                child: buildingCard(imageURL: "",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: buildingsPos[index].dist, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // Empty widget if not Hospital
                            }
                          },
                          itemCount: venueList.length,
                        ),
                        ListView.builder(
                          itemBuilder: (context, index) {

                            // calcDistanceFromUser(buildingsPos,userLoc!);
                            // buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            var currentData = buildingsPos[index];
                            if (currentData.Tag == "Hospital") {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc),
                                    ),
                                  );
                                },
                                child: buildingCard(imageURL: "",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: buildingsPos[index].dist, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // Empty widget if not Hospital
                            }
                          },
                          itemCount: venueList.length,
                        ),
                        // ListView.builder(
                        //   itemBuilder: (context, index) {
                        //     var currentData = newbuildingList[index];
                        //     if (currentData.category == "Mall") {
                        //       return buildingCard(
                        //         imageURL: currentData.photo ?? "",
                        //         Name: currentData.buildingName ?? "",
                        //         Tag: currentData.category ?? "",
                        //         Address: currentData.address ?? "",
                        //         Distance: 190,
                        //         NumberofBuildings: 3,
                        //         bid: currentData.sId ?? "",
                        //       );
                        //     } else {
                        //       return SizedBox.shrink(); // Empty widget if not Hospital
                        //     }
                        //   },
                        //   itemCount: newbuildingList.length,
                        // ),
                        ListView.builder(
                          itemBuilder: (context, index) {

                            // calcDistanceFromUser(buildingsPos,userLoc!);
                            // buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            var currentData = buildingsPos[index];
                            if (currentData.Tag == "Event") {
                              return GestureDetector(
                                onTap: () {
                                  print("Object Handeling");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc),
                                    ),
                                  );
                                },
                                child: buildingCard(imageURL: "",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: buildingsPos[index].dist, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // Empty widget if not Hospital
                            }
                          },
                          itemCount: venueList.length,
                        ),

                      ],

                    )
                )
              ],
            )
        )

        // AnimationLimiter(
        //   child: ListView.builder(
        //     itemCount: newbuildingList.length,
        //     itemBuilder: (context, index) {
        //       // Apply animation to each ListTile
        //       return AnimationConfiguration.staggeredList(
        //         position: index,
        //         duration: const Duration(milliseconds: 500),
        //         child: SlideAnimation(
        //           verticalOffset: 50.0,
        //           child: FadeInAnimation(
        //             child: buildingCard(imageURL: newbuildingList[index].photo??"",
        //               Name: newbuildingList[index].buildingName??"",
        //               Tag: newbuildingList[index].category?? "", Address: newbuildingList[index].address?? "", Distance: 190, NumberofBuildings: 3, bid: newbuildingList[index].sId??"",)
        //           ),
        //
        //         ),
        //
        //       );
        //     },
        //
        //   ),
        // )


      ),
    );
  }
}


