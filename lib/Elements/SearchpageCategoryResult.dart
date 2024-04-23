import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iwayplusnav/Elements/HelperClass.dart';

import '../FloorSelectionPage.dart';
class SearchpageCategoryResults extends StatefulWidget {
  final String name;
  final String buildingName;

  const SearchpageCategoryResults({required this.name,required this.buildingName,});

  @override
  State<SearchpageCategoryResults> createState() => _SearchpageCategoryResultsState();
}

class _SearchpageCategoryResultsState extends State<SearchpageCategoryResults> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FloorSelectionPage(filterName: widget.name, filterBuildingName: widget.buildingName,),
          ),
        );

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

              child: SvgPicture.asset("assets/SearchpageCategoryResult_manIcon.svg"),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12,left: 12),
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
                  margin: EdgeInsets.only(top:3,bottom: 14,left: 12),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(widget.buildingName,25),
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
            Container(
              margin: EdgeInsets.only(left: 8,right:16 ),
              alignment: Alignment.center,
                child: Icon(Icons.chevron_right,color: Color(0xff8d8c8c),size: 25,)
            ),
          ],
        ),
      ),
    );
  }
}
