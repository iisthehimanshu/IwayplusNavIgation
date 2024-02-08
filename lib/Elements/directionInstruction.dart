import 'package:flutter/material.dart';

class directionInstruction extends StatefulWidget {
  String direction;
  String distance;
  directionInstruction({required this.direction, required this.distance});

  @override
  State<directionInstruction> createState() => _directionInstructionState();
}

class _directionInstructionState extends State<directionInstruction> {
  Icon icon = Icon(Icons.directions);
  String distance  = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      icon = getCustomIcon(widget.direction);
    });
  }

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          height: 45,
          margin: EdgeInsets.only(top: 8),
          child:Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.direction,
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff0e0d0d),
                      height: 25/16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "${widget.distance} m",
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
              Spacer(),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
                child: icon
              )
            ],
          ),
        ),
        SizedBox(height: 9,),
        Container(
          width: screenWidth,
          height: 1,
          color: Color(0xffEBEBEB),
        )
      ],
    );
  }
}
