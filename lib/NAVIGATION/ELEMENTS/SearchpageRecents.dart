import 'package:flutter/material.dart';
class SearchpageRecents extends StatefulWidget {
  final Function(String name, String location, String ID, String bid) onVenueClicked;
  final String name;
  final String location;
  final String ID;
  final String bid;
  const SearchpageRecents({required this.name,required this.location,required this.onVenueClicked,required this.ID,required this.bid});

  @override
  State<SearchpageRecents> createState() => _SearchpageRecentsState();
}

class _SearchpageRecentsState extends State<SearchpageRecents> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: (){
        widget.onVenueClicked(widget.name,widget.location,widget.ID,widget.bid);
      },
      child:Container(
        padding: EdgeInsets.only(left:4,top: 16,bottom: 16),
        width: screenWidth-32,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey, // Color of the bottom border
              width: 1.0, // Width of the bottom border
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffebebeb), // Color of the circular container
              ),
              child: Icon(Icons.access_time_sharp,color: Colors.black,size: 24,),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 25/16,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  widget.location,
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff8d8c8c),
                    height: 20/14,
                  ),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
