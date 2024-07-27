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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'APIMODELS/landmark.dart';
import 'Elements/DestinationPageChipsWidget.dart';
import 'Elements/HomepageFilter.dart';

import 'Elements/SearchpageCategoryResult.dart';
import 'Elements/SearchpageResults.dart';

class DestinationSearchPage extends StatefulWidget {
  String hintText;
  String previousFilter;
  bool voiceInputEnabled;

  DestinationSearchPage(
      {this.hintText = "",
        this.previousFilter = "",
        required this.voiceInputEnabled});

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
  int lastIndex = -1;
  String selectedButton = "";

  @override
  void initState() {
    super.initState();
    print("In search page");

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
    fetchandBuild();
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
    print("In initSpeech");
  }

  void onSpeechResult(result) {
    setState(() {
      print("Listening from mic");

      print(result.recognizedWords);
      setState(() {
        _controller.text = result.recognizedWords;
        search(result.recognizedWords);
        print(_controller.text);
      });
      wordsSpoken = "${result.recognizedWords}";
      if (result.recognizedWords == null) {
        setState(() {
          searchHintString = widget.hintText;
        });
      }
    });
    print("In onSpeechResult");
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
        print("Filter cleared");
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
      });
    });
  }

  void addtoRecents(String name, String location, String ID, String bid) async {
    if (!recent
        .any((element) => element[0] == name && element[1] == location)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      recent.add([name, location, ID, bid]);
      await prefs.setString('recents', jsonEncode(recent)).then((value) {
        print("saved $name");
      });
    }
  }

  void clearAllRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recents');
  }

  bool category = false;
  Set<String> cardSet = Set();
  // HashMap<String,Landmarks> cardSet = HashMap();
  List<String> optionList = [
    'washroom',
    'entry',
    'reception',
    'lift',
  ];
  List<String> optionListForUI = [
    'Washroom',
    'Entry',
    'Reception',
    'Lift',
  ];

  Set<String> optionListItemBuildingName = {};
  List<Widget> searcCategoryhResults = [];
  FlutterTts flutterTts  = FlutterTts();

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }


  void search(String searchText) {
    setState(() {
      if (searchText.isNotEmpty) {
        if (optionList.contains(searchText.toLowerCase())) {
          category = true;
          for(int i=0 ; i<optionList.length ; i++){
            if(optionList[i] == searchText.toLowerCase()){
              vall = i;
            }
          }
          searcCategoryhResults.clear();
          landmarkData.landmarksMap!.forEach((key, value) {
            if (searcCategoryhResults.length < 10) {
              if (value.name != null && value.element!.subType != "beacons") {
                if (value.name!.toLowerCase() == searchText.toLowerCase()) {
                  optionListItemBuildingName.add(value.buildingName!);
                  searcCategoryhResults.clear();
                  optionListItemBuildingName.forEach((element) {
                    searcCategoryhResults.add(SearchpageCategoryResults(
                      name: searchText,
                      buildingName: element,
                      onClicked: onVenueClicked,
                    ));
                  });
                }
                if (value.name!
                    .toLowerCase()
                    .contains(searchText.toLowerCase())) {
                  optionListItemBuildingName.add(value.buildingName!);
                  searcCategoryhResults.clear();
                  optionListItemBuildingName.forEach((element) {
                    searcCategoryhResults.add(SearchpageCategoryResults(
                      name: searchText,
                      buildingName: element,
                      onClicked: onVenueClicked,
                    ));
                  });
                }
              }
            } else {
              return;
            }
          });
        } else {
          category = false;
          vall = -1;
          searchResults.clear();
          landmarkData.landmarksMap!.forEach((key, value) {
            if (searchResults.length < 10) {
              if (value.name != null && value.element!.subType != "beacon" && value.buildingID == buildingAllApi.selectedBuildingID) {
                if (value.name!
                    .toLowerCase()
                    .contains(searchText.toLowerCase())) {
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
                  // Assuming `result` is a List<FuseResult<dynamic>>
                  result.forEach((fuseResult) {
                    // Access the item property of the result to get the matched value
                    String matchedName = fuseResult.item;

                    // Access the score of the match
                    double score = fuseResult.score;

                    // Do something with the matchedName or score
                    score == 0.0
                        ? print('Matched Name: $matchedName, Score: $score')
                        : print("");
                  });
                  searchResults.add(SearchpageResults(
                    name: "${value.name}",
                    location:
                    "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
                    onClicked: onVenueClicked,
                    ID: value.properties!.polyId!,
                    bid: value.buildingID!,
                    floor: value.floor!,
                    coordX: value.coordinateX!,
                    coordY: value.coordinateY!,
                  ));
                }
              }
            } else {
              return;
            }
          });
        }
      }
    });
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
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
                                    print("Final Set");
                                  },
                                  onSubmitted: (value) {
                                    // print("Final Set");
                                    print(value);
                                    search(value);
                                  },
                                  onChanged: (value) {
                                    search(value);
                                    // print("Final Set");
                                    print(cardSet);
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
                              onPressed: () {
                                _controller.text = "";
                                print("Tapped----");
                                setState(() {
                                  vall = -1;
                                  search(_controller.text);
                                  recentResults = [];
                                  searcCategoryhResults = [];
                                });
                              },
                              icon: Semantics(
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
              Container(
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
                    print("wilsonchecker");
                    print(val);

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
              Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: Column(
                        children: category ? searcCategoryhResults : searchResults,
                      ))),
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