
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
        isLoading_buildingList = false; // Set loading to false when data is loaded
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              : AnimationLimiter(
          child: ListView.builder(
            itemCount: buildingList.length,
            itemBuilder: (context, index) {
              // Apply animation to each ListTile
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: ListTile(
                      title: Text(buildingList[index].buildingName!),
                      subtitle: Text(buildingList[index].sId!),
                      onTap: () {
                        // Navigate to a new screen on tap
                        print("buildingList[index].sId!");
                        print(buildingList[index].sId!);
                        buildingAllApi.setStoredString(buildingList[index].sId!);
                        print(buildingAllApi.getStoredString());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Navigation(buildingID: buildingList[index].sId!),
                          ),
                        );                      },
                      // Add more UI elements based on your data
                    ),
                  ),
                ),
              );
            },
          ),
        ),

      ),
    );
  }



}