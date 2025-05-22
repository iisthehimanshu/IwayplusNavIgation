import 'package:flutter/material.dart';

import '../IWAYPLUS/Elements/HelperClass.dart';

class direcToMobile extends StatelessWidget {
  const direcToMobile({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      height: 45,
        decoration: BoxDecoration(
          color: Colors.white,  // Container color
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),  // Shadow color
              spreadRadius: 2,  // Shadow spread
              blurRadius: 10,  // Shadow blur
            ),
          ],
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 8,),
          Container(
            height: 24,
              width: 24,
              child: Image.asset("assets/AppIcon.png")),
          SizedBox(width: 8,),
          Text("Iwayplus",
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xff000000),
                height: 25 / 16,
              )),
          Spacer(),
          ElevatedButton(onPressed: (){
            HelperClass.launchURL('');
            // HelperClass.openMobileApp();
          }, child: Text("Agenda",style: const TextStyle(
            color: Colors.white,
          )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              )),
          SizedBox(width:10),
          ElevatedButton(onPressed: (){
            HelperClass.openMobileApp();
          }, child: Text("Open App",style: const TextStyle(
            color: Colors.white,
          )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              ))
        ],
      ),
    );
  }
}
