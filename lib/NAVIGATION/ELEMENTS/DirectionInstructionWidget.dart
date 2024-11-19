import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_svg/svg.dart';
import '../../IWAYPLUS/Elements/locales.dart';
import '../directionClass.dart';

class DirectionInstructionWidget extends StatefulWidget {

  String StartName;
  String StartBuildingName;
  int StartFloor;
  int Turns;
  double TotalDistance;

  String EndName;
  String EndBuildingName;
  int EndFloor;

  double FirstHeight;
  double SecondHeight;
  double ThirdHeight;
  double ForthHeight;

  String LiftString;

  List<direction> directionList;
  bool IsMultiFloor;
  bool IsMultiBuilding;
  String BuildingID;

  bool reverse;
  //for multibuilding 2nd means reverse card

  DirectionInstructionWidget(
      {required this.StartName,
      required this.StartBuildingName,
      required this.StartFloor,
      required this.EndName,
      required this.EndBuildingName,
      required this.EndFloor,
      required this.FirstHeight,
      required this.SecondHeight,
      required this.ThirdHeight,
      required this.ForthHeight,
      required this.LiftString,
      required this.directionList,
      required this.IsMultiFloor,
      required this.IsMultiBuilding,
      required this.Turns,
      required this.TotalDistance,
      required this.BuildingID,
      this.reverse = false});

  @override
  _DirectionInstructionWidgetState createState() =>
      _DirectionInstructionWidgetState();
}

class _DirectionInstructionWidgetState extends State<DirectionInstructionWidget> {
  bool ListExpand = false;


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    print("widget.IsMultiFloor");
    print(widget.IsMultiFloor);
    print(widget.IsMultiBuilding);


    return GestureDetector(
      onTap: (){
        ListExpand = !ListExpand;
        print("widget.StartName");
        print(widget.StartName);
        print(widget.StartBuildingName);
        print(widget.EndName);
        print(widget.EndBuildingName);


      },
      child: Container(
        margin: EdgeInsets.only(top: !widget.IsMultiBuilding? 20:10,),
        decoration: widget.IsMultiBuilding?BoxDecoration(
          border: Border.all(
            color: Colors.black12, // Color of the outline
            width: 2, // Width of the outline
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,// Optional: Rounded corners
        ) : BoxDecoration(),
        padding: widget.IsMultiBuilding? EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 15):EdgeInsets.only(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top:8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: SvgPicture.asset(
                      "assets/DirectionInstruction_sourceIcon.svg",height: 25,),
                  ),
                  Container(height:ListExpand? widget.FirstHeight : screenHeight*0.055 ,width: 2, color: Color(0xff132F59)),
                  Container(
                    child: SvgPicture.asset(
                      "assets/DirectionInstruction_manImage.svg",height: 30,),
                  ),
                  Container(height:ListExpand? widget.SecondHeight : screenHeight*0.055,width: 2, color: Color(0xff132F59)),
                  ListExpand && widget.IsMultiFloor? Container(
                    width: 20, // Width of the circle
                    height: 20, // Height of the circle
                    decoration: BoxDecoration(
                      color: Color(0xff132F59), // Color of the circle
                      shape: BoxShape.circle, // Makes the container a circle
                    ),
                  ): Container(),
                  //single floor ke liye ye destination icon
                  !widget.IsMultiFloor? Container(
                    child: SvgPicture.asset(
                      "assets/DirectionInstruction_locationPin.svg",height: 25,),
                  ) : Container(),
                  ListExpand && widget.IsMultiFloor? Container(height:30,width: 5, color: Color(0xffFB6B00)): Container(),
                  ListExpand && widget.IsMultiFloor? Container(
                    child: SvgPicture.asset(
                      "assets/DirectionInstruction_LiftIcon.svg",height: 35,),
                  ):Container(),
                  ListExpand && widget.IsMultiFloor? Container(height:30,width: 5, color: Color(0xffFB6B00)): Container(),
                  ListExpand && widget.IsMultiFloor? Container(
                    width: 20, // Width of the circle
                    height: 20, // Height of the circle
                    decoration: BoxDecoration(
                      color: Color(0xff132F59), // Color of the circle
                      shape: BoxShape.circle, // Makes the container a circle
                    ),
                  ) : Container(),
                  ListExpand && widget.IsMultiFloor?Container(height:widget.ThirdHeight,width: 2, color: Color(0xff132F59)) : Container(),
                  ListExpand && widget.IsMultiFloor? Container(
                    child: SvgPicture.asset(
                      "assets/DirectionInstruction_manImage.svg",height: 30,),
                  ): Container(),
                  ListExpand && widget.IsMultiFloor? Container(height:widget.ForthHeight,width: 2, color: Color(0xff132F59)) : Container(),
                  //multi floor ke liye last destination icon
                  widget.IsMultiFloor?Container(
                    child: SvgPicture.asset(
                      "assets/DirectionInstruction_locationPin.svg",height: 25,),
                  ):Container()

                ],
              ),
            ),
            SizedBox(width: 14,),
            Container(
              margin: EdgeInsets.only(top: 8),
              width: screenWidth*0.72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.reverse? Text(
                    "Entering ${widget.StartName}",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff3f3f46),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ): Text(
                    widget.StartName,
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff3f3f46),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),

                  widget.reverse? Container() : Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: widget.IsMultiBuilding?Color(0xffD2F9EF) : Color(0xff6527F5),
                      ),
                      child: widget.IsMultiBuilding? Text("${widget.StartBuildingName} - Floor ${widget.StartFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.black)):
                      Text("Floor ${widget.StartFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))),
                  // Divider(thickness: 1,color: Color(0xffE5E7EB),),
                  SizedBox(height: 10,),

                  Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,),
                  widget.LiftString != "" ?
                  //for single floor in that widget.LiftString will be null
                  Row(
                    children: [
                      ListExpand? Container(
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
                      !ListExpand? Container(child:  Text(
                        widget.LiftString,
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff000000),
                          height: 20/14,
                        ),
                        textAlign: TextAlign.left,
                      ),) : Container(child:  Text(
                        widget.LiftString,
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
                  ) :
                  //for multi floor when the widget.LiftString is given
                  Row(
                    children: [
                      ListExpand? Container(
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
                      !ListExpand? Container(child:  Text(
                        "${widget.Turns} Turns (${widget.TotalDistance} m)",
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff000000),
                          height: 20/14,
                        ),
                        textAlign: TextAlign.left,
                      ),) : Container(child:  Text(
                        "${widget.Turns} Turns (${widget.TotalDistance} m)",
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
                  ListExpand? Container() : Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,),

                  ListExpand? SizedBox(height: 20,):Container(),
                  ListView.builder(
                    itemCount: ListExpand?widget.directionList.length : min(widget.directionList.length, 0),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0,bottom: 0),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final direction = widget.directionList[index];
                      return GestureDetector(
                        onTap: (){
                          ListExpand = !ListExpand;
                          setState((){});
                        },
                        child: Column(
                          children: [
                            // widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
                            //     margin: EdgeInsets.only(top:10),
                            //     child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: screenHeight*0.02,):SizedBox(height: 3,),
                                    widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? ExcludeSemantics(
                                      child: Text(
                                        (direction.turnDirection??""),
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff3f3f46),
                                          height: 23/16,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ): ExcludeSemantics(
                                      child: Text(
                                        (direction.turnDirection??""),
                                        style: TextStyle(
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

                                    widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
                                      margin: EdgeInsets.only(top: 16),
                                      child: Row(
                                        children: [
                                          ExcludeSemantics(
                                            child: Text(
                                              "Press",
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
                                          Container(
                                            margin: EdgeInsets.only(left: 10,right: 10),
                                            width: 25, // Set the width and height to make the container a circle
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xffA606D2), // Background color of the circle
                                              shape: BoxShape.circle, // Makes the container circular
                                            ),
                                            alignment: Alignment.center, // Center the text inside the circle
                                            child: Text(
                                              direction.liftDestinationFloor.toString(), // Your text here
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                                height: 25/16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          ExcludeSemantics(
                                            child: Text(
                                              "button in the lift",
                                              style: const TextStyle(
                                                fontFamily: "Roboto",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff000000),
                                                height: 25/16,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),


                                        ],
                                      ),
                                    )

                                        :ExcludeSemantics(
                                      child: Text(
                                        ((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurn}" :"${(direction.distanceToNextTurn??0*0.3048).ceil()} m",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff8d8c8c),
                                          height: 20 / 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ) ,

                                    widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: screenHeight*0.02,):SizedBox(height: 3,),


                                  ],
                                ) ,
                                Spacer(),
                                widget.IsMultiBuilding && !ListExpand? Container(): widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
                                  child : Text(
                                    "30 sec",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xffa1a1aa),
                                      height: 20/14,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                              ) : Container(
                                  height: 35,
                                  width: 35,

                                  child: getCustomIcon((direction.turnDirection??""), context),
                                ),

                              ],

                            ),
                            // SizedBox(height: 2,),
                            Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,),
                            // widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
                            //     margin: EdgeInsets.only(top:10),
                            //     child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
                            widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: 20,): Container(),


                          ],
                        ),
                      );
                    },
                  ),
                  // !ListExpand? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
                  SizedBox(height: 20,),

                  !widget.IsMultiBuilding || widget.reverse? Text(
                    widget.EndName,
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff3f3f46),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ) : Text(
                    "Exiting ${widget.StartBuildingName}",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff3f3f46),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),

                  !widget.IsMultiBuilding? Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xff4899EA),
                      ),
                      child: Text("Floor ${widget.EndFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))) : widget.reverse? Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xffF9D2D3),
                        ),
                      child:Text("${widget.StartBuildingName} - Floor ${widget.StartFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.black))): Container(),

                ],
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


// !vm.isMultiBuilding? Container(
//   child: Semantics(
//     excludeSemantics: true,
//     child: Text(
//       "Steps",
//       style: const TextStyle(
//         fontFamily: "Roboto",
//         fontSize: 18,
//         fontWeight: FontWeight.w500,
//         color: Color(0xff000000),
//         height: 24 / 18,
//       ),
//       textAlign: TextAlign.left,
//     ),
//   ),
// ):Container(),
//
//
//
// vm.isMultiBuilding? GestureDetector(
//   onTap: (){
//     sourceBuildingListExpand = !sourceBuildingListExpand;
//   },
//   child: Container(
//     margin: EdgeInsets.only(top: !vm.isMultiBuilding? 20:10),
//     decoration: vm.isMultiBuilding?BoxDecoration(
//       border: Border.all(
//         color: Colors.black12, // Color of the outline
//         width: 2, // Width of the outline
//       ),
//       borderRadius: BorderRadius.circular(12),
//       color: Colors.white,// Optional: Rounded corners
//     ) : BoxDecoration(),
//     padding: vm.isMultiBuilding? EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 15):EdgeInsets.only(),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: EdgeInsets.only(top:8),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 child: SvgPicture.asset(
//                     "assets/DirectionInstruction_sourceIcon.svg",height: 25,),
//               ),
//               Container(height:vm.isMultiFloor?sourceBuildingListExpand? vm.sourceSemiHeightUp/2+80+45:50:vm.sourceSemiHeightUp/2,width: 2, color: Color(0xff132F59)),
//               Container(
//                 child: SvgPicture.asset(
//                     "assets/DirectionInstruction_manImage.svg",height: 30,),
//               ),
//               Container(height:vm.isMultiFloor?sourceBuildingListExpand? vm.sourceSemiHeightUp/2+45:50: vm.sourceSemiHeightUp/2,width: 2, color: Color(0xff132F59)),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(
//                 width: 20, // Width of the circle
//                 height: 20, // Height of the circle
//                 decoration: BoxDecoration(
//                   color: Color(0xff132F59), // Color of the circle
//                   shape: BoxShape.circle, // Makes the container a circle
//                 ),
//               ): Container(),
//               sourceBuildingListExpand && !vm.isMultiFloor? Container(
//                 child: SvgPicture.asset(
//                     "assets/DirectionInstruction_locationPin.svg",height: 25,),
//               ) : Container(),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(height:30,width: 5, color: Color(0xffFB6B00)): Container(),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(
//                 child: SvgPicture.asset(
//                   "assets/DirectionInstruction_LiftIcon.svg",height: 35,),
//               ):Container(),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(height:30,width: 5, color: Color(0xffFB6B00)): Container(),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(
//                 width: 20, // Width of the circle
//                 height: 20, // Height of the circle
//                 decoration: BoxDecoration(
//                   color: Color(0xff132F59), // Color of the circle
//                   shape: BoxShape.circle, // Makes the container a circle
//                 ),
//               ) : Container(),
//               sourceBuildingListExpand && vm.isMultiFloor?Container(height:sourceBuildingListExpand? vm.sourceSemiHeightDown/2:40,width: 2, color: Color(0xff132F59)) : Container(),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(
//                 child: SvgPicture.asset(
//                   "assets/DirectionInstruction_manImage.svg",height: 30,),
//               ): Container(),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(height:sourceBuildingListExpand? vm.sourceSemiHeightDown/2:40,width: 2, color: Color(0xff132F59)) : Container(),
//               sourceBuildingListExpand && vm.isMultiFloor? Container(
//                 child: SvgPicture.asset(
//                   "assets/DirectionInstruction_locationPin.svg",height: 25,),
//               ): vm.isMultiBuilding? Container(
//                 width: 10, // Width of the circle
//                 height: 10, // Height of the circle
//                 decoration: BoxDecoration(
//                   color: Color(0xff132F59), // Color of the circle
//                   shape: BoxShape.circle, // Makes the container a circle
//                 ),
//               ) : Container(),
//
//             ],
//           ),
//         ),
//         SizedBox(width: 14,),
//         Container(
//           width: screenWidth*0.72,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 vm.sourceName,
//                 style: const TextStyle(
//                   fontFamily: "Roboto",
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xff3f3f46),
//                   height: 24/18,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//
//               Container(
//                 margin: EdgeInsets.only(top: 8),
//                 padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     color: vm.isMultiBuilding?Color(0xffD2F9EF) : Color(0xff6527F5),
//                   ),
//                   child:vm.isMultiBuilding? Text("${vm.sourceBuildingName} - Floor ${vm.sourceFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.black)):
//                   Text("${vm.sourceBuildingName} - Floor ${vm.sourceFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))),
//               // Divider(thickness: 1,color: Color(0xffE5E7EB),),
//               SizedBox(height: 10,),
//
//               Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,),
//               Row(
//                 children: [
//                   sourceBuildingListExpand?Container(
//                     height: 35,
//                     width: 18,
//                     margin: EdgeInsets.only(right: 20),
//                     child: Icon(Icons.keyboard_arrow_up),
//                   ) : Container(
//                     height: 35,
//                     width: 18,
//                     margin: EdgeInsets.only(right: 20),
//                     child: Icon(Icons.keyboard_arrow_down),
//                   ),
//                   !sourceBuildingListExpand? Container(child:  Text(
//                     vm.sourceLiftIndexString,
//                     style: const TextStyle(
//                       fontFamily: "Roboto",
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                       color: Color(0xff000000),
//                       height: 20/14,
//                     ),
//                     textAlign: TextAlign.left,
//                   ),) : Container(child:  Text(
//                     vm.sourceLiftIndexString,
//                     style: const TextStyle(
//                       fontFamily: "Roboto",
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xff000000),
//                       height: 20/14,
//                     ),
//                     textAlign: TextAlign.left,
//                   ),),
//                 ],
//               ),
//               sourceBuildingListExpand? SizedBox(height: 20,):Container(),
//               ListView.builder(
//                 itemCount: vm.isMultiBuilding? sourceBuildingListExpand?vm.sourceDirection.length : min(vm.sourceDirection.length, 0) : vm.sourceDirection.length,
//                 shrinkWrap: true,
//                 padding: EdgeInsets.only(top: 0,bottom: 0),
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   final direction = vm.sourceDirection[index];
//                   return GestureDetector(
//                     onTap: (){
//                       if(vm.isMultiBuilding){
//                         sourceBuildingListExpand = !sourceBuildingListExpand;
//                         setState((){});
//                       }
//                     },
//                     child: Column(
//                       children: [
//                         vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                           margin: EdgeInsets.only(top:10),
//                             child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             vm.isMultiBuilding && !sourceBuildingListExpand? Container(
//                               height: 35,
//                               width: 18,
//                               margin: EdgeInsets.only(right: 20),
//                               child: Icon(Icons.keyboard_arrow_down_sharp),
//                             ) : Container(),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(height: 3,),
//                                 vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? ExcludeSemantics(
//                                   child: Text(
//                                     (direction.turnDirection??""),
//                                     style: const TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: Color(0xff3f3f46),
//                                       height: 23/16,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ): ExcludeSemantics(
//                                   child: Text(
//                                     (direction.turnDirection??""),
//                                     style: TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w400,
//                                       color: Color(0xff0e0d0d),
//                                       height: 25 / 16,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ),
//                                 SizedBox(height: 1,),
//
//                                 vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                                   margin: EdgeInsets.only(top: 16),
//                                   child: Row(
//                                     children: [
//                                       ExcludeSemantics(
//                                         child: Text(
//                                           "Press",
//                                           style: const TextStyle(
//                                             fontFamily: "Roboto",
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w400,
//                                             color: Color(0xff8d8c8c),
//                                             height: 20 / 14,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                       ),
//                                       Container(
//                                         margin: EdgeInsets.only(left: 10,right: 10),
//                                         width: 25, // Set the width and height to make the container a circle
//                                         height: 25,
//                                         decoration: BoxDecoration(
//                                           color: Color(0xffA606D2), // Background color of the circle
//                                           shape: BoxShape.circle, // Makes the container circular
//                                         ),
//                                         alignment: Alignment.center, // Center the text inside the circle
//                                         child: Text(
//                                           direction.liftDestinationFloor.toString(), // Your text here
//                                           style: const TextStyle(
//                                             fontFamily: "Roboto",
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: Colors.white,
//                                             height: 25/16,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       ExcludeSemantics(
//                                         child: Text(
//                                           "button in the lift",
//                                           style: const TextStyle(
//                                             fontFamily: "Roboto",
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: Color(0xff000000),
//                                             height: 25/16,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                       ),
//
//
//                                     ],
//                                   ),
//                                 )
//
//                                     :ExcludeSemantics(
//                                   child: Text(
//                                     ((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurn}" :"${(direction.distanceToNextTurn??0*0.3048).ceil()} m",
//                                     style: const TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w400,
//                                       color: Color(0xff8d8c8c),
//                                       height: 20 / 14,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ) ,
//
//                               ],
//                             ) ,
//                             Spacer(),
//                             vm.isMultiBuilding && !sourceBuildingListExpand? Container(): Container(
//                               height: 35,
//                               width: 35,
//
//                               child: getCustomIcon((direction.turnDirection??""), context),
//                             ),
//
//                           ],
//
//                         ),
//                         // SizedBox(height: 2,),
//
//                         sourceBuildingListExpand && index != vm.sourceDirection.length-1? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
//                         vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                             margin: EdgeInsets.only(top:10),
//                             child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
//                         vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: 20,): Container(),
//
//
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               !sourceBuildingListExpand? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
//               SizedBox(height: 10,),
//
//               !vm.isMultiBuilding? Text(
//                 vm.destinationName,
//                 style: const TextStyle(
//                   fontFamily: "Roboto",
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xff3f3f46),
//                   height: 24/18,
//                 ),
//                 textAlign: TextAlign.left,
//               ) : Text(
//                 "Exiting ${vm.sourceBuildingName}",
//                 style: const TextStyle(
//                   fontFamily: "Roboto",
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xff3f3f46),
//                   height: 24/18,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//
//               !vm.isMultiBuilding? Container(
//                   margin: EdgeInsets.only(top: 8),
//                   padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
//
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     color: Color(0xff4899EA),
//                   ),
//                   child:Text("Floor ${vm.destionationFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))) : Container(),
//
//             ],
//           ),
//         ),
//       ],
//     ),
//   ),
// ) :
// Container(
//   margin: EdgeInsets.only(top:10),
//   child: Row(
//     crossAxisAlignment: vm.isMultiFloor?CrossAxisAlignment.center:CrossAxisAlignment.start,
//     children: [
//       Container(
//         padding: EdgeInsets.only(top: 8),
//         child: Column(
//           children: [
//             Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_sourceIcon.svg",height: 25,),
//             ),
//             Container(height:vm.isMultiFloor?vm.sourceSemiHeightUp/2+80:vm.sourceSemiHeightUp/2+100,width: 2, color: Color(0xff132F59)),
//             Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_manImage.svg",height: 30,),
//             ),
//             Container(height:vm.isMultiFloor?vm.sourceSemiHeightUp/2:vm.sourceSemiHeightUp/2+80,width: 2, color: Color(0xff132F59)),
//              vm.isMultiFloor? Container(
//               width: 20, // Width of the circle
//               height: 20, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xff132F59), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ): Container(),
//             !vm.isMultiFloor? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_locationPin.svg",height: 25,),
//             ) : Container(),
//             vm.isMultiFloor? Container(height:30,width: 5, color: Color(0xffFB6B00)): Container(),
//             vm.isMultiFloor? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_LiftIcon.svg",height: 35,),
//             ):Container(),
//             vm.isMultiFloor? Container(height:30,width: 5, color: Color(0xffFB6B00)): Container(),
//             vm.isMultiFloor? Container(
//               width: 20, // Width of the circle
//               height: 20, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xff132F59), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ) : Container(),
//             vm.isMultiFloor?Container(height:(vm.sourceSemiHeightDown/2),width: 2, color: Color(0xff132F59)) : Container(),
//             vm.isMultiFloor? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_manImage.svg",height: 30,),
//             ): Container(),
//             vm.isMultiFloor? Container(height:(vm.sourceSemiHeightDown/2+100),width: 2, color: Color(0xff132F59)) : Container(),
//             vm.isMultiFloor? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_locationPin.svg",height: 25,),
//             ): vm.isMultiBuilding? Container(
//               width: 10, // Width of the circle
//               height: 10, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xff132F59), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ) : Container(),
//             SizedBox(height: screenHeight*0.3,)
//           ],
//         ),
//       ),
//       SizedBox(width: 14,),
//       Row(
//         children: [
//           Container(
//             width: screenWidth*0.72,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   vm.sourceName,
//                   style: const TextStyle(
//                     fontFamily: "Roboto",
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xff3f3f46),
//                     height: 24/18,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//
//                 Container(
//                     margin: EdgeInsets.only(top: 8),
//                     padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       color:Color(0xff6527F5),
//                     ),
//                     child:Text("${vm.sourceBuildingName} - Floor ${vm.sourceFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))),
//                 // Divider(thickness: 1,color: Color(0xffE5E7EB),),
//                 ListView.builder(
//                   itemCount: vm.sourceDirection.length,
//                   shrinkWrap: true,
//                   padding: EdgeInsets.only(top: 10,bottom: 10),
//                   physics: NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     final direction = vm.sourceDirection[index];
//                     return GestureDetector(
//                       onTap: (){
//
//                       },
//                       child: Column(
//                         children: [
//                           vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                               margin: EdgeInsets.only(top:10),
//                               child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(height: 3,),
//
//                                   vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? ExcludeSemantics(
//                                     child: Text(
//                                       (direction.turnDirection??""),
//                                       style: const TextStyle(
//                                         fontFamily: "Roboto",
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xff3f3f46),
//                                         height: 23/16,
//                                       ),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ): ExcludeSemantics(
//                                     child: Text(
//                                       (direction.turnDirection??""),
//                                       style: TextStyle(
//                                         fontFamily: "Roboto",
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400,
//                                         color: Color(0xff0e0d0d),
//                                         height: 25 / 16,
//                                       ),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ),
//                                   SizedBox(height: 1,),
//
//                                   vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                                     margin: EdgeInsets.only(top: 16),
//                                     child: Row(
//                                       children: [
//                                         ExcludeSemantics(
//                                           child: Text(
//                                             "Press",
//                                             style: const TextStyle(
//                                               fontFamily: "Roboto",
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w400,
//                                               color: Color(0xff8d8c8c),
//                                               height: 20 / 14,
//                                             ),
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ),
//                                         Container(
//                                           margin: EdgeInsets.only(left: 10,right: 10),
//                                           width: 25, // Set the width and height to make the container a circle
//                                           height: 25,
//                                           decoration: BoxDecoration(
//                                             color: Color(0xffA606D2), // Background color of the circle
//                                             shape: BoxShape.circle, // Makes the container circular
//                                           ),
//                                           alignment: Alignment.center, // Center the text inside the circle
//                                           child: Text(
//                                             direction.liftDestinationFloor.toString(), // Your text here
//                                             style: const TextStyle(
//                                               fontFamily: "Roboto",
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w400,
//                                               color: Colors.white,
//                                               height: 25/16,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                         ExcludeSemantics(
//                                           child: Text(
//                                             "button in the lift",
//                                             style: const TextStyle(
//                                               fontFamily: "Roboto",
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w400,
//                                               color: Color(0xff000000),
//                                               height: 25/16,
//                                             ),
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ),
//
//
//                                       ],
//                                     ),
//                                   )
//                                       :ExcludeSemantics(
//                                         child: Text(
//                                           ((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurn}" :"${(direction.distanceToNextTurn??0*0.3048).ceil()} m",
//                                           style: const TextStyle(
//                                             fontFamily: "Roboto",
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w400,
//                                             color: Color(0xff8d8c8c),
//                                             height: 20 / 14,
//                                       ),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ) ,
//
//                                 ],
//                               ),
//                               Spacer(),
//                               vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                                   child : Text(
//                                     "30 sec",
//                                     style: const TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w400,
//                                       color: Color(0xffa1a1aa),
//                                       height: 20/14,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   )
//                               ) : Container(
//                                 height: 35,
//                                 width: 35,
//                                 child: getCustomIcon((direction.turnDirection??""), context),
//                               ),
//                             ],
//
//                           ),
//                           // SizedBox(height: 2,),
//                           index != vm.sourceDirection.length-1? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
//                           vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                               margin: EdgeInsets.only(top:10),
//                               child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
//                           vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: 20,): Container(),
//
//
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//
//                 Text(
//                   vm.destinationName,
//                   style: const TextStyle(
//                     fontFamily: "Roboto",
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xff3f3f46),
//                     height: 24/18,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//
//                 Container(
//                     margin: EdgeInsets.only(top: 8),
//                     padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
//
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       color: Color(0xff4899EA),
//                     ),
//                     child:Text("Floor ${vm.destionationFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))),
//
//                 SizedBox(height: screenHeight*0.3,)
//               ],
//             ),
//           ),
//
//         ],
//       ),
//
//
//     ],
//   ),
// ),
// vm.isMultiBuilding? SizedBox(height: screenHeight*0.018,): Container(),
// vm.isMultiBuilding?Divider(thickness: 2,color: Color(0xffE5E7EB),indent: 40,endIndent: 20,) : Container(),
//
// vm.isMultiBuilding? GestureDetector(
//   onTap: (){
//     outdoorListExpand = !outdoorListExpand;
//   },
//   child: Container(
//     padding: EdgeInsets.only(left: 20,top: 5,right: 10,bottom: 15),
//     child: Row(
//       children: [
//         Column(
//           children: [
//             Container(
//               width: 10, // Width of the circle
//               height: 10, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xffE5E7EB), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ),
//             Container(height:outdoorListExpand?vm.outdoorWidgetHeight+50+50: 65,width: 1, color: Color(0xffE5E7EB)),
//             Container(
//               width: 10, // Width of the circle
//               height: 10, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xffE5E7EB), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ),
//           ],
//         ),
//         SizedBox(width: 20,),
//         Container(
//           width: screenWidth*0.74,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 margin:EdgeInsets.only(top: 5),
//                 child: Text(
//                   "Outdoor Path",
//                   style: const TextStyle(
//                     fontFamily: "Roboto",
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xff3f3f46),
//                     height: 24/18,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               SizedBox(height:15),
//               !outdoorListExpand? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,) : Container(),
//               Row(
//                 children: [
//                   outdoorListExpand?Container(
//                     height: 35,
//                     width: 18,
//                     margin: EdgeInsets.only(right: 20),
//                     child: Icon(Icons.keyboard_arrow_up),
//                   ) : Container(
//                     height: 35,
//                     width: 18,
//                     margin: EdgeInsets.only(right: 20),
//                     child: Icon(Icons.keyboard_arrow_down),
//                   ),
//                   !outdoorListExpand? Container(child: Text(
//                     "Walk ${"vm.totalOutdoorMeter.toInt()"} meters to reach ${vm.destinationBuildingName}",
//                     style: const TextStyle(
//                       fontFamily: "Roboto",
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                       color: Color(0xff000000),
//                       height: 20/14,
//                     ),
//                     textAlign: TextAlign.left,
//                   ),) : Container(child: Text(
//                     "Walk ${"vm.totalOutdoorMeter.toInt()"} meters to reach ${vm.destinationBuildingName}",
//                     style: const TextStyle(
//                       fontFamily: "Roboto",
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xff000000),
//                       height: 20/14,
//                     ),
//                     textAlign: TextAlign.left,
//                   ),),
//                 ],
//               ),
//               outdoorListExpand?SizedBox(height:15): Container(),
//
//
//               ListView.builder(
//                 itemCount: outdoorListExpand? vm.outdoorDirection.length: min(vm.outdoorDirection.length,0),
//                 shrinkWrap: true,
//                 padding: EdgeInsets.only(top: 10),
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   final direction = vm.outdoorDirection[index];
//                   return GestureDetector(
//                     onTap: (){
//                       outdoorListExpand = !outdoorListExpand;
//                     },
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             outdoorListExpand? Container():Container(
//                               height: 35,
//                               width: 18,
//                               margin: EdgeInsets.only(right: 20),
//                               child: Icon(Icons.keyboard_arrow_down_sharp),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(height: 3,),
//
//                                 ExcludeSemantics(
//                                   child: Text(
//                                     (direction.turnDirection??""),
//                                     style: const TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w400,
//                                       color: Color(0xff0e0d0d),
//                                       height: 25 / 16,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ),
//                                 SizedBox(height: 1,),
//                                 ExcludeSemantics(
//                                   child: Text(
//                                     ((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurn}" :"${(direction.distanceToNextTurn??0*0.3048).ceil()} m",
//                                     style: const TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w400,
//                                       color: Color(0xff8d8c8c),
//                                       height: 20 / 14,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ),
//
//                               ],
//                             ),
//                             Spacer(),
//                             outdoorListExpand? Container(
//                               height: 35,
//                               width: 35,
//
//                               child: getCustomIcon((direction.turnDirection??""), context),
//                             ):Container(),
//
//                           ],
//
//                         ),
//                         // SizedBox(height: 2,),
//                         outdoorListExpand? index!=vm.outdoorDirection.length-1? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,):Container():Container(),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   ),
// ) : Container(),
//
//
// vm.isMultiBuilding?Divider(thickness: 2,color: Color(0xffE5E7EB),indent: 40,endIndent: 20,): Container(),
// vm.isMultiBuilding?SizedBox(height: screenHeight*0.018,): Container(),
//
//
//
// vm.isMultiBuilding? GestureDetector(
//   onTap: (){
//     destinationListExpand = !destinationListExpand;
//   },
//   child: Container(
//     decoration:BoxDecoration(
//       border: Border.all(
//         color: Colors.black12, // Color of the outline
//         width: 2, // Width of the outline
//       ),
//       borderRadius: BorderRadius.circular(12), // Optional: Rounded corners
//       color: Colors.white,// Optional: Rounded corners
//
//     ),
//     padding: EdgeInsets.only(left: 10,top: 15,right: 10,bottom: 15),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//
//           children: [
//             Container(
//               width: 10, // Width of the circle
//               height: 10, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xff132F59), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ),
//             Container(height:destinationListExpand? vm.isMultiFloor?
//             vm.destinationSemiheight2/2+45:vm.destinationSemiheight2+45:60,
//                 width: 2, color: Color(0xff132F59)),
//             Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_manImage.svg",height: 30,),
//             ),
//             Container(height:destinationListExpand? vm.isMultiFloor?
//             vm.destinationSemiheight2/2+45:vm.destinationSemiheight2+45:60,width: 2, color: Color(0xff132F59)),
//             destinationListExpand? vm.isDestinationMultiFloor? Container(
//               width: 20, // Width of the circle
//               height: 20, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xff132F59), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ): Container(): Container(),
//             destinationListExpand? !vm.isMultiBuilding && !vm.isDestinationMultiFloor? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_locationPin.svg",height: 25,),
//             ) : Container(): Container(),
//             destinationListExpand? vm.isDestinationMultiFloor? Container(height:40,width: 5, color: Color(0xffFB6B00)): Container() : Container(),
//             destinationListExpand? vm.isDestinationMultiFloor? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_LiftIcon.svg",height: 35,),
//             ):Container() : Container(),
//             destinationListExpand? vm.isDestinationMultiFloor? Container(height:40,width: 5, color: Color(0xffFB6B00)): Container(): Container(),
//             destinationListExpand? vm.isDestinationMultiFloor? Container(
//               width: 20, // Width of the circle
//               height: 20, // Height of the circle
//               decoration: BoxDecoration(
//                 color: Color(0xff132F59), // Color of the circle
//                 shape: BoxShape.circle, // Makes the container a circle
//               ),
//             ) : Container(): Container(),
//             destinationListExpand? vm.isDestinationMultiFloor?Container(height:vm.isMultiFloor?vm.destinationSemiheight:vm.destinationSemiheight,width: 2, color: Color(0xff132F59)) : Container(): Container(),
//             destinationListExpand? vm.isDestinationMultiFloor? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_manImage.svg",height: 30,),
//             ): Container(): Container(),
//             destinationListExpand? vm.isDestinationMultiFloor? Container(height:vm.isMultiFloor?vm.destinationSemiheight:vm.destinationSemiheight,width: 2, color: Colors.black87) : Container(): Container(),
//             vm.isMultiBuilding? Container(
//               child: SvgPicture.asset(
//                 "assets/DirectionInstruction_locationPin.svg",height: 25,),
//             ): Container(),
//           ],
//         ),
//         SizedBox(width: 14,),
//         Container(
//           width: screenWidth*0.72,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "${vm.destinationBuildingName} - Entrance",
//                 style: const TextStyle(
//                   fontFamily: "Roboto",
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xff3f3f46),
//                   height: 24/18,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//               SizedBox(height: 10,),
//
//               Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,),
//
//               vm.destinationLiftIndexString!=""?Row(
//                 children: [
//                   destinationListExpand?Container(
//                     height: 35,
//                     width: 18,
//                     margin: EdgeInsets.only(right: 20),
//                     child: Icon(Icons.keyboard_arrow_up),
//                   ) : Container(
//                     height: 35,
//                     width: 18,
//                     margin: EdgeInsets.only(right: 20),
//                     child: Icon(Icons.keyboard_arrow_down),
//                   ),
//                   !destinationListExpand? Container(child:  Text(
//                     vm.destinationLiftIndexString,
//                     style: const TextStyle(
//                       fontFamily: "Roboto",
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                       color: Color(0xff000000),
//                       height: 20/14,
//                     ),
//                     textAlign: TextAlign.left,
//                   ),) : Container(child:  Text(
//                     vm.destinationLiftIndexString,
//                     style: const TextStyle(
//                       fontFamily: "Roboto",
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xff000000),
//                       height: 20/14,
//                     ),
//                     textAlign: TextAlign.left,
//                   ),),
//                 ],
//               ):Container(),
//               destinationListExpand? SizedBox(height: 20,):Container(),
//
//               ListView.builder(
//                 itemCount: vm.isMultiBuilding? destinationListExpand?vm.destinationDirection.length : min(vm.destinationDirection.length, vm.destinationLiftIndexString==""?1:0) : vm.destinationDirection.length,
//                 shrinkWrap: true,
//                 padding: EdgeInsets.only(top: 0,bottom: 0),
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   final direction = vm.destinationDirection[index];
//                   return GestureDetector(
//                     onTap: (){
//                       if(vm.isMultiBuilding){
//                         destinationListExpand = !destinationListExpand;
//                         setState((){});
//                       }
//                     },
//                     child: Column(
//                       children: [
//                         vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                             margin: EdgeInsets.only(top:10),
//                             child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             vm.isMultiBuilding && !destinationListExpand? Container(
//                               height: 35,
//                               width: 18,
//                               margin: EdgeInsets.only(right: 20),
//                               child: Icon(Icons.keyboard_arrow_down_sharp),
//                             ) : Container(),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(height: 3,),
//
//                                 vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? ExcludeSemantics(
//                                   child: Text(
//                                     (direction.turnDirection??""),
//                                     style: const TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: Color(0xff3f3f46),
//                                       height: 23/16,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ): ExcludeSemantics(
//                                   child: Text(
//                                     (direction.turnDirection??""),
//                                     style: TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w400,
//                                       color: Color(0xff0e0d0d),
//                                       height: 25 / 16,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ),
//                                 SizedBox(height: 1,),
//
//                                 vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                                   margin: EdgeInsets.only(top: 16),
//                                   child: Row(
//                                     children: [
//                                       ExcludeSemantics(
//                                         child: Text(
//                                           "Press",
//                                           style: const TextStyle(
//                                             fontFamily: "Roboto",
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w400,
//                                             color: Color(0xff8d8c8c),
//                                             height: 20 / 14,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                       ),
//                                       Container(
//                                         margin: EdgeInsets.only(left: 10,right: 10),
//                                         width: 25, // Set the width and height to make the container a circle
//                                         height: 25,
//                                         decoration: BoxDecoration(
//                                           color: Color(0xffA606D2), // Background color of the circle
//                                           shape: BoxShape.circle, // Makes the container circular
//                                         ),
//                                         alignment: Alignment.center, // Center the text inside the circle
//                                         child: Text(
//                                           direction.liftDestinationFloor.toString(), // Your text here
//                                           style: const TextStyle(
//                                             fontFamily: "Roboto",
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: Colors.white,
//                                             height: 25/16,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       ExcludeSemantics(
//                                         child: Text(
//                                           "button in the lift",
//                                           style: const TextStyle(
//                                             fontFamily: "Roboto",
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: Color(0xff000000),
//                                             height: 25/16,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                       ),
//
//
//                                     ],
//                                   ),
//                                 )
//
//                                     :ExcludeSemantics(
//                                   child: Text(
//                                     ((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurn}" :"${(direction.distanceToNextTurn??0*0.3048).ceil()} m",
//                                     style: const TextStyle(
//                                       fontFamily: "Roboto",
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w400,
//                                       color: Color(0xff8d8c8c),
//                                       height: 20 / 14,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
//                                 ) ,
//
//                               ],
//                             ),
//                             Spacer(),
//                             vm.isMultiBuilding && !destinationListExpand? Container(): Container(
//                               height: 35,
//                               width: 35,
//
//                               child: getCustomIcon((direction.turnDirection??""), context),
//                             ),
//
//                           ],
//
//                         ),
//                         // SizedBox(height: 2,),
//
//                         destinationListExpand && index != vm.destinationDirection.length-1? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
//                         vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
//                             margin: EdgeInsets.only(top:10),
//                             child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
//                         vm.isMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: 20,): Container(),
//
//
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               !destinationListExpand? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
//
//               Text(
//                 vm.destinationName,
//                 style: const TextStyle(
//                   fontFamily: "Roboto",
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xff3f3f46),
//                   height: 24/18,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//
//               Container(
//                   margin: EdgeInsets.only(top: 8),
//                   padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     color: vm.isMultiBuilding? Color(0xffF9D2D3) : Color(0xff4899EA),
//                   ),
//                   child:Text("${vm.destinationBuildingName} - Floor ${vm.destionationFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.black))),
//
//             ],
//           ),
//         ),
//       ],
//     ),
//   ),
// ) : Container(),
//
// vm.isMultiBuilding? SizedBox(height: screenHeight*0.3,): Container()
//
//