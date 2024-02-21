import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/Elements/buildingCard.dart';
import 'package:iwayplusnav/Navigation.dart';
import 'API/BuildingAPI.dart';
import 'APIMODELS/BuildingAPIModel.dart';
import 'APIMODELS/buildingAllModel.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'Elements/InsideBuildingCard.dart';


class BuildingInfoScreen extends StatefulWidget {
  List<buildingAllModel>? receivedAllBuildingList;

  BuildingInfoScreen({ this.receivedAllBuildingList,});


  @override
  State<BuildingInfoScreen> createState() => _BuildingInfoScreenState();
}

class _BuildingInfoScreenState extends State<BuildingInfoScreen> {
  late List<buildingAllModel> allBuildingList=[];
  List<BuildingAPIInsideModel> dd = [];


  String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + '..';
    }
  }
  String extractLastThreeWords(String inputString) {
    List<String> words = inputString.split(',');
    // Ensure there are at least three words before extracting the last three
    if (words.length > 3) {
      return words[words.length-3]+","+words[words.length-4];
    } else {
      // Handle the case when there are fewer than three words
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.receivedAllBuildingList);
    apiCall();
  }

  void apiCall() async{
    await BuildingAPI().fetchBuildData().then((value) => dd = value.data!);
    print("API CAll");
    for (BuildingAPIInsideModel i in dd){
      print(i.buildingName);
    }
    //print(dd[0].buildingName);
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            alignment: Alignment.centerRight,
            width: 60,
            child: Container(
                child: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios)
                )
            ),
          ),
          actions: [
            Container(
                margin: EdgeInsets.only(right: 20),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8.0),
                //   border: Border.all(
                //     color: Color(0x204A4545),
                //   ),
                // ),
                child: SvgPicture.asset("assets/BuildingInfoScreen_Share.svg"),
            )
          ],
          backgroundColor: Colors.transparent, // Set the background color to transparent
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], // Set your gradient colors
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: screenHeight+250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicWidth(
                  child: Container(
                    height: 22,
                    margin: EdgeInsets.only(top: 20,left: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xff0f98B5),Color(0xff872DE1)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(margin: EdgeInsets.only(left: 8,right: 8),child: Icon(Icons.school_outlined,color: Colors.white,size: 17,)),
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Text(
                            widget.receivedAllBuildingList![0].category??"No category",
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
                ),
                IntrinsicHeight(
                  child: Container(
                    margin: EdgeInsets.only(top: 6,left: 16),
                    child: Text(
                      widget.receivedAllBuildingList![0].venueName??"",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16,top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined,size: 15,color: Color(0xff8D8C8C),),
                      SizedBox(width: 8,),
                      Container(
                        child: Text(
                          truncateString(extractLastThreeWords(widget.receivedAllBuildingList![0].address.toString()) ?? "",25),
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff8d8c8c),
                            height: 20/14,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 3, // Set the maximum number of lines
                          overflow: TextOverflow.ellipsis, // Display '...' when overflowed
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 6,left:16,right: 16),
                  child: Text(
                    "Ashoka University’s Liberal Arts and Sciences education enables critical thinking, read more",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),


                Container(
                  margin: EdgeInsets.only(top: 32,left:16),
                  child: Text(
                    " Buildings",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection:Axis.horizontal ,
                    itemBuilder: (context,index){
                      var currentData = widget.receivedAllBuildingList![index];
                      return GestureDetector(
                        child: InsideBuildingCard(
                          imageURL: currentData.photo?? "",
                          buildingName: currentData.buildingName?? "",
                          Tag: currentData.category?? "",
                          buildingId: currentData.sId??"",
                        ),
                      );
                    },
                    itemCount: widget.receivedAllBuildingList?.length,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 32,left:16),
                  child: Text(
                    "This Buildings has",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                          child: Expanded(
                            child: Container(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.all(8),
                              height: 70,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Color(0xffEBEBEB),
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8))
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: SvgPicture.asset("assets/BuildingInfoScreen_ParkingLogo.svg",width: 24),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.only(top: 10,),
                                    child: Text(
                                      "Parking",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff4a789c),
                                        height: 20/14,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              )
                            )
                          )
                      ),
                      Container(
                          child: Expanded(
                              child: Container(
                                  margin: EdgeInsets.all(16),
                                  padding: EdgeInsets.all(8),
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Color(0xffEBEBEB),
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(8))
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: SvgPicture.asset("assets/BuildingInfoScreen_ElevatorLogo.svg",width: 22),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: 8,),
                                        child: Text(
                                          "Elevator",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff4a789c),
                                            height: 20/14,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  )
                              )
                          )
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: 55,
                            margin: EdgeInsets.only(left: 16,right: 16,top: 8),
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
                                  margin: EdgeInsets.only(left: 8),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset("assets/BuildingInfoScreen_AccesibilityLogo.svg",width: 24),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(left: 12),
                                  child: Text(
                                    "Accessible Pathways",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff4a789c),
                                      height: 20/14,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            )
                        )
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 32,left:16),
                  child: Text(
                    "Venue Information",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12,top:16 ),
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenueLocationIconsvg.svg",width: 40),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 12),
                        child: Text(
                          "Plot No. 2, Rajivpat Haryana-131029",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff4a789c),
                            height: 20/14,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12,top:12),
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenuePhoneIcon.svg",width: 40),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 12),
                        child: Text(
                          "044 - 2344542",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff4a789c),
                            height: 20/14,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12,top:12),
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenueLinkIcon.svg",width: 40),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 12),
                        child: Text(
                          "https://www.ashoka.edu.in/",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff4a789c),
                            height: 20/14,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12,top:12),
                  alignment: Alignment.centerLeft,
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenueLinkIcon.svg",width: 40),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 12),
                        child: Column(
                          children: [
                            Container(
                              child: Text(
                                "Opening Hours: Monday to Saturday",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff4a789c),
                                  height: 20/14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            // Container(
                            //   alignment: Alignment.bottomLeft,
                            //   child: Text(
                            //     "9:00 Am - 05:00 Pm",
                            //     style: const TextStyle(
                            //       fontFamily: "Roboto",
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w400,
                            //       color: Color(0xff4a789c),
                            //       height: 20/14,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),


      ),
    );
  }


}