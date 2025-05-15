
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandmarkInfoScreen extends StatelessWidget{
  const LandmarkInfoScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20), // Add this line
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("3A - 2B Iwayplus",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xff292929),
                height: 25 / 18,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 10),
            const Text("Floor 3, Research And Innovation Park",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xff292929),
                height: 25 / 18,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 5),
            const Text("IIT Delhi",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xff292929),
                height: 25 / 18,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 20,),
            // Container(
            //   width: 375,
            //   child: CupertinoButton(
            //     onPressed: null,
            //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     borderRadius: BorderRadius.only(
            //       topRight: Radius.circular(20),
            //       topLeft: Radius.circular(20),
            //       bottomLeft: Radius.circular(20),
            //       bottomRight: Radius.circular(20),
            //     ),              color: Colors.transparent, // No fill color
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(CupertinoIcons.location, color: Colors.black),
            //         SizedBox(width: 8),
            //         Text(
            //           "Direction",
            //           style: TextStyle(color: Colors.black),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Container(
              width: double.infinity, // Full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black26, width: 1),
                color: Colors.black12,
              ),

              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                onPressed: () {
                  // Your action here
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.location, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      "Direction",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),


            // SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }

}
