import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchNearby extends StatefulWidget {
  const SearchNearby({super.key});

  @override
  State<SearchNearby> createState() => _SearchNearbyState();
}

class _SearchNearbyState extends State<SearchNearby> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth-32,
      margin: EdgeInsets.only(left: 16,right: 16),
      padding: EdgeInsets.fromLTRB(17, 20, 18, 21),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xffEBEBEB), // Set the color of the border
          width: 2.0, // Set the width of the border
        ),
        borderRadius: BorderRadius.circular(4.0), // Set the border radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Search nearby",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xff000000),
              height: 23/16,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 16,),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              InkWell(
                child: Container(
                  width: 82,
                  height: 62,
                child: Column(
                  children: [
                    SvgPicture.asset("assets/FoodandDrinks.svg"),
                    Text(
                      "Food & Drinks",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                        height: 18/12,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
            ),
              ),
              InkWell(
                child: Container(
                  width: 82,
                  height: 62,
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/Washroom.svg"),
                      Text(
                        "Washroom",
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff000000),
                          height: 18/12,
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  width: 82,
                  height: 62,
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/HelpDesk.svg"),
                      Text(
                        "Help Desk",
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff000000),
                          height: 18/12,
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  width: 82,
                  height: 62,
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/FirstAid.svg"),
                      Text(
                        "First Aid",
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff000000),
                          height: 18/12,
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  width: 82,
                  height: 62,
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/EmergencyExit.svg"),
                      Text(
                        "Emergency exit",
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff000000),
                          height: 18/12,
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                ),
              ),
            ]
          )
        ],
      ),
    );
  }
}
