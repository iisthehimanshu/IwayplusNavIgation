import 'package:flutter/material.dart';

import '../pathState.dart';
import '../singletonClass.dart';

class AccessiblePathButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final String accessibleBy;
  final Function calculateroute;
  final pathState PathState;

  AccessiblePathButton({
    required this.label,
    required this.icon,
    required this.accessibleBy,
    required this.PathState,
    required this.calculateroute,
  });

  @override
  _AccessiblePathButtonState createState() => _AccessiblePathButtonState();
}

class _AccessiblePathButtonState extends State<AccessiblePathButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.PathState.accessiblePath == widget.accessibleBy;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          widget.PathState.accessiblePath = widget.accessibleBy;
          widget.PathState.clearforaccessiblepath();
          SingletonFunctionController.building.landmarkdata!.then((value) async {
            try {
              await Future.delayed(Duration(milliseconds: 50));
              widget.calculateroute(value.landmarksMap!,
                  accessibleby: widget.accessibleBy);
            } catch (e) {}
          });
        },
        child: Container(
          width: 138,
          margin: EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: isHovered ? Colors.grey[50] : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: isSelected
                          ? Color(0xff24B9B0)
                          : Colors.grey[700],
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected
                            ? Color(0xff24B9B0)
                            : Colors.grey[900],
                        height: 20 / 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Underline indicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(0xff24B9B0)
                        : (isHovered ? Color(0xff24B9B0)!.withOpacity(0.3) : Colors.transparent),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}