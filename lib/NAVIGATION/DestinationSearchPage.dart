import 'dart:async';
import 'dart:convert';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:iwaymaps/IWAYPLUS/API/buildingAllApi.dart';
import 'package:iwaymaps/NAVIGATION/singletonClass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../IWAYPLUS/Elements/HelperClass.dart';
import 'API/ladmarkApi.dart';
import 'APIMODELS/landmark.dart';
import 'Elements/DestinationPageChipsWidget.dart';
import 'Elements/SearchpageCategoryResult.dart';
import 'Elements/SearchpageResults.dart';
import 'FloorSelectionPage.dart';
import 'StringStorage.dart';
import 'navigationTools.dart';

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

  List<SearchpageResults> searchResults = [];

  List<SearchpageResults> recentResults = [];
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
      if (optionListForUI.toList()[i].toLowerCase() ==
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


    // fetchRecents();


    // recentResults.add(Container(
    //   margin: EdgeInsets.only(left: 16, right: 16, top: 8),
    //   child: Semantics(
    //     excludeSemantics: true,
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           "Recent Searches",
    //           style: const TextStyle(
    //             fontFamily: "Roboto",
    //             fontSize: 16,
    //             fontWeight: FontWeight.w500,
    //             color: Color(0xff000000),
    //             height: 23 / 16,
    //           ),
    //           textAlign: TextAlign.left,
    //         ),
    //         TextButton(
    //             onPressed: () {
    //               clearAllRecents();
    //               recent.clear();
    //               setState(() {
    //                 recentResults.clear();
    //               });
    //             },
    //             child: Text(
    //               "Clear all",
    //               style: const TextStyle(
    //                 fontFamily: "Roboto",
    //                 fontSize: 16,
    //                 fontWeight: FontWeight.w400,
    //                 color: Color(0xff24b9b0),
    //                 height: 25 / 16,
    //               ),
    //               textAlign: TextAlign.left,
    //             ))
    //       ],
    //     ),
    //   ),
    // ));
  }
  String name = "";
  String floor = "";
  String polyID = "";
  String buildingID = "";
  String finalName = "";
  bool promptLoader = false;
  Set<String> optionListItemBuildingNameNew = {};


  pushToFloorSelection() async {
    await fetchFloors("AIIMS Bhopal",widget.previousFilter.toUpperCase()).then((_){
      print("floors list $floors ");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FloorSelectionPage(filterName: widget.previousFilter, filterBuildingName: optionListItemBuildingName.first,floors: floors.toList()..sort(),),
        ),
      ).then((value){
        print("value $value");
        _controller.text="";
        searchResults = [];
        searcCategoryhResults = [];
        vall = -1;
        floors.clear();
        onVenueClicked(value[0],value[1],value[2],value[3]);
        // widget.onClicked(value[0],value[1],value[2],value[3]);
      });
    });

  }


  Set<String> floors = {};
  Future<void> fetchFloors(String building,String name)async{
    print("building:${building} ${buildingAllApi.getStoredAllBuildingID()}");
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {

      await landmarkApi().fetchLandmarkData(id: key).then((value){

        value.landmarksMap?.forEach((key, landmark){
          if (landmark.floor != null &&
              landmark.buildingName == building &&
              landmark.name != null &&
              landmark.name!.toUpperCase().contains(name.toUpperCase())) {
            print("Matched floor: ${landmark.name} ${landmark.floor}");
            floors.add(landmark.floor!.toString());
          }
        });
        landmarkData.mergeLandmarks(value.landmarks);
      });
    });
  }


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
              setState((){
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
    setState((){
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
    setState((){
      micColor = Colors.black;
    });
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
    await fetchlist().then((value){
      setState(() {
        if (_controller.text.isNotEmpty) {
          search(_controller.text);
        } else {
          if (widget.previousFilter != "") {
            setState(() {
              _controller.text = widget.previousFilter;
            });
            pushToFloorSelection();
          }
          // print("Filter cleared");
          topSearchesFunc();
          loadLandmarkData();
          searchResults = [];
          searcCategoryhResults = [];
          vall = -1;
        }
      });
    });
  }

  Future<void> fetchlist() async {
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      await landmarkApi().fetchLandmarkData(id: key).then((value) {
        landmarkData.mergeLandmarks(value.landmarks);
        optionListItemBuildingNameNew.add(value.landmarks!.first.buildingName!);
        optionListItemBuildingName.add(value.landmarks!.first.buildingName!);
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
  Set<String> optionListForUI ={};

  List<IconData> _icons = [
    Icons.wash_sharp,
    Icons.local_cafe,
    Icons.water_drop,
    Icons.atm_sharp,
    Icons.door_front_door_outlined,
    Icons.elevator,
    Icons.desk_sharp,
  ];

  bool isUpdated=false;
  Future<void> loadLandmarkData() async {
    try {
      print("entered here ${landmarkData.landmarksMap}");
      await Future.forEach(
          landmarkData.landmarksMap!.entries,(MapEntry keyValue) async {
        var value = keyValue.value;
        if (value.name != null &&
            (value.element!.subType == "restRoom" ||
                value.element!.subType == "Cafeteria" ||
                value.element!.subType == "main entry" ||
                value.element!.subType == "Help Desk | Reception" ||
                value.element!.subType == "lift" ||
                value.element!.subType == "ATM" ||
                value.element!.subType == "Drinking Water")) {
          if (value.element!.subType == "restRoom") {
            optionListForUI.add("Washroom");
          } else if (value.element!.subType == "Cafeteria") {
            print("landmark id is ${value.sId}  with building id ${value.buildingID}");
            optionListForUI.add("Cafeteria");
          } else if (value.element!.subType == "main entry") {
            optionListForUI.add("Entry");
          } else if (value.element!.subType == "lift") {
            optionListForUI.add("Lift");
          } else if (value.element!.subType == "Drinking Water") {
            optionListForUI.add("Drinking Water");
          } else if (value.element!.subType == "Help Desk | Reception") {
            optionListForUI.add("Reception");
          } else if (value.element!.subType == "ATM") {
            optionListForUI.add("ATM");
          }
        }
      });
      setState(() {
        isUpdated=true;
      });
    }catch(e){
      print("error in updating liist ");
    }
    setState(() {
      isUpdated=false;
    });
  }



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
      print("optionListForUI $optionListForUI searchText $searchText");
      if (optionListForUI.map((e) => e.toLowerCase()).contains(searchText.toLowerCase())){
        category = true;
        topCategory=false;
        vall = indexOfCaseInsensitive(optionListForUI.toList(), searchText);
        print("landmarkData.landmarksMap ${landmarkData.landmarksMap}");
        if (landmarkData.landmarksMap != null){
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && value.element!.subType != "beacons") {
              final lowerCaseName = value.name!.toLowerCase();
              print("lowerCaseName $lowerCaseName searchText $searchText");
              if(value.element!.subType == "main entry"){
                optionListItemBuildingName.add(value.buildingName!);
              }else if(lowerCaseName == searchText || lowerCaseName.contains(searchText)) {
                optionListItemBuildingName.add(value.buildingName!);
              }
            }

          });
          optionListItemBuildingName.forEach((element){
            searcCategoryhResults.add(
                SearchpageCategoryResults(
                  key: UniqueKey(),
                  name: searchText,
                  buildingName: element,
                  onClicked: onVenueClicked,
                )
            );
          });
        }
      } else {
        category = false;
        vall = -1;
        topCategory=false;
        if (landmarkData.landmarksMap != null) {
          String normalizedSearchText = normalizeText(searchText);

          final fuse = Fuzzy(
            landmarkData.landmarks!.map((e) => normalizeText(e.name??e.element?.subType??e.element!.type!)).toList(),
            options: FuzzyOptions(
              findAllMatches: true,
              threshold: 0.4,  // adjust sensitivity
              tokenize: false, // optional
            ),
          );
          final result = fuse.search(normalizedSearchText);
          result.sort((a, b) {
            print("${normalizedSearchText.toLowerCase()} a.item.toLowerCase().split(' ') ${a.item.toLowerCase().split(' ')}");
            final aHasExact = a.item.toLowerCase().split(' ').contains(normalizedSearchText.toLowerCase());
            final bHasExact = b.item.toLowerCase().split(' ').contains(normalizedSearchText.toLowerCase());

            if (aHasExact && !bHasExact) return -1;
            if (!aHasExact && bHasExact) return 1;

            return a.score!.compareTo(b.score!);
          });

          for (var fuseResult in result) {
            if (fuseResult.score < 0.5) {
              Landmarks landmark = landmarkData.landmarks!.firstWhere((value)=>normalizeText(value.name??value.element?.subType??value.element!.type!) == fuseResult.item);
              if ((searchResults.isNotEmpty || wantToFilter.isNotEmpty) &&
                  SingletonFunctionController().getlocalizedBeacon() !=
                      null && false) {
                print("adding ${landmark.name} with score ${fuseResult.score}");
                sortAndSeparateByUserLocation(
                    SingletonFunctionController().getlocalizedBeacon()!
                        .coordinateX!,
                    SingletonFunctionController().getlocalizedBeacon()!
                        .coordinateY!,
                    SingletonFunctionController().getlocalizedBeacon()!
                        .floor!,
                    SingletonFunctionController().getlocalizedBeacon()!
                        .buildingID!, landmark, normalizedSearchText);
              } else {
                print("adding ${landmark.name} with score ${fuseResult.score}");
                print("got into this");
                searchResults.add(SearchpageResults(
                  name: landmark.name??landmark.element?.subType??landmark.element!.type!,
                  location: landmark.buildingID == buildingAllApi.outdoorID
                      ? "${landmark.venueName}"
                      : "Floor ${landmark.floor}, ${landmark.venueName}",
                  onClicked: onVenueClicked,
                  ID: landmark.properties!.polyId!,
                  bid: landmark.buildingID!,
                  floor: landmark.floor!,
                  coordX: landmark.coordinateX!,
                  coordY: landmark.coordinateY!,
                  accessible: landmark.element!.subType == "restRoom" &&
                      landmark.properties!.washroomType == "Handicapped"
                      ? "true"
                      : "false",
                  distance: 0,
                ));
              }
            }
          }
        }
      }
    });
  }
  int indexOfCaseInsensitive(List<String> optionListForUI, String searchText) {
    return optionListForUI.indexWhere(
            (option) => option.toLowerCase() == searchText.toLowerCase());
  }

  void sortAndSeparateByUserLocation(int userLat, int userLng, int userFloor, String userBuildingID,Landmarks value,String searchedtext) {
    if (value.name!.toLowerCase().contains(searchedtext.toLowerCase()) && value.buildingID==userBuildingID && value.floor==userFloor) {
      searchResults.add(SearchpageResults(
        name: value.name!,
        location: value.buildingID == buildingAllApi.outdoorID ? "${value
            .venueName}" : "Floor ${value.floor}, ${value
            .venueName}",
        onClicked: onVenueClicked,
        ID: value.properties!.polyId!,
        bid: value.buildingID!,
        floor: value.floor!,
        coordX: value.doorX??value.coordinateX!,
        coordY: value.doorY??value.coordinateY!,
        accessible: value.element!.subType == "restRoom" &&
            value.properties!.washroomType == "Handicapped" ? "true" : "false",
        distance: 0,
      ));
    }
    // Step 1: Sort the main list as per previous logic
    searchResults.sort((a, b) {
      // Building comparison
      // Distance comparison within the same building and floor
      double distanceA = tools.calculateDistance([userLat, userLng], [a.coordX!, a.coordY!]);
      double distanceB = tools.calculateDistance([userLat, userLng], [b.coordX!, b.coordY!]);
      // Populate the distance field for each element
      a.distance = (distanceA*0.306).toInt();
      b.distance = (distanceB*0.306).toInt();
      return distanceA.compareTo(distanceB);
    });
    if(searchResults.length>2){
      print("searchResults after in desti: ${searchResults[1].name}  ${searchResults[1].coordX} ${searchResults[1].coordY}");
    }

  }
  bool partialMatch(String dataName, String searchQuery) {
    String normalizedData = normalizeString(dataName);
    String normalizedQuery = normalizeString(searchQuery);

    // Break query into keywords and check if all are present in data
    List<String> queryKeywords = normalizedQuery.split(' ');
    return queryKeywords.every((keyword) => normalizedData.contains(keyword));
  }
  String normalizeString(String input) {
    // Remove common prefixes and convert to lowercase
    input = input.toLowerCase().replaceAll(RegExp(r'^(dr|mr|mrs|ms|prof)\s*'), '');

    // Return the cleaned-up string
    return input;
  }
  Future<void> topSearchesFunc() async {
    List<String> strings = await StringStorage.getStrings();
    setState(() {
      try{
        if(landmarkData.landmarksMap!=null){
          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && strings.contains(value.properties?.polyId)) {
              topSearches.add(SearchpageResults(
                name: "${value.name}",
                location: "Floor ${value.floor}, ${value
                    .buildingName}, ${value.venueName}",
                onClicked: onVenueClicked,
                ID: value.properties!.polyId!,
                bid: value.buildingID!,
                floor: value.floor!,
                coordX: value.coordinateX!,
                coordY: value.coordinateY!,
                accessible:  value.properties!.wheelChairAccessibility??"", distance: 0,
                icon: Icon(
                  Icons.access_time,
                  color: Color(0xff000000),
                  size: 25,
                ),
              ));
            }
          });

          landmarkData.landmarksMap!.forEach((key, value) {
            if (value.name != null && value.element!.subType != "beacon" && !strings.contains(value.properties?.polyId)) {
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
                  icon: Icon(
                    Icons.star,
                    color: Color(0xff000000),
                    size: 25,
                  ),
                ));
              }
            }
          });
        }

      }catch(e){

      }

    });
  }


  String normalizeText(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').toLowerCase();
  }

  Future<void> onVenueClicked(String name, String location, String ID, String bid) async {
    await StringStorage.addString(ID);
    Navigator.pop(context, ID);
  }

  // void fetchRecents() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? savedData = prefs.getString('recents');
  //   if (savedData != null) {
  //     recent = jsonDecode(savedData);
  //     setState(() {
  //       for (List<dynamic> value in recent) {
  //         if (buildingAllApi.getStoredAllBuildingID()[value[3]] != null) {
  //           recentResults.add(SearchpageRecents(
  //             name: value[0],
  //             location: value[1],
  //             onVenueClicked: onVenueClicked,
  //             ID: value[2],
  //             bid: value[3],
  //           ));
  //           searchResults = recentResults;
  //         }
  //       }
  //     });
  //   }
  // }


  List<String> optionsTags = [];
  List<String> floorOptionsTags = [];
  String currentSelectedFilter = "";
  Color containerBoxColor = Color(0xffA1A1AA);
  Color micColor = Colors.black;
  bool micselected = false;
  int vall = -1;
  int newvall = -1;
  int lastval =-1;


  String getIcon(String option) {
    switch (option.toLowerCase()) {
      case 'washroom':
        return 'assets/washroomIcon.png';
      case 'cafeteria':
        return 'assets/cafeteria.png';
      case 'drinking water':
        return 'assets/waterPoint.png';
      case 'atm':
        return 'assets/atmIcon.png';
      case 'entry':
        return 'assets/entryExit.png';
      case 'lift':
        return 'assets/liftIcon.png';
      case 'reception':
        return 'assets/receptionIcon.png';
      default:
        return ''; // Return a default icon if no match is found
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;



    // if(speetchText.isNotListening){
    //   micColor = Colors.black;
    //   print("Not listening");
    // }else{
    //   micColor = Color(0xff24B9B0);
    // }
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: statusBarHeight),
        color: Color(0xfff2f3f5),
        child: !promptLoader? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              child: Column(
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
                                          if(_controller.text.isEmpty){
                                            searchResults.clear();
                                            searcCategoryhResults.clear();
                                            topSearches.clear();
                                            topSearchesFunc();
                                          }else{
                                            search(value);
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
                  optionListForUI.isNotEmpty?Semantics(
                    label: "Filter Section",
                    header: true,
                    child: Container(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      width: screenWidth,
                      child: ChipsChoice<int>.single(
                        value: vall,
                        onChanged: (val) async {
                          if(HelperClass.SemanticEnabled){
                            speak("${optionListForUI.toList()[val]} selected");
                          }
                          selectedButton = optionListForUI.toList()[val];
                          setState(() => vall = val);
                          lastval = val;
                          _controller.text = optionListForUI.toList()[val];
                          print("optionListItemBuildingName:${optionListItemBuildingName}");
                          if(optionListItemBuildingName.length==1){
                            await fetchFloors(optionListItemBuildingName.first,optionListForUI.toList()[val].toUpperCase()).then((_){
                              print("floors list $floors");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FloorSelectionPage(filterName: optionListForUI.toList()[val], filterBuildingName: optionListItemBuildingName.first,floors: floors.toList()..sort(),),
                                ),
                              ).then((value){
                                print("value $value");
                                _controller.text="";
                                searchResults = [];
                                searcCategoryhResults = [];
                                vall = -1;
                                floors.clear();
                                onVenueClicked(value[0],value[1],value[2],value[3]);
                                // widget.onClicked(value[0],value[1],value[2],value[3]);
                              });
                            });
                          }else{
                            search(optionListForUI.toList()[val]);
                          }
                        },
                        choiceItems: C2Choice.listFrom<int, String>(
                          source: optionListForUI.toList(),
                          value: (i, v) => i,
                          label: (i, v) => v,
                        ),

                        choiceBuilder: (item, i) {
                          if(!item.selected){
                            vall = -1;
                          }
                          return DestinationPageChipsWidget(
                            svgPath: '',
                            text: optionListForUI.toList()[i],
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
                            }, icon: _icons[i],
                          );
                        },
                        direction: Axis.horizontal,
                      ),
                    ),
                  ):Container(),
                  (searchHintString.toLowerCase().contains("source") && widget.userLocalized != "")?
                  InkWell(
                    onTap: (){
                      Navigator.pop(context, widget.userLocalized);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 16,right: 16),
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xfff2f3f5), // light gray line
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xff24B9B0).withOpacity(0.1), // change color as needed
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.my_location, size: 20, color: Color(0xff24B9B0),),
                              ),
                              SizedBox(width: 8,),
                              Text(style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff000000),
                              ),"Your Location")
                            ],
                          ),
                        ],
                      ),
                    ),
                  ):Container(),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context, widget.userLocalized);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 16,right: 16),
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xffF1F0F0), // change color as needed
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.map, size: 20, color: Colors.black,),
                              ),
                              SizedBox(width: 8,),
                              Text(style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff000000),
                              ),"Choose on Map")
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // !category && _controller.text.isNotEmpty ? Semantics(
            //   header: true,
            //   label: "Building Filter section",
            //   child: Container(
            //     margin: EdgeInsets.only(left: 7,top: 4),
            //     width: screenWidth,
            //     child: ChipsChoice<int>.single(
            //       value: newvall,
            //       onChanged: (val) {
            //
            //         // if(HelperClass.SemanticEnabled) {
            //         //   speak("${optionListItemBuildingName.toList()[val]} selected");
            //         // }
            //         //
            //         // selectedButton = optionListItemBuildingName.toList()[val];
            //         setState(() => newvall = val);
            //         //
            //         //
            //         // //_controller.text = optionListItemBuildingName.toList()[val];
            //         // search(optionListItemBuildingName.toList()[val]);
            //       },
            //       choiceItems: C2Choice.listFrom<int, String>(
            //         source: optionListItemBuildingNameNew.toList(),
            //         value: (i, v) => i,
            //         label: (i, v) => v,
            //       ),
            //       choiceBuilder: (item, i) {
            //         if(!item.selected){
            //           newvall = -1;
            //         }
            //         return DestinationPageChipsWidget(
            //           svgPath: '',
            //           text: optionListItemBuildingNameNew.toList()[i],
            //           onSelect: item.select!,
            //           selected: item.selected,
            //
            //           onTap: (String Text) {
            //             print("tapped$Text");
            //
            //             if (Text.isNotEmpty) {
            //               search(_controller.text,wantToFilter: Text);
            //             }
            //             // else {
            //             //   search(Text,wantToFilter: optionListItemBuildingName.toList()[i]);
            //             //   _controller.text="";
            //             //   searchResults = [];
            //             //   searcCategoryhResults = [];
            //             //   newvall = -1;
            //             // }
            //           }, icon: getIcon(optionList[i].toLowerCase())
            //         );
            //       },
            //       direction: Axis.horizontal,
            //     ),
            //   ),
            // ) : Container(),
            SizedBox(height: 9,),
            Flexible(
                flex: 1,
                child: SingleChildScrollView(
                  child: Semantics(
                    label: "Search Results",
                    header: true,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (searcCategoryhResults.isEmpty && searchResults.isEmpty && _controller.text.isEmpty)?topSearches:((category)?searcCategoryhResults:searchResults)
                      ),
                    ),
                  ),
                )),
            if (_controller.text.isNotEmpty && searchResults.isEmpty && searcCategoryhResults.isEmpty)
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