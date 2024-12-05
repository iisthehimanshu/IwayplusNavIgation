
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/IWAYPLUS/BuildingInfoScreen.dart';
import 'package:iwaymaps/IWAYPLUS/websocket/NotifIcationSocket.dart';
import 'package:iwaymaps/IWAYPLUS/websocket/UserLog.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import '/IWAYPLUS/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import '/IWAYPLUS/DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '/NAVIGATION/DATABASE/BOXES/BeaconAPIModelBOX.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/OutDoorModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/WayPointModel.dart';

import '/NAVIGATION/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import '/NAVIGATION/DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import 'DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import 'Elements/deeplinks.dart';
import 'Elements/locales.dart';
import 'FIREBASE NOTIFICATION API/PushNotifications.dart';
import 'LOGIN SIGNUP/SignIn.dart';
import 'MainScreen.dart';
import '/NAVIGATION/Navigation.dart';
import 'dart:io' show Platform;

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if(message.notification != null){
    print("Some notification Received");
  }
}
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  localDBInitialsation();
  if(!kIsWeb){
    mobileInitialization();
    runApp(const MobileApp());
  }else{
    runApp(const WebApp());
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
  WakelockPlus.enable();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );

  //ON BACKGROUND TAPPED
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if(message.notification != null){
      print("BACKGROUNG NOTIFICATION TAPPED");
      //navigatorKey.currentState!.pushNamed("/message",arguments: message);
    }
  });

  // PushNotifications.init();
  PushNotifications.localNotiInit();
  //firebase listen to background notification
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  PushNotifications().foregroundMessage();

  //to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {

    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if(kDebugMode){
      print("notificationtitle ${message.notification!.title}");
      print("notificationbody ${message.notification!.body}");
    }
    if(Platform.isIOS){
      PushNotifications().foregroundMessage();
    }

    if(message.notification!=null){
      PushNotifications.showSimpleNotification(title: message.notification!.title!, body: message.notification!.body!, payload: payloadData);
    }
  });

  // for handling in terminated state
  FirebaseMessaging.instance.getInitialMessage().then((message){
    if (message != null) {
      print("Launched from terminated state");
      Future.delayed(Duration(seconds: 1), () {
        navigatorKey.currentState!.pushNamed("/message", arguments: message);
      });
    }
  });

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
  late AppLinks _appLinks;

  @override
  void initState() {
    configureLocalization();
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _initDeepLinkListener(context);
    // });
  }
  void configureLocalization(){
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');
    localization.onTranslatedLanguage = ontranslatedLanguage;
  }

  void ontranslatedLanguage(Locale? locale){
    setState(() {

    });
  }

  void _initDeepLinkListener(BuildContext c) async {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      Deeplink.deeplinkConditions(uri, c).then((v){
      });
    });
  }

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
              _initDeepLinkListener(context);
              return MainScreen(initialIndex: 0);
            } // Redirect to Sign-In screen if user is not authenticated
          } else {
            print("googleSignInUserName");
            print(googleSignInUserName);
            _initDeepLinkListener(context);
            return MainScreen(initialIndex: 0); // Redirect to MainScreen if user is authenticated
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
    return const MaterialApp(home: SignIn(emailOrPhoneNumber: "mailtohimanshu100@gmail.com",password: "BlackWater4232",));
  }
}

