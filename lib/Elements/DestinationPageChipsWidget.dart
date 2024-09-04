import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../DestinationSearchPage.dart';
import '../SourceAndDestinationPage.dart';

class DestinationPageChipsWidget extends StatefulWidget {
  final String svgPath;
  final String text;
  bool selected;
  final Function(bool selected) onSelect;
  final Function(String Text) onTap;



  DestinationPageChipsWidget({
    required this.svgPath,
    required this.text,
    this.selected = false,
    required this.onSelect,
    required this.onTap,
  });

  @override
  _DestinationPageChipsWidgetState createState() => _DestinationPageChipsWidgetState();
}

class _DestinationPageChipsWidgetState extends State<DestinationPageChipsWidget> {


  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.text + (widget.selected?"selected":""),
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
        padding: EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 2), // Offset of the shadow
              blurRadius: 4, // Spread of the shadow
            ),
          ],
        ),
        duration: Duration(milliseconds: 600),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(10.0)), // Updated borderRadius
          onTap: () {
            setState(() {
              widget.selected = !widget.selected;
            });
            widget.onTap(widget.text);
            widget.onSelect(widget.selected);
            widget.selected ? print("black") : print("white");
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => DestinationSearchPage(previousFilter: widget.text,))
            // );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 4),
                child: Icon(Icons.wallet_giftcard_outlined, size: 18, color: widget.selected? Colors.white: Colors.black,),
              ),
              Semantics(
                excludeSemantics: true,
                child: Container(
                  margin: EdgeInsets.only(left: 8, right: 4),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.selected? Colors.white : Color(0xff49454f) ,
                      height: 20 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              widget.selected? InkWell(
                onTap: (){
                  setState(() {
                    widget.selected=!widget.selected;
                    widget.onTap("");
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 4),
                  child: Icon(Icons.close, size: 18, color: widget.selected? Colors.white: Colors.black,),
                ),
              ) : Container()


              // Icon displayed when active is true
            ],
          ),
        ),
      ),
    );
  }
}
