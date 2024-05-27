import 'package:flutter/material.dart';

import '../navigationTools.dart';
import 'HelperClass.dart';

class ExploreModeWidget extends StatelessWidget {
  nearestLandInfo currentInfo;
  String finalDirection;
  
  ExploreModeWidget(this.currentInfo,this.finalDirection);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: EdgeInsets.only(
          top: 10,),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xffEBEBEB),
          ),
          borderRadius:
          BorderRadius.all(Radius.circular(8))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: 12, left: 18),
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
                    margin: EdgeInsets.only(
                        left: 10, top: 14),
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
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: 18,
                        top: 3,
                        bottom: 14,
                        right: 10),
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
                        top: 3,
                        bottom: 14,
                        left: 2),
                    alignment: Alignment.topLeft,
                    child: Text(
                      HelperClass.truncateString(
                          currentInfo.buildingName!,
                          30),
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffa1a1aa),
                        height: 20 / 14,
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
