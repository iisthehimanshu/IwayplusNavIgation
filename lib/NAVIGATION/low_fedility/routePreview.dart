import 'package:flutter/material.dart';

class Routepreview extends StatefulWidget {
  const Routepreview({super.key});

  @override
  State<Routepreview> createState() => _RoutepreviewState();
}

class _RoutepreviewState extends State<Routepreview> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 130,
          color: Colors.white,
          child: Container(
            margin: EdgeInsets.only(top: 16, right: 16),
            child: Column(
              children: [
                SizedBox(height: 7,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Semantics(
                            label: "Back",
                            child: Icon(
                              Icons.arrow_back,
                              size: 24,
                            ),
                          )),
                    ),
                    Expanded(
                      child: Semantics(
                        excludeSemantics: true,
                        child: Column(
                          children: [
                            Semantics(
                              label: 'Source Name',
                              header: true,
                              child: InkWell(
                                child: Container(
                                  height: 56,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Color(0xffE2E2E2)),
                                  ),
                                  padding: EdgeInsets.only(left: 12, right: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "PathState.sourceName",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                            Semantics(
                              label:"destination name",
                              header: true,
                              child: InkWell(
                                child: Container(
                                  height: 56,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Color(0xffE2E2E2)),
                                  ),
                                  padding:
                                  EdgeInsets.only(left: 12, right: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "PathState.destinationName",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
