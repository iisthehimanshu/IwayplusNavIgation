import 'package:flutter/material.dart';

class DebugToggle extends StatefulWidget {
  static bool Slider = false;
  static bool StepButton = false;
  static bool PDRIcon = false;
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
