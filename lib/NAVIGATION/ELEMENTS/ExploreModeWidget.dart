import 'package:flutter/material.dart';

import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/landmark.dart';
import '../navigationTools.dart';
import '../APIMODELS/landmark.dart';

class ExploreModeWidget extends StatelessWidget {
  nearestLandInfo currentInfo;
  String finalDirection;
  bool facing;
  
  ExploreModeWidget(this.currentInfo,this.finalDirection,{this.facing = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 5),
      decoration: BoxDecoration(
          color: facing? Colors.teal:Colors.white,
          border: Border.all(
            color: Color(0xffEBEBEB),
          ),
          borderRadius:
          BorderRadius.all(Radius.circular(8))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, left: 18,bottom: 12),
                    alignment: Alignment.topLeft,
                    child: Text(
                      HelperClass.truncateString(
                          currentInfo.name!, 30),
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff18181b),
                        height: 25 / 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, top: 12, right: 0,bottom: 12),
                    alignment: Alignment.center,
                    child: Text(
                      HelperClass.truncateString(
                          "Floor ${currentInfo.floor}",
                          25),
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffa1a1aa),
                        height: 20 / 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 14,bottom: 12),
                    alignment: Alignment.topLeft,
                    child: Text(
                      HelperClass.truncateString(
                          finalDirection,
                          30),
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffa1a1aa),
                        height: 20 / 12,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
