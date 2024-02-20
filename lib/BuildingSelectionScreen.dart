
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwayplusnav/Elements/buildingCard.dart';
import 'package:iwayplusnav/MODELS/VenueModel.dart';

import 'API/buildingAllApi.dart';
import 'APIMODELS/buildingAllModel.dart';
import 'BuildingInfoScreen.dart';
import 'HomeNestedSearch.dart';

class BuildingSelectionScreen extends StatefulWidget{
  @override
  State<BuildingSelectionScreen> createState() => _BuildingSelectionScreenState();
}

class _BuildingSelectionScreenState extends State<BuildingSelectionScreen>{
  late List<buildingAllModel> buildingList=[];
  late List<buildingAllModel> newbuildingList=[];
  bool isLoading_buildingList = true;
  List<Widget> BuildingCard = [];
  late List<VenueModel> venueList=[];
  late Map<String, List<buildingAllModel>> venueHashMap = new HashMap();


  @override
  void initState(){
    super.initState();
    apiCall();
    // print("object");
  }

  void apiCall() async  {
    // print('Running api');
    await Future.delayed(Duration(milliseconds: 1300));
    await buildingAllApi().fetchBuildingAllData().then((value) {
      setState(() {
        buildingList = value;
        newbuildingList = value;
        createBuildingCards(buildingList);
        isLoading_buildingList = false; // Set loading to false when data is loaded
      });
    });
    // print("print after");
    //filterVenueList(buildingList);
    print(venueList);
    venueHashMap = createVenueHashMap(buildingList);
    print(venueHashMap.keys);
    //venueList = venueHashMap.keys
    venueList = createVenueList(venueHashMap);
  }

  List<VenueModel> createVenueList(Map<String, List<buildingAllModel>> venueHashMap){
    List<VenueModel> newList = [];
    for (var entry in venueHashMap.entries) {
      String key = entry.key;
      List<buildingAllModel> value = entry.value;
      newList.add(VenueModel(venueName: key, distance: 190, buildingNumber: value.length, imageURL: value[0].photo??"", Tag: value[0].category??"", address: value[0].address));
      // print('Key: $key');
      // print('Value: $value');
    }
    return newList;
  }

  Map<String, List<buildingAllModel>> createVenueHashMap(List<buildingAllModel> buildingList) {
    Map<String, List<buildingAllModel>> dummyVenueHashMap = HashMap<String, List<buildingAllModel>>();

    for (buildingAllModel building in buildingList) {
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



  void createBuildingCards(List<buildingAllModel> buildingList){
    setState(() {

      BuildingCard.add(SizedBox(height: 12,));
      for(int i = 0; i<buildingList.length; i++){
        BuildingCard.add(buildingCard(imageURL: buildingList[i].photo != null? buildingList[i].photo!:"", Name: buildingList[i].buildingName!, Tag: buildingList[i].category != null?buildingList[i].category!:"", Address: buildingList[i].address!, Distance: 119, NumberofBuildings: 3, bid: buildingList[i].sId!,));
      }
    });
  }






  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Container(
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
          centerTitle: true,
          leading: Container(
            alignment: Alignment.centerRight,
            width: 60,
            child: SvgPicture.asset("assets/MainScreen_IwayplusLogo.svg"),
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
                icon: Icon(Icons.search),
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
        body: isLoading_buildingList
                ? Center(
                child: Animate(
                    effects: [FadeEffect(), ScaleEffect()],
                    child: Text("Loading Data!!",style: TextStyle(
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
                          // isScrollable: true,
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
                                return GestureDetector(
                                  onTap: () {
                                    // Handle onTap for the specific item here
                                    // For example, you can navigate to a new screen or perform some action
                                    // print("Tapped on item at index $index");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName]),
                                      ),
                                    );
                                  },
                                  child: buildingCard(
                                    imageURL: currentData.imageURL ?? "",
                                    Name: currentData.venueName ?? "",
                                    Tag: currentData.Tag ?? "",
                                    Address: currentData.address ?? "",
                                    Distance: 190,
                                    NumberofBuildings: currentData.buildingNumber ?? 0,
                                    bid: currentData.venueName ?? "",
                                  ),
                                );
                              },
                              itemCount: venueList.length,
                          ),
                          ListView.builder(
                            itemBuilder: (context, index) {
                              var currentData = venueList[index];
                              if (currentData.Tag == "Academic") {
                                return buildingCard(imageURL: currentData.imageURL??"",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: 190, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
                                );
                              } else {
                                return SizedBox.shrink(); // Empty widget if not Hospital
                              }
                            },
                            itemCount: venueList.length,
                          ),
                          ListView.builder(
                            itemBuilder: (context, index) {
                              var currentData = venueList[index];
                              if (currentData.Tag == "Hospital") {
                                return buildingCard(imageURL: currentData.imageURL??"",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: 190, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
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
                              var currentData = venueList[index];
                              if (currentData.Tag == "Event") {
                                return buildingCard(imageURL: currentData.imageURL??"",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: 190, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
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
    ,

      ),
    );
  }


}
