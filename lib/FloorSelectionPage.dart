import 'dart:collection';
import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwayplusnav/API/buildingAllApi.dart';
import 'package:iwayplusnav/API/ladmarkApi.dart';
import 'package:iwayplusnav/APIMODELS/buildingAll.dart';
import 'package:iwayplusnav/Elements/HelperClass.dart';
import 'package:iwayplusnav/Elements/SearchNearby.dart';
import 'package:iwayplusnav/Elements/SearchpageRecents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'APIMODELS/landmark.dart';
import 'Elements/DestinationPageChipsWidget.dart';
import 'Elements/HomepageFilter.dart';
import 'Elements/SearchpageCategoryResult.dart';
import 'Elements/SearchpageResults.dart';
class FloorSelectionPage extends StatefulWidget {
  String filterName ;
  String filterBuildingName;

  FloorSelectionPage({required this.filterName,required this.filterBuildingName});

  @override
  State<FloorSelectionPage> createState() => _FloorSelectionPageState();
}

class _FloorSelectionPageState extends State<FloorSelectionPage> {
  land landmarkData = land();

  List<Widget> searchResults = [];

  List<Widget> recentResults = [];

  List<dynamic> recent = [];

  TextEditingController _controller = TextEditingController();

  final SpeechToText speetchText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = "";
  String searchHintString = "";
  bool topBarIsEmptyOrNot = false;



  @override
  void initState() {
    super.initState();
    optionListForUI.add(widget.filterName);
    optionListForUI.add(widget.filterBuildingName);


    if(widget.filterName!=""){
      setState(() {
        _controller.text = widget.filterName;
      });
    }
    setState(() {
      searchHintString = widget.filterName;
    });
    fetchlist();
  }


  void fetchlist()async{
    buildingAllApi.getStoredAllBuildingID().forEach((key, value)async{
      await landmarkApi().fetchLandmarkData(id: key).then((value){
        landmarkData.mergeLandmarks(value.landmarks);
      });
    });
  }

  bool category = false;
  Set<String> cardSet = Set();
  // HashMap<String,Landmarks> cardSet = HashMap();
  List<String> optionList = [
    'washroom', 'entry',
    'reception', 'lift',
  ];
  List<String> optionListForUI = [];
  List<String> floorOptionList = ['B2', 'B1', 'F0','F1','F2'];

  Set<String> optionListItemBuildingName = {};
  List<Widget> searcCategoryhResults = [];

  List<int> floors = [];

  void search(String filterText,String buildingText,List<int> floor){
    setState(() {
      try {
        if(landmarkData.landmarksMap!.isNotEmpty) {
          searchResults.clear();
          landmarkData.landmarksMap!.forEach((key, value) {
            if (searchResults.length < 10) {
              if (value.name != null && value.element!.subType != "beacons") {
                if(floor.isNotEmpty){
                  print(value.floor);
                  if (value.name!.toLowerCase().contains(filterText.toLowerCase()) && value.buildingName!.toLowerCase().contains(buildingText.toLowerCase()) && floor.contains(value.floor)) {
                    searchResults.add(SearchpageResults(name: "${value.name}",
                      location: "Floor ${value.floor}, ${value
                          .buildingName}, ${value.venueName}",
                      onClicked: onVenueClicked,
                      ID: value.properties!.polyId!,
                      bid: value.buildingID!,
                      floor: value.floor.toString(),));
                  }
                }else{
                  if (value.name!.toLowerCase().contains(filterText.toLowerCase()) && value.buildingName!.toLowerCase().contains(buildingText.toLowerCase())) {
                    searchResults.add(SearchpageResults(name: "${value.name}",
                      location: "Floor ${value.floor}, ${value
                          .buildingName}, ${value.venueName}",
                      onClicked: onVenueClicked,
                      ID: value.properties!.polyId!,
                      bid: value.buildingID!,
                      floor: value.floor.toString(),));
                  }
                }

              }
            } else {
              return;
            }
          });
        }
      }catch(e){
        print("Error in FloorSelectionPage");
      }


    });

    print("optionListItemBuildingName");
    print(optionListItemBuildingName);
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
    Navigator.pop(context,ID);
  }




  List<IconData> _icons = [
    Icons.home,
    Icons.wash_sharp,
    Icons.school,
  ];
  List<String> optionsTags = [];
  List<String> floorOptionsTags = [];
  String currentSelectedFilter = "";
  Color containerBoxColor = Color(0xffA1A1AA);
  Color micColor = Colors.black;
  bool micselected = false;
  int vall = 0;
  int vall2 = 0;
  int tag=0;


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if(widget.filterName.isNotEmpty && widget.filterBuildingName.isNotEmpty){
      search(widget.filterName, widget.filterBuildingName,floors);
    }
    // if(speetchText.isNotListening){
    //   micColor = Colors.black;
    //   print("Not listening");
    // }else{
    //   micColor = Color(0xff24B9B0);
    // }
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  width: screenWidth - 32,
                  height: 48,
                  margin: EdgeInsets.only(top: 16,left: 16,right: 17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: containerBoxColor, // You can customize the border color
                      width: 1.0, // You can customize the border width
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: SvgPicture.asset("assets/DestinationSearchPage_BackIcon.svg"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: TextField(
                              autofocus: true,
                              enabled: false,
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: "${searchHintString}",
                                border: InputBorder.none, // Remove default border
                              ),
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff18181b),
                                height: 25/16,
                              ),
                              onTap: (){
                                if(containerBoxColor==Color(0xffA1A1AA)){
                                  containerBoxColor = Color(0xff24B9B0);
                                }else{
                                  containerBoxColor = Color(0xffA1A1AA);
                                }
                                print("Final Set");

                              },
                            )),
                      ),

                    ],
                  )
              ),

              Container(
                width: screenWidth,
                child: ChipsChoice<int>.single(
                  value: vall,
                  onChanged: (val){
                    setState(() => vall = val);
                    print("wilsonchecker");
                    print(optionListForUI.length);
                  },
                  choiceItems: C2Choice.listFrom<int, String>(
                    source: optionListForUI,
                    value: (i, v) => i,
                    label: (i, v) => v,
                  ),
                  choiceBuilder: (item, i) {
                    return DestinationPageChipsWidgetForFloorSelectionPage(svgPath: '',
                      text: optionListForUI[i],
                      onSelect: (bool selected) {},selected: true,);
                  },
                  direction: Axis.horizontal,
                ),
              ),
              Container(
                width: screenWidth,
                margin: EdgeInsets.only(bottom: 10),
                child: ChipsChoice<int>.single(
                  value: tag,
                  onChanged: (val){
                    setState(() => tag = val);
                    // print("wilsonchecker");
                    // print(val);
                    print("Floor check");
                    print(val);
                    floors.clear();
                      floors.add(val);
                    search(widget.filterName, widget.filterBuildingName, floors);
                    print(searchResults);
                  },
                  choiceItems: C2Choice.listFrom<int, String>(
                    source: floorOptionList,
                    value: (i, v) => i,
                    label: (i, v) => v,
                  ),
                  choiceBuilder: (item, i) {
                    return FloorWidgetForFloorSelectionPage(
                      // onSelect: (setVal) {
                      //   floors.clear();
                      //   floors.add(i);
                      //   setState(() {
                      //     search(widget.filterName, widget.filterBuildingName, floors);
                      //     selVal = !selVal;
                      //   });
                      //
                      //   print("selVal");
                      //   print(selVal);
                      //
                      // },
                      onSelect: item.select!,selected: item.selected,
                      floorNo: i.toString(),
                      // selected: selVal,

                    );
                  },
                  direction: Axis.horizontal,
                ),
              ),

              Flexible(flex:1,
                  child: SingleChildScrollView(
                      child: Column(children:searchResults,)
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DestinationPageChipsWidgetForFloorSelectionPage extends StatefulWidget {
  final String svgPath;
  final String text;
  bool selected;
  final Function(bool selected) onSelect;

  DestinationPageChipsWidgetForFloorSelectionPage({
    required this.svgPath,
    required this.text,
    this.selected = false,
    required this.onSelect,
  });

  @override
  _DestinationPageChipsWidgetForFloorSelectionPageState createState() => _DestinationPageChipsWidgetForFloorSelectionPageState();
}

class _DestinationPageChipsWidgetForFloorSelectionPageState extends State<DestinationPageChipsWidgetForFloorSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: EdgeInsets.only(top: 8,left: 8,right: 4),

      padding: EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.selected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey, // Shadow color
            offset: Offset(0, 2), // Offset of the shadow
            blurRadius: 4, // Spread of the shadow
          ),
        ],
      ),
      duration: Duration(milliseconds: 500),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(10.0)), // Updated borderRadius
        onTap: () {

          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 4),
              child: Icon(Icons.wallet_giftcard_outlined, size: 18, color: widget.selected? Colors.white: Colors.black,),
            ),
            Container(
              margin: EdgeInsets.only(left: 8, right: 4),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.selected? Colors.white : Color(0xff49454f) ,
                  height: 20 / 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 4),
              child: Icon(Icons.close, size: 18, color: widget.selected? Colors.white: Colors.black,),
            )


            // Icon displayed when active is true
          ],
        ),
      ),
    );
  }
}

class FloorWidgetForFloorSelectionPage extends StatefulWidget {
  final String floorNo;
  bool selected;
  final Function(bool selected) onSelect;

  FloorWidgetForFloorSelectionPage({
    required this.floorNo,
    required this.selected ,
    required this.onSelect,
  });

  @override
  _FloorWidgetForFloorSelectionPageState createState() => _FloorWidgetForFloorSelectionPageState();
}

class _FloorWidgetForFloorSelectionPageState extends State<FloorWidgetForFloorSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: 50,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.only(left: 8,right: 8,top: 8,bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.selected ? Colors.black : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey, // Shadow color
            offset: Offset(0, 2), // Offset of the shadow
            blurRadius: 4, // Spread of the shadow
          ),
        ],
      ),
      duration: Duration(milliseconds: 500),
      child: InkWell(
        onTap: () {
          setState(() {
            widget.selected = !widget.selected;
          });
          widget.onSelect(widget.selected);
          widget.selected ? print("black") : print("white");

          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => DestinationSearchPage(previousFilter: widget.text,))
          // );
        },
        child: Center(
          child: Text(
            widget.floorNo,
            style: TextStyle(
              color: widget.selected ? Colors.white : Colors.black,
              fontSize: 16, // Adjust font size as needed
            ),
          ),
        ),
      ),
    );
  }
}

