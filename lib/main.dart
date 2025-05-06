import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/IWAYPLUS/websocket/NotifIcationSocket.dart';
import 'package:iwaymaps/NAVIGATION/DatabaseManager/DataBaseManager.dart';
import 'package:iwaymaps/NAVIGATION/Repository/RepositoryManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'IWAYPLUS/Elements/locales.dart';
import 'IWAYPLUS/FIREBASE NOTIFICATION API/PushNotifications.dart';
import 'IWAYPLUS/LOGIN SIGNUP/SignIn.dart';
import 'IWAYPLUS/MainScreen.dart';
import 'dart:io' show Platform;
import 'IWAYPLUS/websocket/navigationLogManager.dart';
import 'NAVIGATION/webHome.dart';

final navigatorKey = GlobalKey<NavigatorState>();


final navigationManager=NavigationLogManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localDBInitialsation();
  RepositoryManager().loadBuildings();
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
  DataBaseManager.init();
  await navigationManager.initialize();

  await Hive.openBox('Favourites');
  await Hive.openBox('UserInformation');
  await Hive.openBox('Filters');
  await Hive.openBox('SignInDatabase');
  await Hive.openBox('LocationPermission');
  await Hive.openBox('VersionData');

}

Future<void> mobileInitialization () async {
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
              return MainScreen(initialIndex: 0);
            } // Redirect to Sign-In screen if user is not authenticated
          } else {
            print("googleSignInUserName");
            print(googleSignInUserName);
            // _initDeepLinkListener(context);
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
  final SignInDatabasebox = Hive.box('SignInDatabase');

  late final GoRouter _router;

  @override
  void initState() {
    configureLocalization();

    _router = GoRouter(
      initialLocation: '/web',
      routes: [
        GoRoute(
          path: '/web',
          builder: (context, state) {
            // If no ID is given, show a screen to input the ID
            if(!SignInDatabasebox.containsKey("accessToken")){
              return SignIn();
            }else{
              return AskForIdPage(); // Create this screen
            }
          },
        ),
        GoRoute(
          path: '/web/:id',
          builder: (context, state) {
            if(!SignInDatabasebox.containsKey("accessToken")){
              return SignIn();
            }else{
              final id = state.pathParameters['id']!;
              return webHome(Venue: id,source: null,); // Create this screen
            }

          },
        ),
        GoRoute(
          path: '/web/:id/:source',
          builder: (context, state) {
            if(!SignInDatabasebox.containsKey("accessToken")){
              return SignIn();
            }else{
              final id = state.pathParameters['id']!;
              final source = state.pathParameters['source']!;
              return webHome(Venue: id,source: source,); // Create this screen
            }
          },
        ),
      ],
    );

    super.initState();
  }

  void configureLocalization() {
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');
    localization.onTranslatedLanguage = ontranslatedLanguage;
  }

  void ontranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}


