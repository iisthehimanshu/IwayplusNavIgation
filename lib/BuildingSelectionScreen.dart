
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwayplusnav/Elements/buildingCard.dart';

import 'API/buildingAllApi.dart';
import 'APIMODELS/buildingAllModel.dart';
import 'Navigation.dart';

class BuildingSelectionScreen extends StatefulWidget{
  @override
  State<BuildingSelectionScreen> createState() => _BuildingSelectionScreenState();
}

class _BuildingSelectionScreenState extends State<BuildingSelectionScreen>{
  late List<buildingAllModel> buildingList=[];
  bool isLoading_buildingList = true;
  List<Widget> BuildingCard = [];
  @override
  void initState(){
    super.initState();
    apiCall();

  }
  void apiCall() async  {
    await Future.delayed(Duration(milliseconds: 1300));
    await buildingAllApi().fetchBuildingAllData().then((value) {
      setState(() {
        buildingList = value;
        createBuildingCards(buildingList);
        isLoading_buildingList = false; // Set loading to false when data is loaded
      });
    });
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Iwayplus",
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 24,
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Color(0x204A4545),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  // Handle search icon pressed
                  // You can add your search functionality here
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                iconSize: 30,
              ),
            ),
          ],
          backgroundColor: Color(0xffFFFFFF),
          elevation: 0,
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
              : SingleChildScrollView(
                child: Column(
          children: BuildingCard,
        ),
              )

      ),
    );
  }



}