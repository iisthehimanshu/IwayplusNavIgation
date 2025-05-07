import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/low_fedility/searchPage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class homePageSearchBar extends StatefulWidget {
  homePageSearchBar({super.key});

  @override
  State<homePageSearchBar> createState() => _homePageSearchBarState();
}

class _homePageSearchBarState extends State<homePageSearchBar> {
  TextEditingController _controller = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;

  Future<void> listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('StatusHimanshu: $status');
          if (status == 'done') {
            print('Status: $status');
            _isListening = false;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Searchpage(query: _controller.text,),
              ),
            ).then((value){
              _controller.clear();
            });
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 2.5,bottom: 2.5,right: 2.5),
      margin: EdgeInsets.only(left: 13,right: 13, bottom: 24),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFDDDBDB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16,right: 16),
              child:TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Search Destination",
                  border: InputBorder.none,
                ),
                onSubmitted: (query){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Searchpage(query: query,),
                    ),
                  ).then((value){
                    _controller.clear();
                  });
                },
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
              decoration: BoxDecoration(color: Color(0xFFFFD700)),
              child:Icon(
                Icons.mic_none_outlined,size: 32,color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
