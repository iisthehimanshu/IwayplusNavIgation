import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'package:fuzzy/fuzzy.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/Elements/HomepageFilter.dart';
import 'package:iwaymaps/SourceAndDestinationPage.dart';

import '../APIMODELS/landmark.dart';
import '../DestinationSearchPage.dart';
import 'package:animated_checkmark/animated_checkmark.dart';

import 'HomepageFilter.dart';



class HomepageSearch extends StatefulWidget {
  final searchText;
  final Function(String ID) onVenueClicked;
  final Function(List<String>) fromSourceAndDestinationPage;
  const HomepageSearch({this.searchText = "Search", required this.onVenueClicked, required this.fromSourceAndDestinationPage});

  @override
  State<HomepageSearch> createState() => _HomepageSearchState();
}

class _HomepageSearchState extends State<HomepageSearch> {
  List<String> optionsTags = [];
  List<String> floorOptionsTags = [];

  List<String> options = [
    'Washroom', 'Entry',
    'Reception', 'Lift',
  ];

  List<IconData> _icons = [
    Icons.home,
    Icons.wash_sharp,
    Icons.school,
  ];
  //double ratio=0.0;
  String currentSelectedFilter = "";
  int vall = 0;
  int lastValueStored = 0;

  FlutterTts flutterTts  = FlutterTts();

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Running init");
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
            width: screenWidth - 32,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white, // You can customize the border color
                width: 1.0, // You can customize the border width
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Shadow color
                  offset:
                  Offset(0, 2), // Offset of the shadow
                  blurRadius: 4, // Spread of the shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: FocusScope(
                    autofocus: true,
                    child: Focus(
                      child: Semantics(
                        sortKey: const OrdinalSortKey(0),
                        label: "Search Bar",
                        child: InkWell(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DestinationSearchPage(hintText: 'Destination location',voiceInputEnabled: false,))
                            ).then((value){
                              widget.onVenueClicked(value);
                            });
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 16),
                              child: Text(
                                widget.searchText,
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff8e8d8d),
                                  height: 25 / 16,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 48,
                  margin: EdgeInsets.only(right: 5),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DestinationSearchPage(hintText: 'Destination location',voiceInputEnabled: true,))
                        ).then((value){
                          widget.onVenueClicked(value);
                        });
                      },
                      icon: Semantics(
                        label: "Voice search",
                        sortKey: const OrdinalSortKey(1),
                        child: Icon(
                          Icons.mic_none_sharp,
                          color: Color(0xff8E8C8C),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  width: 47,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xff24B9B0),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(3), // Adjust the radius as needed
                      bottomRight: Radius.circular(3), // Adjust the radius as needed
                      topLeft: Radius.circular(3), // Adjust the radius as needed
                      bottomLeft: Radius.circular(3), // Adjust the radius as needed
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SourceAndDestinationPage())
                        ).then((value){
                          widget.fromSourceAndDestinationPage(value);
                        });
                      },

                      icon: Semantics(
                        label: "Get Direction",
                        child: SvgPicture.asset(
                            "assets/HomepageSearch_topBarDirectionIcon.svg"),
                      ),
                    ),
                  ),
                )
              ],
            )),
        Container(
          width: screenWidth,
          child: ChipsChoice<int>.single(
            value: vall,
            onChanged: (val){
              setState(() => vall = val);

              if(HelperClass.SemanticEnabled){
                speak("${options[val]} selected");
              }else if(lastValueStored == val){
                speak("${options[val]} selected");
              }
              lastValueStored = val;
              print("wilsonchecker");
              print(val);
            },
            choiceItems: C2Choice.listFrom<int, String>(
              source: options,
              value: (i, v) => i,
              label: (i, v) => v,
            ),
            choiceBuilder: (item, i) {
              return HomepageFilter(svgPath: '', text: options[i], onSelect: (bool selected) {  }, onClicked: widget.onVenueClicked,);
            },
            direction: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}

class CustomChip extends StatelessWidget {
  final String label;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final Function(bool selected) onSelect;

  const CustomChip({
    Key? key,
    required this.label,
    this.color,
    this.width,
    this.height,
    this.margin,
    this.selected = false,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected
            ? (color ?? Colors.white)
            : Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(selected ? 10 : 10)),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(selected ? 25 : 10)),
        onTap: () => onSelect(!selected),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10,left: 10,right: 10,bottom: 10),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : theme.colorScheme.onSurface,
                  height: 20/14,
                ),
              ),
            ),
            Container(
              child: selected ? AnimatedCrossFade(
                duration: const Duration(milliseconds: 400),
                firstChild: const Icon(Icons.close, color: Colors.white), // Check icon when selected
                secondChild: const Icon(Icons.close, color: Colors.white), // Close icon when not selected
                crossFadeState: selected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              ): null,
            ) ,
            // Icon displayed when active is true

          ],
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  final String title;
  final Widget child;

  const Content({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  ContentState createState() => ContentState();
}

class ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            // color: Colors.blueGrey[50],
            child: Text(
              widget.title,
              style: const TextStyle(
                // color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}

void _about(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              'chips_choice',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.black87),
            ),
            subtitle: const Text('by davigmacode'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Easy way to provide a single or multiple choice chips.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.black54),
                  ),
                  Container(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}