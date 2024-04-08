import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iwayplusnav/SourceAndDestinationPage.dart';

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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
        width: screenWidth - 32,
        height: 48,
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
            Container(
              width: 44,
              height: 48,
              margin: EdgeInsets.only(right: 4),
              child: Center(
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
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
              height: 48,
              width: 1,
              margin: EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  height: 20.5,
                  width: 1,
                  color: Color(0xff8E8C8C),
                ),
              ),
            ),
            Container(
              height: 48,
              width: 47,
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
                  icon: SvgPicture.asset("assets/HomepageSearch_getDirectionIcon.svg"),
                ),
              ),
            )
          ],
        ));
  }
}
