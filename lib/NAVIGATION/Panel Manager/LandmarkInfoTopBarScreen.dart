
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iwaymaps/NAVIGATION/Panel%20Manager/PanelManager.dart';

import 'PanelState.dart';

class LandmarkInfoTopBarScreen extends StatelessWidget{
  const LandmarkInfoTopBarScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.arrow_left),
              onPressed: () {
                PanelManager().showPanel(PanelState.localized);
              },
            ),
            const SizedBox(width: 12),
            const Text(
              "3A - 2B Iwayplus",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

          ],
        ),
      ),
    );
  }

}
