import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwayplusnav/SourceAndDestinationPage.dart';

import '../APIMODELS/landmark.dart';
import '../DestinationSearchPage.dart';

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
    Icons.work,
    Icons.school,


  ];
  //double ratio=0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Running init");
    _calculateSimilarityRatio("Book");
  }
  void _calculateSimilarityRatio(String text1,) {
    final bookList = [
      'Old Man\'s War',
      'The Lock Artist',
      'HTML5',
      'Right Ho Jeeves',
      'The Code of the Wooster',
      'Thank You Jeeves',
      'The DaVinci Code',
      'Angels & Demons',
      'The Silmarillion',
      'Syrup',
      'The Lost Symbol',
      'The Book of Lies',
      'Lamb',
      'Fool',
      'Incompetence',
      'Fat',
      'Colony',
      'Backwards, Red Dwarf',
      'The Grand Design',
      'The Book of Samson',
      'The Preservationist',
      'Fallen',
      'Monster 1959',
    ];
    Fuzzy fuse = Fuzzy(bookList,
      options: FuzzyOptions(
      findAllMatches: true,
      tokenize: true,
      threshold: 0.5,
    ),);
    //return ratioCalc.list;
    final result = fuse.search('book');

    print(
        'A score of 0 indicates a perfect match, while a score of 1 indicates a complete mismatch.');

    result.forEach((r) {
      print('\nScore: ${r.score}\nTitle: ${r.item}');
    });
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
                  child: Semantics(
                    label: "Search Bar",
                    sortKey: const OrdinalSortKey(1),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DestinationSearchPage(hintText: 'Destination location',))
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

                      icon: SvgPicture.asset(
                          "assets/HomepageSearch_topBarDirectionIcon.svg"),
                    ),
                  ),
                )
              ],
            )),
        Container(
          child: ValueListenableBuilder(
            valueListenable: Hive.box('Filters').listenable(),
            builder: (BuildContext context, value, Widget? child) {
              //List<dynamic> aa = []
              if(value.length==2){
                floorOptionsTags = value.getAt(1);
              }
              return ChipsChoice<String>.multiple(
                value: floorOptionsTags,
                onChanged: (val) {
                  print("Filter change${val}${value.values}");
                  value.put(1, val);
                  setState(() {
                    floorOptionsTags = val;
                    //onTagsChanged();
                  });
                },
                choiceItems: C2Choice.listFrom<String, String>(
                  source: floorOptions,
                  value: (i, v) => v,
                  label: (i, v) => v,
                  tooltip: (i, v) => v,
                  meta: (i, v) => _icons[i], // Provide the icon data for each choice
                ),
                choiceLeadingBuilder: (data, i) {
                  if (data.meta == null) return null;
                  return Icon(data.meta as IconData); // Display the icon from the meta property
                },
                choiceCheckmark: false,
                choiceStyle: C2ChipStyle.filled(
                  height: 38,
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),

                ),
                wrapped: false,
              );
            },
          ),
        ),

      ],
    );
  }
}
