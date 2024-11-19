
import 'package:flutter/material.dart';
import '/IWAYPLUS/Elements/HelperClass.dart';

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
    required this.distance
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
        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xffEBEBEB),
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffF5F5F5),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Color(0xff000000),
                    size: 25,
                  ),
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
                        margin: EdgeInsets.only(top: 12, left: 18),
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff000000),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
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
