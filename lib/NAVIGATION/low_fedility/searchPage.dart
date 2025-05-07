import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'fuzzySearch.dart';

class Searchpage extends StatefulWidget {
  String? query;
  Searchpage({super.key, this.query});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    computeQuery();
  }

  Future<void> listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('StatusHimanshu: $status');
          if (status == 'done') {
            print('Status: $status');
            _isListening = false;
            search(_controller.text);
          }
        },
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        _isListening = true;
        _speech.listen(
          onResult: (result) {
            _controller.text = result.recognizedWords;
          },
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
    }
  }

  void computeQuery(){
    if(widget.query != null && widget.query!.isNotEmpty){
      _controller.text = widget.query!;
      search(widget.query!);
    }
  }

  Future<void> search(String query) async {
    fuzzyResults = await fuzzySearch(query);
    setState(() {});
  }

  List<Widget> fuzzyResults = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Material(
              color: Colors.transparent, // Prevents Material effects from showing
              child: Container(
                padding: EdgeInsets.only(top: 2.5,bottom: 2.5,right: 2.5),
                margin: EdgeInsets.only(left: 13,right: 13, bottom: 24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color(0xffDEDBDB), // Set the border color to grey
                      width: 2,            // Set the width of the border
                    )
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: Colors.white),
                        child:Icon(
                          Icons.arrow_back,size: 24,color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 16,right: 16),
                        child:TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: "Search Destination",
                            border: InputBorder.none,
                          ),
                          onSubmitted:(query) async {
                            search(query);
                          },
                        ),
                      ),
                    ),
                    _controller.text.isEmpty?Row(
                      children: [
                        InkWell(
                          onTap: (){},
                          child: Container(
                            width: 48,
                            height: 48,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(color: Colors.white),
                            child:Icon(
                              Icons.qr_code_scanner_sharp,size: 24,color: Color(0xff515151),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            listen();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(color: Colors.white),
                            child:Icon(
                              Icons.mic_none_outlined,size: 24,color: Color(0xff515151),
                            ),
                          ),
                        )
                      ],
                    ):InkWell(
                      onTap: (){
                        setState(() {
                          _controller.clear();
                          fuzzyResults.clear();
                        });
                        _focusNode.requestFocus();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: Colors.white),
                        child:Icon(
                          Icons.close,size: 24,color: Color(0xff515151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _controller.text.isNotEmpty && fuzzyResults.isEmpty?Noresult():Expanded(
              child: ListView.builder(
                itemCount: fuzzyResults.length,
                itemBuilder: (context, index) {
                  return fuzzyResults[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Noresult extends StatelessWidget {
  const Noresult({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 35),
        height: 60,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'No search result found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                height: 1.20,
              ),
            ),
            Text(
              'Try  Searching for something else',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            )
          ],
        ),
      ),
    );
  }
}


