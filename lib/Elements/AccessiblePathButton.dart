import 'package:flutter/material.dart';

import '../pathState.dart';
import '../singletonClass.dart';

class AccessiblePathButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String accessibleBy;
  final Function calculateroute;
  pathState PathState;

  AccessiblePathButton({
    required this.label,
    required this.icon,
    required this.accessibleBy,
    required this.PathState,
    required this.calculateroute,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        PathState.accessiblePath = accessibleBy;
        PathState.clearforaccessiblepath();
        SingletonFunctionController
            .building.landmarkdata!
            .then((value) async {
          try {
            await Future.delayed(Duration(milliseconds: 10));
            calculateroute(value.landmarksMap!,
                accessibleby: accessibleBy);
          } catch (e) {}
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.greenAccent,
        backgroundColor: PathState.accessiblePath == accessibleBy
            ? Color(0xff24B9B0)
            : Colors.white,
        elevation: 0, // No elevation
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: PathState.accessiblePath == accessibleBy
                  ? Colors.white
                  : Color(0xff24B9B0),
            ),
            Container(
              margin: EdgeInsets.only(left: 3),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: PathState.accessiblePath == accessibleBy
                      ? Colors.white
                      : Colors.black,
                  height: 20 / 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
