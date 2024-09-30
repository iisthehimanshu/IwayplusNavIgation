import 'package:flutter/material.dart';

import 'API/LocalNotificationAPI.dart';
import 'APIMODELS/LocalNotificationAPIModel.dart';
import 'Elements/Translator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationsInLocalNotificationModule> notificationsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getNotificationData();
  }

  void getNotificationData() async {
    setState(() {
      isLoading = true;
    });

    notificationsList = await LocalNotificationAPI().getNotifications();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          text: "Notification",
          fontSize: "16",
          fontFamily: "Roboto",
          fontWeight: "500",
          color: "#18181b",
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.teal,))
            : notificationsList.isEmpty
            ? _buildEmptyNotificationView()
            : _buildNotificationList(),
      ),
    );
  }

  Widget _buildEmptyNotificationView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Frame.png',
            width: 100,
            height: 100,
          ),
          TranslatorWidget(
            text: 'No Notifications',
            fontSize: "18",
            fontFamily: 'Roboto',
            fontWeight: "700",
            color: "#18181B",
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TranslatorWidget(
              text: "We'll let you know when there will be something to update you.",
              fontSize: "14",
              fontFamily: 'Roboto',
              fontWeight: "400",
              color: "#A1A1AA",
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: notificationsList.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final notification = notificationsList[index];
        print(notification.appId.runtimeType);
        if(notification.appId == 'com.iwayplus.navigation') {
          return Card(
            elevation: 1,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Handle notification tap
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Icon(
                        Icons.notifications,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            notification.body ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Text(
                          //   _formatDate(),
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.black45,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }else{
          print("tileelse");
        }
      },
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}