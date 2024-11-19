import 'package:flutter/material.dart';

import '../DestinationSearchPage.dart';

class HomepageLandmarkClickedSearchBar extends StatefulWidget {
  final searchText;
  final VoidCallback onToggle;
  HomepageLandmarkClickedSearchBar({this.searchText = "Search",required this.onToggle});

  @override
  State<HomepageLandmarkClickedSearchBar> createState() => _HomepageLandmarkClickedSearchBarState();
}

class _HomepageLandmarkClickedSearchBarState extends State<HomepageLandmarkClickedSearchBar> {
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
                  onPressed: () {
                    widget.onToggle();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
            Expanded(
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
            Container(
              height: 48,
              width: 47,
              child: Center(
                child: IconButton(
                  onPressed: () { widget.onToggle();},
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
