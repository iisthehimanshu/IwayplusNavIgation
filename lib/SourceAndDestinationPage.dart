import 'dart:convert';

import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iwaymaps/API/ladmarkApi.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/Elements/SearchpageRecents.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'APIMODELS/landmark.dart';
import 'DestinationSearchPage.dart';
import 'Elements/SearchpageResults.dart';
import 'UserState.dart';
class SourceAndDestinationPage extends StatefulWidget {
  String SourceID ;
  String DestinationID;
  UserState? user;
  SourceAndDestinationPage({this.SourceID = "", this.DestinationID = "", this.user});

  @override
  State<SourceAndDestinationPage> createState() => _SourceAndDestinationPageState();
}

class _SourceAndDestinationPageState extends State<SourceAndDestinationPage> {

  land landmarkData = land();

  String SourceName = "";
  String DestinationName = "";

  List<Widget> recentResults = [];

  List<dynamic> recent = [];


  @override
  void initState() {
    super.initState();
    fetchlist().then((value){
      setState(() {
        if(widget.SourceID == ""){
          SourceName = "Select source";
        }else{
          SourceName = landmarkData.landmarksMap![widget.SourceID]!.name!;
          print("SourceName");
          print(SourceName);
        }
        if(widget.DestinationID == ""){
          DestinationName = "Search destination";
        }else{
          DestinationName = landmarkData.landmarksMap![widget.DestinationID]!.name!;
        }
      });
    });
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

  Future<void> fetchlist()async{
    buildingAllApi.getStoredAllBuildingID().forEach((key, value)async{
      await landmarkApi().fetchLandmarkData(id: key).then((value){
        landmarkData.mergeLandmarks(value.landmarks);
      });
    });
  }

  void swap(){
    String temp = widget.SourceID;
    widget.SourceID = widget.DestinationID;
    widget.DestinationID = temp;

    fetchlist().then((value){
      setState(() {
        if(widget.SourceID == ""){
          SourceName = "Select source";
        }else{
          SourceName = landmarkData.landmarksMap![widget.SourceID]!.name!;
        }
        if(widget.DestinationID == ""){
          DestinationName = "Search destination";
        }else{
          DestinationName = landmarkData.landmarksMap![widget.DestinationID]!.name!;
        }
      });
    });
  }


  void clearAllRecents()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recents');
  }

  void fetchRecents()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('recents');
    if(savedData != null){
      recent = jsonDecode(savedData);
      setState(() {
        for(List<dynamic> value in recent){
          recentResults.add(SearchpageRecents(name: value[0], location: value[1],onVenueClicked: onVenueClicked, ID: value[2], bid: value[3],));
        }
      });
    }
  }

  void onVenueClicked(String name, String location, String ID,String bid){
    fillFromRecent(name, ID);
  }

  void fillFromRecent(String name, String ID){
    setState(() {
      if(widget.SourceID == ""){
        widget.SourceID = ID;
        SourceName = name;
      }else if(widget.DestinationID == ""){
        widget.DestinationID = ID;
        DestinationName = name;
      }
      if(widget.SourceID != "" && widget.DestinationID != ""){
        print("h1");
        Navigator.pop(context,[widget.SourceID,widget.DestinationID]);
      }

    });
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 119,
                width: screenWidth-32,
                padding: EdgeInsets.only(top: 15,bottom: 15),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: IconButton(onPressed: (){
                        print("h2");
                        Navigator.pop(context);
                      }, icon: Semantics(label:"Back",child: Icon(Icons.arrow_back_ios_new,size: 24,))),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          FocusScope(
                            autofocus: true,
                            child: Focus(
                              child: Semantics(
                                label: "SourceName",
                                child: InkWell(
                                  child: Container(height:40,width:double.infinity,margin:EdgeInsets.only(bottom: 8),decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: Color(0xffE2E2E2)),
                                  ),
                                    padding: EdgeInsets.only(left: 8,top: 7,bottom: 8),
                                    child: Text(
                                      SourceName,
                                      style:  TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: widget.SourceID != ""?Color(0xff24b9b0):Color(0xff282828),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),),
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DestinationSearchPage(hintText: 'Source location',voiceInputEnabled: false,userLocalized: widget.user != null? widget.user!.key:"",))
                                    ).then((value){
                                      setState(() {
                                        widget.SourceID = value;
                                        print("dataPOpped:$value");
                                        SourceName = widget.user?.key == value ? "Your current location":landmarkData.landmarksMap![value]!.name!;
                                        if(widget.SourceID != "" && widget.DestinationID != ""){
                                          print("h3");
                                          Navigator.pop(context,[widget.SourceID,widget.DestinationID]);
                                        }
                                      });
                                    });
                                  },
                                ),

                              ),),


                          ),
                          InkWell(
                            child: Container(height:40,width:double.infinity,decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Color(0xffE2E2E2)),
                            ),
                              padding: EdgeInsets.only(left: 8,top: 7,bottom: 8),
                              child: Text(
                                DestinationName,
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff282828),
                                ),
                                textAlign: TextAlign.left,
                              ),),
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DestinationSearchPage(hintText: 'Destination location',voiceInputEnabled: false,))
                              ).then((value){
                                setState(() {
                                  widget.DestinationID = value;
                                  DestinationName = landmarkData.landmarksMap![value]!.name??landmarkData.landmarksMap![value]!.element!.subType!;
                                  if(widget.SourceID != "" && widget.DestinationID != ""){
                                    print("h4");
                                    Navigator.pop(context,[widget.SourceID,widget.DestinationID]);
                                  }
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: IconButton(onPressed: (){
                        swap();
                      }, icon: Semantics(label: "Swap Directions",child: Icon(Icons.swap_vert_circle_outlined,size: 24,))),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: screenWidth,
                height: 1,
                color: Color(0xffB3B3B3),
              ),
              Flexible(flex:1,child: SingleChildScrollView(child: Column(children: recentResults,)))
            ],
          ),
        ),
      ),
    );
  }
}