import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../DestinationSearchPage.dart';
import '../SourceAndDestinationPage.dart';

class HomepageFilter extends StatefulWidget {
  final Function(String ID) onClicked;
  final String svgPath;
  final String text;
  bool selected;
  final Function(bool selected) onSelect;

  HomepageFilter({
    required this.svgPath,
    required this.text,
    this.selected = false,
    required this.onSelect,
    required this.onClicked
  });

  @override
  _HomepageFilterState createState() => _HomepageFilterState();
}

class _HomepageFilterState extends State<HomepageFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
      padding: EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey, // Shadow color
            offset: Offset(0, 2), // Offset of the shadow
            blurRadius: 4, // Spread of the shadow
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(10.0)), // Updated borderRadius
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DestinationSearchPage(previousFilter: widget.text,voiceInputEnabled: false,))
          ).then((value){
            widget.onClicked(value);
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 4),
              child: Icon(Icons.wallet_giftcard_outlined, size: 18),
            ),
            Container(
              margin: EdgeInsets.only(left: 8, right: 4),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff49454f),
                  height: 20 / 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Icon displayed when active is true
          ],
        ),
      ),
    );
  }
}
