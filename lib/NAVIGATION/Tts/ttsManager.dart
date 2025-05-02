import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import '../../IWAYPLUS/FIREBASE NOTIFICATION API/PushNotifications.dart';
import '../UserState.dart';

class TTSManager {
  TTSManager._privateConstructor();
  static final TTSManager instance = TTSManager._privateConstructor();

  final FlutterTts _flutterTts = FlutterTts();

  bool disposed = false;
  bool isSemanticEnabled = false;

  // Internal config state
  String _languageCode = "en";
  double _pitch = 1.0;
  double _speechRateAndroid = 0.7;
  double _speechRateIOS = 0.55;

  // --- SETTERS ---
  void setLanguageCode(String code) => _languageCode = code;
  void setPitch(double value) => _pitch = value;
  void setSpeechRate({required double androidRate, required double iosRate}) {
    _speechRateAndroid = androidRate;
    _speechRateIOS = iosRate;
  }

  // --- GETTERS ---
  String get languageCode => _languageCode;
  double get pitch => _pitch;
  double get speechRate => Platform.isAndroid ? _speechRateAndroid : _speechRateIOS;

  Future<void> speak(String msg, {bool prevPause = false}) async{
    if (UserState.ttsAllStop || disposed) return;
    try {
      if (prevPause) {
        await _flutterTts.pause();
      }

      // Set voice
      if (_languageCode == "hi") {
        await _flutterTts.setVoice(
          Platform.isAndroid
              ? {"name": "hi-in-x-hia-local", "locale": "hi-IN"}
              : {"name": "Lekha", "locale": "hi-IN"},
        );
      } else {
        await _flutterTts.setVoice({"name": "en-US-language", "locale": "en-US"});
      }

      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setPitch(_pitch);

      if (isSemanticEnabled) {
        PushNotifications.showSimpleNotification(
          body: "",
          payload: "",
          title: msg,
        );
      } else {
        await _flutterTts.speak(msg);
      }
    } catch (e) {
      print("TTSManager Error: $e");
    }
  }

  Future<void> dispose() async {
    disposed = true;
    await _flutterTts.stop();
  }

  Future<void> reset() async {
    disposed = false;
  }
}
