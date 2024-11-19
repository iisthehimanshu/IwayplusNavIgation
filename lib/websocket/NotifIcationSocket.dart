
import 'dart:convert';

import 'package:iwaymaps/FIREBASE%20NOTIFICATION%20API/PushNotifications.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'Model/NotificationData.dart';

class NotificationSocket{
  NotificationSocket(){
    channel.connect();
  }

  static final channel = io('https://dev.iwayplus.in', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  static void receiveMessage(){
    channel.on("com.iwayplus.navigation", (value){
      NotificationData notification = NotificationData.fromJson(value);
      PushNotifications.showSimpleNotificationwithImage(body: notification.title,imageUrl: notification.filepath,payload: notification.body,title: notification.title);
      print("socketMessage${value}");
    });
    List<dynamic> receivedMessage = channel.receiveBuffer;
    print(receivedMessage);
  }

}

