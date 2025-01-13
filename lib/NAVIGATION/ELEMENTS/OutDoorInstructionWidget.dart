
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_svg/svg.dart';

import '../../IWAYPLUS/Elements/locales.dart';
import '../directionClass.dart';

class OutDoorInstructionWidget extends StatefulWidget{
  double ListHeight;
  double TotalOutDoorInFeet;
  String EndBuildingName;

  List<direction> directions;
  bool ShowLandmark;
  String endName;


  OutDoorInstructionWidget({required this.ListHeight,required this.TotalOutDoorInFeet,required this.EndBuildingName,required this.directions,required this.ShowLandmark,required this.endName});

  @override
  _OutDoorInstructionWidgetState createState() => _OutDoorInstructionWidgetState();

}

class _OutDoorInstructionWidgetState extends State<OutDoorInstructionWidget>{
  bool ListExpand = false;


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: (){
        ListExpand = !ListExpand;
      },
      child: Container(
        padding: EdgeInsets.only(left: 20,top: 0,right: 10),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 10, // Width of the circle
                  height: 10, // Height of the circle
                  decoration: BoxDecoration(
                    color: Color(0xffE5E7EB), // Color of the circle
                    shape: BoxShape.circle, // Makes the container a circle
                  ),
                ),
                Container(height:ListExpand?widget.ListHeight: widget.ShowLandmark? 105: 65,width: 1, color: Color(0xffE5E7EB)),
                Container(
                  width: 10, // Width of the circle
                  height: 10, // Height of the circle
                  decoration: BoxDecoration(
                    color: Color(0xffE5E7EB), // Color of the circle
                    shape: BoxShape.circle, // Makes the container a circle
                  ),
                ),
              ],
            ),
            SizedBox(width: 20,),
            Semantics(
              label: "Take Outdoor path and Walk ${widget.TotalOutDoorInFeet.toInt()} meters to reach ${widget.EndBuildingName}",
              child: Container(
                width: screenWidth*0.74,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        margin:EdgeInsets.only(top: 5),
                        child: Text(
                          "Outdoor Path",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff3f3f46),
                            height: 24/18,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SizedBox(height:10),
                    !ListExpand? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,) : Container(),
                    SizedBox(height:7),
                    ExcludeSemantics(
                      child: Row(
                        children: [
                          ListExpand?Container(
                            height: 35,
                            width: 18,
                            margin: EdgeInsets.only(right: 20),
                            child: Icon(Icons.keyboard_arrow_up),
                          ) : Container(
                            height: 35,
                            width: 18,
                            margin: EdgeInsets.only(right: 20),
                            child: Icon(Icons.keyboard_arrow_down),
                          ),
                          !ListExpand? Container(child: Text(
                            "Walk ${(widget.TotalOutDoorInFeet*0.3048).ceil()} meters to reach ${widget.EndBuildingName}",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                              height: 20/14,
                            ),
                            textAlign: TextAlign.left,
                          ),) : Container(child: Text(
                            "Walk ${(widget.TotalOutDoorInFeet*0.3048).ceil()} meters to reach ${widget.EndBuildingName}",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff000000),
                              height: 20/14,
                            ),
                            textAlign: TextAlign.left,
                          ),),
                        ],
                      ),
                    ),
                    ListExpand?SizedBox(height:15): Container(),


                    ListView.builder(
                      itemCount: ListExpand? widget.directions.length: min(widget.directions.length,0),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 10),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final direction = widget.directions[index];
                        return Semantics(
                          label: index == widget.directions.length-1? "${direction.turnDirection} ${((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurnInFeet}" :"${(direction.distanceToNextTurnInFeet??0*0.3048).ceil()} m"}, you'll reach ${widget.endName}":"${direction.turnDirection} ${((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurnInFeet}" :"${(direction.distanceToNextTurnInFeet??0*0.3048).ceil()} m"}",
                          excludeSemantics: true,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ListExpand? Container():Container(
                                    height: 35,
                                    width: 18,
                                    margin: EdgeInsets.only(right: 20),
                                    child: Icon(Icons.keyboard_arrow_down_sharp),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 3,),

                                      ExcludeSemantics(
                                        child: Text(
                                          (direction.turnDirection??""),
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff0e0d0d),
                                            height: 25 / 16,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(height: 1,),
                                      ExcludeSemantics(
                                        child: Text(
                                          ((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurnInFeet}" :"${((direction.distanceToNextTurnInFeet??0)*0.3048).ceil()} m",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff8d8c8c),
                                            height: 20 / 14,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),

                                    ],
                                  ),
                                  Spacer(),
                                  ListExpand? Container(
                                    height: 35,
                                    width: 35,

                                    child: getCustomIcon((direction.turnDirection??""), context),
                                  ):Container(),

                                ],

                              ),
                              // SizedBox(height: 2,),
                              ListExpand? index!=widget.directions.length-1? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,):Container():Container(),
                            ],
                          ),
                        );
                      },
                    ),

                    widget.ShowLandmark? ExcludeSemantics(
                      child: Container(
                        margin: EdgeInsets.only(top:20),
                        child: Text(
                          widget.endName,
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff3f3f46),
                            height: 24/18,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ): Container(),
                    widget.ShowLandmark && widget.EndBuildingName != widget.endName?ExcludeSemantics(
                      child: Container(
                          margin: EdgeInsets.only(top: 8,bottom: 8),
                          padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color(0xffF9D2D3),
                          ),
                          child:Text("${widget.EndBuildingName}", style: const TextStyle(fontSize: 14,color:Colors.black))),
                    ): Container()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCustomIcon(String direction,context) {
    if (direction ==  LocaleData.gostraight.getString(context)) {
      return Icon(
        Icons.straight,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.slightright.getString(context))) {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.sharpright.getString(context))) {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.tright.getString(context))) {
      return Icon(
        Icons.turn_right,
        color: Colors.black,
        size: 32,
      );
    }  else if (direction.contains(LocaleData.uturn.getString(context))) {
      return Icon(
        Icons.u_turn_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.sharpleft.getString(context))) {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.slightleft.getString(context))) {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.black,
        size: 32,
      );

    } else if (direction.contains(LocaleData.tleft.getString(context))) {
      return Icon(
        Icons.turn_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Lift")) {
      return Padding(
        padding: const EdgeInsets.all(3.5),
        child: SvgPicture.asset("assets/elevator.svg"),
      );
    }
    // else if(direction.substring(0,4)=="Take"){
    //   return Icon(
    //     Icons.abc,
    //     color: Colors.black,
    //     size: 32,
    //   );
    // }

    else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.black,
        size: 32,
      );
    }
  }
}
