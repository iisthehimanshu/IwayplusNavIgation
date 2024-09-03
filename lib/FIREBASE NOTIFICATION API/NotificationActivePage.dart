import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationActivePage extends StatefulWidget {
  int totalNoti;
  List<Map<String, dynamic>> messages = [];


  NotificationActivePage({required this.totalNoti,required this.messages});

  @override
  State<NotificationActivePage> createState() => _NotificationActivePageState();
}

class _NotificationActivePageState extends State<NotificationActivePage> {
  //List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        widget.messages = [...widget.messages, _convertMessageToMap(message)];
        _saveNotifications(widget.messages);
      });
    });
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNotifications = prefs.getString('notifications');
    if (savedNotifications != null) {
      List<dynamic> decodedNotifications = jsonDecode(savedNotifications);
      setState(() {
        widget.messages = decodedNotifications.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _saveNotifications(List<Map<String, dynamic>> notifications) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(notifications));
  }

  Future<void> _deleteNotifications(String notifications) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(notifications);
    //await prefs.setString('notifications', jsonEncode(notifications));
  }


  Map<String, dynamic> _convertMessageToMap(RemoteMessage message) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedTime = formatter.format(message.sentTime!);
    return {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'sentTime': formattedTime ,
      // Add other properties of the message that you want to save
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Notifications",
            style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Semantics(
                label: 'Back ',child: Icon(Icons.arrow_back_ios_new, color: Colors.black)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xffFFFFFF),
          elevation: 0,
        ),
        body: Center(child: Text('No message received')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Semantics(
              label: 'Back ',child: Icon(Icons.arrow_back_ios_new, color: Colors.black)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Semantics(
            label:"",
            child: Center(
              child: GestureDetector(
                child: Container(
                 margin: EdgeInsets.only(right: 16), // Adjust the gap between items

                  child: Text(
                    "Clear All",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),

                  ),
                ),
                onTap: () {
                  // Handle search button press
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Search(qrdatalist: [])));
                  _deleteNotifications("notifications");

                  setState(() {
                    widget.messages.clear();
                  });
                },
              ),
            ),
          ),
        ],
        backgroundColor: Color(0xffFFFFFF),
        elevation: 0,
      ),

      body: SafeArea(
        child: widget.messages.isEmpty
            ? Center(
          child: Text(
            'No notifications',
            style: TextStyle(fontSize: 18.0),
          ),
        )
            :ListView.builder(
          shrinkWrap: true,
          reverse: true,
          itemCount: widget.messages.length,
          itemBuilder: (context, index) {
            // if (index.isOdd) {
            //   return Container(
            //     width: 10.0, // Adjust the width of the divider
            //     child: Divider(
            //       color: Color(0xFF48246C), // Your purple color
            //       thickness:0.3, // Adjust thickness as needed
            //       height: 1.0, // Adjust the space between items
            //     ),
            //   );
            // }
            Map<String, dynamic> message = widget.messages[index];
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top : 8 , bottom: 8.0), // Adjust the gap between items
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0), // Adjust horizontal margin
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                      //color: Color(0xFF48246C), // Your desired color

                    ),
                    child: ListTile(
                      title: Text(message['title'] ?? 'N/D', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(height: 4.0),
                          Text(
                            message['body'] ?? '', // Replace 'description' with your key
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4.0),

                          Text(
                            message['sentTime'].toString(),
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                      leading: SvgPicture.asset(
                        'assets/Purple Fest Logo 2024.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ),
            Container(
            width: MediaQuery.of(context).size.width,
              // Adjust the width of the divider
            child: Divider(
            color: Color(0xFF48246C), // Your purple color
            thickness:0.3, // Adjust thickness as needed
            height: 1.0, // Adjust the space between items
            ),
            )
              ],
            );
          },
        ),
      ),
    );
  }
}
