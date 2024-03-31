import 'dart:convert';

import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/API/ladmarkApi.dart';
import 'package:iwayplusnav/APIMODELS/buildingAll.dart';
import 'package:iwayplusnav/Elements/SearchNearby.dart';
import 'package:iwayplusnav/Elements/SearchpageRecents.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'APIMODELS/landmark.dart';
import 'Elements/SearchpageResults.dart';
class DestinationSearchPage extends StatefulWidget {
  String hintText ;
  DestinationSearchPage({required this.hintText});

  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {


  land landmarkData = land();

  List<Widget> searchResults = [];

  List<Widget> recentResults = [];

  List<dynamic> recent = [];


  @override
  void initState() {
    super.initState();
    fetchlist();
    fetchRecents();
    recentResults.add(Container(
      margin: EdgeInsets.only(left:16, right: 16, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Searches",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff000000),
              height: 23/16,
            ),
            textAlign: TextAlign.left,
          ),
          TextButton(onPressed: (){
            clearAllRecents();
            recent.clear();
            setState(() {
              recentResults.clear();
            });
          }, child: Text(
            "Clear all",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xff24b9b0),
              height: 25/16,
            ),
            textAlign: TextAlign.left,
          ))
        ],
      ),
    ));
  }

  void fetchlist()async{
    buildingAllApi.getStoredAllBuildingID().forEach((key, value)async{
      await landmarkApi().fetchLandmarkData(id: key).then((value){
        landmarkData.mergeLandmarks(value.landmarks);
      });
    });
  }

  void addtoRecents(String name, String location, String ID, String bid)async{
    if (!recent.any((element) => element[0] == name && element[1] == location)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      recent.add([name,location,ID,bid]);
      await prefs.setString('recents', jsonEncode(recent)).then((value){
        print("saved $name");
      });
    }

  }

  void clearAllRecents()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recents');
  }

  void search(String searchText){
    setState(() {
      searchResults.clear();
      if(searchText.length>0){
        landmarkData.landmarksMap!.forEach((key, value) {
          if(searchResults.length<10){
            if(value.name != null && value.element!.subType != "beacons"){
              if(value.name!.toLowerCase().contains(searchText.toLowerCase())){
                searchResults.add(SearchpageResults(name: "${value.name}", location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}", onClicked: onVenueClicked, ID: value.properties!.polyId!, bid: value.buildingID!,));
              }
            }
          }else{
            return;
          }
        });
      }else{
        searchResults = recentResults;
      }
    });
  }

  void fetchRecents()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('recents');
    if(savedData != null){
      recent = jsonDecode(savedData);
      setState(() {
        for(List<dynamic> value in recent){
          if(buildingAllApi.getStoredAllBuildingID()[value[3]] != null){
            recentResults.add(SearchpageRecents(name: value[0], location: value[1],onVenueClicked: onVenueClicked, ID: value[2], bid: value[3],));
            searchResults = recentResults;
          }
        }
      });
    }
  }

  void onVenueClicked(String name, String location, String ID, String bid){
    addtoRecents(name, location,ID,bid);
    Navigator.pop(context,ID);
  }

  void showToast(String mssg) {
    Fluttertoast.showToast(
      msg: mssg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 16),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  width: screenWidth - 32,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white, // You can customize the border color
                      width: 1.0, // You can customize the border width
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 48,
                        margin: EdgeInsets.only(right: 4),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: TextFormField(
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: "${widget.hintText}"
                              ),
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff000000),
                                height: 25/16,
                              ),
                              onChanged: (value){
                                search(value);
                              },
                            )),
                      ),
                      Container(
                        width: 40,
                        height: 48,
                        child: Center(
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.mic_none_sharp,
                              color: Color(0xff8E8C8C),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      EasterEggTrigger(
                        child: Container(
                          width: 40,
                          height: 48,
                          margin: EdgeInsets.only(right: 7),
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                print("no easter egg");
                              },
                              icon: Icon(
                                Icons.qr_code_scanner_sharp,
                                color: Color(0xff8E8C8C),
                                size: 24,
                              ),
                            ),
                          ),
                        ),codes: [
                          EasterEggTriggers.SwipeDown,
                        EasterEggTriggers.LongPress,
                      ],
                        action: (){
                          showToast("Why are you doing this");
                        },
                      )
                      ,
                    ],
                  )),
              SizedBox(
                height: 16,
              ),
              Container(
                width: screenWidth,
                height: 1,
                color: Color(0xffB3B3B3),
              ),
              Flexible(flex:1,child: SingleChildScrollView(child: Column(children: searchResults,))),
            ],
          ),
        ),
      ),
    );
  }
}
