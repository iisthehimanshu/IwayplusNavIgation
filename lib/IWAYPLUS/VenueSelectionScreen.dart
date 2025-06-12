
import 'dart:collection';
import 'dart:io';

import 'dart:math';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/IWAYPLUS/websocket/NotifIcationSocket.dart';
import 'package:iwaymaps/NAVIGATION/API/BuildingAPI.dart';
import 'package:iwaymaps/NAVIGATION/API/RefreshTokenAPI.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/Buildingbyvenue.dart';
import 'package:iwaymaps/NAVIGATION/BluetoothManager/BLEManager.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/DataVersionLocalModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/BOXES/WayPointModelBOX.dart';
import 'package:iwaymaps/NAVIGATION/DatabaseManager/DataBaseManager.dart';
import 'package:iwaymaps/NAVIGATION/DatabaseManager/SwitchDataBase.dart';
import 'package:iwaymaps/NAVIGATION/MapManager/GoogleMapManager.dart';
import 'package:iwaymaps/NAVIGATION/Panel%20Manager/PanelManager.dart';
import 'package:iwaymaps/NAVIGATION/Panel%20Manager/PanelState.dart';
import 'package:iwaymaps/NAVIGATION/Repository/RepositoryManager.dart';
import 'package:iwaymaps/NAVIGATION/VenueManager/VenueManager.dart';
import 'package:iwaymaps/NAVIGATION/ViewModel/LocalizedScreenViewModel.dart';
import 'package:provider/provider.dart';
import '../NAVIGATION/BluetoothScanAndroid.dart';
import '../NAVIGATION/Network/NetworkManager.dart';
import '/IWAYPLUS/Elements/HelperClass.dart';
import '/IWAYPLUS/Elements/UserCredential.dart';
import '/IWAYPLUS/Elements/buildingCard.dart';
import 'package:iwaymaps/NAVIGATION/UserState.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iwaymaps/NAVIGATION/IOSScannerScreen.dart';

import '/NAVIGATION/APIMODELS/Building.dart';
import '/IWAYPLUS/APIMODELS/buildingAll.dart';
import '/NAVIGATION/APIMODELS/patchDataModel.dart';
import 'API/UsergetAPI.dart';
import 'API/buildingAllApi.dart';
import 'BuildingInfoScreen.dart';
import '/NAVIGATION/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import '/NAVIGATION/DATABASE/BOXES/LandMarkApiModelBox.dart';
import '/NAVIGATION/DATABASE/BOXES/OutDoorModelBOX.dart';
import '/NAVIGATION/DATABASE/BOXES/PatchAPIModelBox.dart';
import '/NAVIGATION/DATABASE/BOXES/PolyLineAPIModelBOX.dart';
import '/NAVIGATION/HomeNestedSearch.dart';
import '/NAVIGATION/Navigation.dart';
import 'DATABASE/BOXES/BuildingAllAPIModelBOX.dart';
import 'MODELS/VenueModel.dart';
import 'NotificationScreen.dart';
import 'package:iwaymaps/IWAYPLUS/FIREBASE NOTIFICATION API/PushNotifications.dart';
import 'package:iwaymaps/NAVIGATION/BluetoothService.dart';

class VenueSelectionScreen extends StatefulWidget{

  VenueSelectionScreen({super.key});
  @override
  State<VenueSelectionScreen> createState() => _VenueSelectionScreenState();
}

class _VenueSelectionScreenState extends State<VenueSelectionScreen>{
  NetworkManager networkManager = NetworkManager();
  late List<buildingAll> buildingList=[];
  late List<buildingAll> newbuildingList=[];
  bool isLoading_buildingList = true;
  List<Widget> BuildingCard = [];
  late List<VenueModel> venueList=[];
  late Map<String, List<buildingAll>> venueHashMap = new HashMap();
  // Replace with your actual document ID
  bool checkedForBuildingAllUpdated = false;
  bool isLocating=false;

  @override
  void initState() {
    super.initState();
    PanelState.none;
    // BLEManager bleManager = BLEManager();
    // bleManager.startScanning(
    //   bufferSize: 6,
    //   streamFrequency: 6,
    //   duration: null,
    // );
    //
    // bleManager.bufferedDeviceStream.listen((bufferedData) {
    //   // You can update UI or process data here
    //   print("Scanned data: $bufferedData");
    //
    //   if(mounted) context.read<LocalizedScreenViewModel>().setNearestBeacon = bufferedData;
    //   // GoogleMapManager(PanelManager()).setNearestLandmark(bufferedData);
    //   // if(mounted) context.read<GoogleMapManager>().setNearestLandmark(bufferedData);
    // });
    NotificationSocket.receiveMessage();
    // checkForUpdate();
    //startScan();
    getLocs();
    RepositoryManager().loadBuildings();

    // print("GREEN DATABASE IS ACTIVE venueselectionscreen : ${SwitchDataBase().isGreenDataBaseActive()}");

    apiCall();
    print("venueHashMap");
    print(venueHashMap);
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    // Ask for regular storage permission (Android <11)
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print("✅ Storage permission granted");
    } else if (status.isDenied) {
      print("❌ Storage permission denied");
    } else if (status.isPermanentlyDenied) {
      print("❌ Permission permanently denied, please enable from settings");
      await openAppSettings();
    }
  }


  bool _updateAvailable = false;
  bool _checkingForUpdate = true;
  String? currentVersion = "";

  Future<void> checkForUpdate() async {
    final newVersion = NewVersionPlus(
      androidId: 'com.iwayplus.navigation',
      iOSId: 'com.iwayplus.navigation',
    );

    try {
      final status = await newVersion.getVersionStatus();
      print("status");
      print(status!.canUpdate);
      setState(() {
        currentVersion = status?.localVersion;
        _updateAvailable = status != null && status.canUpdate;
        _checkingForUpdate = false;
      });

      // Show dialog if update is available
      if (_updateAvailable) {
        _showUpdateDialog();
      }

    } catch (e) {
      print('Error checking for updates: $e');
      setState(() {
        _checkingForUpdate = false;
      });
    }
  }

  // Function to show update dialog
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Available"),
          content: Text("A new version of the app is available. Please update to the latest version."),
          actions: <Widget>[
            TextButton(
              child: Text("Update Now"),
              onPressed: () async {
                // Add your app update logic here
                final url = Theme.of(context).platform ==
                    TargetPlatform.iOS
                    ? 'https://apps.apple.com/in/app/iwaymaps/id6478580371'
                    : 'https://play.google.com/store/apps/details?id=com.iwayplus.navigation';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  void startScan(){
    FlutterBluePlus.startScan();
    //  print("himanshu 3");
    FlutterBluePlus.scanResults.listen((results) async {
      // print("himanshu 4");
      for (ScanResult result in results) {
        if(result.device.platformName.length > 2){
          //print("himanshu 5 ${result}");
          String MacId = "${result.device.platformName}";
          int Rssi = result.rssi;
          print("mac $MacId    rssi $Rssi");
          networkManager.ws.updateInitialization(bleScanResults: MapEntry(MacId, Rssi));
        }
      }
    });
  }
  static var infoBox=Hive.box('SignInDatabase');
  void loadInfoToFile(){

    String accessToken = infoBox.get('accessToken');
    print('loadInfoToFile');
    print(infoBox.get('userId'));
    UsergetAPI().getUserDetailsApi(infoBox.get('userId'));
  }


  void getLocs()async{
    setState(() {
      isLocating=true;
    });
    userLoc= await getUsersCurrentLatLng();
if(userLoc!=null){
  UserState.geoLat=userLoc!.latitude;
  UserState.geoLng=userLoc!.longitude;
}else{
  userLoc=Position(longitude: 77.18803031572772, latitude:  28.544277333724025, timestamp: DateTime.now(), accuracy: 100, altitude: 1, altitudeAccuracy: 100, heading: 10, headingAccuracy: 100, speed: 100, speedAccuracy: 100);
}
    if(mounted){
      setState(() {
        isLocating=false;

      });
    }

  }

  var locBox=Hive.box('LocationPermission');
  Position? userLoc;

  Future<Position?> getUsersCurrentLatLng()async{
   //if ((locBox.get('location')==null)?false:locBox.get('location')) {
      try{
        Position? position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        Geolocator.getLocationAccuracy();
        return position;
      }catch(e){
        print("error in location fetching");
        return null;
      }



   // }
    // else{
    //   Position pos=Position(longitude: 79.10139, latitude:  28.947555, timestamp: DateTime.now(), accuracy: 100, altitude: 1, altitudeAccuracy: 100, heading: 10, headingAccuracy: 100, speed: 100, speedAccuracy: 100);
    //   return pos;
    // }

  }


  void apiCall() async  {
    await buildingAllApi().fetchBuildingAllData().then((value) {
      print(value);
      setState(() {
        buildingList = value;
        newbuildingList = value;
        createBuildingCards(buildingList);
        isLoading_buildingList = false; // Set loading to false when data is loaded
      });
    });

    print("print after");
    //filterVenueList(buildingList);
    print(venueList);
    venueHashMap = createVenueHashMap(buildingList);


    print(venueHashMap.keys);
    //venueList = venueHashMap.keys
    venueList = createVenueList(venueHashMap);
    for(int i=0;i<venueList.length;i++)
    {
      buildingsPos.add(venueList[i]);
    }

    loadInfoToFile();

  }
  int getDistanceFromLatLonInKm(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the earth in km
    double dLat = deg2rad(lat2 - lat1); // deg2rad below
    double dLon = deg2rad(lon2 - lon1);
    double a = pow(sin(dLat / 2), 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = R * c; // Distance in km
    return d.toInt();
  }

  double deg2rad(double deg) {
    return deg * (pi / 180);
  }

  List<VenueModel> createVenueList(Map<String, List<buildingAll>> venueHashMap){
    List<VenueModel> newList = [];
    for (var entry in venueHashMap.entries) {
      String key = entry.key;
      List<buildingAll> value = entry.value;
      newList.add(VenueModel(venueName: key, distance: 190, buildingNumber: value.length, imageURL: value[0].venuePhoto??"", Tag: value[0].venueCategory??"", address: value[0].address,description: value[0].description,phoneNo: value[0].phone,website: value[0].website,coordinates: value[0].coordinates!, dist: 0));
      // print('Key: $key');
      // print('Value: $value');
    }
    return newList;
  }

  Map<String, List<buildingAll>> createVenueHashMap(List<buildingAll> buildingList) {
    Map<String, List<buildingAll>> dummyVenueHashMap = HashMap<String, List<buildingAll>>();

    for (buildingAll building in buildingList) {
      // Check if the venueName is already a key in the HashMap
      if (dummyVenueHashMap.containsKey(building.venueName)) {
        // If yes, add the building to the existing list
        dummyVenueHashMap[building.venueName]!.add(building);
      } else {
        // If no, create a new list with the building and add it to the HashMap
        dummyVenueHashMap[building.venueName??""] = [building];
      }
    }
    return dummyVenueHashMap;
  }

  void createBuildingCards(List<buildingAll> buildingList){
    setState(() {

      BuildingCard.add(SizedBox(height: 12,));
      for(int i = 0; i<buildingList.length; i++){
        BuildingCard.add(buildingCard(imageURL: buildingList[i].venuePhoto != null? buildingList[i].venuePhoto!:"", Name: buildingList[i].buildingName!, Tag: buildingList[i].venueCategory != null?buildingList[i].venueCategory!:"", Address: buildingList[i].address!, Distance: 119, NumberofBuildings: 3, bid: buildingList[i].sId!,));
      }
    });
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
  static const methodChannel = MethodChannel('com.example.bluetooth/scan');


  Future<void> startBagScan() async {
    try {
      await methodChannel.invokeMethod('startScanBackground');

    } on PlatformException catch (e) {
      print("Failed to stop scan: ${e.message}");
    }
  }

  calcDistanceFromUser(List<VenueModel> buildingsPos,Position userLoc){
    // buildingsPos.clear();
    // finalDist.clear();
    print("userlocs");
    print(buildingsPos[0].coordinates);
    print(userLoc);

    for(int i=0;i<buildingsPos.length;i++){
      int dist=getDistanceFromLatLonInKm(buildingsPos[i].coordinates[0],buildingsPos[i].coordinates[1],userLoc.latitude,userLoc.longitude);
      buildingsPos[i].dist=dist;
      finalDist.add(dist);
    }
    // print("finalDist");
    // print(finalDist);
  }
  List<VenueModel> buildingsPos=[];
  List<int> finalDist=[];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            label: "Iwayplus",
            child: InkWell(
              onTap: (){
                RefreshTokenAPI.refresh();

              },
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Iwayplus",
                  style: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff000000),
                  ),
                ),
              ),
            ),
          ),
          centerTitle: true,
          leading: Semantics(
            child: EasterEggTrigger(
              child: Container(
                alignment: Alignment.centerRight,
                width: 60,
                child: SvgPicture.asset("assets/MainScreen_IwayplusLogo.svg"),
              ),codes: [
              EasterEggTriggers.SwipeDown,
              EasterEggTriggers.LongPress,
            ],
              action: (){
                final BeaconBox = BeaconAPIModelBOX.getData();
                final BuildingAllBox = BuildingAllAPIModelBOX.getData();
                final LandMarkBox = LandMarkApiModelBox.getData();
                final PatchBox = PatchAPIModelBox.getData();
                final PolyLineBox = PolylineAPIModelBOX.getData();
                final WayPointBox = WayPointModeBOX.getData();
                final OutBuildingBox = OutDoorModeBOX.getData();
                final DataVersionBox = DataVersionLocalModelBOX.getData();

                BeaconBox.clear();
                BuildingAllBox.clear();
                LandMarkBox.clear();
                PatchBox.clear();
                PolyLineBox.clear();
                WayPointBox.clear();
                OutBuildingBox.clear();
                DataVersionBox.clear();
                showToast("Database Cleared ${BeaconBox.length},${BuildingAllBox.length},${LandMarkBox.length},${PatchBox.length},${PolyLineBox.length},${WayPointBox.length},${OutBuildingBox.length},${DataVersionBox.length}");

              },
            ),
          ),

          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none_outlined),
              color: Color(0xff18181b),
              onPressed: () {
                // PushNotifications.showSimpleNotification(body: "",payload: "",title: "Title");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BluetoothScanAndroid(),
                  ),
                );
              },
            ),
            Container(
                margin: EdgeInsets.only(right: 20),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8.0),
                //   border: Border.all(
                //     color: Color(0x204A4545),
                //   ),
                // ),
                child: IconButton(
                  icon: Semantics(
                      label: "Search",
                      child: Icon(Icons.search,color: Colors.black,)),
                  color: Color(0xff000000),
                  onPressed: () {
                    showSearch(context: context, delegate: HomeNestedSearch(newbuildingList));
                  },
                )),

          ],
          backgroundColor: Colors.transparent, // Set the background color to transparent
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], // Set your gradient colors
              ),
            ),
          ),
        ),
        body:(isLocating)? Center(
            child: Animate(
                effects: [FadeEffect(), ScaleEffect()],
                child: Text("Loading Data. . .",style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 30,
                  color: Color(0xFF666870),
                  height: 1,
                  letterSpacing: -1,
                ),)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                    .animate() // this wraps the previous Animate in another Animate
                    .fade(duration: 1200.ms, curve: Curves.ease)
                    .slide()
            )
          // Show linear loading indicator
        ):isLoading_buildingList
            ? Center(
            child: Animate(
                effects: [FadeEffect(), ScaleEffect()],
                child: Text("Loading Data. . .",style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 30,
                  color: Color(0xFF666870),
                  height: 1,
                  letterSpacing: -1,
                ),)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                    .animate() // this wraps the previous Animate in another Animate
                    .fade(duration: 1200.ms, curve: Curves.ease)
                    .slide()
            )
          // Show linear loading indicator
        )
            : DefaultTabController(

            length: 4,
            child: Column(
              children: [
                Material(
                  child: Container(
                    height: 55,
                    color: Color(0xffFFFFFF),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], // Set your gradient colors
                        ),
                      ),
                      child: TabBar(
                        unselectedLabelColor: Color(0xffB3B3B3),
                        isScrollable: false,
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        tabs: [
                          Tab(
                            child: Container(
                              height: 35,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("All"),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              height: 35,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Academic"),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              height: 35,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Hospital"),
                              ),
                            ),
                          ),
                          // Tab(child: Container(
                          //   height: 35,
                          //   child: Align(
                          //     alignment: Alignment.center,
                          //     child: Text("Mall"),
                          //   ),
                          // ),
                          // ),
                          Tab(child: Container(
                            height: 35,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Event"),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          itemBuilder: (context,index){

                             //var currentData = venueList[index];


                             calcDistanceFromUser(buildingsPos,userLoc!);
                            buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            var currentData = buildingsPos[index];



                            return GestureDetector(
                              onTap: () async{
                                // Handle onTap for the specific item here
                                // For example, you can navigate to a new screen or perform some action
                                // print("Tapped on item at index $index");
                                buildingAllApi.setStoredVenue(currentData.venueName!);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc,),
                                  ),
                                );
                              },
                              child: buildingCard(
                                imageURL: "",
                                Name: currentData.venueName ?? "",
                                Tag: currentData.Tag ?? "Null",
                                Address: currentData.address ?? "",
                                Distance:buildingsPos[index].dist,
                                NumberofBuildings: currentData.buildingNumber ?? 0,
                                bid: currentData.venueName ?? "",

                              ),
                            );
                          },
                          itemCount: venueList.length,
                        ),
                        ListView.builder(
                          itemBuilder: (context, index) {

                            // calcDistanceFromUser(buildingsPos,userLoc!);
                            // buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            var currentData = buildingsPos[index];
                            if (currentData.Tag == "Academic") {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc),
                                    ),
                                  );
                                },
                                child: buildingCard(imageURL: "",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: buildingsPos[index].dist, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // Empty widget if not Hospital
                            }
                          },
                          itemCount: venueList.length,
                        ),
                        ListView.builder(
                          itemBuilder: (context, index) {

                            // calcDistanceFromUser(buildingsPos,userLoc!);
                            // buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            var currentData = buildingsPos[index];
                            if (currentData.Tag == "Hospital") {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc),
                                    ),
                                  );
                                },
                                child: buildingCard(imageURL: "",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: buildingsPos[index].dist, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // Empty widget if not Hospital
                            }
                          },
                          itemCount: venueList.length,
                        ),
                        // ListView.builder(
                        //   itemBuilder: (context, index) {
                        //     var currentData = newbuildingList[index];
                        //     if (currentData.category == "Mall") {
                        //       return buildingCard(
                        //         imageURL: currentData.photo ?? "",
                        //         Name: currentData.buildingName ?? "",
                        //         Tag: currentData.category ?? "",
                        //         Address: currentData.address ?? "",
                        //         Distance: 190,
                        //         NumberofBuildings: 3,
                        //         bid: currentData.sId ?? "",
                        //       );
                        //     } else {
                        //       return SizedBox.shrink(); // Empty widget if not Hospital
                        //     }
                        //   },
                        //   itemCount: newbuildingList.length,
                        // ),
                        ListView.builder(
                          itemBuilder: (context, index) {

                            // calcDistanceFromUser(buildingsPos,userLoc!);
                            // buildingsPos.sort((a, b) => a.dist.compareTo(b.dist));

                            var currentData = buildingsPos[index];
                            if (currentData.Tag == "Event") {
                              return GestureDetector(
                                onTap: () {
                                  print("Object Handeling");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuildingInfoScreen(receivedAllBuildingList: venueHashMap[currentData.venueName],venueDescription:  currentData.description,venueTitle: currentData.venueName,venueAddress: currentData.address,venueCategory: currentData.Tag,venuePhone: currentData.phoneNo,venueWebsite: currentData.website,dist: buildingsPos[index].dist,currentLatLng: userLoc),
                                    ),
                                  );
                                },
                                child: buildingCard(imageURL: "",
                                  Name: currentData.venueName??"",
                                  Tag: currentData.Tag?? "", Address: currentData.address?? "", Distance: buildingsPos[index].dist, NumberofBuildings: currentData.buildingNumber??0, bid: currentData.venueName??"",
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // Empty widget if not Hospital
                            }
                          },
                          itemCount: venueList.length,
                        ),

                      ],

                    )
                ),
              ],
            )
        ),

        // AnimationLimiter(
        //   child: ListView.builder(
        //     itemCount: newbuildingList.length,
        //     itemBuilder: (context, index) {
        //       // Apply animation to each ListTile
        //       return AnimationConfiguration.staggeredList(
        //         position: index,
        //         duration: const Duration(milliseconds: 500),
        //         child: SlideAnimation(
        //           verticalOffset: 50.0,
        //           child: FadeInAnimation(
        //             child: buildingCard(imageURL: newbuildingList[index].photo??"",
        //               Name: newbuildingList[index].buildingName??"",
        //               Tag: newbuildingList[index].category?? "", Address: newbuildingList[index].address?? "", Distance: 190, NumberofBuildings: 3, bid: newbuildingList[index].sId??"",)
        //           ),
        //
        //         ),
        //
        //       );
        //     },
        //
        //   ),
        // )
        floatingActionButton: FloatingActionButton(
          backgroundColor: CupertinoColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(CupertinoIcons.ant, color: Colors.white,size: 30,),
          enableFeedback: true,
          onPressed: () {
            if(RepositoryManager().preLoadDataBaseCreated){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Local Database Already Prepared',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.fixed,
                  backgroundColor: Color(0xFF2C3E50), // professional dark tone
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              );
            }else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Preparing Local DataBase',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.fixed,
                  backgroundColor: Color(0xFF2C3E50),
                  // professional dark tone
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              );

              List<Buildingbyvenue> totalBuildings = VenueManager().buildings;

              totalBuildings.forEach((indexBuilding) async {
                await RepositoryManager().runAPICallDataVersion(indexBuilding.sId!, generateJSON: true);
                await RepositoryManager().runAPICallPatchData(indexBuilding.sId!, generateJSON: true);
                await RepositoryManager().runAPICallPolylineData(indexBuilding.sId!, generateJSON: true);
                await RepositoryManager().runAPICallLandmarkData(indexBuilding.sId!, generateJSON: true);
                await RepositoryManager().runAPICallBeaconData(indexBuilding.sId!, generateJSON: true);
                //await RepositoryManager().getGlobalAnnotationData(indexBuilding.sId!,generateJSON: true);
                try {
                  await RepositoryManager().getWaypointData(
                      indexBuilding.sId!, generateJSON: true);
                }catch(e){}
              });

              RepositoryManager().loadPreLoadedDataBase();
              Future.delayed(Duration(seconds: 2));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Local Database Prepared',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.fixed,
                  backgroundColor: Color(0xFF2C3E50),
                  // professional dark tone
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              );
            }
          },
        ),

      ),
    );
  }
}


