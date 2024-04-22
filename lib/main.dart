import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iwayplusnav/BuildingInfoScreen.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import 'package:path_provider/path_provider.dart';

import 'DATABASE/BOXES/BeaconAPIModelBOX.dart';
import 'DATABASE/BOXES/FavouriteDataBaseModelBox.dart';
import 'DATABASE/BOXES/SignINAPIModelBox.dart';
import 'DATABASE/DATABASEMODEL/SignINAPIModel.dart';
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
  await Hive.openBox('Filters');
  await Hive.openBox('SignInDatabase');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String googleSignInUserName='';
  Future<bool> _isUserAuthenticated() async {
    // Check if the user is already signed in with Google
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is signed in, return true
    if (user != null) {
      googleSignInUserName = user.displayName!;
      print(user.metadata);
      print(user.emailVerified);
      print(user.phoneNumber);
      print(user.photoURL);
      print(user.tenantId);
      print(user.refreshToken);

      return true;
    }
    // If the user is not signed in, return false
    return false;
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

    return MaterialApp(
      title: "IWAYPLUS",
      home: MainScreen()


      // FutureBuilder<bool>(
      //   future: _isUserAuthenticated(),
      //   builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return CircularProgressIndicator();
      //     }
      //     if (snapshot.hasError) {
      //       return Text(snapshot.error.toString());
      //     }
      //
      //     final bool isUserAuthenticated = snapshot.data ?? false;
      //
      //     if (!isUserAuthenticated) {
      //       var SignInDatabasebox = Hive.box('SignInDatabase');
      //       print(SignInDatabasebox.values);
      //       //List<dynamic> ss = SignInDatabasebox.get("roles");
      //       // print(ss.length);
      //       // if(SignInDatabasebox.get("roles")=="[user]"){
      //       //   print("True");
      //       // }
      //       final SigninBox = SignINAPIModelBox.getData();
      //       print("SigninBox.length");
      //       print(SigninBox.values);
      //       print(SigninBox);
      //       print(googleSignInUserName);
      //
      //       if(!SignInDatabasebox.containsKey("accessToken")){
      //         return SignIn();
      //       }else{
      //
      //         return MainScreen(initialIndex: 0);
      //       } // Redirect to Sign-In screen if user is not authenticated
      //     } else {
      //       print("googleSignInUserName");
      //       print(googleSignInUserName);
      //       return MainScreen(initialIndex: 0); // Redirect to MainScreen if user is authenticated
      //     }
      //   },
      // ),

    );
  }
}
