import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/IWAYPLUS/BuildingInfoScreen.dart';
import 'package:iwaymaps/IWAYPLUS/Elements/HelperClass.dart';
import 'package:iwaymaps/IWAYPLUS/websocket/NotifIcationSocket.dart';
import 'package:iwaymaps/IWAYPLUS/websocket/UserLog.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:screen_protector/screen_protector.dart';
import '/IWAYPLUS/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import '/IWAYPLUS/DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '/NAVIGATION/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/OutDoorModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/WayPointModel.dart';

import '/NAVIGATION/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'IWAYPLUS/DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import 'IWAYPLUS/DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import 'IWAYPLUS/Elements/deeplinks.dart';
import 'IWAYPLUS/Elements/locales.dart';
import 'IWAYPLUS/FIREBASE NOTIFICATION API/PushNotifications.dart';
import 'IWAYPLUS/LOGIN SIGNUP/SignIn.dart';
import 'IWAYPLUS/MainScreen.dart';
import '/NAVIGATION/Navigation.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isJailBroken = await JailbreakRootDetection.instance.isJailBroken;
  await localDBInitialsation();
  await ScreenProtector.preventScreenshotOn();
  if (isJailBroken) {
    HelperClass.showToast("Root/Jailbreak caught");
    exit(0); // Note: You need `dart:io` for this.
  } else {
    if(!kIsWeb){
      mobileInitialization();
      runApp(const MobileApp());
    }else{
      runApp(const WebApp());
    }
  }

}

Future<void> localDBInitialsation() async {
  if(kIsWeb){
    await Hive.initFlutter();
  }else {
    var directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
  }
  Hive.registerAdapter(LandMarkApiModelAdapter());
  await Hive.openBox<LandMarkApiModel>('LandMarkApiModelFile');
  Hive.registerAdapter(PatchAPIModelAdapter());
  await Hive.openBox<PatchAPIModel>('PatchAPIModelFile');
  Hive.registerAdapter(PolyLineAPIModelAdapter());
  await Hive.openBox<PolyLineAPIModel>("PolyLineAPIModelFile");
  Hive.registerAdapter(BuildingAllAPIModelAdapter());
  await Hive.openBox<BuildingAllAPIModel>("BuildingAllAPIModelFile");
  Hive.registerAdapter(FavouriteDataBaseModelAdapter());
  await Hive.openBox<FavouriteDataBaseModel>("FavouriteDataBaseModelFile");
  Hive.registerAdapter(BeaconAPIModelAdapter());
  await Hive.openBox<BeaconAPIModel>('BeaconAPIModelFile');
  Hive.registerAdapter(BuildingAPIModelAdapter());
  await Hive.openBox<BuildingAPIModel>('BuildingAPIModelFile');
  Hive.registerAdapter(SignINAPIModelAdapter());
  await Hive.openBox<SignINAPIModel>('SignINAPIModelFile');
  Hive.registerAdapter(OutDoorModelAdapter());
  await Hive.openBox<OutDoorModel>('OutDoorModelFile');
  Hive.registerAdapter(WayPointModelAdapter());
  await Hive.openBox<WayPointModel>('WayPointModelFile');
  Hive.registerAdapter(DataVersionLocalModelAdapter());
  await Hive.openBox<DataVersionLocalModel>('DataVersionLocalModelFile');
  Hive.registerAdapter(LocalNotificationAPIDatabaseModelAdapter());
  await Hive.openBox<LocalNotificationAPIDatabaseModel>('LocalNotificationAPIDatabaseModel');
  await Hive.openBox('Favourites');
  await Hive.openBox('UserInformation');
  await Hive.openBox('Filters');
  await Hive.openBox('SignInDatabase');
  await Hive.openBox('LocationPermission');
  await Hive.openBox('VersionData');
}

Future<void> mobileInitialization () async {
  WidgetsFlutterBinding.ensureInitialized();

  // PushNotifications.init();
  PushNotifications.localNotiInit();
  PushNotifications.resetBadgeCount();


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}




class MobileApp extends StatefulWidget {
  const MobileApp({super.key});

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  late String googleSignInUserName='';
  final FlutterLocalization localization = FlutterLocalization.instance;
  wsocket soc = wsocket('com.iwaypus.navigation');
  NotificationSocket notificationSocket = NotificationSocket();

  @override
  void initState() {
    configureLocalization();
    super.initState();

  }
  void configureLocalization(){
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');
    localization.onTranslatedLanguage = ontranslatedLanguage;
  }

  void ontranslatedLanguage(Locale? locale){
    setState(() {

    });
  }

  // void _initDeepLinkListener(BuildContext c) async {
  //   _appLinks = AppLinks();
  //   _appLinks.uriLinkStream.listen((Uri? uri) {
  //     Deeplink.deeplinkConditions(uri, c).then((v){
  //     });
  //   });
  // }

  var locBox=Hive.box('LocationPermission');
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    print(status);

    await locBox.put('location', (status.isGranted)?true:false);
    if (status.isGranted) {

      print('location permission granted');



    } else if(status.isPermanentlyDenied) {
      print('location permission is permanently granted');
    }else{
      print("location permission is granted");
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isIOS = Platform.isIOS; // Check if the current platform is iOS
    bool isAndroid = Platform.isAndroid;
    if(isIOS){
      print("IOS");
    }else if(isAndroid){
      print("Android");
    }
requestLocationPermission();
    return MaterialApp(
      title: "IWAYPLUS",
      home: FutureBuilder<bool>(
        future: null,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final bool isUserAuthenticated = snapshot.data ?? false;

          if (!isUserAuthenticated) {
            var SignInDatabasebox = Hive.box('SignInDatabase');
            print("SignInDatabasebox.containsKey(accessToken)");
            print(SignInDatabasebox.containsKey("accessToken"));

            if(!SignInDatabasebox.containsKey("accessToken")){
              return SignIn();
            }else{
              // _initDeepLinkListener(context);
              return Navigation();
            } // Redirect to Sign-In screen if user is not authenticated
          } else {
            print("googleSignInUserName");
            print(googleSignInUserName);
            // _initDeepLinkListener(context);
            return Navigation(); // Redirect to MainScreen if user is authenticated
          }
        },
      ),
      supportedLocales: [
        Locale('en'), // English
        Locale('hi'), // Hindi
        // Locale('es'), // Spanish
        // Locale('fr'), // French
        // Locale('de'), // German
        Locale('ta'), // Tamil
        Locale('te'), // Telugu
        Locale('pa'), // Punjabi
      ],
      localizationsDelegates: localization.localizationsDelegates,
      //LoginScreen(),
      // MainScreen(initialIndex: 0,),

    );
  }
}

class WebApp extends StatefulWidget {
  const WebApp({super.key});

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  var SignInDatabasebox = Hive.box('SignInDatabase');

  @override
  void initState() {
    configureLocalization();
    super.initState();
  }

  void configureLocalization(){
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');
    localization.onTranslatedLanguage = ontranslatedLanguage;
  }
  void ontranslatedLanguage(Locale? locale){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SignInDatabasebox.containsKey("accessToken")?Navigation():SignIn());
  }
}

