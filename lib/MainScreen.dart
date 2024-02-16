import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    Navigation(buildingID: ''),
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

          }),
          destinations: [
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_home.svg",color: Color(0xff24B9B0),), label: '',),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff1C1B1F)),selectedIcon: SvgPicture.asset("assets/MainScreen_Map.svg",color: Color(0xff24B9B0),), label: "Map",),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Scanner.svg",color: Color(0xff1C1B1F),width: 34,height: 34,), label: 'Scan',),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Favourite.svg",color: Color(0xff1C1B1F),), label: "Favourite",),
            NavigationDestination(icon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),),selectedIcon: SvgPicture.asset("assets/MainScreen_Profile.svg",color: Color(0xff1C1B1F),), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
