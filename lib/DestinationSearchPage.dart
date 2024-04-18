import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  TextEditingController _controller = TextEditingController();
  final SpeechToText speetchText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = "";
  String searchHintString = "";
  bool topBarIsEmptyOrNot = false;
  Set<String> cardSet = Set();


  @override
  void initState() {
    super.initState();
    print("In search page");
    initSpeech();
    setState(() {
      searchHintString = widget.hintText;
    });


    fetchlist();
    fetchRecents();
    recentResults.add(
        Container(
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

  void initSpeech() async {
    speechEnabled = await speetchText.initialize();
    setState(() {});
  }
  void startListening() async {
    if(await speetchText.hasPermission==false){
      HelperClass.showToast("Permission not allowed");
      return;
    }

    setState(() {
      searchHintString = "";
    });
    await speetchText.listen(onResult: onSpeechResult);
    if(speetchText.isNotListening){
      setState(() {
        searchHintString = widget.hintText;
      });
    }
    print("In initSpeech");
  }

  void onSpeechResult(result){
    setState(() {
      print("Listening from mic");
      print(result.recognizedWords);
      setState(() {
        _controller.text = result.recognizedWords;
        search(result.recognizedWords);
        print(_controller.text);
      });
      wordsSpoken = "${result.recognizedWords}";
      if(result.recognizedWords == null){
        setState(() {
          searchHintString = widget.hintText;
        });
      }
    });
    print("In onSpeechResult");
  }

  void stopListening() async{
    await speetchText.stop();
    if(speetchText.isNotListening) {
      setState(() {
        searchHintString = widget.hintText;
      });
    }
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
                final nameList = [value.name!.toLowerCase()];
                final fuse = Fuzzy(
                  nameList,
                  options: FuzzyOptions(
                    findAllMatches: true,
                    tokenize: true,
                    threshold: 0.5,
                  ),
                );
                final result = fuse.search(searchText.toLowerCase());

                // print("Wilsonchexker");
                // print(result);
                cardSet.add(value.name!);

                searchResults.add(SearchpageResults(name: "${value.name}", location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}", onClicked: onVenueClicked, ID: value.properties!.polyId!, bid: value.buildingID!,floor: value.floor.toString(),));
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
    print("id received $ID");
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

  List<String> options = [
    'Washroom', 'Food & Drinks',
    'Reception', 'Break Room', 'Education',
    'Fashion', 'Travel', 'Rooms', 'Tech',
    'Science',
  ];

  List<String> floorOptions = [
    'Food & Drinks', 'Washroom', 'Water',
  ];

  List<IconData> _icons = [
    Icons.home,
    Icons.wash_sharp,
    Icons.school,
  ];
  List<String> optionsTags = [];
  List<String> floorOptionsTags = [];
  String currentSelectedFilter = "";
  Color containerBoxColor = Color(0xffA1A1AA);


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                            child: TextFormField(
                              autofocus: false,
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
                              },
                              onChanged: (value){
                                // setState(() {
                                //   if(value.length!=0){
                                //     speechEnabled = false;
                                //     searchString = widget.hintText;
                                //   }else{
                                //     print("Tapped");
                                //   }
                                //
                                // });

                                search(value);
                                print("Final Set");
                                print(cardSet);
                              },
                            )),
                      ),
                      Container(
                        width: 40,
                        height: 48,
                        margin: EdgeInsets.only(right: 12),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                speetchText.isListening? stopListening() : startListening();
                              });
                            },
                            icon: Icon(
                              Icons.mic_none_sharp,
                              color: Color(0xff282828),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ),

              Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                child: ValueListenableBuilder(
                  valueListenable: Hive.box('Filters').listenable(),
                  builder: (BuildContext context, value, Widget? child) {
                    //List<dynamic> aa = []
                    if(value.length==2){
                      floorOptionsTags = value.getAt(1);
                    }
                    return ChipsChoice<String>.single(
                      value: currentSelectedFilter,
                      onChanged: (val) {
                        print("Destinationpage Filter change${val}${value.values}");
                        value.put(1, val);
                        setState(() {
                          currentSelectedFilter = val;
                          //onTagsChanged();
                        });
                      },
                      choiceItems: C2Choice.listFrom<String, String>(
                        source: floorOptions,
                        value: (i, v) => v,
                        label: (i, v) => v,
                        tooltip: (i, v) => v,
                        meta: (i, v) => _icons[i],
                        // delete: (i, v) => () {
                        //   setState(() => options.removeAt(i));
                        // },
                      ),
                      choiceLeadingBuilder: (data, i) {
                        if (data.meta == null) return null;
                        return Icon(data.meta as IconData); // Display the icon from the meta property
                      },
                      padding: EdgeInsets.only(left: 0,top: 10),
                      choiceCheckmark: true,
                      choiceStyle: C2ChipStyle.outlined(
                        height: 38,
                        borderRadius: BorderRadius.all(
                          Radius.circular(9),
                        ),
                        selectedStyle:  C2ChipStyle.filled(
                          color: Colors.black
                        ),
                        borderWidth: 1,

                      ),
                      wrapped: false,
                    );
                  },
                ),
              ),

              Flexible(flex:1,
                  child: SingleChildScrollView(
                      child: Column(children: searchResults,)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SetInfo{
  String SetInfoLandmarkName;
  String SetInfoBuildingName;
  SetInfo({required this.SetInfoBuildingName,required this.SetInfoLandmarkName});
}
