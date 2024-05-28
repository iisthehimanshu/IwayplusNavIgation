import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/Elements/buildingCard.dart';
import 'package:iwaymaps/Navigation.dart';
import 'API/BuildingAPI.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/buildingAll.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'Elements/InsideBuildingCard.dart';
import 'DATABASE/BOXES/FavouriteDataBaseModelBox.dart';
import 'DATABASE/DATABASEMODEL/FavouriteDataBase.dart';


class FavouriteScreen extends StatefulWidget {

  FavouriteScreen();


  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<FavouriteDataBaseModel> favouriteList = [];

  @override
  void initState() {
    super.initState();
    var favouriteBox = FavouriteDataBaseModelBox.getData();
    print("favouriteBox.length");
    print(favouriteBox.length);
    favouriteList = List.from(favouriteBox.values);
    //print(favouriteBox.getAt(0)?.venueBuildingLocation);
    print(favouriteList);

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
                // child: IconButton(
                //     onPressed: (){
                //       Navigator.pop(context);
                //     },
                //     icon: const Icon(Icons.arrow_back_ios)
                // )
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
                Container(
                  height: screenHeight,
                  child: ListView.builder(
                    itemBuilder: (context,index){
                      var currentData = favouriteList[index];
                      return GestureDetector(
                        onTap: () {
                          // Handle onTap for the specific item here
                          // For example, you can navigate to a new screen or perform some action
                          // print("Tapped on item at index $index");
                          // buildingAllApi.setStoredVenue(currentData.venueName!);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName]),
                          //   ),
                          // );
                        },
                        child: buildingCard(
                          imageURL:  "",
                          Name: "",
                          Tag: "",
                          Address: "",
                          Distance: 190,
                          NumberofBuildings: 0,
                          bid: "",
                        ),
                      );
                    },
                    itemCount: favouriteList.length,
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