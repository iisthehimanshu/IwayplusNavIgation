import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:iwayplusnav/BuildingInfoScreen.dart';
import 'package:iwayplusnav/DATABASE/BOXES/FavouriteDataBaseModelBox.dart';
import '../API/buildingAllApi.dart';
import '../DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import '../DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import '../Navigation.dart';

class InsideBuildingCard extends StatefulWidget {
  String imageURL;
  String buildingName;
  String Tag;
  String buildingId;
  bool favourite = false;

  InsideBuildingCard(
      {required this.imageURL, required this.buildingName, required this.Tag, required this.buildingId, this.favourite = false});

  @override
  _InsideBuildingCardState createState() => _InsideBuildingCardState();

}

class _InsideBuildingCardState extends State<InsideBuildingCard> {
  bool isFavourite = false;
  var favouriteBox = FavouriteDataBaseModelBox.getData();


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

    return Container(
      margin: EdgeInsets.only(left: 16,top: 10,),
      width: 184,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xffEBEBEB),
          ),
          borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              buildingAllApi.setStoredString(widget.buildingId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Navigation(buildingID: buildingAllApi.selectedID,),
                ),
              );
            },
            child: Container(
              width: 168,
              height: 117,
              margin: EdgeInsets.only(top: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8),bottomLeft:Radius.circular(8),bottomRight: Radius.circular(8) ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8),bottomLeft:Radius.circular(8),bottomRight: Radius.circular(8)),
                child: Image.network(
                  'https://dev.iwayplus.in/uploads/$widget.imageURL',
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
          ),
          GestureDetector(
            onTap: (){
              buildingAllApi.setStoredString(widget.buildingId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Navigation(buildingID: buildingAllApi.selectedID,),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(top: 12,left: 8),
              alignment: Alignment.topLeft,
              child: Text(
                truncateString(widget.buildingName,15),
                style: const TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff0c141c),
                  height: 25/16,
                ),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: (){
                  buildingAllApi.setStoredString(widget.buildingId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Navigation(buildingID: buildingAllApi.selectedID,),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(left: 8,top:3,bottom: 8),
                  alignment: Alignment.topLeft,
                  child: Text(
                    truncateString(widget.Tag,25),
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
              ),
              Spacer(),
              GestureDetector(
                onTap: (){
                  //widget.favourite = true;
                  // print("HEART");
                  setState(() {
                    isFavourite = !isFavourite;
                  });
                  if(isFavourite){
                    final data = FavouriteDataBaseModel(venueBuildingName: widget.buildingName, venueBuildingLocation: widget.Tag);
                    favouriteBox.add(data);
                  }else{
                    print("favouriteBox.keys.contains(widget.buildingName");
                    print(favouriteBox.keys.contains(widget.buildingName));

                    favouriteBox.deleteAt(favouriteBox.get(widget.buildingName) as int);
                  }
                },
                child: Container(
                    margin:EdgeInsets.only(right: 8,bottom: 7),
                    child: isFavourite ? SvgPicture.asset("assets/IndideBuildingCard_HeartRed.svg") : SvgPicture.asset("assets/InsideBuildingCard_HeartIcon.svg"),
              ))
            ],
          ),


        ],
      ),
    );
  }
  }
