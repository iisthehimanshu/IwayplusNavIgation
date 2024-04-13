import 'package:flutter/material.dart';

class DirectionHeader extends StatelessWidget {
  final String direction;
  final int distance;

  DirectionHeader({required this.direction, required this.distance});


  Icon getCustomIcon(String direction) {
    if(direction == "Go Straight"){
      return Icon(
        Icons.straight,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Slight Right, and Go Straight"){
      return Icon(
        Icons.turn_slight_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Right, and Go Straight"){
      return Icon(
        Icons.turn_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Sharp Right, and Go Straight"){
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn U Turn, and Go Straight"){
      return Icon(
        Icons.u_turn_right,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Sharp Left, and Go Straight"){
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Left, and Go Straight"){
      return Icon(
        Icons.turn_left,
        color: Colors.black,
        size: 32,
      );
    }else if(direction == "Turn Slight Left, and Go Straight"){
      return Icon(
        Icons.turn_slight_left,
        color: Colors.black,
        size: 32,
      );
    }else{
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.black,
        size: 32,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
      height: 95,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xff01544F),
        border: Border.all(
          color: Color(0xff01544F),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    direction,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,

                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(

                    '${distance} m',
                    style: TextStyle(

                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,

                    ),
                  ),

                ],
              ),

              Spacer(),
              Container(

                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(28.0),
                  ),

                  child: getCustomIcon(direction)),

            ],
          ),


        ],
      ),
    );
  }
}