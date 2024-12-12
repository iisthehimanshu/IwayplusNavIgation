import 'package:flutter/material.dart';

import '/IWAYPLUS/APIMODELS/LocalNotificationAPIModel.dart';
import 'API/LocalNotificationAPI.dart';
import 'ELEMENTS/HelperClass.dart';
import 'ELEMENTS/Translator.dart';

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
        final notification = notificationsList[notificationsList.length-index-1];
        print(notification.appId.runtimeType);
        if(notification.appId == 'com.iwayplus.navigation') {
          return Container(
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color(0xffEBEBEB),
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffF5F5F5),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: Color(0xff000000),
                    size: 25,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 12, left: 18),
                            child: Text(
                              notification.title!,
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff000000),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 3, bottom: 14, left: 18),
                            child: Text(
                              HelperClass.truncateString(notification.body!, 40),
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff8d8c8c),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
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