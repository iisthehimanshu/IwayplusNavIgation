import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '/IWAYPLUS/ELEMENTS/HelperClass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:iwaymaps/NAVIGATION/Navigation.dart';

import '../API/buildingAllApi.dart';
import '/IWAYPLUS/APIMODELS/buildingAll.dart';

class Deeplink{
  static String? initialDocId; // To store the initial doctor's ID from the deep link
 static String? initialServiceId;
  static String? accessToken;
  static String? bid;
  static String landmarkID = "";
  static String? source;
 static var signinBox = Hive.box('SignInDatabase');

  static Future<void> deeplinkConditions(Uri?uri,BuildContext context)async{
    if (uri != null) {

      print('Received deep link: ${uri.toString()}');

      if (uri.toString().contains("rgci.com")) {
        await rgciDeepLink(uri, context, "rgci.com");
      }else if(uri.toString().contains("iwaymaps.com")){
        await iwaymapsDeepLink(uri, context, "iwaymaps.com");
      }

    }
    return ;
  }

  static Future<void> iwaymapsDeepLink(Uri?uri,BuildContext context,String appName) async {
    print("deeplink print ${uri.toString()}");
    if(uri.toString().contains("iwayplus://${appName}/landmark")){
      final b = uri!.queryParameters['bid'];
      final l = uri!.queryParameters['landmark'];
      final s = uri!.queryParameters['source'];
      if (b != null) {
        bid = b;
      }
      if (l != null) {
        landmarkID = l;
      }
      if(s != null){
        source = s;
      }
      await buildingAllApi().fetchBuildingAllData().then((value)async{
        print("deeplink $bid ${uri!.queryParameters['bid']} $value");
        String venue = value.where((building)=>building.sId == bid).first.venueName!;
        HashMap<String,List<buildingAll>> venueMap = await HelperClass.groupBuildings(value);
        Map<String, g.LatLng> AllBuildingMap = await HelperClass.createAllbuildingMap(venueMap, venue);
        buildingAllApi.allBuildingID = AllBuildingMap;
        buildingAllApi.selectedBuildingID = bid!;
        buildingAllApi.selectedID = bid!;
        buildingAllApi.selectedVenue = venue;
        if(Deeplink.source != null){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Navigation(directsourceID: uri!.queryParameters['source']??""))
          );
        }else{
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Navigation(directLandID: uri!.queryParameters['landmark']??""))
          );
        }
        return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Navigation(directLandID: landmarkID,))
        );
      });
    }
  }

  static Future<void> rgciDeepLink(Uri?uri,BuildContext context,String appName)async{
    if (uri.toString().contains("iwayplus://${appName}/doctor")) {
      final docId = uri!.queryParameters['docId'];
      if (docId != null) {
        initialDocId = docId;
      }
    } else if (uri.toString().contains("iwayplus://${appName}/service")) {
      final serviceId = uri!.queryParameters['serviceId'];
      if (serviceId != null) {
        initialServiceId = serviceId;
      }
    } else if (uri.toString().contains("iwayplus://auth")) {
      Navigator.pushNamed(context, 'signIn');
    } else if(uri.toString().contains("iwayplus://${appName}/landmark")){
      final b = uri!.queryParameters['bid'];
      final l = uri!.queryParameters['landmark'];
      final s = uri!.queryParameters['source'];
      if (b != null) {
        bid = b;
      }
      if (l != null) {
        landmarkID = l;
      }
      if(s != null){
        source = s;
      }
      await buildingAllApi().fetchBuildingAllData().then((value)async{
        print("deeplink $bid ${uri!.queryParameters['bid']} $value");
        String venue = value.where((building)=>building.sId == bid).first.venueName!;
        HashMap<String,List<buildingAll>> venueMap = await HelperClass.groupBuildings(value);
        Map<String, g.LatLng> AllBuildingMap = await HelperClass.createAllbuildingMap(venueMap, venue);
        buildingAllApi.allBuildingID = AllBuildingMap;
        buildingAllApi.selectedBuildingID = bid!;
        buildingAllApi.selectedID = bid!;
        buildingAllApi.selectedVenue = venue;
        if(Deeplink.source != null){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Navigation(directsourceID: uri!.queryParameters['source']??""))
          );
        }else{
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Navigation(directLandID: uri!.queryParameters['landmark']??""))
          );
        }
        return;
      });
    }

    final accessToke = uri!.queryParameters['token'];
    if (accessToke != null) {
      accessToken = accessToke;

      signinBox.put('rgciCareAccessToken', accessToke);
    }
  }

  static String extractDomain(Uri uri) {
    // Convert Uri to string and use the same regular expression to match the domain part of the URL
    final regex = RegExp(r'\/iway-apps\/([^\/]+)\/');
    final match = regex.firstMatch(uri.toString());

    // If a match is found, return the matched group, otherwise return an empty string
    if (match != null && match.groupCount > 0) {
      return match.group(1) ?? '';
    }

    return '';
  }
}