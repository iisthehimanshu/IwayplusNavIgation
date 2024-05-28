import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class directionInstruction extends StatefulWidget {
  String direction;
  String distance;
  directionInstruction({required this.direction, required this.distance});

  @override
  State<directionInstruction> createState() => _directionInstructionState();
}

class _directionInstructionState extends State<directionInstruction> {
  Widget icon = Icon(Icons.directions);
  String distance = "";
  @override
  void initState() {

    super.initState();
    setState(() {
      icon = getCustomIcon(widget.direction);
    });
  }

  Widget getCustomIcon(String direction) {
    if (direction == "Go Straight") {
      return Icon(
        Icons.straight,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Slight Right")) {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Sharp Right")) {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Right")) {
      return Icon(
        Icons.turn_right,
        color: Colors.black,
        size: 32,
      );
    }  else if (direction.contains("U Turn")) {
      return Icon(
        Icons.u_turn_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Sharp Left")) {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Slight Left")) {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.black,
        size: 32,
      );

    } else if (direction.contains("Left")) {
      return Icon(
        Icons.turn_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Lift")) {
      return Padding(
        padding: const EdgeInsets.all(3.5),
        child: SvgPicture.asset("assets/elevator.svg"),
      );
    }
    // else if(direction.substring(0,4)=="Take"){
    //   return Icon(
    //     Icons.abc,
    //     color: Colors.black,
    //     size: 32,
    //   );
    // }

    else {
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
          width: screenWidth,
          margin: EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  label: widget.direction + "${widget.distance} m",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          widget.direction,
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff0e0d0d),
                            height: 25 / 16,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      ExcludeSemantics(
                        child: Text(
                          (widget.direction.substring(0,4)=="Take")? "${widget.distance}" :"${widget.distance} m",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff8d8c8c),
                            height: 20 / 14,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: icon)
            ],
          ),
        ),
        SizedBox(
          height: 9,
        ),
        Container(
          width: screenWidth,
          height: 1,
          color: Color(0xffEBEBEB),
        )
      ],
    );
  }
}
