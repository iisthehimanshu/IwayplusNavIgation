
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/BuildingInfoScreen.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import 'package:iwaymaps/websocket/UserLog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'DATABASE/BOXES/FavouriteDataBaseModelBox.dart';
import 'DATABASE/BOXES/SignINAPIModelBox.dart';
import 'DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import 'Elements/UserCredential.dart';
import 'Elements/locales.dart';
import 'LOGIN SIGNUP/LOGIN SIGNUP APIS/MODELS/SignInAPIModel.dart';
import 'LOGIN SIGNUP/SignIn.dart';
import 'VenueSelectionScreen.dart';
import 'DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import 'DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import 'DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'MainScreen.dart';
import 'Navigation.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(LandMarkApiModelAdapter());
  await Hive.openBox<LandMarkApiModel>('LandMarkApiModelFile'); //LandMarkApiModelFile name ke ek file bn rhi hy and usme LandMarkApiModelFile type ke object store ho rhe hy
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
  // await Firebase.initializeApp();

  await Hive.openBox('Favourites');
  await Hive.openBox('UserInformation');
  //var userInformationBox = Hive.box('UserInformation');
  //userInformationBox.put("UserHeight ", 5.8);

  await Hive.openBox('Filters');
  await Hive.openBox('SignInDatabase');
  await Hive.openBox('LocationPermission');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String googleSignInUserName='';
  final FlutterLocalization localization = FlutterLocalization.instance;
  wsocket soc = wsocket();
  // Future<bool> _isUserAuthenticated() async {
  //   // Check if the user is already signed in with Google
  //   User? user = FirebaseAuth.instance.currentUser;
  //
  //   // If the user is signed in, return true
  //   if (user != null) {
  //     googleSignInUserName = user.displayName!;
  //     print(user.metadata);
  //     print(user.emailVerified);
  //     print(user.phoneNumber);
  //     print(user.photoURL);
  //     print(user.tenantId);
  //     print(user.refreshToken);
  //
  //     return true;
  //   }
  //   // If the user is not signed in, return false
  //   return false;
  // }

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
              return MainScreen(initialIndex: 0);
            } // Redirect to Sign-In screen if user is not authenticated
          } else {
            print("googleSignInUserName");
            print(googleSignInUserName);
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
