import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/low_fedility/routePreview.dart';

import '../APIMODELS/landmark.dart';
import '../navigationTools.dart';
import 'homepage.dart';

class SearchresultWithoutAddress extends StatelessWidget {
  Landmarks Location;
  Landmarks? MyLocation;
  bool invert;
  SearchresultWithoutAddress(this.MyLocation,
      {super.key, required this.Location, this.invert = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: (){
          Homepage.homePageKey.currentState?.getDirection(Location);
          //Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.only(left: 13, right: 13, top: 8.5, bottom: 8.5),
          padding: EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
          decoration: ShapeDecoration(
            color: invert ? Colors.white : Color(0xff003366),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  width: 1, color: invert ? Color(0xFFDDDBDB) : Color(0xff003366)),
            ),
          ),
          height: 86,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: invert ? Color(0xff003366) : Colors.white, // White color
                  shape: BoxShape.circle, // Circular shape
                ),
                child: Icon(
                  getIcon(Location.element!.subType ?? ""),
                  color: invert ? Colors.white : Color(0xff003366),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${Location!.name}',
                    style: TextStyle(
                      color: invert ? Color(0xff003366) : Color(0xFFF5F5F5),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                    ),
                  ),
                  MyLocation != null
                      ? Text(
                          '${(tools.calculateDistance([
                                    MyLocation!.coordinateX!,
                                    MyLocation!.coordinateY!
                                  ], [
                                    Location.coordinateX!,
                                    Location.coordinateY!
                                  ]) * 0.3048).ceil()}m',
                          style: TextStyle(
                            color: invert ? Colors.black : Color(0xFFF5F5F5),
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : Container(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SearchresultWithAddress extends StatelessWidget {
  Landmarks Location;
  Landmarks? MyLocation;
  SearchresultWithAddress(this.MyLocation, {super.key, required this.Location});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Homepage.homePageKey.currentState?.getDirection(Location);
          Navigator.pop(context);
        },
        child: Container(
          margin:
              const EdgeInsets.only(left: 13, right: 13, top: 8.5, bottom: 8.5),
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: Color(0xFFDDDBDB)),
            ),
          ),
          height: 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xff003366), // White color
                  shape: BoxShape.circle, // Circular shape
                ),
                child: Icon(
                  getIcon(Location.element!.subType ?? ""),
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${Location!.name}',
                      style: const TextStyle(
                        color: Color(0xFF003366),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 1.20,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Floor ${Location!.floor}, ${Location.buildingName}',
                        style: const TextStyle(
                          color: Color(0xFF515151),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AmmenityResult extends StatelessWidget {
  List<Landmarks> Location;
  Landmarks? MyLocation;
  Map<String, List<Landmarks>> landmarkGroups = {};
  AmmenityResult(this.MyLocation, {super.key, required this.Location}) {
    landmarkGroups = groupLandmarksByBuilding(Location);
  }

  String getAlternativeName(String? input) {
    Map<String, String> alternatives = {
      "restRoom": "Washroom",
      "Cafeteria": "Food Court",
      "main entry": "Main Gate",
      "Help Desk | Reception": "Information Desk",
      "lift": "Elevator",
      "ATM": "Cash Machine",
      "Drinking Water": "Water Dispenser",
    };

    return alternatives[input] ?? "Amenity";
  }

  Map<String, List<Landmarks>> groupLandmarksByBuilding(
      List<Landmarks> locations) {
    Map<String, List<Landmarks>> buildingMap = {};

    for (var landmark in locations) {
      buildingMap.putIfAbsent(landmark.buildingName!, () => []);
      buildingMap[landmark.buildingName]!.add(landmark);
    }

    return buildingMap;
  }

  void resultOnTap(BuildContext context){
    if(landmarkGroups.keys.length == 1){
      Homepage.homePageKey.currentState?.getDirection(landmarkGroups.values.toList()[0].first);
      Navigator.of(context).popUntil((route) => route.settings.name == 'targetScreen');
      Navigator.pop(context);
    }else{
      showCustomDialog(context);
    }
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 387,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xffE7F0F9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                      Text(
                        'Choose Building',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          backgroundColor: Color(0xFFFFD700),
                          shape: const CircleBorder(),
                        ),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(
                              Icons.mic_none,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12,),
                SizedBox(
                  height: min((landmarkGroups.keys.length * 48).toDouble()+70, 300),
                  child: ListView.builder(
                    shrinkWrap: true, // Helps avoid layout issues
                    itemCount: landmarkGroups.keys.length,
                    itemBuilder: (context, index) {
                      return BuildingButton(
                        buildingName: landmarkGroups.keys.toList()[index], landmarks: landmarkGroups.values.toList()[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          resultOnTap(context);
        },
        child: Container(
          margin:
              const EdgeInsets.only(left: 13, right: 13, top: 8.5, bottom: 8.5),
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
          color: Color(0xff003366),
          height: 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white, // White color
                  shape: BoxShape.circle, // Circular shape
                ),
                child: Icon(
                  getIcon(Location.first.element!.subType ?? ""),
                  color: Color(0xff003366),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${getAlternativeName(Location.first.element!.subType)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 1.20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData getIcon(String option) {
  print("option $option");
  switch (option) {
    case 'restRoom':
      return Icons.wash_sharp;
    case 'Cafeteria':
      return Icons.local_cafe;
    case 'Drinking Water':
      return Icons.water_drop;
    case 'ATM':
      return Icons.atm_sharp;
    case 'main entry':
      return Icons.door_front_door_outlined;
    case 'lift':
      return Icons.elevator;
    case 'Help Desk | Reception':
      return Icons.desk_sharp;
    default:
      return Icons
          .pin_drop_rounded; // Return a default icon if no match is found
  }
}

class BuildingButton extends StatelessWidget {
  String buildingName;
  List<Landmarks> landmarks;
  BuildingButton({super.key, required this.buildingName, required this.landmarks});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Homepage.homePageKey.currentState?.getDirection(landmarks.first);
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: Container(
        height: 48,
        margin: EdgeInsets.only(left: 12,right: 12, top: 8, bottom: 8),
        padding: EdgeInsets.only(left: 10,right: 10,top: 13,bottom: 13),
        color: Color(0xff003366),
        child: Center(
          child: Text(
            buildingName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.20,
            ),
          ),
        ),
      ),
    );
  }
}

