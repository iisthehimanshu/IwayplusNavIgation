import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as ht;



// import '../fcmapi.dart';
import '../../main.dart';
// import '../userdata.dart';

class PushNotifications {
  static var signInBox = Hive.box('SignInDatabase');


  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // request notification permission
  // static Future init() async {
  //   userdata uobj = new userdata();
  //   await _firebaseMessaging.requestPermission(
  //     alert: true,
  //     announcement: true,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //   // get the device fcm token
  //   final token = await _firebaseMessaging.getToken();
  //   final iosToken = await _firebaseMessaging.getAPNSToken();
  //   if(token != null){
  //     uobj.savedata("fcm",token);
  //     signInBox.put("FCMToken", token);
  //   }
  //   if(iosToken != null){
  //     uobj.savedata("fcm",iosToken);
  //     signInBox.put("FCMToken", iosToken);
  //   }
  //
  //   print("device token: $token");
  //   print("IOS device token: $iosToken");
  // }


// initalize local notifications
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
        _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,

        );


    // _flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //   onDidReceiveBackgroundNotificationResponse: (value){
    //     print("onDidReceiveBackgroundNotificationResponse");
    //     print(value.notificationResponseType);
    //     print(value);
    //   }
    // );


  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    print("value--${notificationResponse}");
    // navigatorKey.currentState!.pushNamed("/message", arguments: notificationResponse);
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }
  // Helper function to download an image and save it locally
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

    String? filePath = await _downloadAndSaveImage("https://dev.iwayplus.in/uploads/"+imageUrl, 'notification_image');

    // Step 2: Create the notification with the downloaded image
    final BigPictureStyleInformation bigPictureStyleInformation =
    BigPictureStyleInformation(
      FilePathAndroidBitmap(filePath??""),  // Use the local file path
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
      ticker: 'ticker',
    );

    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

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

    String? filePath = await _downloadAndSaveImage("https://dev.iwayplus.in/uploads/"+imageUrl, 'notification_image');

    // Step 2: Create the notification with the downloaded image
    final BigPictureStyleInformation bigPictureStyleInformation =
    BigPictureStyleInformation(
      FilePathAndroidBitmap(filePath??""),  // Use the local file path
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('Direction', 'Direction',)
      ]
    );

    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future foregroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

}