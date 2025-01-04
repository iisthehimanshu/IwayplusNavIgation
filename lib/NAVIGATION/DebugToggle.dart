import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugToggle extends StatefulWidget {
  //always change only the first boolean value only
  static bool Slider = kDebugMode?false:false;
  static bool StepButton = kDebugMode?true:false;
  static bool PDRIcon = kDebugMode?false:false;
  const DebugToggle({super.key});

  @override
  State<DebugToggle> createState() => _DebugToggleState();
}

class _DebugToggleState extends State<DebugToggle> {
  bool Slider = true;
  bool StepButton = true;
  bool PDRIcon = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Direction Slider"),
                  Switch(value: Slider, onChanged: (value){
                    setState(() {
                      Slider = value;
                      DebugToggle.Slider = value;
                    });
                  })
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Step Button"),
                  Switch(value: StepButton, onChanged: (value){
                    setState(() {
                      StepButton = value;
                      DebugToggle.StepButton = value;
                    });
                  })
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("PDRIcon"),
                  Switch(value: PDRIcon, onChanged: (value){
                    setState(() {
                      PDRIcon = value;
                      DebugToggle.PDRIcon = value;
                    });
                  })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
