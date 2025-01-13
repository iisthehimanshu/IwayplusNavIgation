import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../APIMODELS/landmark.dart';

class pinLandmark extends StatefulWidget {
  final Function(MarkerId) update;
  final Function() localize;
  final Map<MarkerId, Marker> nearbyLandmarks;
  Landmarks? pinedLandmark;

  pinLandmark({
    required this.update,
    required this.nearbyLandmarks,
    required this.pinedLandmark,
    required this.localize,
    Key? key,
  }) : super(key: key);

  @override
  _pinLandmarkState createState() => _pinLandmarkState();
}

class _pinLandmarkState extends State<pinLandmark> {
  late FixedExtentScrollController _controller;
  int selectedindex = 0;

  @override
  void initState() {
    super.initState();
    if(widget.pinedLandmark != null){
      int index = widget.nearbyLandmarks.keys.toList().indexWhere((id)=>id.value==widget.pinedLandmark!.sId);
      _controller = FixedExtentScrollController(initialItem: index);
    }else{
      _controller = FixedExtentScrollController(initialItem: 0);
    }
  }

  Landmarks? _previousPinedLandmark;

  @override
  void didUpdateWidget(covariant pinLandmark oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if pinedLandmark has changed
    if (widget.pinedLandmark != oldWidget.pinedLandmark) {
      _previousPinedLandmark = oldWidget.pinedLandmark;
      _onPinedLandmarkChanged();
    }
  }

  void _onPinedLandmarkChanged() {
    if(widget.pinedLandmark != null){
      int index = widget.nearbyLandmarks.keys.toList().indexWhere((id)=>id.value==widget.pinedLandmark!.sId);
      if(selectedindex != index){
        selectedindex = index;
        setPickerIndex(selectedindex);
      }
    }
  }

  void setPickerIndex(int index) {
    // Dynamically change the selected index
    _controller.animateToItem(
      index,
      duration: Duration(milliseconds: 200), // Animation duration
      curve: Curves.easeInOut, // Animation curve
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Semantics(
          label: "Confirm Your Location Amongst Below Given List",
          readOnly: true,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ExcludeSemantics(
              child: Text(
                "Confirm Your Location",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff000000),
                  height: 24 / 18,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 2,
          width: screenWidth,
          color: Color(0xff24B9B0),
        ),
        SizedBox(height: 12,),
        Container(
          height: 100, // Adjust the height of the CupertinoPicker
          child: CupertinoPicker(
            scrollController: _controller,
            looping: false,
            itemExtent: 40, // Height for each item
            onSelectedItemChanged: (index) {
              if(selectedindex != index){
                print("changing index $selectedindex");
                selectedindex = index;
                widget.update(widget.nearbyLandmarks.keys.toList()[selectedindex]);
              }
            },
            children:

            widget.nearbyLandmarks.values
                .where((marker) => marker.markerId.value.split('#')[1] == "true")
                .map((marker) => Center(
              child: Text(marker.markerId.value.split('#').first),
            ))
                .toList()

            ,
          ),
        ),
        Spacer(),
        SizedBox(
          width: screenWidth,
          child: Container(
            margin: EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () {
                widget.localize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Corner radius
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16), // Optional padding
              ),
              child: Text(
                "Confirm Location",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 24 / 18,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
