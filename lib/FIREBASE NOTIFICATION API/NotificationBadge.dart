import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationBatch extends StatelessWidget{
  final int totalNotifications;

  const NotificationBatch({required this.totalNotifications});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle

      ),
      child: Center(
        child: Padding(
          padding:  EdgeInsets.all(8),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white,fontSize: 20),
          ),
        ),
      ),
    );
  }

}