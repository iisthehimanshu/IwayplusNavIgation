
import 'package:flutter/material.dart';

import '../../IWAYPLUS/Elements/HelperClass.dart';

class SearchpageResults extends StatefulWidget {
  final Function(String name, String location, String ID, String bid) onClicked;
  final String name;
  final String location;
  final String ID;
  final String bid;
  final int floor;
  int coordX;
  int coordY;
  String accessible;
  int distance;
  Icon icon ;

  SearchpageResults({
    required this.name,
    required this.location,
    required this.onClicked,
    required this.ID,
    required this.bid,
    required this.floor,
    required this.coordX,
    required this.coordY,
    required this.accessible,
    required this.distance,
    this.icon = const Icon(
      Icons.location_on_outlined,
      color: Color(0xff000000),
      size: 22,
    )
  });

  @override
  State<SearchpageResults> createState() => _SearchpageResultsState();
}

class _SearchpageResultsState extends State<SearchpageResults> {
  @override
  void initState() {
    super.initState();
  }

  int calculateindex(int x, int y, int fl) {
    return (y * fl) + x;
  }

  Future<int> calculateValue() async {
    await Future.delayed(const Duration(seconds: 1));
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        widget.onClicked(widget.name, widget.location, widget.ID, widget.bid);
      },
      child: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300, // light gray line
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffF5F5F5),
                  ),
                  child: widget.icon,
                ),
                if(widget.distance!=0) Container(
                  margin: EdgeInsets.only(top: 4, left: 11),
                  child: Text(
                    "${widget.distance.toString()}m",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width-100, // Adjust width if needed
                          ),
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 2, left: 8),
                        child: Text(
                          HelperClass.truncateString(widget.location, 40),
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff8d8c8c),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  widget.accessible == "true"? Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Icon(Icons.accessible,color: Colors.black,),
                  ) : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
