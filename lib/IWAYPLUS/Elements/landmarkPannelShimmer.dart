import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class landmarkPannelShimmer extends StatefulWidget {
  landmarkPannelShimmer();

  @override
  State<landmarkPannelShimmer> createState() => _landmarkPannelShimmerState();
}

class _landmarkPannelShimmerState extends State<landmarkPannelShimmer> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only( left : 17,top: 26,right: 17),
      width: screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.only(bottom:5),
              child: Skelton(
                height: 25,
                width: 90,
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.only(bottom:5),
              child: Skelton(
                width: 318,
                height: 25,
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.only(bottom:20),
              child: Skelton(
                width: 108,
                height: 40,
              ),
            ),
          ),
          Container(
            height: 1,
            width: screenWidth,
            color: Color(0xffebebeb),
            margin: EdgeInsets.only(bottom:20),
          ),
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.only(bottom:15),
              child: Skelton(
                width: 95,
                height: 24,
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.only(bottom:20),
              child: Skelton(
                width: 272,
                height: 25,
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.only(bottom:20),
              child: Skelton(
                width: 272,
                height: 25,
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.only(bottom:20),
              child: Skelton(
                width: 272,
                height: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class Skelton extends StatelessWidget{
  const Skelton({
    Key? key, this.height, this.width,
  }): super(key: key);

  final double? height, width;

  @override
  Widget build(BuildContext context){
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.07),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
    );
  }
}

