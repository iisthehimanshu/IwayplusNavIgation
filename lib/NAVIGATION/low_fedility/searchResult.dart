import 'package:flutter/material.dart';

import '../APIMODELS/landmark.dart';
import '../navigationTools.dart';

class Searchresult extends StatelessWidget {
  Landmarks Location;
  Landmarks? MyLocation;
  Searchresult(this.MyLocation, {super.key, required this.Location});

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
        return Icons.pin_drop_rounded; // Return a default icon if no match is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 13,right: 13,top: 8.5,bottom: 8.5),
      padding: EdgeInsets.only(left: 16,right: 16,top: 15,bottom: 15),
      color: Color(0xff003366),
      height: 84,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,  // White color
              shape: BoxShape.circle,  // Circular shape
            ),
            child: Icon(getIcon(Location.element!.subType??"")),
          ),
          SizedBox(width: 16,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Location!.name}',
                style: TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  height: 1.20,
                ),
              ),
              MyLocation!=null?Text(
                '${(tools.calculateDistance([MyLocation!.coordinateX!,MyLocation!.coordinateY!], [Location.coordinateX!,Location.coordinateY!])*0.3048).ceil()}m',
                style: TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ):Container(),
            ],
          )

        ],
      ),
    );
  }
}
