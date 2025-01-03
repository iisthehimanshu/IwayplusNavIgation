import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'IWAYPLUS/API/buildingAllApi.dart';
import 'IWAYPLUS/Elements/HelperClass.dart';
import 'NAVIGATION/API/ladmarkApi.dart';
import 'NAVIGATION/APIMODELS/landmark.dart';
import 'NAVIGATION/ELEMENTS/DestinationPageChipsWidget.dart';
import 'NAVIGATION/ELEMENTS/SearchpageCategoryResult.dart';
import 'NAVIGATION/ELEMENTS/SearchpageResults.dart';

class NewSearchPage extends StatefulWidget {
  String hintText;
  String previousFilter;
  bool voiceInputEnabled;
  String userLocalized;
  NewSearchPage({this.hintText = "",
    this.previousFilter = "",
    required this.voiceInputEnabled,this.userLocalized = ""});

  @override
  State<NewSearchPage> createState() => _NewsearchpageState();
}

class _NewsearchpageState extends State<NewSearchPage> {
  land landmarkData = land();
  Color containerBoxColor = Color(0xffA1A1AA);
  TextEditingController _controller = TextEditingController();
  Color micColor = Colors.black;
  String searchHintString = "";
  List<SearchpageResults> searchResults = [];
  List<Widget> topSearches=[];
  int vall = -1;
  Set<String> optionListItemBuildingName = {};
  List<Widget> searcCategoryhResults = [];
  int lastIndex = -1;
  String selectedButton = "";
  bool isTyping=true;
  int lastval =-1;
  bool category = false;
  final SpeechToText speetchText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = "";
  bool micselected = false;
  bool promptLoader = false;


  List<String> optionListForUI = [
    'Washroom',
    'Cafeteria',
    'Drinking water',
    'ATM',
    'Entry',
    'Lift',
    'Reception',
  ];


  IconData getIcon(String option) {
    switch (option.toLowerCase()) {
      case 'washroom':
        return Icons.wash_sharp;
      case 'cafeteria':
        return Icons.local_cafe;
      case 'drinking water':
        return Icons.water_drop;
      case 'atm':
        return Icons.atm_sharp;
      case 'entry':
        return Icons.door_front_door_outlined;
      case 'lift':
        return Icons.elevator;
      case 'reception':
        return Icons.desk_sharp;
      default:
        return Icons.help_outline; // Return a default icon if no match is found
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    fetchandBuild();
    if(widget.hintText!=""){
      searchHintString=widget.hintText;
    }
    if (widget.previousFilter != "") {
      setState(() {
        _controller.text = widget.previousFilter;
        isTyping=false;
        search(_controller.text.toLowerCase());
      });
    }
    super.initState();
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
      }
    });
  }
  void topSearchesFunc(){
    setState(() {
      topSearches.add(Container(margin:EdgeInsets.only(left: 26,top: 12,bottom: 12),child:const Row(
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
      try{
        if(landmarkData.landmarksMap!=null){
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && value.element!.subType != "beacon") {
              if(value.priority!=null && value.priority!>1){
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
                  accessible:  value.properties!.wheelChairAccessibility??"", distance: 0,

                ));
              }
            }
          });
        }

      }catch(e){

      }

    });
  }

  Future<void> fetchlist() async {
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      await landmarkApi().fetchLandmarkData(id: key).then((value) {
        landmarkData.mergeLandmarks(value.landmarks);
        //optionListForUI.addAll(fetchCategories(value));
      });
    });


  }

  List<String> fetchCategories(land value){
    List<String> list = [];
    for (var landmark in value.landmarks!) {
      if(landmark.element!.subType != "room door"){
        list.add(landmark.element!.subType!);
      }
    }
    return list;
  }

  bool containsSearchText(List<String> optionListForUI, String searchText) {
    return optionListForUI
        .map((option) => option.toLowerCase()) // Convert each list item to lowercase
        .contains(searchText.toLowerCase());  // Convert search text to lowercase
  }

  int indexOfCaseInsensitive(List<String> optionListForUI, String searchText) {
    return optionListForUI.indexWhere(
            (option) => option.toLowerCase() == searchText.toLowerCase());
  }


  String normalizeText(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }
  void onVenueClicked(String name, String location, String ID, String bid) {
    Navigator.pop(context, ID);
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

  void search(String searchText) {
    if (searchText.isEmpty) {
      return;
    }
    setState(() {
      searchResults.clear();
      searcCategoryhResults.clear();
      optionListItemBuildingName.clear();
    });
    if (containsSearchText(optionListForUI, searchText)) {
      setState(() {
        category = true;
      });
      vall = indexOfCaseInsensitive(optionListForUI, searchText);
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
        print("entered here");
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
    }
    else{
      setState(() {
        category = false;
      });
      if (landmarkData.landmarksMap != null) {
        String normalizedSearchText = normalizeText(searchText);
        // Collect all landmarks into a single list for Fuzzy initialization
        final landmarkList = landmarkData.landmarksMap!.values
            .where((value) => value.name != null && value.element!.subType != "beacon")
            .map((value) => normalizeText(value.name!))
            .toList();
        final fuse = Fuzzy(
          landmarkList,
          options: FuzzyOptions(
            findAllMatches: true,
            tokenize: true,
            threshold: 0.5,
          ),
        );
        // Search using Fuzzy and build results
        final result = fuse.search(normalizedSearchText);
        List<SearchpageResults> newResults = [];
        print("result11-${result}");
        result.forEach((fuseResult) {
          if (fuseResult.score <=0.5) {
            final value = landmarkData.landmarksMap!.values
                .firstWhere((v) => v.name != null && v.element!.subType != "beacon" && normalizeText(v.name!) == fuseResult.item);
            newResults.add(SearchpageResults(
              name: value.name!,
              location: value.buildingID == buildingAllApi.outdoorID
                  ? "${value.venueName}"
                  : "Floor ${value.floor}, ${value.buildingName}, ${value.venueName}",
              onClicked: onVenueClicked,
              ID: value.properties!.polyId!,
              bid: value.buildingID!,
              floor: value.floor!,
              coordX: value.coordinateX!,
              coordY: value.coordinateY!,
              accessible: value.element!.subType == "restRoom" && value.properties!.washroomType == "Handicapped"
                  ? "true"
                  : "false",
              distance: 0,
            ));
          }
        });

        setState(() {
          searchResults = newResults.take(25).toList(); // Limit results to 25
        });
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: statusBarHeight),
        color: Colors.white,
        child: !promptLoader?
        Column(
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
                            child: Semantics(
                              hint: "Enter ${searchHintString}",
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
                                        isTyping=true;
                                        topSearches.clear();
                                        topSearchesFunc();
                                        searchResults=[];
                                        searcCategoryhResults=[];
                                        vall=-1;
                                      }else{
                                        setState(() {
                                          category=false;
                                          isTyping=false;
                                        });
                                      }


                                    },
                                  )),
                            ),
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
                                setState(() {
                                  vall = -1;
                                  topSearches.clear();
                                  topSearchesFunc();
                                  searchResults=[];
                                  searcCategoryhResults=[];
                                  isTyping=true;
                                  category=false;
                                });
                              },
                              icon: Semantics(
                                  container: true,
                                  label: "Clear",hint: "button. Double tap to activate",
                                  child: Icon(Icons.close)))
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


            searchHintString.toLowerCase().contains("source")?Divider(thickness: 6,color: Color(0xfff2f3f5),):Container(),
            Visibility(
              visible: isTyping,
              child: Semantics(
                label: "Facilities Filter",
                header: true,
                child: Container(
                  margin: EdgeInsets.only(left: 7,top: 4),
                  width: screenWidth,
                  child: ChipsChoice<int>.single(
                    value: vall,
                    onChanged: (val) {
                      print("this is working");
                      if(HelperClass.SemanticEnabled) {
                        // speak("${optionListForUI[val]} selected");
                      }
                      if(_controller.text.isNotEmpty && vall!=-1){
                        setState((){
                          vall=-1;
                        });
                      }
                      selectedButton = optionListForUI[val];
                      setState(() => vall = val);
                      lastval = val;
                      _controller.text = optionListForUI[val];
                      search(optionListForUI[val].toLowerCase());

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
                          print("again tapped ${Text}");
                          if (Text.isNotEmpty) {
                            search(Text);
                          } else {
                            search(Text);
                            _controller.text="";
                            searchResults = [];
                            searcCategoryhResults=[];
                            //searcCategoryhResults = [];
                            vall = -1;
                          }
                        }, icon: getIcon(optionListForUI[i].toLowerCase()),
                      );
                    },
                    direction: Axis.horizontal,
                  ),
                ),
              ),
            ),
            Flexible(
                flex: 1,
                child: SingleChildScrollView(
                  child: Semantics(
                    label: 'Available Buildings with ${_controller.text} Facilities',
                    header: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:(searcCategoryhResults.isNotEmpty)?searcCategoryhResults:(searchResults.isNotEmpty)?searchResults:(topSearches.isNotEmpty)?topSearches:[]
                    ),
                  ),
                )),

            // if((searchResults.isEmpty && _controller.text.isNotEmpty) || searcCategoryhResults.isEmpty)
            //   Column(
            //       children: [
            //         SizedBox(height: 16,),
            //         Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: Image.asset('assets/noResults.png'),
            //         ),
            //         Text(
            //           'Sorry, No Results Found',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 16,
            //             fontFamily: 'Roboto',
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //         Text(
            //           ' Try something new  with different keywords',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //             color: Color(0xFFA1A1AA),
            //             fontSize: 14,
            //             fontFamily: 'Roboto',
            //             fontWeight: FontWeight.w400,
            //           ),
            //         )
            //       ]
            //   )
          ],
        ):Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      ),
    );

  }
}
