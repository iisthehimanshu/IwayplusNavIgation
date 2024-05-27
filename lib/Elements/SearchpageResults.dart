import 'package:flutter/material.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/UserState.dart';
import 'package:iwaymaps/localizedData.dart';
import 'package:iwaymaps/path.dart';

import '../navigationTools.dart';

class SearchpageResults extends StatefulWidget {
  final Function(String name, String location, String ID, String bid) onClicked;
  final String name;
  final String location;
  final String ID;
  final String bid;
  final int floor;
  int coordX;
  int coordY;
  // String LandmarkName;
  // String LandmarkFloor;
  // String LandmarksubName;
  // String LandmarkDistance;
  SearchpageResults(
      {required this.name,
      required this.location,
      required this.onClicked,
      required this.ID,
      required this.bid,
      required this.floor,
      required this.coordX,
      required this.coordY});

  @override
  State<SearchpageResults> createState() => _SearchpageResultsState();
}

class _SearchpageResultsState extends State<SearchpageResults> {
  //double distance = 0.0;
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
    // if(widget.floor == localizedData.floor){
    //   int numRows = localizedData.currentfloorDimenssion[localizedData.floor]![1]; //floor breadth
    //   int numCols = localizedData.currentfloorDimenssion[localizedData.floor]![0]; //floor length
    //   int sourceIndex = calculateindex(localizedData.coordX, localizedData.coordY, numCols);
    //   int destinationIndex = calculateindex(widget.coordX, widget.coordY, numCols);
    //   // Simulate a network request or a heavy computation with a delay
    //
    //   List<int> p = findPath(numRows, numCols, localizedData.nonWalkable[localizedData.floor]!, sourceIndex, destinationIndex);
    //   await Future.delayed(const Duration(milliseconds: 500));
    //
    //   return (p.length* 0.3048).toInt(); // This is your calculated integer
    // }else{
    //   int numRows = localizedData.currentfloorDimenssion[localizedData.floor]![1]; //floor breadth
    //   int numCols = localizedData.currentfloorDimenssion[localizedData.floor]![0]; //floor length
    //   int sourceIndex = calculateindex(localizedData.coordX, localizedData.coordY, numCols);
    //   int destinationIndex = calculateindex(widget.coordX, widget.coordY, numCols);
    //   // Simulate a network request or a heavy computation with a delay
    //
    //   List<int> p = findPath(numRows, numCols, localizedData.nonWalkable[localizedData.floor]!, sourceIndex, destinationIndex);
    //
    //
    //   // numRows = localizedData.currentfloorDimenssion[widget.floor]![1]; //floor breadth
    //   // numCols = localizedData.currentfloorDimenssion[widget.floor]![0]; //floor length
    //   // sourceIndex = calculateindex(localizedData.coordX, localizedData.coordY, numCols);
    //   // destinationIndex = calculateindex(widget.coordX, widget.coordY, numCols);
    //   // // Simulate a network request or a heavy computation with a delay
    //   //
    //   // List<int> p = findPath(numRows, numCols, localizedData.nonWalkable[localizedData.floor]!, sourceIndex, destinationIndex);
    //   // await Future.delayed(const Duration(milliseconds: 500));
    //
    //   return (p.length* 0.3048).toInt(); // This is your calculated integer
    // }

  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 8,
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5F5F5), // Specify the background color here
              ),
              child: Icon(
                Icons.man,
                color: Color(0xff000000),
                size: 25,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(widget.name, 20),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                  alignment: Alignment.topLeft,
                  child: Text(
                    HelperClass.truncateString(widget.location, 25),
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff8d8c8c),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            Spacer(),
            // Column(
            //   children: [
            //     FutureBuilder<int>(
            //       future: calculateValue(),
            //       builder: (context, snapshot) {
            //         // Checking connection state of the future
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return SizedBox(width:24,height:24,child: CircularProgressIndicator(color: Colors.grey,)); // Show loading indicator while waiting
            //         } else if (snapshot.hasError) {
            //           return Text('--');
            //         } else {
            //           // Once the data is fetched, show the data
            //           return Text('${snapshot.data} m',
            //               style: const TextStyle(
            //                 fontFamily: "Roboto",
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w400,
            //                 color: Color(0xff000000),
            //                 height: 25/16,
            //               ));
            //         }
            //       },
            //     ),
            //     Container(
            //       margin: EdgeInsets.only(top: 3, bottom: 14, right: 10),
            //       alignment: Alignment.center,
            //       child: Text(
            //         HelperClass.truncateString("Floor ${widget.floor}", 25),
            //         style: const TextStyle(
            //           fontFamily: "Roboto",
            //           fontSize: 14,
            //           fontWeight: FontWeight.w400,
            //           color: Color(0xff8d8c8c),
            //           height: 20 / 14,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
            //   ],
            // ),
            Container(
              margin: EdgeInsets.only(top: 3, bottom: 14, right: 10),
              alignment: Alignment.center,
              child: Text(
                HelperClass.truncateString("Floor ${widget.floor}", 25),
                style: const TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff8d8c8c),
                  height: 20 / 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
