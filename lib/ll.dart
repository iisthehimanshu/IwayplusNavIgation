// Widget routeDeatilPannel() {
//   setState(() {
//     semanticShouldBeExcluded = true;
//   });
//   double? angle;
//   if (PathState.singleCellListPath.isNotEmpty) {
//     int l = PathState.singleCellListPath.length;
//     angle = tools.calculateAngle([
//       PathState.singleCellListPath[l - 2].x,
//       PathState.singleCellListPath[l - 2].y
//     ], [
//       PathState.singleCellListPath[l - 1].x,
//       PathState.singleCellListPath[l - 1].y
//     ], [
//       PathState.destinationX,
//       PathState.destinationY
//     ]);
//   }
//
//   double screenWidth = MediaQuery.of(context).size.width;
//   double screenHeight = MediaQuery.of(context).size.height;
//   List<Widget> directionWidgets = [];
//   directionWidgets.clear();
//   if (PathState.directions.isNotEmpty) {
//     directionWidgets.add(directionInstruction(
//         direction: "Go Straight",
//         distance: (PathState.directions[0].distanceToNextTurn! * 0.3048)
//             .ceil()
//             .toString()));
//     for (int i = 1; i < PathState.directions.length; i++) {
//       if (PathState.directions[i].nearbyLandmark != null) {
//         directionWidgets.add(directionInstruction(
//             direction: PathState.directions[i].turnDirection == "Straight"
//                 ? "Go Straight"
//                 : "Turn ${PathState.directions[i].turnDirection!} from ${PathState.directions[i].nearbyLandmark!.name!}, and Go Straight",
//             distance: (PathState.directions[i].distanceToNextTurn! * 0.3048)
//                 .ceil()
//                 .toString()));
//       } else {
//         if (PathState.directions[i].node == -1) {
//           directionWidgets.add(directionInstruction(
//               direction: "${PathState.directions[i].turnDirection!}",
//               distance:
//               "and go to ${PathState.directions[i].distanceToPrevTurn ?? 0.toInt()} floor"));
//         } else {
//           directionWidgets.add(directionInstruction(
//               direction: PathState.directions[i].turnDirection == "Straight"
//                   ? "Go Straight"
//                   : "Turn ${PathState.directions[i].turnDirection!}, and Go Straight",
//               distance:
//               (PathState.directions[i].distanceToNextTurn ?? 0 * 0.3048)
//                   .ceil()
//                   .toString()));
//         }
//       }
//     }
//   }
//
//   // for (int i = 0; i < PathState.directions.length; i++) {
//   //   if (PathState.directions[i].keys.first == "Straight") {
//   //     directionWidgets.add(directionInstruction(
//   //         direction: "Go " + PathState.directions[i].keys.first,
//   //         distance: tools
//   //             .roundToNextInt(PathState.directions[i].values.first * 0.3048)
//   //             .toString()));
//   //   } else if (PathState.directions[i].keys.first.substring(0, 4) == "Take") {
//   //     directionWidgets.add(directionInstruction(
//   //         direction: PathState.directions[i].keys.first,
//   //         distance: "Floor $sourceVal -> Floor $destinationVal"));
//   //   } else {
//   //     directionWidgets.add(directionInstruction(
//   //         direction: "Turn " +
//   //             PathState.directions[i].keys.first +
//   //             ", and Go Straight",
//   //         distance: tools
//   //             .roundToNextInt(PathState.directions[++i].values.first * 0.3048)
//   //             .toString()));
//   //   }
//   // }
//   double time = 0;
//   double distance = 0;
//   DateTime currentTime = DateTime.now();
//   if (PathState.path.isNotEmpty) {
//     PathState.path.forEach((key, value) {
//       time = time + value.length / 120;
//       distance = distance + value.length;
//     });
//     time = time.ceil().toDouble();
//
//     distance = distance * 0.3048;
//     distance = double.parse(distance.toStringAsFixed(1));
//   }
//   DateTime newTime = currentTime.add(Duration(minutes: time.toInt()));
//
//   return Visibility(
//     visible: _isRoutePanelOpen,
//     child: Stack(
//       children: [
//         Container(
//           margin: EdgeInsets.only(left: 16, top: 16),
//           height: 119,
//           width: screenWidth - 32,
//           padding: EdgeInsets.only(top: 15, right: 8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10.0),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5),
//                 spreadRadius: 2,
//                 blurRadius: 5,
//                 offset: Offset(0, 3), // changes the position of the shadow
//               ),
//             ],
//           ),
//           child: Semantics(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   child: IconButton(
//                       onPressed: () {
//                         showMarkers();
//                         List<double> mvalues = tools.localtoglobal(
//                             PathState.destinationX, PathState.destinationY);
//                         _googleMapController.animateCamera(
//                           CameraUpdate.newLatLngZoom(
//                             LatLng(mvalues[0], mvalues[1]),
//                             20, // Specify your custom zoom level here
//                           ),
//                         );
//                         _isRoutePanelOpen = false;
//                         _isLandmarkPanelOpen = true;
//                         PathState = pathState.withValues(
//                             -1, -1, -1, -1, -1, -1, null, 0);
//                         PathState.path.clear();
//                         PathState.sourcePolyID = "";
//                         PathState.destinationPolyID = "";
//                         singleroute.clear();
//                         _isBuildingPannelOpen = true;
//                         clearPathVariables();
//                         setState(() {
//                           Marker? temp = selectedroomMarker[
//                           buildingAllApi.getStoredString()]
//                               ?.first;
//
//                           selectedroomMarker.clear();
//                           selectedroomMarker[buildingAllApi.getStoredString()]
//                               ?.add(temp!);
//                           pathMarkers.clear();
//                         });
//                       },
//                       icon: Semantics(
//                         label: "Back",
//                         onDidGainAccessibilityFocus: closeRoutePannel,
//                         child: Icon(
//                           Icons.arrow_back_ios_new,
//                           size: 24,
//                         ),
//                       )),
//                 ),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       InkWell(
//                         child: Container(
//                           height: 40,
//                           width: double.infinity,
//                           margin: EdgeInsets.only(bottom: 8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10.0),
//                             border: Border.all(color: Color(0xffE2E2E2)),
//                           ),
//                           padding:
//                           EdgeInsets.only(left: 8, top: 7, bottom: 8),
//                           child: Text(
//                             PathState.sourceName,
//                             style: const TextStyle(
//                               fontFamily: "Roboto",
//                               fontSize: 16,
//                               fontWeight: FontWeight.w400,
//                               color: Color(0xff24b9b0),
//                             ),
//                             textAlign: TextAlign.left,
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => DestinationSearchPage(
//                                     hintText: 'Source location',
//                                     voiceInputEnabled: false,
//                                   ))).then((value) {
//                             onSourceVenueClicked(value);
//                           });
//                         },
//                       ),
//                       InkWell(
//                         child: Container(
//                           height: 40,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10.0),
//                             border: Border.all(color: Color(0xffE2E2E2)),
//                           ),
//                           padding:
//                           EdgeInsets.only(left: 8, top: 7, bottom: 8),
//                           child: Semantics(
//                             onDidGainAccessibilityFocus: closeRoutePannel,
//                             child: Text(
//                               PathState.destinationName,
//                               style: const TextStyle(
//                                 fontFamily: "Roboto",
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w400,
//                                 color: Color(0xff282828),
//                               ),
//                               textAlign: TextAlign.left,
//                             ),
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => DestinationSearchPage(
//                                     hintText: 'Destination location',
//                                     voiceInputEnabled: false,
//                                   ))).then((value) {
//                             _isBuildingPannelOpen = false;
//                             onDestinationVenueClicked(value);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           PathState.swap();
//                           PathState.path.clear();
//                           pathMarkers.clear();
//                           PathState.directions.clear();
//                           clearPathVariables();
//                           building.landmarkdata!.then((value) {
//                             calculateroute(value.landmarksMap!);
//                           });
//                         });
//                       },
//                       icon: Semantics(
//                         label: "Swap location",
//                         child: Icon(
//                           Icons.swap_vert_circle_outlined,
//                           size: 24,
//                         ),
//                       )),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Visibility(
//           visible: PathState.sourceX != 0,
//           child: SlidingUpPanel(
//               controller: _routeDetailPannelController,
//               borderRadius: BorderRadius.all(Radius.circular(24.0)),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 20.0,
//                   color: Colors.grey,
//                 ),
//               ],
//               minHeight: 163,
//               maxHeight: screenHeight * 0.9,
//               panel: Semantics(
//                 sortKey: const OrdinalSortKey(0),
//                 child: Column(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                         color: Colors.white,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Semantics(
//                             excludeSemantics: true,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 38,
//                                   height: 6,
//                                   margin: EdgeInsets.only(top: 8),
//                                   decoration: BoxDecoration(
//                                     color: Color(0xffd9d9d9),
//                                     borderRadius: BorderRadius.circular(5.0),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(bottom: 20),
//                             padding: EdgeInsets.only(left: 17, top: 12),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Focus(
//                                   autofocus: true,
//                                   child: Semantics(
//                                     label:
//                                     "Your destination is ${distance}m away ",
//                                     child: Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.start,
//                                       children: [
//                                         Semantics(
//                                           excludeSemantics: true,
//                                           child: Text(
//                                             "${time.toInt()} min ",
//                                             style: const TextStyle(
//                                               color: Color(0xffDC6A01),
//                                               fontFamily: "Roboto",
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.w500,
//                                               height: 24 / 18,
//                                             ),
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ),
//                                         Semantics(
//                                           excludeSemantics: true,
//                                           child: Text(
//                                             "(${distance} m)",
//                                             style: const TextStyle(
//                                               fontFamily: "Roboto",
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.w500,
//                                               height: 24 / 18,
//                                             ),
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ),
//                                         Spacer(),
//                                         IconButton(
//                                             onPressed: () {
//                                               showMarkers();
//                                               _isBuildingPannelOpen = true;
//                                               _isRoutePanelOpen = false;
//                                               selectedroomMarker.clear();
//                                               pathMarkers.clear();
//
//                                               building.selectedLandmarkID =
//                                               null;
//
//                                               PathState =
//                                                   pathState.withValues(
//                                                       -1,
//                                                       -1,
//                                                       -1,
//                                                       -1,
//                                                       -1,
//                                                       -1,
//                                                       null,
//                                                       0);
//                                               PathState.path.clear();
//                                               PathState.sourcePolyID = "";
//                                               PathState.destinationPolyID =
//                                               "";
//                                               PathState.sourceBid = "";
//                                               PathState.destinationBid = "";
//                                               singleroute.clear();
//                                               PathState.directions = [];
//                                               interBuildingPath.clear();
//                                               clearPathVariables();
//                                               fitPolygonInScreen(patch.first);
//                                             },
//                                             icon: Semantics(
//                                               label: "Close",
//                                               child: Icon(
//                                                 Icons.cancel_outlined,
//                                                 size: 25,
//                                               ),
//                                             ))
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 // Text(
//                                 //   "via",
//                                 //   style: const TextStyle(
//                                 //     fontFamily: "Roboto",
//                                 //     fontSize: 16,
//                                 //     fontWeight: FontWeight.w400,
//                                 //     color: Color(0xff4a4545),
//                                 //     height: 25 / 16,
//                                 //   ),
//                                 //   textAlign: TextAlign.left,
//                                 // ),
//                                 // Text(
//                                 //   "ETA- ${newTime.hour}:${newTime.minute}",
//                                 //   style: const TextStyle(
//                                 //     fontFamily: "Roboto",
//                                 //     fontSize: 14,
//                                 //     fontWeight: FontWeight.w400,
//                                 //     color: Color(0xff8d8c8c),
//                                 //     height: 20 / 14,
//                                 //   ),
//                                 //   textAlign: TextAlign.left,
//                                 // ),
//                                 SizedBox(
//                                   height: 8,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Semantics(
//                                       sortKey: const OrdinalSortKey(1),
//                                       child: Container(
//                                         width: 108,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           color: Color(0xff24B9B0),
//                                           borderRadius:
//                                           BorderRadius.circular(4.0),
//                                         ),
//                                         child: TextButton(
//                                           onPressed: () async {
//                                             user.Bid = PathState.sourceBid;
//                                             user.floor =
//                                                 PathState.sourceFloor;
//                                             user.pathobj = PathState;
//                                             user.path =
//                                                 PathState.singleListPath;
//                                             user.isnavigating = true;
//                                             user.Cellpath =
//                                                 PathState.singleCellListPath;
//                                             user
//                                                 .moveToStartofPath()
//                                                 .then((value) async {
//                                               BitmapDescriptor userloc =
//                                               await BitmapDescriptor
//                                                   .fromAssetImage(
//                                                 ImageConfiguration(
//                                                     size: Size(44, 44)),
//                                                 'assets/userloc0.png',
//                                               );
//                                               BitmapDescriptor userlocdebug =
//                                               await BitmapDescriptor
//                                                   .fromAssetImage(
//                                                 ImageConfiguration(
//                                                     size: Size(44, 44)),
//                                                 'assets/tealtorch.png',
//                                               );
//                                               setState(() {
//                                                 markers.clear();
//                                                 List<double> val =
//                                                 tools.localtoglobal(
//                                                     user.showcoordX
//                                                         .toInt(),
//                                                     user.showcoordY
//                                                         .toInt());
//
//                                                 markers.putIfAbsent(
//                                                     user.Bid, () => []);
//                                                 markers[user.Bid]?.add(Marker(
//                                                   markerId: MarkerId(
//                                                       "UserLocation"),
//                                                   position:
//                                                   LatLng(val[0], val[1]),
//                                                   icon: userloc,
//                                                   anchor: Offset(0.5, 0.829),
//                                                 ));
//
//                                                 val = tools.localtoglobal(
//                                                     user.coordX.toInt(),
//                                                     user.coordY.toInt());
//
//                                                 markers[user.Bid]?.add(Marker(
//                                                   markerId: MarkerId("debug"),
//                                                   position:
//                                                   LatLng(val[0], val[1]),
//                                                   icon: userlocdebug,
//                                                   anchor: Offset(0.5, 0.829),
//                                                 ));
//                                               });
//                                             });
//                                             _isRoutePanelOpen = false;
//
//                                             building.selectedLandmarkID =
//                                             null;
//
//                                             _isnavigationPannelOpen = true;
//
//                                             semanticShouldBeExcluded = false;
//
//                                             StartPDR();
//                                             alignMapToPath([
//                                               user.lat,
//                                               user.lng
//                                             ], [
//                                               PathState
//                                                   .singleCellListPath[
//                                               user.pathobj.index + 1]
//                                                   .lat,
//                                               PathState
//                                                   .singleCellListPath[
//                                               user.pathobj.index + 1]
//                                                   .lng
//                                             ]);
//                                           },
//                                           child: !startingNavigation
//                                               ? Row(
//                                             mainAxisSize:
//                                             MainAxisSize.min,
//                                             children: [
//                                               Icon(
//                                                 Icons
//                                                     .assistant_navigation,
//                                                 color: Colors.black,
//                                               ),
//                                               SizedBox(width: 8),
//                                               Text(
//                                                 "Start",
//                                                 style: TextStyle(
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                               : Container(
//                                               width: 24,
//                                               height: 24,
//                                               child:
//                                               CircularProgressIndicator(
//                                                 color: Colors.white,
//                                               )),
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       width: 95,
//                                       height: 40,
//                                       margin: EdgeInsets.only(left: 12),
//                                       decoration: BoxDecoration(
//                                         borderRadius:
//                                         BorderRadius.circular(4.0),
//                                         border:
//                                         Border.all(color: Colors.black),
//                                       ),
//                                       child: TextButton(
//                                         onPressed: () {
//                                           if (_routeDetailPannelController
//                                               .isPanelOpen) {
//                                             _routeDetailPannelController
//                                                 .close();
//                                           } else {
//                                             _routeDetailPannelController
//                                                 .open();
//                                           }
//                                         },
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               _routeDetailPannelController
//                                                   .isAttached
//                                                   ? _routeDetailPannelController
//                                                   .isPanelClosed
//                                                   ? Icons
//                                                   .short_text_outlined
//                                                   : Icons.map_sharp
//                                                   : Icons.short_text_outlined,
//                                               color: Colors.black,
//                                             ),
//                                             SizedBox(width: 8),
//                                             Semantics(
//                                               sortKey:
//                                               const OrdinalSortKey(2),
//                                               onDidGainAccessibilityFocus:
//                                               openRoutePannel,
//                                               child: Text(
//                                                 _routeDetailPannelController
//                                                     .isAttached
//                                                     ? _routeDetailPannelController
//                                                     .isPanelClosed
//                                                     ? "Steps"
//                                                     : "Map"
//                                                     : "Steps",
//                                                 style: TextStyle(
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             margin:
//                             EdgeInsets.only(left: 17, top: 12, right: 17),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   child: Semantics(
//                                     excludeSemantics: true,
//                                     child: Text(
//                                       "Steps",
//                                       style: const TextStyle(
//                                         fontFamily: "Roboto",
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xff000000),
//                                         height: 24 / 18,
//                                       ),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 22,
//                                 ),
//                                 Semantics(
//                                   child: Expanded(
//                                     child: SingleChildScrollView(
//                                       child: Column(
//                                         children: [
//                                           Semantics(
//                                             excludeSemantics: false,
//                                             child: Row(
//                                               crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                   height: 25,
//                                                   margin: EdgeInsets.only(
//                                                       right: 8),
//                                                   child: SvgPicture.asset(
//                                                       "assets/StartpointVector.svg"),
//                                                 ),
//                                                 Semantics(
//                                                   label:
//                                                   "Steps preview,    You are heading from",
//                                                   child: Text(
//                                                     "${PathState.sourceName}",
//                                                     style: const TextStyle(
//                                                       fontFamily: "Roboto",
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                       FontWeight.w400,
//                                                       color:
//                                                       Color(0xff0e0d0d),
//                                                       height: 25 / 16,
//                                                     ),
//                                                     textAlign: TextAlign.left,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 15,
//                                           ),
//                                           Container(
//                                             width: screenHeight,
//                                             height: 1,
//                                             color: Color(0xffEBEBEB),
//                                           ),
//                                           Column(
//                                             children: directionWidgets,
//                                           ),
//                                           SizedBox(
//                                             height: 22,
//                                           ),
//                                           Row(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                             children: [
//                                               Container(
//                                                 height: 25,
//                                                 margin:
//                                                 EdgeInsets.only(right: 8),
//                                                 child: Icon(
//                                                   Icons.pin_drop_sharp,
//                                                   size: 24,
//                                                 ),
//                                               ),
//                                               Semantics(
//                                                 label:
//                                                 "Your are heading towards ",
//                                                 child: Text(
//                                                   angle != null
//                                                       ? "${PathState.destinationName} will be ${tools.angleToClocks3(angle)}"
//                                                       : PathState
//                                                       .destinationName,
//                                                   style: const TextStyle(
//                                                     fontFamily: "Roboto",
//                                                     fontSize: 16,
//                                                     fontWeight:
//                                                     FontWeight.w400,
//                                                     color: Color(0xff0e0d0d),
//                                                     height: 25 / 16,
//                                                   ),
//                                                   textAlign: TextAlign.left,
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             height: 15,
//                                           ),
//                                           Container(
//                                             width: screenHeight,
//                                             height: 1,
//                                             color: Color(0xffEBEBEB),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//         ),
//       ],
//     ),
//   );
// }