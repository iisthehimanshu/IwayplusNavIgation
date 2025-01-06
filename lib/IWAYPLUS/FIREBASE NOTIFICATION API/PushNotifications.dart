import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as ht;

import '../../main.dart';

class PushNotifications {
  static var signInBox = Hive.box('SignInDatabase');

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(onDidReceiveLocalNotification: (id, title, body, payload) => null);
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
    // _flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //   onDidReceiveBackgroundNotificationResponse: (value){
    //     print("onDidReceiveBackgroundNotificationResponse");
    //     print(value.notificationResponseType);
    //     print(value);
    //   }
    // );
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    print("value--${notificationResponse}");
    // navigatorKey.currentState!.pushNamed("/message", arguments: notificationResponse);
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: '',
      playSound: false,
      sound: null, // Make notification silent
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.cancelAll();

    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails, payload: payload);
  }

  static Future<String?> _downloadAndSaveImage(String url, String fileName) async {
    try {
      final response = await ht.get(Uri.parse(url));
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName.jpg';
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  static Future showSimpleNotificationwithImage({
    required String title,
    required String body,
    required String payload,
    required String imageUrl,
  }) async {
    String? filePath = await _downloadAndSaveImage("https://dev.iwayplus.in/uploads/" + imageUrl, 'notification_image');

    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(filePath ?? ""),
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
      ticker: 'ticker',
      playSound: false,
      sound: null, // Make notification silent
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future showSimpleNotificationwithButton({
    required String title,
    required String body,
    required String payload,
    required String imageUrl,
  }) async {
    String? filePath = await _downloadAndSaveImage("https://dev.iwayplus.in/uploads/" + imageUrl, 'notification_image');

    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(filePath ?? ""),
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
      ticker: 'ticker',
      playSound: false,
      sound: null, // Make notification silent
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('Direction', 'Direction')
      ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
