import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/BuildingInfoScreen.dart';
import 'package:iwaymaps/DATABASE/BOXES/FavouriteDataBaseModelBox.dart';
import '../API/buildingAllApi.dart';
import '../APIMODELS/buildingAll.dart';
import '../DATABASE/BOXES/BuildingAPIModelBox.dart';
import '../DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import '../DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import '../Navigation.dart';

class NavigatonFilterCard extends StatefulWidget {
  String LandmarkName;
  String LandmarkFloor;
  String LandmarksubName;
  String LandmarkDistance;

  NavigatonFilterCard(
      {required this.LandmarkName,
        required this.LandmarkFloor,
        required this.LandmarksubName,
        required this.LandmarkDistance,
      });

  @override
  _NavigatonFilterCardState createState() => _NavigatonFilterCardState();

}

class _NavigatonFilterCardState extends State<NavigatonFilterCard> {
  //bool isFavourite = false;
  var favouriteBox = FavouriteDataBaseModelBox.getData();

  String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + '..';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Container(
      margin: EdgeInsets.only(left: 16,top: 10,right: 16),
      width: 184,
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
                  truncateString(widget.LandmarkName,20),
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
                  truncateString(widget.LandmarksubName,25),
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
                  truncateString(widget.LandmarkDistance,15),
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
                  truncateString(widget.LandmarkFloor,25),
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
    );
  }
}

