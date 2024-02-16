import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

class buildingCard extends StatelessWidget {
  String imageURL;
  String Name;
  String Tag;
  String Address;
  int Distance;
  int NumberofBuildings;
  buildingCard({required this.imageURL, required this.Name, required this.Tag, required this.Address, required this.Distance, required this.NumberofBuildings});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth - 32,
      height: 145,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xffEBEBEB),
        ),
        borderRadius: BorderRadius.all(Radius.circular(4))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(4),bottomLeft: Radius.circular(4))
            ),
            width: 124,
          ),
          SizedBox(width: 16,),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff0f98B5),Color(0xff872DE1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4)),

                  ),
                  child: Row(
                    children: [
                      Container(margin: EdgeInsets.only(left: 8,right: 8),child: Icon(Icons.school_outlined,color: Colors.white,size: 17,)),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Text(
                          "$Tag",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffffffff),
                            height: 18/12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  "$Name",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff000000),
                    height: 25/16,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4,),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,size: 13,color: Color(0xff8D8C8C),),
                    SizedBox(width: 8,),
                    Text(
                      "$Address",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff8d8c8c),
                        height: 20/14,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
                SizedBox(height: 4,),
                Text(
                  "$Distance Km to Venue",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff24b9b0),
                    height: 20/14,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4,),
                Text(
                  "$NumberofBuildings Buildings",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff000000),
                    height: 20/14,
                  ),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
