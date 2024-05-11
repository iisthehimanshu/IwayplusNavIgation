import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Elements/locales.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool NotificationswitchValue = true;
  bool DisabilityswitchValue = false;
  bool ColorContrastswitchValue = false;
  bool isNaturalDirectionSelected = true;
  bool isFocusMode = true;
  bool isDistanceinM = true;
  // String? selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();

  }

  void _toggleSelection() {
    setState(() {
      isNaturalDirectionSelected = !isNaturalDirectionSelected;
    });
  }

  void _toggleSelection2() {
    setState(() {
      isFocusMode = !isFocusMode;
    });
  }

  void _toggleSelection3() {
    setState(() {
      isDistanceinM = !isDistanceinM;
    });
  }

  final List<bool> _selectedDisability = <bool>[true, false, false, false];
  TextEditingController _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    List<Widget> disability = <Widget>[
      Text(
        'Blind'
        // LocaleData.blind.getString(context),
      ),
      Text(
        'Low Vision'
        // LocaleData.lowVision.getString(context),
      ),
      Text(
        'Wheelchair'
        // LocaleData.wheelchair.getString(context),
      ),
      Text(
        'Regular',
        // LocaleData.regular.getString(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey,
        centerTitle: true,
        bottomOpacity: 0.8,
        title: Text(
          // 'Settings',
          "Settings",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 0.09,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
              4.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEBEBEB),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,right: 10),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Enter a decimal value',
                    ),

                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      double? decimalValue = double.tryParse(_controller.text);
                      if (decimalValue != null) {
                        // Do something with the decimal value
                        print('You entered: $decimalValue');
                      } else {
                        // Handle invalid input
                        print('Invalid input. Please enter a valid decimal value.');
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    LocaleData.generalSettings.getString(context),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 0.10,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'Language',
                      LocaleData.language.getString(context),

                      style: TextStyle(
                        color: Color(0xFF3F3F46),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),

                  ],
                ),
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'Push Notification',
                      LocaleData.pushNotification.getString(context),

                      style: TextStyle(
                        color: Color(0xFF3F3F46),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(

                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: Switch(
                      inactiveTrackColor: Color(0xffEBEBEB),
                      inactiveThumbColor: Color(0xff79747E),
                      activeColor: Colors.white,
                      activeTrackColor: Color(0xff0B6B94),
                      value: NotificationswitchValue,
                      onChanged: (bool value) {
                        setState(() {
                          NotificationswitchValue = value;
                        });
                      },
                    )),
                  ],
                ),
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'App Information',

                      LocaleData.appInformation.getString(context),

                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Text(
                      // 'Update Available',
                      LocaleData.updateAvailable.getString(context),

                      style: TextStyle(
                        color: Color(0xFF0B6B94),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // 'Accessibility Setttings',
                    LocaleData.accessibilitySettings.getString(context),

                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 0.10,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'High Contrast Mode',
                      LocaleData.highContrastMode.getString(context),

                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                        // width: 12,
                        // height: 12,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: Switch(
                      inactiveTrackColor: Color(0xffEBEBEB),
                      inactiveThumbColor: Color(0xff79747E),
                      activeColor: Colors.white,
                      activeTrackColor: Color(0xff0B6B94),
                      value: ColorContrastswitchValue,
                      onChanged: (bool value) {
                        setState(() {
                          ColorContrastswitchValue = value;
                        });
                      },
                    )),
                  ],
                ),
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'Person with Disability',
                      LocaleData.personWithDisability.getString(context),

                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(

                        child: Switch(
                      inactiveTrackColor: Color(0xffEBEBEB),
                      inactiveThumbColor: Color(0xff79747E),
                      activeColor: Colors.white,
                      activeTrackColor: Color(0xff0B6B94),
                      value: DisabilityswitchValue,
                      onChanged: (bool value) {
                        setState(() {
                          DisabilityswitchValue = value;
                        });
                      },
                    )),
                    // SizedBox(
                    //   width: 16,
                    // )
                  ],
                ),
              ),
            ),
            DisabilityswitchValue
                ? Container(
                    height: 56,
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    child: Container(
                      // padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xff0B6B94), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ToggleButtons(
                          direction: Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0;
                                  i < _selectedDisability.length;
                                  i++) {
                                _selectedDisability[i] = i == index;
                              }
                            });
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          selectedBorderColor: Color(0xff0B6B94),
                          borderColor: Colors.white,
                          selectedColor: Colors.white,
                          // disabledColor: Color(0xff0B6B94),
                          fillColor: Color(0xff0B6B94),
                          color: Color(0xff0B6B94),
                          constraints: BoxConstraints(
                              minWidth: MediaQuery.sizeOf(context).width * 0.2,
                              minHeight: 40
                              // minHeight: 15.0,
                              // minWidth: 15.0,
                              ),
                          isSelected: _selectedDisability,
                          // children: disability,
                          children: [
                            for (int i = 0; i < disability.length; i++)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 6,
                                  ),
                                  disability.elementAt(
                                      i),
                                  SizedBox(
                                      width:
                                          6),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // 'Navigation Settings',
                    LocaleData.navigationSettings.getString(context),

                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 0.10,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'Navigation Mode',
                      LocaleData.navigationMode.getString(context),

                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 13,
                      height: 13,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/info.svg'),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: _toggleSelection,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 48,
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.45,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: isNaturalDirectionSelected
                                ? Color(0xFF0B6B94)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isNaturalDirectionSelected
                                      ? Color(0xFF0B6B94)
                                      : Color(0xFF0B6B94)),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // 'Natural Direction',
                                LocaleData.naturalDirection.getString(context),

                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isNaturalDirectionSelected
                                      ? Colors.white
                                      : Color(0xFF0B6B94),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.45,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: !isNaturalDirectionSelected
                                      ? Color(0xFF0B6B94)
                                      : Color(0xFF0B6B94)),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            color: !isNaturalDirectionSelected
                                ? Color(0xFF0B6B94)
                                : Colors.white,
                          ),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // 'Clock Direction',
                                LocaleData.clockDirection.getString(context),

                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isNaturalDirectionSelected
                                      ? Colors.white
                                      : Color(0xFF0B6B94),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'Orientation Setting',
                      LocaleData.orientationSetting.getString(context),

                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 13,
                      height: 13,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/info.svg'),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: _toggleSelection2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 48,
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.45,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color:
                                isFocusMode ? Color(0xFF0B6B94) : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isFocusMode
                                      ? Color(0xFF0B6B94)
                                      : Color(0xFF0B6B94)),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // 'Focus Mode',
                                LocaleData.focusMode.getString(context),

                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isFocusMode
                                      ? Colors.white
                                      : Color(0xFF0B6B94),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.45,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: !isFocusMode
                                      ? Color(0xFF0B6B94)
                                      : Color(0xFF0B6B94)),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            color:
                                !isFocusMode ? Color(0xFF0B6B94) : Colors.white,
                          ),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // 'Explore Mode',
                                LocaleData.exploreMode.getString(context),

                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isFocusMode
                                      ? Colors.white
                                      : Color(0xFF0B6B94),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Semantics(
              label: "",
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 'Path Details',
                      LocaleData.pathDetails.getString(context),

                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 13,
                      height: 13,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/info.svg'),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: _toggleSelection3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 48,
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.45,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: isDistanceinM
                                ? Color(0xFF0B6B94)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDistanceinM
                                      ? Color(0xFF0B6B94)
                                      : Color(0xFF0B6B94)),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                          ),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // 'Distance in meters',
                                LocaleData.distanceInMeters.getString(context),

                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDistanceinM
                                      ? Colors.white
                                      : Color(0xFF0B6B94),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.45,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: !isDistanceinM
                                      ? Color(0xFF0B6B94)
                                      : Color(0xFF0B6B94)),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            color: !isDistanceinM
                                ? Color(0xFF0B6B94)
                                : Colors.white,
                          ),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // 'Estimated steps',
                                LocaleData.estimatedSteps.getString(context),

                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isDistanceinM
                                      ? Colors.white
                                      : Color(0xFF0B6B94),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
