import 'package:flutter/material.dart';

import 'Elements/SearchpageResults.dart';
class DestinationSearchPage extends StatefulWidget {
  const DestinationSearchPage({super.key});

  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 16),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  width: screenWidth - 32,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white, // You can customize the border color
                      width: 1.0, // You can customize the border width
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 48,
                        margin: EdgeInsets.only(right: 4),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: TextFormField(
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: "Search"
                              ),
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff000000),
                                height: 25/16,
                              ),
                            )),
                      ),
                      Container(
                        width: 40,
                        height: 48,
                        child: Center(
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.mic_none_sharp,
                              color: Color(0xff8E8C8C),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 48,
                        margin: EdgeInsets.only(right: 7),
                        child: Center(
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.qr_code_scanner_sharp,
                              color: Color(0xff8E8C8C),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 16,
              ),
              Container(
                width: screenWidth,
                height: 1,
                color: Color(0xffB3B3B3),
              ),
              SearchpageResults(name: 'S', location: 'H',)
            ],
          ),
        ),
      ),
    );
  }
}
