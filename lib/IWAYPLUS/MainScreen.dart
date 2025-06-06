import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/IWAYPLUS/VenueSelectionScreen.dart';
import 'package:iwaymaps/NAVIGATION/Navigation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../NAVIGATION/MapManager/MapScreen.dart';
import '../NAVIGATION/Network/NetworkManager.dart';
import 'Elements/QRLandmarkScreen.dart';
import 'FavouriteScreen.dart';
import 'ProfilePage.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex=0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NetworkManager networkManager = NetworkManager();
  late int index;
  final screens = [
    VenueSelectionScreen(),
    MapScreen(),
    QRViewExample(frmMainPage: true,),
    FavouriteScreen(),
    ProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    checkPermission();
    index = widget.initialIndex;
    setIDforWebSocket();
  }
  checkPermission()async{

    await requestBluetoothConnectPermission();
  }
  void setIDforWebSocket()async{
    final signInBox = await Hive.openBox('SignInDatabase');
    networkManager.ws.updateUserId(signInBox.get("userId"));
  }
  var locBox=Hive.box('LocationPermission');

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    print(status);

    locBox.put('location', (status.isGranted)?true:false);
    if (status.isGranted) {

      print('location permission granted');


      requestBluetoothConnectPermission();


    } else if(status.isPermanentlyDenied) {
      print('location permission is permanently granted');
    }else{
        print("location permission is granted");
    }
  }


  Future<Position> getUsersCurrentLatLng()async{

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  Future<void> requestBluetoothConnectPermission() async {
    final PermissionStatus permissionStatus = await Permission.bluetooth.request();
    print("permissionStatus    ----   ${permissionStatus}");
    if (permissionStatus.isGranted) {
      print("Bluetooth permission is granted");
      // Permission granted, you can now perform Bluetooth operations
    } else {
      // Permission denied, handle accordingly
      print("Bluetooth permission is denied");
    }
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
            if (index==3){
              // Check if the 4th screen is selected
              showToast('Feature coming soon');
            } else {
              // Switch to the selected screen for other cases
              // if (index == 1) {
              //   // Open MapScreen in full screen
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
              // } else {
              //   // Switch to the selected screen for other cases
              //   this.index = index;
              // }
              this.index = index;
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
