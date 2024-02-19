import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';

import 'APIMODELS/buildingAllModel.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';


class BuildingInfoScreen extends StatefulWidget {
  const BuildingInfoScreen({Key? key,}) : super(key: key);


  @override
  State<BuildingInfoScreen> createState() => _BuildingInfoScreenState();
}

class _BuildingInfoScreenState extends State<BuildingInfoScreen> {
  late List<buildingAllModel> buildingList=[];
  final BuildingAllBox = BuildingAllAPIModelBOX.getData();



  String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + '..';
    }
  }
  @override
  void initState(){
    super.initState();
    if(BuildingAllBox.length!=0){
      print("BUILDING API DATA FROM DATABASE");
      print(BuildingAllBox.length);
      List<dynamic> responseBody = BuildingAllBox.getAt(0)!.responseBody;
      buildingList = responseBody.map((data) => buildingAllModel.fromJson(data)).toList();
      print(buildingList);
    }
    print(buildingList[0]);
  }


  @override
  Widget build(BuildContext context) {
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: Container(
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
                        "",
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
            SizedBox(height: 8,),
            Text(
              "",
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined,size: 13,color: Color(0xff8D8C8C),),
                SizedBox(width: 8,),
                Text(
                  truncateString("", 25),
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff8d8c8c),
                    height: 20/14,
                  ),
                  maxLines: 1, // Set the maximum number of lines
                  overflow: TextOverflow.ellipsis, // Display '...' when overflowed
                ),
              ],
            ),
            SizedBox(height: 4,),
            Text(
              "Km to Venue",
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
              " Buildings",
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

      ),
    );
  }


}