import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/Panel%20Manager/PanelManager.dart';
import 'package:provider/provider.dart';
import '../MapManager/GoogleMapManager.dart';
import 'PanelState.dart';

class LocalizedScreen extends StatelessWidget {
  const LocalizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final beacon = context.watch<GoogleMapManager>().nearestBeacon;
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20), // Add this line
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(
              "You are near ${beacon}",
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xff292929),
                height: 25 / 18,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              overflow: TextOverflow.visible,
            )
            ),
            IconButton(
              icon: Icon(CupertinoIcons.arrow_right),
              onPressed: () {
                PanelManager().showPanel(PanelState.landmarkInfo);
              },
            )
          ],
        ),
      ),
    );
  }

}
