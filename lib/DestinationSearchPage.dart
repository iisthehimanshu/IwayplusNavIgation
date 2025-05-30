import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/API/ladmarkApi.dart';
import 'package:iwaymaps/APIMODELS/buildingAll.dart';
import 'package:iwaymaps/Elements/DestinationPageChipsWidget.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/Elements/SearchNearby.dart';
import 'package:iwaymaps/Elements/SearchpageRecents.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:iwaymaps/pathState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'APIMODELS/landmark.dart';
import 'Elements/DestinationPageChipsWidget.dart';
import 'Elements/HomepageFilter.dart';

import 'Elements/SearchpageCategoryResult.dart';
import 'Elements/SearchpageResults.dart';
import 'package:iwaymaps/buildingState.dart';


class DestinationSearchPage extends StatefulWidget {
  String hintText;
  String previousFilter;
  bool voiceInputEnabled;
  String userLocalized;

  DestinationSearchPage(
      {this.hintText = "",
        this.previousFilter = "",
        required this.voiceInputEnabled,this.userLocalized = ""});

  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {
  land landmarkData = land();
  List<String> landmarkFuzzyNameList = [];

  List<Widget> searchResults = [];

  List<Widget> recentResults = [];
  List<Widget> topSearches=[];

  List<dynamic> recent = [];

  TextEditingController _controller = TextEditingController();
  Timer? _searchDebounce;

  final SpeechToText speetchText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = "";
  String searchHintString = "";
  bool topBarIsEmptyOrNot = false;
  int lastIndex = -1;
  String selectedButton = "";

  @override

  void initState()  {
    super.initState();
    fetchandBuild();
    _controller.addListener(_onSearchChanged);
    // //optionListItemBuildingNameNew.clear();
    // print("optionListItemBuildingNameNew");
    // print(optionListItemBuildingNameNew);
    // Building.buildingData?.forEach((key, value) {
    //   optionListItemBuildingNameNew.add(value!);
    // });
    // print(optionListItemBuildingNameNew);
    for (int i = 0; i < optionListForUI.length; i++) {
      if (optionListForUI[i].toLowerCase() ==
          widget.previousFilter.toLowerCase()) {
        vall = i;
      }
    }
    if (widget.voiceInputEnabled) {
      initSpeech();
      setState(() {
        speetchText.isListening ? stopListening() : startListening();
      });
      if (!micselected) {
        micColor = Color(0xff24B9B0);
      }

      setState(() {});
    }

    if (widget.previousFilter != "") {
      setState(() {
        _controller.text = widget.previousFilter;
      });
    }
    setState(() {
      searchHintString = widget.hintText;
    });

    fetchRecents();
    recentResults.add(Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Semantics(
        excludeSemantics: true,
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
                height: 23 / 16,
              ),
              textAlign: TextAlign.left,
            ),
            TextButton(
                onPressed: () {
                  clearAllRecents();
                  recent.clear();
                  setState(() {
                    recentResults.clear();
                  });
                },
                child: Text(
                  "Clear all",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff24b9b0),
                    height: 25 / 16,
                  ),
                  textAlign: TextAlign.left,
                ))
          ],
        ),
      ),
    ));
  }
  String name = "";
  String floor = "";
  String polyID = "";
  String buildingID = "";
  String finalName = "";
  bool promptLoader = false;
  Set<String> optionListItemBuildingNameNew = {};



  void _onSearchChanged() {
    List<String> promptArray = ["navigate to","take me to"];
    String userInput = _controller.text.toLowerCase();
    String stringToRemove = "";
    bool containsPrompt = promptArray.any((element) {
      if(userInput.contains(element)){
        stringToRemove = element;
        return true;
      }else{
        return false;
      }
    });
    if(containsPrompt){
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

      _searchDebounce = Timer(Duration(seconds: 3), () {
        setState(() {
          promptLoader = true;
        });

        // Perform search
        //_performSearch(_controller.text);

        String modifiedString = _controller.text.replaceAll(stringToRemove, "");
        if(modifiedString.trim().length>0){
          final fuse = Fuzzy(
            landmarkData.landmarkNames,
            options: FuzzyOptions(
              findAllMatches: true,
              tokenize: true,
              threshold: 0.7,
            ),
          );
          final outputresult = fuse.search(modifiedString.toLowerCase());
          // Assuming `result` is a List<FuseResult<dynamic>>
          outputresult.forEach((fuseResult) {
            // Access the item property of the result to get the matched value
            String matchedName = fuseResult.item;
            fuseResult.matches.length;

            // Access the score of the match
            double score = fuseResult.score;

            // Do something with the matchedName or score
            // score == 0.0
            //     ? print('Matched Name: $matchedName, Score: $score')
            //     : print("");
            if (score <= 0.3) { //0.5 for normal
              finalName = fuseResult.item;
            }
          });

          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && value.element!.subType != "beacons") {
              if (value.name!.toLowerCase().contains(finalName.toLowerCase())) {
                name = value.name!;
                floor = value.name!;
                polyID = value.properties!.polyId!;
                buildingID = value.buildingID!;
              }else{
                print("nooo${value.name!.toLowerCase()} ----- ${finalName.toLowerCase()}");
              }
            }
          });

          if(landmarkData.landmarkNames!.contains(finalName)){
            //onVenueClicked(name, floor, polyID, buildingID);
            if(polyID.isNotEmpty){
              HelperClass.showToast("Navigating to ${finalName}");
              setState(() {
                promptLoader = false;
              });
              //Future.delayed(Duration(seconds: 2));
              Navigator.pop(context, polyID);
            }else{
            }
          }
          
        }else{
          HelperClass.showToast("Provide a Landmark name !!");
        }




      });
    }else{
      print("Prompt not used");
    }

  }



  void initSpeech() async {
    speechEnabled = await speetchText.initialize();
    setState(() {});
  }

  void startListening() async {
    if (await speetchText.hasPermission == false) {
      HelperClass.showToast("Permission not allowed");
      return;
    }
    setState(() {
      searchHintString = "";
    });
    await speetchText.listen(onResult: onSpeechResult);
    if (speetchText.isNotListening) {
      setState(() {
        searchHintString = widget.hintText;
      });
    }
    HelperClass.showToast("Speak to search");
    await Future.delayed(Duration(seconds: 5));
    micColor = Colors.black;
    setState(() {});
  }

  void onSpeechResult(result) {
    setState(() {
      print("Listening from mic");

      setState(() {
        _controller.text = result.recognizedWords;
        search(result.recognizedWords);
        // print(_controller.text);
      });
      wordsSpoken = "${result.recognizedWords}";

      // if (result.recognizedWords == null) {
      //   print("result.recognizedWords");
      //
      //
      //   setState(() {
      //     searchHintString = widget.hintText;
      //   });
      // }
    });
  }

  void stopListening() async {
    await speetchText.stop();
    micColor = Colors.black;
    setState(() {});
    if (speetchText.isNotListening) {
      setState(() {
        searchHintString = widget.hintText;
      });
    }
  }

  void fetchandBuild() async {
    await fetchlist();
    setState(() {
      if (_controller.text.isNotEmpty) {
        search(_controller.text);
      } else {
        // print("Filter cleared");
        topSearchesFunc();
        searchResults = [];
        searcCategoryhResults = [];
        vall = -1;
      }
    });
  }

  Future<void> fetchlist() async {
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      await landmarkApi().fetchLandmarkData(id: key).then((value) {
        landmarkData.mergeLandmarks(value.landmarks);
        optionListItemBuildingNameNew.add(value.landmarks!.first.buildingName!);
        print("optionListItemBuildingNameNew${optionListItemBuildingNameNew}");
      });
    });


  }

  void addtoRecents(String name, String location, String ID, String bid) async {
    if (!recent
        .any((element) => element[0] == name && element[1] == location)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      recent.add([name, location, ID, bid]);
      await prefs.setString('recents', jsonEncode(recent)).then((value) {
        //print("saved $name");
      });
    }
  }

  void clearAllRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recents');
  }

  bool category = false;
  bool topCategory=false;
  Set<String> cardSet = Set();
  // HashMap<String,Landmarks> cardSet = HashMap();
  int selectedChipIndex = -1; // Track selected chip index

  List<String> optionList = [
    'washroom',
    'cafeteria',
    'drinking water',
    'atm',
    'entry',
    'lift',
    'reception',


  ];
  List<String> optionListForUI = [
    'Washroom',
    'Cafeteria',
    'Drinking water',
    'ATM',
    'Entry',
    'Lift',
    'Reception',


  ];



  void onChipSelected(int index) {
    setState(() {
      selectedChipIndex = index;
    });
  }
  Set<String> optionListItemBuildingName = {};
  List<Widget> searcCategoryhResults = [];
  FlutterTts flutterTts  = FlutterTts();

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }


  void search(String searchText,{String wantToFilter=''}) {
    setState(() {
      if (searchText.isEmpty) {
        return;
      }

      searchText = searchText.toLowerCase();
      searchResults.clear();
      searcCategoryhResults.clear();
      optionListItemBuildingName.clear();

      if (optionList.contains(searchText)) {
        category = true;
        topCategory=false;
        vall = optionList.indexOf(searchText);

        if (landmarkData.landmarksMap != null) {
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && value.element!.subType != "beacons") {
              final lowerCaseName = value.name!.toLowerCase();
              if(searchText.toLowerCase().contains("entry") && value.element!.subType == "main entry"){
                optionListItemBuildingName.add(value.buildingName!);
              }else if (lowerCaseName == searchText || lowerCaseName.contains(searchText)) {
                optionListItemBuildingName.add(value.buildingName!);
              }
            }
          });

          optionListItemBuildingName.forEach((element) {
            searcCategoryhResults.add(
              SearchpageCategoryResults(
                name: searchText,
                buildingName: element,
                onClicked: onVenueClicked,
              ),
            );
          });
        }
      } else {
        category = false;
        vall = -1;
        topCategory=false;
        if (landmarkData.landmarksMap != null) {
          String normalizedSearchText = normalizeText(searchText);

          landmarkData.landmarksMap!.forEach((key, value) {
            if (searchResults.length >= 25 || value.name == null || value.element!.subType == "beacon") {
              return;
            }

            String normalizedValueName = normalizeText(value.name!);

            if(searchText.toLowerCase() == ("entry")){
              final fuse = Fuzzy(
                [normalizedValueName],
                options: FuzzyOptions(
                  findAllMatches: true,
                  tokenize: true,
                  threshold: 0.5,
                ),
              );

              final result = fuse.search(normalizedSearchText);

              result.forEach((fuseResult) {
                print("fuseResult");
                print(fuseResult);
                if (fuseResult.score < 0.2) {

                  if(wantToFilter.isNotEmpty && value.buildingName == wantToFilter){
                    print('In--IF');
                    searchResults.add(SearchpageResults(
                      name: value.name!,
                      location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
                      onClicked: onVenueClicked,
                      ID: value.properties!.polyId!,
                      bid: value.buildingID!,
                      floor: value.floor!,
                      coordX: value.coordinateX!,
                      coordY: value.coordinateY!,
                      accessible: value.element!.subType=="restRoom" && value.properties!.washroomType=="Handicapped"? "true":"false",
                    ));
                  }else{
                    print('In--ELSE');
                    searchResults.add(SearchpageResults(
                      name: value.name!,
                      location: "Floor ${value.floor}, ${value
                          .buildingName}, ${value.venueName}",
                      onClicked: onVenueClicked,
                      ID: value.properties!.polyId!,
                      bid: value.buildingID!,
                      floor: value.floor!,
                      coordX: value.coordinateX!,
                      coordY: value.coordinateY!,
                        accessible: value.element!.subType=="restRoom" && value.properties!.washroomType=="Handicapped"? "true":"false"
                    ));
                  }
                }
              });
            }else if (normalizedValueName.contains(normalizedSearchText)) {
              final fuse = Fuzzy(
                [normalizedValueName],
                options: FuzzyOptions(
                  findAllMatches: true,
                  tokenize: true,
                  threshold: 0.5,
                ),
              );

              final result = fuse.search(normalizedSearchText);
              print("fuseresult");
              print(result);

              result.forEach((fuseResult) {
                if (fuseResult.score < 0.2) {
                  searchResults.add(SearchpageResults(
                    name: value.name!,
                    location: "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
                    onClicked: onVenueClicked,
                    ID: value.properties!.polyId!,
                    bid: value.buildingID!,
                    floor: value.floor!,
                    coordX: value.coordinateX!,
                    coordY: value.coordinateY!,
                    accessible: value.element!.subType=="restRoom" && value.properties!.washroomType=="Handicapped"? "true":"false",
                  ));
                }
              });
            }
          });
        }
      }
    });
  }
  void topSearchesFunc(){
    setState(() {
      topSearches.add(Container(margin:EdgeInsets.only(left: 26,top: 12,bottom: 12),child: Row(
        children: [
          Icon(Icons.search_sharp),
          SizedBox(width: 26,),
          Text(
            "Top Searches",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff000000),
              height: 24/18,
            ),
            textAlign: TextAlign.left,
          )
        ],
      ),));
      landmarkData.landmarksMap!.forEach((key, value) {
        if (value.name != null && value.element!.subType != "beacon") {
          if(value.priority!=null && value.priority!>1){
            topCategory = true;
            topSearches.add(SearchpageResults(
              name: "${value.name}",
              location:
              "Floor ${value.floor}, ${value
                  .buildingName}, ${value.venueName}",
              onClicked: onVenueClicked,
              ID: value.properties!.polyId!,
              bid: value.buildingID!,
              floor: value.floor!,
              coordX: value.coordinateX!,
              coordY: value.coordinateY!,
              accessible:  value.properties!.wheelChairAccessibility??"",

            ));
          }

        }
      });
    });
  }


  String normalizeText(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }

  void onVenueClicked(String name, String location, String ID, String bid) {
    Navigator.pop(context, ID);
  }

  void fetchRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('recents');
    if (savedData != null) {
      recent = jsonDecode(savedData);
      setState(() {
        for (List<dynamic> value in recent) {
          if (buildingAllApi.getStoredAllBuildingID()[value[3]] != null) {
            recentResults.add(SearchpageRecents(
              name: value[0],
              location: value[1],
              onVenueClicked: onVenueClicked,
              ID: value[2],
              bid: value[3],
            ));
            searchResults = recentResults;
          }
        }
      });
    }
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
  int vall = -1;
  int newvall = -1;
  int lastval =-1;





  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    // if(speetchText.isNotListening){
    //   micColor = Colors.black;
    //   print("Not listening");
    // }else{
    //   micColor = Color(0xff24B9B0);
    // }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: Container(
          color: Colors.white,
          child: !promptLoader? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Semantics(
                header: true,
                label: "Search",
                child: Container(
                    width: screenWidth - 32,
                    height: 48,
                    margin: EdgeInsets.only(top: 16, left: 16, right: 17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                        containerBoxColor, // You can customize the border color
                        width: 1.0, // You can customize the border width
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 6,),
                        Container(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Semantics(
                              label: "Back",
                              child: SvgPicture.asset(
                                  "assets/DestinationSearchPage_BackIcon.svg"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FocusScope(
                            autofocus: true,
                            child: Focus(
                              child: Container(
                                  child: TextField(
                                    autofocus: true,
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
                                      height: 25 / 16,
                                    ),
                                    onTap: () {
                                      if (containerBoxColor == Color(0xffA1A1AA)) {
                                        containerBoxColor = Color(0xff24B9B0);
                                      } else {
                                        containerBoxColor = Color(0xffA1A1AA);
                                      }
                                    },
                                    onSubmitted: (value) {

                                      search(value);
                                    },
                                    onChanged: (value) {
                                      search(value);
                                      if(_controller.text.isEmpty){
                                        topSearches.clear();
                                        topSearchesFunc();
                                      }
                                      // print("Final Set");
                                      // print(cardSet);
                                    },
                                  )),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 6),
                          width: 40,
                          height: 48,
                          child: Center(
                            child: _controller.text.isNotEmpty
                                ? IconButton(
                                onPressed: (){
                                  _controller.text = "";
                                  setState((){
                                    vall = -1;
                                    search(_controller.text);
                                    recentResults = [];
                                    searcCategoryhResults = [];
                                    category=false;
                                    topSearches.clear();
                                    topSearchesFunc();
                                  });
                                },
                                icon: Semantics(
                                    container: true,

                                    label: "Close", child: Icon(Icons.close)))
                                : IconButton(
                              onPressed: () {
                                initSpeech();
                                setState(() {
                                  speetchText.isListening
                                      ? stopListening()
                                      : startListening();
                                });
                                if (!micselected) {
                                  micColor = Color(0xff24B9B0);
                                }

                                setState(() {});
                              },
                              icon: Semantics(
                                label: "Voice Search",
                                child: Icon(
                                  Icons.mic,
                                  color: micColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              (searchHintString.toLowerCase().contains("source") && widget.userLocalized != "")?InkWell(
                onTap: (){
                  Navigator.pop(context, widget.userLocalized);
                },
                child: Container(
                  margin: EdgeInsets.only(top:24,left: 17,right: 17,bottom: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 16,),
                          Image.asset("assets/rw.png"),
                          SizedBox(width: 24,),
                          Text(style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff000000),
                          ),"Your Current Location")
                        ],
                      ),
                    ],
                  ),
                ),
              ):Container(),
              searchHintString.toLowerCase().contains("source")?Divider(thickness: 6,color: Color(0xfff2f3f5),):Container(),
              Semantics(
                label: "Filter Section",
                header: true,
                child: Container(
                  margin: EdgeInsets.only(left: 7,top: 4),
                  width: screenWidth,
                  child: ChipsChoice<int>.single(
                    value: vall,
                    onChanged: (val) {

                      if(HelperClass.SemanticEnabled) {
                        speak("${optionListForUI[val]} selected");
                      }

                      selectedButton = optionListForUI[val];
                      setState(() => vall = val);
                      lastval = val;


                      _controller.text = optionListForUI[val];
                      search(optionListForUI[val]);
                    },
                    choiceItems: C2Choice.listFrom<int, String>(
                      source: optionListForUI,
                      value: (i, v) => i,
                      label: (i, v) => v,
                    ),

                    choiceBuilder: (item, i) {
                      if(!item.selected){
                        vall = -1;
                      }
                      return DestinationPageChipsWidget(
                        svgPath: '',
                        text: optionListForUI[i],
                        onSelect: item.select!,
                        selected: item.selected,

                        onTap: (String Text) {
                          if (Text.isNotEmpty) {
                            search(Text);
                          } else {
                            search(Text);
                            _controller.text="";
                            searchResults = [];
                            searcCategoryhResults = [];
                            vall = -1;
                          }
                        },
                      );
                    },
                    direction: Axis.horizontal,
                  ),
                ),
              ),
              !category && _controller.text.isNotEmpty ? Semantics(
                header: true,
                label: "Building Filter section",
                child: Container(
                  margin: EdgeInsets.only(left: 7,top: 4),
                  width: screenWidth,
                  child: ChipsChoice<int>.single(
                    value: newvall,
                    onChanged: (val) {

                      // if(HelperClass.SemanticEnabled) {
                      //   speak("${optionListItemBuildingName.toList()[val]} selected");
                      // }
                      //
                      // selectedButton = optionListItemBuildingName.toList()[val];
                      setState(() => newvall = val);
                      //
                      //
                      // //_controller.text = optionListItemBuildingName.toList()[val];
                      // search(optionListItemBuildingName.toList()[val]);
                    },
                    choiceItems: C2Choice.listFrom<int, String>(
                      source: optionListItemBuildingNameNew.toList(),
                      value: (i, v) => i,
                      label: (i, v) => v,
                    ),

                    choiceBuilder: (item, i) {
                      if(!item.selected){
                        newvall = -1;
                      }
                      return DestinationPageChipsWidget(
                        svgPath: '',
                        text: optionListItemBuildingNameNew.toList()[i],
                        onSelect: item.select!,
                        selected: item.selected,

                        onTap: (String Text) {
                          print("tapped$Text");

                          if (Text.isNotEmpty) {
                            search(_controller.text,wantToFilter: Text);
                          }
                          // else {
                          //   search(Text,wantToFilter: optionListItemBuildingName.toList()[i]);
                          //   _controller.text="";
                          //   searchResults = [];
                          //   searcCategoryhResults = [];
                          //   newvall = -1;
                          // }
                        },
                      );
                    },
                    direction: Axis.horizontal,
                  ),
                ),
              ) : Container(),

              SizedBox(height: 4,),
              Divider(thickness: 6,color: Color(0xfff2f3f5)),
              Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: Semantics(
                        label: "Search Results",
                        header: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (!category && topCategory)? topSearches:(category)?searcCategoryhResults:searchResults,

                        ),
                      ),
                  )),
              if (_controller.text.isNotEmpty && searchResults.isEmpty && (category ? searcCategoryhResults : (!category && topCategory ? topSearches : [])).isEmpty)

                Column(
                 children: [
                   SizedBox(height: 16,),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Image.asset('assets/noResults.png'),
                   ),
                   Text(
                     'Sorry, No Results Found',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       color: Colors.black,
                       fontSize: 16,
                       fontFamily: 'Roboto',
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                   Text(
                     ' Try something new  with different keywords',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       color: Color(0xFFA1A1AA),
                       fontSize: 14,
                       fontFamily: 'Roboto',
                       fontWeight: FontWeight.w400,
                     ),
                   )
                 ]
                )

            ],
          ) : Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }



  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }
}

class SetInfo {
  String SetInfoLandmarkName;
  String SetInfoBuildingName;
  SetInfo(
      {required this.SetInfoBuildingName, required this.SetInfoLandmarkName});
}
class ChipFilterWidget extends StatefulWidget {
  final List<String> options;
  final Function(String) onSelected;

  ChipFilterWidget({required this.options, required this.onSelected});

  @override
  _ChipFilterWidgetState createState() => _ChipFilterWidgetState();
}

class _ChipFilterWidgetState extends State<ChipFilterWidget> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 8.0,
      children: widget.options.map((option) {
        return ChoiceChip(
          label: Text(
            option,
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20/14,
            ),
            textAlign: TextAlign.left,
          ),
          selected: _selectedOption == option,
          onSelected: (selected) {
            setState(() {
              _selectedOption = selected ? option : null;
            });
            widget.onSelected(option);
          },
          showCheckmark: false,
          selectedColor: Colors.green,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: _selectedOption == option ? Colors.white : Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.0), // Adjust the radius as needed
            side: BorderSide(
              color: _selectedOption == option ? Colors.green : Colors.black,
              width: 1.0, // Adjust the border width as needed
            ),
          ),
        );
      }).toList(),
    );
  }
}