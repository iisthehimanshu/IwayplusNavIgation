import 'package:flutter/material.dart';

class accessiblepathchip extends StatelessWidget {
  final String value;
  final Icon icon;
  const accessiblepathchip(
      {required this.value, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: ElevatedButton(
          onPressed: () {},
          child: Center(
            child: Row(
              children: [
                icon,
                Container(
                  margin: EdgeInsets.only(left: 3),
                  child: Text(
                    "$value",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff3f3f46),
                      height: 20 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
