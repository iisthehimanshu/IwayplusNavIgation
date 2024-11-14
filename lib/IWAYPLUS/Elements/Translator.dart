
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:translator/translator.dart';

class TranslatorWidget extends StatefulWidget {
  final String text;
  final String color;
  final String fontSize;
  final String fontWeight;
  final String fontFamily;

  TranslatorWidget({
    required this.text,
    this.color = "#000000",
    this.fontFamily = "Roboto",
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  State<TranslatorWidget> createState() => _TranslatorWidgetState();
}

class _TranslatorWidgetState extends State<TranslatorWidget> {
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale = '';

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
    // print(_currentLocale);
  }

  Future<String> _translateText() async {
    final translator = GoogleTranslator();
    try {
      final translation = await translator.translate(
        widget.text,
        to: _currentLocale,
      );
      return translation.text;
    } catch (e) {
      return 'Error: Unable to translate';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocale == 'en') {

      return Text(
        widget.text,
        style: TextStyle(
          fontFamily: widget.fontFamily,
          fontSize: double.parse(widget.fontSize),
          fontWeight: _getFontWeight(widget.fontWeight),
          color: Color(int.parse(widget.color.replaceAll('#', '0xff'))),
        ),
      );
    } else {
      // Use FutureBuilder for translation if the locale is not English
      return FutureBuilder<String>(
        future: _translateText(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(
              snapshot.data ?? 'No translation available',
              style: TextStyle(
                fontFamily: widget.fontFamily,
                fontSize: double.parse(widget.fontSize),
                fontWeight: _getFontWeight(widget.fontWeight),
                color: Color(int.parse(widget.color.replaceAll('#', '0xff'))),
              ),
            );
          }
        },
      );
    }
  }

  FontWeight _getFontWeight(String weight) {
    switch (weight) {
      case '100':
        return FontWeight.w100;
      case '200':
        return FontWeight.w200;
      case '300':
        return FontWeight.w300;
      case '400':
        return FontWeight.w400;
      case '500':
        return FontWeight.w500;
      case '600':
        return FontWeight.w600;
      case '700':
        return FontWeight.w700;
      case '800':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }
}
