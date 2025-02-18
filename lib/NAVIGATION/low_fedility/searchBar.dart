import 'package:flutter/material.dart';

class searchBar extends StatelessWidget {
  const searchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 2.5,bottom: 2.5,right: 2.5),
      margin: EdgeInsets.only(left: 13,right: 13, bottom: 24),
      decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xffDEDBDB), // Set the border color to grey
            width: 2,            // Set the width of the border
          )
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16,right: 16),
              child:TextField(
                decoration: InputDecoration(
                  hintText: "Search Destination",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: (){},
            child: Container(
              width: 48,
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Color(0xFFFFD700)),
              child:Icon(
                Icons.mic_none_outlined,size: 32,color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
