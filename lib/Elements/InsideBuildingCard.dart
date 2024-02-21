import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:iwayplusnav/BuildingInfoScreen.dart';
import '../API/buildingAllApi.dart';
import '../Navigation.dart';

class InsideBuildingCard extends StatelessWidget {
  String imageURL;
  String buildingName;
  String Tag;
  String buildingId;

  InsideBuildingCard({required this.imageURL, required this.buildingName, required this.Tag,required this.buildingId});

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

    return GestureDetector(
      onTap: (){
        buildingAllApi.setStoredString(buildingId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Navigation(buildingID: buildingAllApi.selectedID,),
          ),
        );
      },
        child: Container(
          margin: EdgeInsets.only(left: 16,top: 10,right: 8),
          width: screenWidth-150,
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
                width: screenWidth-150,
                height: 170,
                padding: EdgeInsets.only(left:8,right: 8,top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  child: Image.network(
                    'https://dev.iwayplus.in/uploads/$imageURL',
                    // You can replace the placeholder image URL with your default image URL
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/default-image.jpg', // Replace with the path to your default image asset
                        fit: BoxFit.fill,
                      );
                    },
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          truncateString(buildingName,25),
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff0c141c),
                            height: 25/16,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        margin: EdgeInsets.fromLTRB(16, 3, 16, 0),
                        child: Text(
                          truncateString(Tag,25),
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff4a4545),
                            height: 20/14,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  // Container(
                  //   child: GestureDetector(
                  //     onTap: (){
                  //       buildingAllApi.setStoredString(buildingId);
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => Navigation(buildingID: buildingAllApi.selectedID,),
                  //         ),
                  //       );
                  //     },
                  //     child: Container(
                  //       margin: EdgeInsets.all(16),
                  //       width: 10,
                  //       height: 10,
                  //       alignment: Alignment.center,
                  //       decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           border: Border.all(
                  //             color: Color(0xffEBEBEB),
                  //           ),
                  //           borderRadius: BorderRadius.all(Radius.circular(8))
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),





            ],
          ),
        )
    );
  }
}