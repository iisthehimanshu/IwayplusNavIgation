
import 'dart:collection';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/API/buildingAllApi.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import 'package:iwaymaps/Elements/HelperClass.dart';
import 'package:iwaymaps/Elements/buildingCard.dart';
import 'package:iwaymaps/Navigation.dart';
import 'API/BuildingAPI.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/buildingAll.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'Elements/InsideBuildingCard.dart';
import 'package:iwaymaps/websocket/UserLog.dart';


class BuildingInfoScreen extends StatefulWidget {
  List<buildingAll>? receivedAllBuildingList;
  String? venueTitle;
  String? venueDescription;
  String? venueCategory;
  String? venueAddress;
  String? venuePhone;
  String? venueWebsite;
  int? dist;
  Position? currentLatLng;

  BuildingInfoScreen({ this.receivedAllBuildingList,this.venueTitle,this.venueDescription,this.venueCategory,this.venueAddress,this.venuePhone,this.venueWebsite,this.dist,this.currentLatLng});


  @override
  State<BuildingInfoScreen> createState() => _BuildingInfoScreenState();
}

class _BuildingInfoScreenState extends State<BuildingInfoScreen> {
  late List<buildingAll> allBuildingList=[];
  List<BuildingAPIInsideModel> dd = [];
  HashMap<String,LatLng> allBuildingID = new HashMap();
  String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + '..';
    }
  }
  String makeAddress(String inputString) {
    List<String> words = inputString.split(',');
    // Ensure there are at least three words before extracting the last three
    if (words.length > 3) {
      return words[words.length-3]+","+words[words.length-4];
    } else {
      // Handle the case when there are fewer than three words
      return "";
    }
  }
  bool bluetoohEnabled = false;

  @override
  void initState() {
    super.initState();
    print(widget.receivedAllBuildingList);
    apiCall();
    print("building list");
    widget.receivedAllBuildingList!.forEach((element) {
      LatLng kk = LatLng(element.coordinates![0], element.coordinates![1]);
      allBuildingID[element.sId!] = kk;
    });
  }

  void apiCall() async{
    BuildingAPI().fetchBuildData().then((value){
      setState(() {
        dd = value.data!;
      });
    });
    print("API CAll");
    for (BuildingAPIInsideModel i in dd){
      print(i);
    }
    print(dd.length);
  }
  var currentData;

  Future<void> customEnableBT(BuildContext context) async {
    String dialogTitle = "Hey! Please give me permission to use Bluetooth!";
    bool displayDialogContent = true;
    String dialogContent = "This app requires Bluetooth to connect to device.";
    //or
    // bool displayDialogContent = false;
    // String dialogContent = "";
    String cancelBtnText = "Nope";
    String acceptBtnText = "Sure";
    double dialogRadius = 10.0;
    bool barrierDismissible = true; //

    BluetoothEnable.customBluetoothRequest(
        context,
        dialogTitle,
        displayDialogContent,
        dialogContent,
        cancelBtnText,
        acceptBtnText,
        dialogRadius,
        barrierDismissible)
        .then((value) {
      print(value);
    });
    BluetoothEnable.enableBluetooth.then((value) {
      print(value);
    });
  }



  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            alignment: Alignment.centerRight,
            width: 60,
            child: Container(
                child: Semantics(
                  label: 'Back',
                  child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios,color: Colors.black,)
                  ),
                )
            ),
          ),

          backgroundColor: Colors.transparent, // Set the background color to transparent
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], // Set your gradient colors
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: screenHeight+250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicWidth(
                  child: Container(
                    height: 22,
                    margin: EdgeInsets.only(top: 20,left: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xff0f98B5),Color(0xff872DE1)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(margin: EdgeInsets.only(left: 8,right: 8),child: Icon(Icons.school_outlined,color: Colors.white,size: 17,)),
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Text(
                            widget.venueCategory??"No category",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xffffffff),
                              height: 18/12,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                IntrinsicHeight(
                  child: Container(
                    margin: EdgeInsets.only(top: 6,left: 16),
                    child: Text(
                      widget.venueTitle??"",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16,top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined,size: 15,color: Color(0xff8D8C8C),),
                      SizedBox(width: 8,),
                      Container(
                        child: Text(
                          truncateString(makeAddress(widget.venueAddress.toString()) ?? "",25),
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff8d8c8c),
                            height: 20/14,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 3, // Set the maximum number of lines
                          overflow: TextOverflow.ellipsis, // Display '...' when overflowed
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(top: 6,left:16,right: 16),
                    child: Text(
                      widget.venueDescription??"",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff000000),
                        height: 24/18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 32,left:16),
                  child: Text(
                    "Buildings",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(

                  height: 225,


                  child: ValueListenableBuilder(
                    valueListenable: Hive.box("Favourites").listenable(),
                    builder: (BuildContext context, Box<dynamic> value, Widget? child) {
                      return ListView.builder(
                        scrollDirection:Axis.horizontal ,
                        itemBuilder: (context,index){
                          currentData = widget.receivedAllBuildingList![index];
                          currentData.geofencing;

                          final isFavourite = value.get(currentData.buildingName)!=null;
                          return Container(
                            width: 208,

                            child: Container(

                              child: ListTile(


                                onTap: (){
                                 // if((widget.currentLatLng!.latitude.toStringAsFixed(2)==(28.54343736711034).toStringAsFixed(2) && widget.currentLatLng!.longitude.toStringAsFixed(2)==(77.18752205371858).toStringAsFixed(2)) ){
                                    wsocket.message["AppInitialization"]["BID"]=widget.receivedAllBuildingList![index].sId!;
                                    wsocket.message["AppInitialization"]["buildingName"]=widget.receivedAllBuildingList![index].buildingName!;


                                    buildingAllApi.setStoredString(widget.receivedAllBuildingList![index].sId!);
                                    buildingAllApi.setSelectedBuildingID(widget.receivedAllBuildingList![index].sId!);
                                    buildingAllApi.setStoredAllBuildingID(allBuildingID);
                                    // while({
                                    //
                                    // }
                                    // while(!bluetoohEnabled){
                                    //
                                    // }
                                    //customEnableBT(context);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>   Navigation(),
                                      ),
                                    );
                                // }else{
                                //     if(widget.dist==0 && currentData.geofencing!=false){
                                //       wsocket.message["AppInitialization"]["BID"]=widget.receivedAllBuildingList![index].sId!;
                                //       wsocket.message["AppInitialization"]["buildingName"]=widget.receivedAllBuildingList![index].buildingName!;
                                //       buildingAllApi.setStoredString(widget.receivedAllBuildingList![index].sId!);
                                //       buildingAllApi.setSelectedBuildingID(widget.receivedAllBuildingList![index].sId!);
                                //       buildingAllApi.setStoredAllBuildingID(allBuildingID);
                                //       Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) =>   Navigation(),
                                //         ),
                                //       );
                                //     }else{
                                //       HelperClass.showToast("Not your current venue");
                                //     }
                                //
                                //  }

                                },
                                title: Container(

                                  decoration: BoxDecoration(
                                      color:  ((widget.currentLatLng!.latitude.toStringAsFixed(2)==(28.54343736711034).toStringAsFixed(2) && widget.currentLatLng!.longitude.toStringAsFixed(2)==(77.18752205371858).toStringAsFixed(2)) || widget.dist==0)?Colors.white:Colors.black.withOpacity(0.2),
                                      border: Border.all(
                                        color: Color(0xffEBEBEB),
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(8))
                                  ),
                                  child: Column(
                                    children: [
                                      Container(

                                        width: 208,
                                        height: 117,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8),bottomLeft:Radius.circular(8),bottomRight: Radius.circular(8) ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8),bottomLeft:Radius.circular(8),bottomRight: Radius.circular(8)),
                                          child: Image.network(
                                            // "https://dev.iwayplus.in/uploads/${widget.imageURL}",
                                            "https://dev.iwayplus.in/uploads/${currentData.venuePhoto}",
                                            // You can replace the placeholder image URL with your default image URL
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/default-image.jpg', // Replace with the path to your default image asset
                                                fit: BoxFit.fill,
                                              );
                                            },
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(top: 10,left: 8),
                                          child: Text(
                                            HelperClass.truncateString(currentData.buildingName!,20),
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff0c141c),
                                              height: 25/16,
                                            ),
                                            textAlign: TextAlign.left,
                                          )
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(left: 8,top: 10),
                                              child: Text(
                                                currentData.venueCategory??"",
                                                style: const TextStyle(
                                                  fontFamily: "Roboto",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff4a4545),
                                                  height: 20/14,
                                                ),
                                                textAlign: TextAlign.left,
                                              )
                                          ),
                                          Spacer(),
                                          IconButton(
                                            icon: Semantics(
                                              label: 'Favourite',
                                              child: isFavourite? Icon( Icons.favorite,size: 24,color: Colors.red,) :
                                              Icon(Icons.favorite_border,size: 24,color: Colors.black26,),
                                            ),
                                            onPressed: () async{
                                              if(isFavourite){
                                                await value.delete(currentData.buildingName);
                                              }else {
                                                await value.put(
                                                    currentData.buildingName,
                                                    currentData.buildingName);
                                              }// Add your favorite button onPressed logic here
                                              //log('Favouties Database Size ${value.length}');
                                            },
                                          )
                                        ],
                                      ),


                                      // SizedBox(width: screenWidth/3.2,),

                                      Padding(
                                        padding: const EdgeInsets.only(right: 130),
                                        child: Container(height: 10,width: 10,decoration: BoxDecoration(color: (currentData.geofencing)?Colors.green:Colors.red,borderRadius: BorderRadius.circular(20)),),
                                      )
                                    ],
                                  ),
                                ),
                                // Container(
                                //   decoration: BoxDecoration(
                                //       border: Border.all(
                                //         color: Color(0xffEBEBEB),
                                //       ),
                                //       borderRadius: BorderRadius.all(Radius.circular(8))
                                //   ),
                                //   child: Column(
                                //     children: [
                                //       Container(
                                //         width: 188,
                                //         height: 117,
                                //         padding: EdgeInsets.all(5),
                                //         decoration: BoxDecoration(
                                //           borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8),bottomLeft:Radius.circular(8),bottomRight: Radius.circular(8) ),
                                //         ),
                                //         child: ClipRRect(
                                //           borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8),bottomLeft:Radius.circular(8),bottomRight: Radius.circular(8)),
                                //           child: Image.network(
                                //             // "https://dev.iwayplus.in/uploads/${widget.imageURL}",
                                //             "https://dev.iwayplus.in/uploads/${currentData.venuePhoto}",
                                //             // You can replace the placeholder image URL with your default image URL
                                //             errorBuilder: (context, error, stackTrace) {
                                //               return Image.asset(
                                //                 'assets/default-image.jpg', // Replace with the path to your default image asset
                                //                 fit: BoxFit.fill,
                                //               );
                                //             },
                                //             fit: BoxFit.fill,
                                //           ),
                                //         ),
                                //       ),
                                //       Container(
                                //           alignment: Alignment.topLeft,
                                //           margin: EdgeInsets.only(top: 0,left: 8),
                                //           child: Text(
                                //             HelperClass.truncateString(currentData.buildingName!,20),
                                //             style: const TextStyle(
                                //               fontFamily: "Roboto",
                                //               fontSize: 16,
                                //               fontWeight: FontWeight.w400,
                                //               color: Color(0xff0c141c),
                                //               height: 25/16,
                                //             ),
                                //             textAlign: TextAlign.left,
                                //           )
                                //       ),
                                //       Row(
                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                //         children: [
                                //           Container(
                                //               margin: EdgeInsets.only(left: 8,top: 10),
                                //               child: Text(
                                //                 currentData.venueCategory??"",
                                //                 style: const TextStyle(
                                //                   fontFamily: "Roboto",
                                //                   fontSize: 14,
                                //                   fontWeight: FontWeight.w400,
                                //                   color: Color(0xff4a4545),
                                //                   height: 20/14,
                                //                 ),
                                //                 textAlign: TextAlign.left,
                                //               )
                                //           ),
                                //           Spacer(),
                                //           IconButton(
                                //             icon: Semantics(
                                //               label: 'Favourite',
                                //               child: Icon(
                                //                 isFavourite? Icons.favorite:
                                //                 Icons.favorite_border,size: 24,color: Colors.red,),
                                //             ),
                                //             onPressed: () async{
                                //               if(isFavourite){
                                //                 await value.delete(currentData.buildingName);
                                //               }else {
                                //                 await value.put(
                                //                     currentData.buildingName,
                                //                     currentData.buildingName);
                                //               }// Add your favorite button onPressed logic here
                                //               log('Favouties Database Size ${value.length}');
                                //             },
                                //           )
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),

                              ),
                            ),
                          );
                          //   InsideBuildingCard(
                          //   buildingImageURL: currentData.venuePhoto?? "",
                          //   buildingName: currentData.buildingName?? "",
                          //   buildingTag: currentData.venueCategory?? "",
                          //   buildingId: currentData.sId??"",
                          //   buildingFavourite: false, allBuildingID: allBuildingID,
                          // );
                        },
                        itemCount:widget.receivedAllBuildingList!.length,
                      );
                    },

                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 32,left:16),
                  child: Text(
                    "Venue Information",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                      height: 24/18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                widget.venueAddress != null ?Container(
                  margin: EdgeInsets.only(left: 12,top:16 ,right: 12),
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenueLocationIconsvg.svg",width: 40),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 12),
                          child: Text(
                            widget.venueAddress?.trim()??"",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff4a789c),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ):Container(),
                widget.venuePhone != null ?Container(
                  margin: EdgeInsets.only(left: 12,top:12),
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenuePhoneIcon.svg",width: 40),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 12),
                          child: Text(
                            widget.venuePhone??"",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff4a789c),
                              height: 20/14,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ):Container(),
                widget.venueWebsite != null ?Container(
                  margin: EdgeInsets.only(left: 12,top:12),
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenueLinkIcon.svg",width: 40),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 12),
                          child: Text(
                            widget.venueWebsite??"",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff4a789c),
                              height: 20/14,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ):Container(),
                Container(
                  margin: EdgeInsets.only(left: 12,top:12),
                  alignment: Alignment.centerLeft,
                  width: screenWidth,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        child: SvgPicture.asset("assets/BuildingInfoScreen_VenueLinkIcon.svg",width: 40),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 12),
                        child: Column(
                          children: [
                            Container(
                              child: Text(
                                "Opening Hours: Monday to Saturday",
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff4a789c),
                                  height: 20/14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            // Container(
                            //   alignment: Alignment.bottomLeft,
                            //   child: Text(
                            //     "9:00 Am - 05:00 Pm",
                            //     style: const TextStyle(
                            //       fontFamily: "Roboto",
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w400,
                            //       color: Color(0xff4a789c),
                            //       height: 20/14,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: (){
                  buildingAllApi.setStoredString(currentData.sId!);
                  buildingAllApi.setSelectedBuildingID(currentData.sId!);
                  buildingAllApi.setStoredAllBuildingID(allBuildingID);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>   Navigation(directLandID: "0a8bdc2-b0b2-662a-ae5-bff7bff350c0",),
                    ),
                  );
                }, icon: Icon(Icons.accessibility_outlined),)
                // Flexible(
                //   child: Container(
                //     child: Text(
                //       'This text will determine the height of thedsvvfzvsvszdvs row item',
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),


      ),
    );
  }


}
