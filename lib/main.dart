import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import 'Navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(LandMarkApiModelAdapter());
  await Hive.openBox<LandMarkApiModel>('LandMarkApiModelFile'); //LandMarkApiModelFile name ke ek file bn rhi hy and usme LandMarkApiModelFile type ke object store ho rhe hy

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "IWAYPLUS",
      home: Navigation(),
    );
  }
}
