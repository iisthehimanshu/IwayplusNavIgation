
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwaymaps/NAVIGATION/API/GlobalAnnotationapi.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/outbuildingmodel.dart';
import 'package:iwaymaps/NAVIGATION/DatabaseManager/SwitchDataBase.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/DataVersion.dart';
import '../DATABASE/DATABASEMODEL/DB2DataVersionLocalModel.dart';
import '../DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '../DatabaseManager/DataBaseManager.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/VenueBeaconAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/WayPointModel.dart';
import 'package:iwaymaps/NAVIGATION/Network/APIDetails.dart';
import 'package:iwaymaps/NAVIGATION/Network/NetworkManager.dart';
import 'package:iwaymaps/NAVIGATION/waypoint.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/BuildingByVenueAPIModel.dart';
import '../API/response.dart';
import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/GlobalAnnotationModel.dart';
import '../APIMODELS/beaconData.dart';
import '../APIMODELS/outdoormodel.dart';
import '../APIMODELS/patchDataModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../DATABASE/DATABASEMODEL/GlobalAnnotationAPIModel.dart';
import '../DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../DATABASE/DATABASEMODEL/OutDoorModel.dart';
import '../VenueManager/VenueManager.dart';
import '../VersioInfo.dart';

class RepositoryManager{

    static final RepositoryManager _instance = RepositoryManager._internal();

    factory RepositoryManager() {
        return _instance;
    }

    RepositoryManager._internal() {
        // ✅ This block runs only ONCE, when the singleton is first created
        loadBuildings();
    }

    NetworkManager networkManager = NetworkManager();
    DataBaseManager dataBaseManager = DataBaseManager();
    SwitchDataBase switchDataBase = SwitchDataBase();
    Apidetails apiDetails = Apidetails();
    bool shouldBeInjected = false;
    bool preLoadDataBaseCreated = false;


    Future<void> loadBuildings() async {
        print("loadBuildings");
        List<dynamic> list = await getBuildingByVenue(VenueManager().venueName);
        VenueManager().buildings = list.whereType<Buildingbyvenue>().toList();
        print("VenueManager().buildings ${VenueManager().buildings}");
        VenueManager().buildings.forEach((buildingData){
            getDataVersionData(buildingData.sId!);
        });



    }

    void loadPreLoadedDataBase(){
        if(!preLoadDataBaseCreated) {
            VenueManager().buildings.forEach((buildingByVenue) async {
                Detail dataVersionDetails = await apiDetails.dataVersion(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                Response dataVersionDataFromAPI = await networkManager.api.request(dataVersionDetails);
                if(dataVersionDataFromAPI.statusCode == 200) {
                    final apiData = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);
                    print("dataVersion ${apiData.versionData!.buildingID}");
                    final dataVersionData = DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                    DataBaseManager().saveData(dataVersionData, dataVersionDetails, buildingByVenue.sId!);
                }

                print("CREATING PRELOADED DATABASE");
                Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                if (kDebugMode) print("${landmarkDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonString = await rootBundle.loadString('assets/PreLoads/${landmarkDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final data = json.decode(jsonString);
                final landmarkData = LandMarkApiModel(responseBody: data);
                DataBaseManager().saveData(landmarkData, landmarkDetail, buildingByVenue.sId!);

                Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                if (kDebugMode) print("${polylineDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonStringPolyline = await rootBundle.loadString('assets/PreLoads/${polylineDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final dataPolyline = json.decode(jsonStringPolyline);
                final polyLineData = PolyLineAPIModel(responseBody: dataPolyline);
                DataBaseManager().saveData(polyLineData, polylineDetail, buildingByVenue.sId!);

                Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                if (kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonStringPatch = await rootBundle.loadString('assets/PreLoads/${patchDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final dataPatch = json.decode(jsonStringPatch);
                final patchData = PatchAPIModel(responseBody: dataPatch);
                DataBaseManager().saveData(patchData, patchDetail, buildingByVenue.sId!);
                preLoadDataBaseCreated = true;
            });
        }

    }




    Future<dynamic> getLandmarkData(String bID) async {
        if (bID.isEmpty) return null;
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(switchDataBase.isGreenDataBaseActive()){
            if(kDebugMode) print("${landmarkDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            String jsonString = await rootBundle.loadString('assets/PreLoads/${landmarkDetail.getPreLoadPrefix}$bID.json');
            final data = json.decode(jsonString);
            final landmarkData = LandMarkApiModel(responseBody: data);
            DataBaseManager().saveData(landmarkData, landmarkDetail, bID);
        }else {
            print("getLandmarkData");
            if (landmarkBox.containsKey(bID)) {
                if (kDebugMode) {
                    print("Data from DB");
                }
                LandMarkApiModel responseFromDatabase = DataBaseManager()
                    .getData(landmarkDetail, bID);
                return landmarkDetail.conversionFunction(
                    responseFromDatabase.responseBody);
            } else {
                Response dataFromAPI = await networkManager.api.request(
                    landmarkDetail);
                if (kDebugMode) {
                    print("Data from API");
                }
                if (dataFromAPI.statusCode == 200) {
                    final landmarkData = LandMarkApiModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(landmarkData, landmarkDetail, bID);
                    return landmarkDetail.conversionFunction(dataFromAPI.data);
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                    //open new screen
                }
            }
        }
    }

    Future<dynamic> getPolylineData(String bID) async {
        if (bID.isEmpty) {
            print("getPolylineData bID was null $bID");
            return null;
        }

        Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), bID);
        final polylineBox = polylineDetail.dataBaseGetData!();

        if(switchDataBase.isGreenDataBaseActive()){
            if(kDebugMode) print("${polylineDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            String jsonString = await rootBundle.loadString('assets/PreLoads/${polylineDetail.getPreLoadPrefix}$bID.json');
            final data = json.decode(jsonString);
            final polyLineData = PolyLineAPIModel(responseBody: data);
            DataBaseManager().saveData(polyLineData, polylineDetail, bID);
        }else {
            if (polylineBox.containsKey(bID)) {
                if (kDebugMode) {
                    print("POLYLINE DATA FROM DATABASE");
                }
                PolyLineAPIModel responseFromDatabase = DataBaseManager()
                    .getData(polylineDetail, bID);
                return polylineDetail.conversionFunction(
                    responseFromDatabase.responseBody);
            } else {
                Response dataFromAPI = await networkManager.api.request(
                    polylineDetail);
                if (kDebugMode) {
                    print("POLYLINE DATA FROM API");
                }
                if (dataFromAPI.statusCode == 200) {
                    final polyLineData = PolyLineAPIModel(
                        responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(
                        polyLineData, polylineDetail, bID);
                    return polylineDetail.conversionFunction(dataFromAPI.data);
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            }
        }
    }

    Future<dynamic> getDataVersionData(String bID) async {
        Detail dataVersionDetails = await apiDetails.dataVersion(dataBaseManager.getAccessToken(), bID);
        final DataBox = dataVersionDetails.dataBaseGetDataDB2!();
        final preLoadedDataBox = dataVersionDetails.dataBaseGetData!();

        Response dataVersionDataFromAPI = await networkManager.api.request(dataVersionDetails);
        if(dataVersionDataFromAPI.statusCode == 200){
            final apiData = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);
            print("dataVersion ${apiData.versionData!.buildingID}");
            if (preLoadedDataBox.containsKey(apiData.versionData!.buildingID)) {
                print('DATA ALREADY PRESENT');
                final databaseData = DataVersion.fromJson(preLoadedDataBox.get(apiData.versionData!.buildingID)!.responseBody);
                if (apiData.versionData!.buildingDataVersion != databaseData.versionData!.buildingDataVersion) {
                    print("match ${apiData.versionData!.buildingID!} and $bID");
                    VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = true;
                    shouldBeInjected = true;
                    print("Building Version Change = true ${apiData.versionData!.buildingDataVersion} ${databaseData.versionData!.buildingDataVersion}");
                } else {
                    print("match ${apiData.versionData!.buildingID!} and $bID");
                    VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                    print("Building Version Change = false");
                }

                if (apiData.versionData!.patchDataVersion !=
                    databaseData.versionData!.patchDataVersion) {
                    VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                        .buildingID!] = true;
                    shouldBeInjected = true;
                    print("Patch Version Change = true ${apiData.versionData!
                        .patchDataVersion} ${databaseData.versionData!
                        .patchDataVersion}");
                } else {
                    print("match ${apiData.versionData!.buildingID!} and $bID");

                    VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                        .buildingID!] = false;
                    print("Patch Version Change = false");
                }

                if (apiData.versionData!.landmarksDataVersion !=
                    databaseData.versionData!.landmarksDataVersion) {
                    VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                        .buildingID!] = true;
                    shouldBeInjected = true;
                    print("Landmark Version Change = true ${apiData.versionData!
                        .landmarksDataVersion} ${databaseData.versionData!
                        .landmarksDataVersion}");
                } else {
                    print("match ${apiData.versionData!.buildingID!} and $bID");

                    VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                        .buildingID!] = false;
                    print("Landmark Version Change = false");
                }

                if (apiData.versionData!.polylineDataVersion !=
                    databaseData.versionData!.polylineDataVersion) {
                    VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                        .buildingID!] = true;
                    shouldBeInjected = true;
                    print("Polyline Version Change = true ${apiData.versionData!
                        .polylineDataVersion} ${databaseData.versionData!
                        .polylineDataVersion}");
                } else {
                    print("match ${apiData.versionData!.buildingID!} and $bID");

                    VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                        .buildingID!] = false;
                    print(VersionInfo.buildingPolylineDataVersionUpdate[apiData
                        .versionData!.buildingID!]);
                    print(apiData.versionData!.buildingID!);
                    print("Polyline Version Change = false");
                }
                if (shouldBeInjected) {
                    final dataVersionData = DB2DataVersionLocalModel(
                        responseBody: dataVersionDataFromAPI.data);
                    DataBox.delete(DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID);
                    print("database deleted ${DataBox.containsKey(DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID)}");
                    DataBaseManager().saveData(dataVersionData, dataVersionDetails, bID);
                    print("New Data ${DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID} ${dataVersionData}");
                    dataVersionData.save();
                }
            } else {
                print('DATA NOT PRESENT');
                VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                if (!shouldBeInjected) {
                    print('DATA INJECTED');
                    final dataVersionData = DB2DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);

                    DataBaseManager().saveData(dataVersionData, dataVersionDetails, bID);
                }
            }
        }
    }

    Future<dynamic> getPatchData(String bID) async {
        Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), bID);
        final patchBox = patchDetail.dataBaseGetData!();


        if(switchDataBase.isGreenDataBaseActive()){
            if(kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            String jsonString = await rootBundle.loadString('assets/PreLoads/${patchDetail.getPreLoadPrefix}$bID.json');
            final data = json.decode(jsonString);
            final patchData = PatchAPIModel(responseBody: data);
            DataBaseManager().saveData(patchData, patchDetail, bID);
        }else {
            print("2nd iteration patch return");
            if (patchBox.containsKey(bID)) {
                if (kDebugMode) {
                    print("PATCH DATA FROM DATABASE");
                }
                PatchAPIModel responseFromDatabase = DataBaseManager().getData(
                    patchDetail, bID);
                return patchDetail.conversionFunction(
                    responseFromDatabase.responseBody);
            } else {
                Response dataFromAPI = await networkManager.api.request(
                    patchDetail);
                if (kDebugMode) {
                    print("PATCH DATA FROM DATABASE API");
                }
                if (dataFromAPI.statusCode == 200) {
                    final patchData = PatchAPIModel(
                        responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(patchData, patchDetail, bID);
                    return patchDetail.conversionFunction(dataFromAPI.data);
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            }
        }
    }

    Future<dynamic> getSingleBuildingBeaconData(String bID) async {
        Detail beaconDetail = apiDetails.buildingBeacons(dataBaseManager.getAccessToken(), bID);
        final beaconBox = beaconDetail.dataBaseGetData!();

        if(switchDataBase.isGreenDataBaseActive()){
            return getPreLoadedData(beaconDetail,bID);
        }else {
            return;
            if (beaconBox.containsKey(bID)) {
                if (kDebugMode) {
                    print("BEACON DATA FROM DATABASE");
                }
                BeaconAPIModel responseFromDatabase = DataBaseManager().getData(
                    beaconDetail, bID);
                return beaconDetail.conversionFunction(
                    responseFromDatabase.responseBody);
            } else {
                Response dataFromAPI = await networkManager.api.request(
                    beaconDetail);
                if (kDebugMode) {
                    print("POLYLINE DATA FROM API");
                }
                if (dataFromAPI.statusCode == 200) {
                    final beaconData = BeaconAPIModel(
                        responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(beaconData, beaconDetail, bID);
                    return dataFromAPI.data;
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            }
        }
    }

    Future<dynamic> getVenueBeaconData() async {
        Detail venueBeaconDetail = apiDetails.venueBeacons(dataBaseManager.getAccessToken(), VenueManager().venueName);
        final venueBeaconBox = venueBeaconDetail.dataBaseGetData!();

        if(venueBeaconBox.containsKey(VenueManager().venueName)){
            if (kDebugMode) {
                print("VENUE BEACON DATA FROM DATABASE");
            }
            VenueBeaconAPIModel responseFromDatabase = DataBaseManager().getData(venueBeaconDetail, VenueManager().venueName);
            return venueBeaconDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(venueBeaconDetail);
            if (kDebugMode) {
                print("VENUE BEACON DATA FROM API");
            }
            if(dataFromAPI.statusCode == 200) {
                final venueBeaconData = VenueBeaconAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(venueBeaconData, venueBeaconDetail, VenueManager().venueName);
                return dataFromAPI.data;
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }

        }
    }

    Future<dynamic> getBuildingByVenue(String venueName) async {
        Detail buildingByVenueDetail = apiDetails.buildingByVenueApi(dataBaseManager.getAccessToken(), venueName);

        if(buildingByVenueDetail.dataBaseGetData != null) {
            final buildingByVenueBox = buildingByVenueDetail.dataBaseGetData!();
            if(buildingByVenueBox.containsKey(venueName)) {
                if (kDebugMode) {
                    print("Data from DB");
                }
                BuildingByVenueAPIModel responseFromDatabase = DataBaseManager()
                    .getData(buildingByVenueDetail, venueName);
                return buildingByVenueDetail.conversionFunction(responseFromDatabase.responseBody);
            }
        }else {
            Response dataFromAPI = await networkManager.api.request(buildingByVenueDetail);
            if (kDebugMode) {
              print("Data from API");
            }
            if(dataFromAPI.statusCode == 200) {
                // final buildingByVenueData = BuildingByVenueAPIModel(
                //     responseBody: dataFromAPI.data);
                // DataBaseManager().saveData(
                //     buildingByVenueData, buildingByVenueDetail, venueName);
                return buildingByVenueDetail.conversionFunction(dataFromAPI.data);
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }
        }
    }

    Future<dynamic> getGlobalAnnotationData(String bID) async {
        Detail globalAnnotationDetail = apiDetails.globalAnnotation(dataBaseManager.getAccessToken(), bID);
        final globalAnnotationBox = globalAnnotationDetail.dataBaseGetData!();

        if(globalAnnotationBox.containsKey(bID)){
            if (kDebugMode) {
              print("Data from DB");
            }
            GlobalAnnotationAPIModel responseFromDatabase = DataBaseManager().getData(globalAnnotationDetail, bID);
            return globalAnnotationDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(globalAnnotationDetail);
            if (kDebugMode) {
              print("Data from API");
            }
            if(dataFromAPI.statusCode == 200) {
                final globalAnnotationData = GlobalAnnotationAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(
                    globalAnnotationData, globalAnnotationDetail, bID);
                return dataFromAPI.data;
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }
        }
    }

    Future<dynamic> getWaypointData(String bID) async {
        Detail waypointDetails = apiDetails.waypoint(dataBaseManager.getAccessToken(), bID);
        final waypointBox = waypointDetails.dataBaseGetData!();
        if (waypointBox.containsKey(bID)) {
            if (kDebugMode) {
                print("WAYPOINT DATA FROM DATABASE");
            }
            WayPointModel responseFromDatabase = DataBaseManager().getData(waypointDetails, bID);
            return waypointDetails.conversionFunction(responseFromDatabase.responseBody);
        } else {

            Response dataFromAPI = await networkManager.api.request(
                waypointDetails);
            if (kDebugMode) {
                print("POLYLINE DATA FROM API");
            }
            if (dataFromAPI.statusCode == 200) {
                final wayPointData = WayPointModel(
                    responseBody: dataFromAPI.data);
                DataBaseManager().saveData(
                    wayPointData, waypointDetails, bID);
                return dataFromAPI.data;
            } else if (dataFromAPI.statusCode == 201) {
                return null;
            } else {
                return null;
            }
        }


    }

    Future<dynamic> getCampusData(List<String> bIDS) async {
        Detail campusDetails = apiDetails.outBuilding(dataBaseManager.getAccessToken(), bIDS);
        final campusBox = campusDetails.dataBaseGetData!();

        for (var bid in bIDS) {
            if(campusBox.containsKey(bid)){
                if (kDebugMode) {
                    print("Data from DB");
                }
                OutDoorModel responseFromDatabase = DataBaseManager().getData(campusDetails, bid);
                return campusDetails.conversionFunction(responseFromDatabase.responseBody);
            }
        }

        Response dataFromAPI = await networkManager.api.request(campusDetails);
        if (kDebugMode) {
            print("Data from API");
        }
        if(dataFromAPI.statusCode == 200) {
            final campusData = OutDoorModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(campusData, campusDetails, bIDS[0]);
            return dataFromAPI.data;
        }else if(dataFromAPI.statusCode == 201){
            return null;
        }else{
            return null;
        }

    }

    dynamic getPreLoadedData(Detail details,String bID) async {
        // if(kDebugMode) print("${details.getPreLoadPrefix} DATA FROM GREEN DATABASE");
        String jsonString = await rootBundle.loadString('assets/PreLoads/${details.getPreLoadPrefix}$bID.json');
        final data = json.decode(jsonString);
        details.method;
        return details.conversionFunction(data);
    }

}

