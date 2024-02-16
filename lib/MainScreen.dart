import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iwayplusnav/BuildingSelectionScreen.dart';
import 'package:iwayplusnav/Navigation.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex=0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late int index;
  final screens = [
    BuildingSelectionScreen(),
    Navigation(buildingID: '',),
    BuildingSelectionScreen(),
    BuildingSelectionScreen(),
  ];
  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelTextStyle: MaterialStateProperty.all(TextStyle(
            fontFamily: "Roboto",
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xff4B4B4B),
            height: 20/14,
          )),
        ),

        child: NavigationBar(
          backgroundColor: Color(0xffFFFFFF),
          selectedIndex: index,
          onDestinationSelected: (index)=>setState(() {
            if (index == 3 || index==2 || index==4 || index==1 ){
              // Check if the 4th screen is selected
              showToast('Feature coming soon');
            } else {
              // Switch to the selected screen for other cases
              setState(() {
                this.index = index;
              });
            }
          }),
          destinations: [
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff24B9B0),), label: 'Home',),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff24B9B0),), label: "Map",),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),width: 34,height: 34,), label: 'Scan',),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),), label: "Favourite",),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),), label: "Profile"),
          ],
        ),
      ),
    );
  }

  void showToast(String mssg) {
    Fluttertoast.showToast(
      msg: mssg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
