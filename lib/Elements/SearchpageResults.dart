import 'package:flutter/material.dart';
import 'package:iwayplusnav/Elements/HelperClass.dart';
import 'package:iwayplusnav/UserState.dart';

import '../navigationTools.dart';
class SearchpageResults extends StatefulWidget {
  final Function(String name, String location, String ID, String bid) onClicked;
  final String name;
  final String location;
  final String ID;
  final String bid;
  final String floor;
  int coordX;
  int coordY;
  // String LandmarkName;
  // String LandmarkFloor;
  // String LandmarksubName;
  // String LandmarkDistance;
  SearchpageResults({required this.name,required this.location,required this.onClicked,required this.ID,required this.bid,required this.floor,required this.coordX,required this.coordY});

  @override
  State<SearchpageResults> createState() => _SearchpageResultsState();
}

class _SearchpageResultsState extends State<SearchpageResults> {

  double distance = 0.0;
  @override
  void initState(){
    super.initState();
    if(widget.coordX == 0 || widget.coordY == 0 || UserState.BeaconCoordX == 0 || UserState.BeaconCoordY==0){
      distance = 0.0;
      print("inif");
    }else {
      print("inelse");
      List<int> landCord = [];
      landCord.add(widget.coordX);
      landCord.add(widget.coordY);
      List<int> beacondCord = [];
      beacondCord.add(UserState.BeaconCoordX);
      beacondCord.add(UserState.BeaconCoordY);
      distance = tools.calculateDistance(landCord, beacondCord);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: (){
        widget.onClicked(widget.name, widget.location, widget.ID,widget.bid);
      },
      child: Container(
        margin: EdgeInsets.only(top: 10,left: 16,right: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xffEBEBEB),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 8,),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5), // Specify the background color here
              ),
              child: Icon(Icons.man,color: Color(0xff000000),size: 25,),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12,left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(widget.name,20),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:3,bottom: 14,left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(widget.location,25),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12,left: 8,right:16 ),
                  alignment: Alignment.center,
                  child: Text(
                    HelperClass.truncateString(distance!=0.0? distance.toString() : 0.0.toString(),15),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                      height: 25/16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:3,bottom: 14,right:10 ),
                  alignment: Alignment.center,
                  child: Text(
                    HelperClass.truncateString("Floor ${widget.floor}",25),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                      height: 20/14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
