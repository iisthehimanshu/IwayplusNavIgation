import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:iwaymaps/IWAYPLUS/Elements/locales.dart';
import 'package:iwaymaps/NAVIGATION/UserState.dart';

class NearestLandmarkScreen extends StatefulWidget {
  const NearestLandmarkScreen({super.key});

  @override
  State<NearestLandmarkScreen> createState() => _NearestLandmarkScreenState();
}

class _NearestLandmarkScreenState extends State<NearestLandmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "You are near , ${LocaleData.floor.getString(context)} ",
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xff292929),
                height: 25 / 18,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              overflow: TextOverflow.visible,
            )
          ],
        ),
      ),
    );
  }
}
