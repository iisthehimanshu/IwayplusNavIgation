
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iwaymaps/NAVIGATION/API/GlobalAnnotationapi.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/outbuildingmodel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/DB2BeaconAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/DB2PolyLineAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DatabaseManager/SwitchDataBase.dart';
import '../../IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/DataVersion.dart';
import '../DATABASE/DATABASEMODEL/DB2DataVersionLocalModel.dart';
import '../DATABASE/DATABASEMODEL/DB2LandMarkApiModel.dart';
import '../DATABASE/DATABASEMODEL/DB2PatchAPIModel.dart';
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

    }

    void loadPreLoadedDataBase(){
        if(!preLoadDataBaseCreated) {
            VenueManager().buildings.forEach((buildingByVenue) async {
                print("CREATING DB1 FROM PRELOADED JSON");
                Detail dataVersionDetail = apiDetails.dataVersion(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                String jsonStringDataVersion = await rootBundle.loadString('assets/PreLoads/${dataVersionDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final versionData = json.decode(jsonStringDataVersion);
                final dataVersionData = DataVersionLocalModel(responseBody: versionData);
                DataBaseManager().saveData(dataVersionData, dataVersionDetail, buildingByVenue.sId!);
                print("CREATING DB1 DATA VERSION ${DataBaseManager().getDataBaseKeys(dataVersionDetail)}");


                Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // if (kDebugMode) print("${landmarkDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonString = await rootBundle.loadString('assets/PreLoads/${landmarkDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final data = json.decode(jsonString);
                final landmarkData = LandMarkApiModel(responseBody: data);
                DataBaseManager().saveData(landmarkData, landmarkDetail, buildingByVenue.sId!);
                print("CREATING DB1 LANDMARK ${DataBaseManager().getDataBaseKeys(landmarkDetail)}");

                Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // if (kDebugMode) print("${polylineDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonStringPolyline = await rootBundle.loadString('assets/PreLoads/${polylineDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final dataPolyline = json.decode(jsonStringPolyline);
                final polyLineData = PolyLineAPIModel(responseBody: dataPolyline);
                DataBaseManager().saveData(polyLineData, polylineDetail, buildingByVenue.sId!);
                print("CREATING DB1 POLYLINE ${DataBaseManager().getDataBaseKeys(polylineDetail)}");


                Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // if (kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonStringPatch = await rootBundle.loadString('assets/PreLoads/${patchDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final dataPatch = json.decode(jsonStringPatch);
                final patchData = PatchAPIModel(responseBody: dataPatch);
                DataBaseManager().saveData(patchData, patchDetail, buildingByVenue.sId!);
                print("CREATING DB1 PATCH ${DataBaseManager().getDataBaseKeys(patchDetail)}");


                Detail beaconDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // if (kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonStringbeacon = await rootBundle.loadString('assets/PreLoads/${beaconDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final databeacon = json.decode(jsonStringbeacon);
                final beaconData = PatchAPIModel(responseBody: databeacon);
                DataBaseManager().saveData(beaconData, patchDetail, buildingByVenue.sId!);
                print("BEACON ${DataBaseManager().getDataBaseKeys(beaconDetail)}");


                Detail waypointDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), buildingByVenue.sId!);
                // if (kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
                String jsonStringwaypoint = await rootBundle.loadString('assets/PreLoads/${waypointDetail.getPreLoadPrefix}${buildingByVenue.sId!}.json');
                final dataWaypoint= json.decode(jsonStringwaypoint);
                final waypointData = PatchAPIModel(responseBody: dataWaypoint);
                DataBaseManager().saveData(waypointData, patchDetail, buildingByVenue.sId!);
                print("WAYPOINT ${DataBaseManager().getDataBaseKeys(waypointDetail)}");
                preLoadDataBaseCreated = true;
            });
        }else{
            print("DB1 ALREADY CREATED FROM PRELOADED JSON");
        }

    }


    Future<dynamic> getLandmarkDataNew(String bID) async {
        Detail landmarkDetail = await apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        if(SwitchDataBase().isGreenDataBaseActive()){
            LandMarkApiModel responseFromDatabase = DataBaseManager().getData(landmarkDetail, bID);
            print("LANDMARK DATA FROM DB1");
            return landmarkDetail.conversionFunction(responseFromDatabase.responseBody);
        }else{
            DB2LandMarkApiModel responseFromDatabase = DataBaseManager().getDataDB2(landmarkDetail, bID);
            print("LANDMARK DATA FROM DB2");
            return landmarkDetail.conversionFunction(responseFromDatabase.responseBody);
        }
    }

    Future<dynamic> runAPICallLandmarkData(String bID,{bool generateJSON = false}) async {
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        Response dataFromAPI = await networkManager.api.request(landmarkDetail);
        if(generateJSON){
            final landmarkData = LandMarkApiModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(landmarkData, landmarkDetail, bID);
            if(generateJSON) {
                print("JSONresponseBody");
                Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                HelperClass().saveJsonToAndroidDownloads("Landmark$bID", formattedJson);
            }
            if (kDebugMode) {
                print("GENERATED JSON FOR LANDMARK $bID");
            }
        }else{
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final patchData = DB2LandMarkApiModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(patchData, landmarkDetail, bID);
                    print("LANDMARK DATA FROM API STORED IN DB2");
                }else{
                    final patchData = LandMarkApiModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(patchData, landmarkDetail, bID);
                    print("LANDMARK DATA FROM API STORED IN DB1");
                }
            }
        }
    }

    Future<dynamic> getLandmarkData(String bID,{bool generateJSON = false}) async {
        if (bID.isEmpty) return null;
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(switchDataBase.isGreenDataBaseActive()){
            if(kDebugMode) print("${landmarkDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            LandMarkApiModel responseFromDatabase = DataBaseManager().getData(landmarkDetail, bID);
            return landmarkDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            print("getLandmarkData");
            if(generateJSON || !landmarkBox.containsKey(bID)){
                Response dataFromAPI = await networkManager.api.request(
                    landmarkDetail);
                if (dataFromAPI.statusCode == 200) {
                    final landmarkData = LandMarkApiModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(landmarkData, landmarkDetail, bID);
                    if(generateJSON) {
                        print("JSONresponseBody");
                        Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                        String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                        HelperClass().saveJsonToAndroidDownloads("Landmark$bID", formattedJson);
                    }
                    if (kDebugMode) {
                        generateJSON? print("GENERATED JSON FOR LANDMARK $bID") : print("LANDMARK DATA FROM API");
                    }
                    return landmarkDetail.conversionFunction(dataFromAPI.data);
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                    //open new screen
                }
            }else {
                if (kDebugMode) {
                    print("LANDMARK DATA FROM DATABASE");
                }
                LandMarkApiModel responseFromDatabase = DataBaseManager().getData(landmarkDetail, bID);
                return landmarkDetail.conversionFunction(responseFromDatabase.responseBody);
            }
        }
    }


    Future<dynamic> getPolylineDataNew(String bID) async {
        Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), bID);
        if(SwitchDataBase().isGreenDataBaseActive()){
            PolyLineAPIModel responseFromDatabase = DataBaseManager().getData(polylineDetail, bID);
            print("POLYLINE DATA FROM DB1");
            return polylineDetail.conversionFunction(responseFromDatabase.responseBody);
        }else{
            DB2PolyLineAPIModel responseFromDatabase = DataBaseManager().getDataDB2(polylineDetail, bID);
            print("POLYLINE DATA FROM DB2");
            return polylineDetail.conversionFunction(responseFromDatabase.responseBody);
        }
    }

    Future<dynamic> runAPICallPolylineData(String bID,{bool generateJSON = false}) async {
        Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), bID);
        Response dataFromAPI = await networkManager.api.request(polylineDetail);
        if(generateJSON){
            if(dataFromAPI.statusCode == 200) {
                final patchData = PolyLineAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(patchData, polylineDetail, bID);
                Map<String, dynamic> JSONresponseBody = dataFromAPI.data;
                String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                HelperClass().saveJsonToAndroidDownloads("Polyline$bID", formattedJson);
                if (kDebugMode) {
                    print("GENERATED JSON FOR POLYLINE $bID");
                }
            }
        }else {
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final polylineData = DB2PolyLineAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(polylineData, polylineDetail, bID);
                    print("POLYLINE DATA FROM API STORED IN DB2");
                }else{
                    final polylineData = PolyLineAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(polylineData, polylineDetail, bID);
                    print("POLYLINE DATA FROM API STORED IN DB1");
                }
            }
        }

    }

    Future<dynamic> getPolylineData(String bID,{bool generateJSON = false}) async {
        if (bID.isEmpty) {
            print("GET_POLYLINE_DATA() BID WAS NULL!!");
            return null;
        }

        Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), bID);
        final polylineBox = polylineDetail.dataBaseGetData!();

        if(switchDataBase.isGreenDataBaseActive()){
            if(kDebugMode) print("${polylineDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            PolyLineAPIModel responseFromDatabase = DataBaseManager().getData(polylineDetail, bID);
            return polylineDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            if(generateJSON || !polylineBox.containsKey(bID)){
                Response dataFromAPI = await networkManager.api.request(polylineDetail);

                if (dataFromAPI.statusCode == 200) {
                    final polyLineData = PolyLineAPIModel(
                        responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(polyLineData, polylineDetail, bID);
                    if(generateJSON) {
                        Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                        String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                        HelperClass().saveJsonToAndroidDownloads("Polyline$bID", formattedJson);
                    }
                    if (kDebugMode) {
                        generateJSON? print("GENERATED JSON FOR POLYLINE $bID") : print("POLYLINE DATA FROM API");
                    }
                    return polylineDetail.conversionFunction(dataFromAPI.data);
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            }else{
                if (kDebugMode) {
                    print("POLYLINE DATA FROM DATABASE");
                }
                PolyLineAPIModel responseFromDatabase = DataBaseManager().getData(polylineDetail, bID);
                return polylineDetail.conversionFunction(responseFromDatabase.responseBody);
            }
        }
    }


    Future<dynamic> getDataVersionDatanew(String bID) async {
        Detail dataVersionDetails = await apiDetails.dataVersion(dataBaseManager.getAccessToken(), bID);
        if(SwitchDataBase().isGreenDataBaseActive()){
            if(kDebugMode) print("${dataVersionDetails.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            DataVersionLocalModel responseFromDatabase = DataBaseManager().getData(dataVersionDetails, bID);
            return dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
        }else{
            if(kDebugMode) print("${dataVersionDetails.getPreLoadPrefix} DATA FROM BLUE DATABASE");
            DataVersionLocalModel responseFromDatabase = DataBaseManager().getDataDB2(dataVersionDetails, bID);
            return dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
        }
    }


    Future<dynamic> runAPICallDataVersion(String bID,{bool generateJSON = false}) async {
        Detail dataVersionDetails = await apiDetails.dataVersion(dataBaseManager.getAccessToken(), bID);
        Response dataVersionDataFromAPI = await networkManager.api.request(dataVersionDetails);
        if(generateJSON){
            if(dataVersionDataFromAPI.statusCode == 200) {
                final apiData = DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                DataBaseManager().saveData(apiData, dataVersionDetails, bID);
                if (generateJSON) {
                    Map<String, dynamic> JSONresponseBody = dataVersionDataFromAPI.data;String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("DataVersion$bID", formattedJson);
                }
                if (kDebugMode) {
                    print("GENERATED JSON FOR DATA VERSION $bID");
                }
            }
        }else{
            if(dataVersionDataFromAPI.statusCode == 200){
                if(SwitchDataBase().isGreenDataBaseActive()) {
                    print("DB1 ACTIVE");

                    DataVersionLocalModel responseFromDatabase = DataBaseManager().getData(dataVersionDetails, bID);
                    DataVersion DB1Data = dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
                    DataVersion newData = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);
                    final dataVersionNewData = DB2DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                    DataBaseManager().saveDataDB2(dataVersionNewData, dataVersionDetails, bID);

                    if(newData.versionData!.buildingDataVersion! > DB1Data.versionData!.buildingDataVersion! ||
                        newData.versionData!.patchDataVersion! > DB1Data.versionData!.patchDataVersion! ||
                        newData.versionData!.polylineDataVersion! > DB1Data.versionData!.polylineDataVersion! ||
                        newData.versionData!.landmarksDataVersion! > DB1Data.versionData!.landmarksDataVersion!){
                        if (kDebugMode) {
                            print("DATA VERSION DATA FROM API STORING IN DB2");
                            print(DataBaseManager().getDataBaseKeysDB2(dataVersionDetails));
                        }
                        SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                        print("REQUESTING TO CREATE DB2");
                    }else{
                        print("DATA VERSION DATA FROM API NO NEW VERSION FOUND");
                    }
                }else{
                    print("DB2 ACTIVE");

                    DB2DataVersionLocalModel responseFromDatabase = DataBaseManager().getDataDB2(dataVersionDetails, bID);
                    DataVersion DB2Data = dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
                    DataVersion newData = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);
                    final dataVersionNewData = DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                    DataBaseManager().saveData(dataVersionNewData, dataVersionDetails, bID);
                    if(newData.versionData!.buildingDataVersion! > DB2Data.versionData!.buildingDataVersion! ||
                        newData.versionData!.patchDataVersion! > DB2Data.versionData!.patchDataVersion! ||
                        newData.versionData!.polylineDataVersion! > DB2Data.versionData!.polylineDataVersion! ||
                        newData.versionData!.landmarksDataVersion! > DB2Data.versionData!.landmarksDataVersion!){
                        if (kDebugMode) {
                            print("DATA VERSION DATA FROM API STORING IN DB1");
                            print(DataBaseManager().getDataBaseKeys(dataVersionDetails));
                        }

                        SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                        print("REQUESTING TO CREATE DB1");
                    }else{
                        print("DATA VERSION DATA FROM API NO NEW VERSION FOUND");
                    }
                }
            }
        }
    }

    Future<dynamic> getDataVersionData(String bID,{bool generateJSON = false}) async {
        Detail dataVersionDetails = await apiDetails.dataVersion(dataBaseManager.getAccessToken(), bID);

        if(SwitchDataBase().isGreenDataBaseActive()){
            if(kDebugMode) print("${dataVersionDetails.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            DataVersionLocalModel responseFromDatabase = DataBaseManager().getData(dataVersionDetails, bID);
            return dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
        }else if(!SwitchDataBase().isGreenDataBaseActive()){
            Response dataVersionDataFromAPI = await networkManager.api.request(dataVersionDetails);
            if(dataVersionDataFromAPI.statusCode == 200){
                print("getting data from DB1");
                DataVersionLocalModel responseFromDatabase = DataBaseManager().getData(dataVersionDetails, bID);
                DataVersion DB1Data = dataVersionDetails.conversionFunction(responseFromDatabase.responseBody);
                DataVersion newData = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);

                if(newData.versionData!.buildingDataVersion! > DB1Data.versionData!.buildingDataVersion!){
                    VersionInfo.buildingBuildingDataVersionUpdate[newData.versionData!.buildingID!] = true;
                    SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                    VersionInfo.shouldBeUpdated = true;
                    print("FOUND NEW DATA BUILDING DATAVERSION");
                }else{
                    VersionInfo.buildingBuildingDataVersionUpdate[newData.versionData!.buildingID!] = false;
                    print("NO NEW DATA FOR BUILDING DATAVERSION");

                }
                if(newData.versionData!.patchDataVersion! > DB1Data.versionData!.patchDataVersion!){
                    VersionInfo.buildingPatchDataVersionUpdate[newData.versionData!.buildingID!] = true;
                    SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                    VersionInfo.shouldBeUpdated = true;
                    print("FOUND NEW DATA PATCH DATAVERSION");
                }else{
                    VersionInfo.buildingPatchDataVersionUpdate[newData.versionData!.buildingID!] = false;
                    print("NO NEW DATA FOR PATCH DATAVERSION");

                }
                if(newData.versionData!.polylineDataVersion! > DB1Data.versionData!.polylineDataVersion!){
                    VersionInfo.buildingPolylineDataVersionUpdate[newData.versionData!.buildingID!] = true;
                    SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                    VersionInfo.shouldBeUpdated = true;
                    print("FOUND NEW DATA POLYLINE DATAVERSION");
                }else{
                    VersionInfo.buildingPolylineDataVersionUpdate[newData.versionData!.buildingID!] = false;
                    print("NO NEW DATA FOR POLYLINE DATAVERSION");

                }
                if(newData.versionData!.landmarksDataVersion! > DB1Data.versionData!.landmarksDataVersion!){
                    VersionInfo.buildingLandmarkDataVersionUpdate[newData.versionData!.buildingID!] = true;
                    SwitchDataBase().newDataFromServerDBShouldBeCreated = true;
                    VersionInfo.shouldBeUpdated = true;
                    print("FOUND NEW DATA LANDMARK DATAVERSION");
                }else{
                    VersionInfo.buildingLandmarkDataVersionUpdate[newData.versionData!.buildingID!] = false;
                    print("NO NEW DATA FOR LANDMARK DATAVERSION");
                }
                print("newData $newData");
                print("DB1Data!.buildingDataVersion${DB1Data}");
                print(DB1Data.versionData!.buildingDataVersion);
                print(newData.versionData!.buildingDataVersion);
                print(SwitchDataBase().newDataFromServerDBShouldBeCreated);
                final apiData = DB2DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                DataBaseManager().saveDataDB2(apiData, dataVersionDetails, bID);
                if(SwitchDataBase().newDataFromServerDBShouldBeCreated){
                    SwitchDataBase().switchGreenDataBase(false);
                }
            }

        } else{
            Response dataVersionDataFromAPI = await networkManager.api.request(dataVersionDetails);
            if(dataVersionDataFromAPI.statusCode == 200){
                final apiData = DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                DataBaseManager().saveData(apiData, dataVersionDetails, bID);
                if(generateJSON) {
                    Map<String,dynamic> JSONresponseBody = dataVersionDataFromAPI.data;
                    String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("DataVersion$bID", formattedJson);
                }
                if (kDebugMode) {
                    generateJSON? print("GENERATED JSON FOR DATA VERSION $bID") : print("DATA VERSION DATA FROM API");
                }
                // if (preLoadedDataBox.containsKey(apiData.versionData!.buildingID)) {
                //     print('DATA ALREADY PRESENT');
                //     final databaseData = DataVersion.fromJson(preLoadedDataBox.get(apiData.versionData!.buildingID)!.responseBody);
                //     if (apiData.versionData!.buildingDataVersion != databaseData.versionData!.buildingDataVersion) {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //         VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Building Version Change = true ${apiData.versionData!.buildingDataVersion} ${databaseData.versionData!.buildingDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //         VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //         print("Building Version Change = false");
                //     }
                //
                //     if (apiData.versionData!.patchDataVersion !=
                //         databaseData.versionData!.patchDataVersion) {
                //         VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Patch Version Change = true ${apiData.versionData!
                //             .patchDataVersion} ${databaseData.versionData!
                //             .patchDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //
                //         VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = false;
                //         print("Patch Version Change = false");
                //     }
                //
                //     if (apiData.versionData!.landmarksDataVersion !=
                //         databaseData.versionData!.landmarksDataVersion) {
                //         VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Landmark Version Change = true ${apiData.versionData!
                //             .landmarksDataVersion} ${databaseData.versionData!
                //             .landmarksDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //
                //         VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = false;
                //         print("Landmark Version Change = false");
                //     }
                //
                //     if (apiData.versionData!.polylineDataVersion !=
                //         databaseData.versionData!.polylineDataVersion) {
                //         VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Polyline Version Change = true ${apiData.versionData!
                //             .polylineDataVersion} ${databaseData.versionData!
                //             .polylineDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //
                //         VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = false;
                //         print(VersionInfo.buildingPolylineDataVersionUpdate[apiData
                //             .versionData!.buildingID!]);
                //         print(apiData.versionData!.buildingID!);
                //         print("Polyline Version Change = false");
                //     }
                //     if (shouldBeInjected) {
                //         final dataVersionData = DB2DataVersionLocalModel(
                //             responseBody: dataVersionDataFromAPI.data);
                //         DataBox.delete(DataVersion
                //             .fromJson(dataVersionDataFromAPI.data)
                //             .versionData!
                //             .buildingID);
                //         print("database deleted ${DataBox.containsKey(DataVersion
                //             .fromJson(dataVersionDataFromAPI.data)
                //             .versionData!
                //             .buildingID)}");
                //         DataBaseManager().saveData(dataVersionData, dataVersionDetails, bID);
                //         print("New Data ${DataVersion
                //             .fromJson(dataVersionDataFromAPI.data)
                //             .versionData!
                //             .buildingID} ${dataVersionData}");
                //         dataVersionData.save();
                //     }
                // } else {
                //     print('DATA NOT PRESENT');
                //     VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     if (!shouldBeInjected) {
                //         print('DATA INJECTED');
                //         final dataVersionData = DB2DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                //
                //         DataBaseManager().saveData(dataVersionData, dataVersionDetails, bID);
                //     }
                // }
            }
        }
        // final DataBox = dataVersionDetails.dataBaseGetDataDB2!();
        final preLoadedDataBox = dataVersionDetails.dataBaseGetData!();
        if(generateJSON){
            Response dataVersionDataFromAPI = await networkManager.api.request(dataVersionDetails);
            if(dataVersionDataFromAPI.statusCode == 200){
                final apiData = DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                DataBaseManager().saveData(apiData, dataVersionDetails, bID);
                if(generateJSON) {
                    Map<String,dynamic> JSONresponseBody = dataVersionDataFromAPI.data;
                    String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("DataVersion$bID", formattedJson);
                }
                if (kDebugMode) {
                    generateJSON? print("GENERATED JSON FOR DATA VERSION $bID") : print("DATA VERSION DATA FROM API");
                }
                // if (preLoadedDataBox.containsKey(apiData.versionData!.buildingID)) {
                //     print('DATA ALREADY PRESENT');
                //     final databaseData = DataVersion.fromJson(preLoadedDataBox.get(apiData.versionData!.buildingID)!.responseBody);
                //     if (apiData.versionData!.buildingDataVersion != databaseData.versionData!.buildingDataVersion) {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //         VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Building Version Change = true ${apiData.versionData!.buildingDataVersion} ${databaseData.versionData!.buildingDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //         VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //         print("Building Version Change = false");
                //     }
                //
                //     if (apiData.versionData!.patchDataVersion !=
                //         databaseData.versionData!.patchDataVersion) {
                //         VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Patch Version Change = true ${apiData.versionData!
                //             .patchDataVersion} ${databaseData.versionData!
                //             .patchDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //
                //         VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = false;
                //         print("Patch Version Change = false");
                //     }
                //
                //     if (apiData.versionData!.landmarksDataVersion !=
                //         databaseData.versionData!.landmarksDataVersion) {
                //         VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Landmark Version Change = true ${apiData.versionData!
                //             .landmarksDataVersion} ${databaseData.versionData!
                //             .landmarksDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //
                //         VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = false;
                //         print("Landmark Version Change = false");
                //     }
                //
                //     if (apiData.versionData!.polylineDataVersion !=
                //         databaseData.versionData!.polylineDataVersion) {
                //         VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = true;
                //         shouldBeInjected = true;
                //         print("Polyline Version Change = true ${apiData.versionData!
                //             .polylineDataVersion} ${databaseData.versionData!
                //             .polylineDataVersion}");
                //     } else {
                //         print("match ${apiData.versionData!.buildingID!} and $bID");
                //
                //         VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                //             .buildingID!] = false;
                //         print(VersionInfo.buildingPolylineDataVersionUpdate[apiData
                //             .versionData!.buildingID!]);
                //         print(apiData.versionData!.buildingID!);
                //         print("Polyline Version Change = false");
                //     }
                //     if (shouldBeInjected) {
                //         final dataVersionData = DB2DataVersionLocalModel(
                //             responseBody: dataVersionDataFromAPI.data);
                //         DataBox.delete(DataVersion
                //             .fromJson(dataVersionDataFromAPI.data)
                //             .versionData!
                //             .buildingID);
                //         print("database deleted ${DataBox.containsKey(DataVersion
                //             .fromJson(dataVersionDataFromAPI.data)
                //             .versionData!
                //             .buildingID)}");
                //         DataBaseManager().saveData(dataVersionData, dataVersionDetails, bID);
                //         print("New Data ${DataVersion
                //             .fromJson(dataVersionDataFromAPI.data)
                //             .versionData!
                //             .buildingID} ${dataVersionData}");
                //         dataVersionData.save();
                //     }
                // } else {
                //     print('DATA NOT PRESENT');
                //     VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                //     if (!shouldBeInjected) {
                //         print('DATA INJECTED');
                //         final dataVersionData = DB2DataVersionLocalModel(responseBody: dataVersionDataFromAPI.data);
                //
                //         DataBaseManager().saveData(dataVersionData, dataVersionDetails, bID);
                //     }
                // }
            }
        }
    }


    Future<dynamic> getPatchDataNew(String bID) async {
        Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), bID);
        if(SwitchDataBase().isGreenDataBaseActive()){
            PatchAPIModel responseFromDatabase = DataBaseManager().getData(patchDetail, bID);
            print("PATCH DATA FROM DB1");
            return patchDetail.conversionFunction(responseFromDatabase.responseBody);
        }else{
            DB2PatchAPIModel responseFromDatabase = DataBaseManager().getDataDB2(patchDetail, bID);
            print("PATCH DATA FROM DB2");
            return patchDetail.conversionFunction(responseFromDatabase.responseBody);
        }
    }

    Future<dynamic> runAPICallPatchData(String bID,{bool generateJSON = false}) async {
        Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), bID);
        Response dataFromAPI = await networkManager.api.request(patchDetail);
        if(generateJSON){
            final patchData = PatchAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(patchData, patchDetail, bID);
            Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
            String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
            HelperClass().saveJsonToAndroidDownloads("Patch$bID", formattedJson);
            if (kDebugMode) {
                print("GENERATED JSON FOR PATCH $bID");
            }
        }else {
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final patchData = DB2PatchAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(patchData, patchDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB2");
                }else{
                    final patchData = PatchAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(patchData, patchDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB1");
                }
            }
        }
    }

    Future<dynamic> getPatchData(String bID,{bool generateJSON = false}) async {
        Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), bID);
        final patchBox = patchDetail.dataBaseGetData!();
        if(switchDataBase.isGreenDataBaseActive()){
            if(kDebugMode) print("${patchDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            PatchAPIModel responseFromDatabase = DataBaseManager().getData(
                patchDetail, bID);
            return patchDetail.conversionFunction(
                responseFromDatabase.responseBody);
        }else {
            if(generateJSON || !patchBox.containsKey(bID)){
                Response dataFromAPI = await networkManager.api.request(
                    patchDetail);
                if (dataFromAPI.statusCode == 200) {
                    final patchData = PatchAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(patchData, patchDetail, bID);
                    if(generateJSON) {
                        Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                        String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                        HelperClass().saveJsonToAndroidDownloads("Patch$bID", formattedJson);
                    }
                    if (kDebugMode) {
                        generateJSON? print("GENERATED JSON FOR PATCH $bID") : print("PATCH DATA FROM API");
                    }
                    return patchDetail.conversionFunction(dataFromAPI.data);
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            }else{
                if (kDebugMode) {
                    print("PATCH DATA FROM DATABASE");
                }
                PatchAPIModel responseFromDatabase = DataBaseManager().getData(
                    patchDetail, bID);
                return patchDetail.conversionFunction(
                    responseFromDatabase.responseBody);
            }
        }
    }


    Future<dynamic> getBeaconDataNew(String bID){
        Detail beaconDetail = apiDetails.buildingBeacons(dataBaseManager.getAccessToken(), bID);

        if(SwitchDataBase().isGreenDataBaseActive()){
            BeaconAPIModel responseFromDatabase = DataBaseManager().getData(beaconDetail, bID);
            print("BEACON DATA FROM DB1");
            return beaconDetail.conversionFunction(responseFromDatabase.responseBody);
        }else{
            DB2BeaconAPIModel responseFromDatabase = DataBaseManager().getDataDB2(beaconDetail, bID);
            print("BEACON DATA FROM DB2");
            return beaconDetail.conversionFunction(responseFromDatabase.responseBody);
        }
    }

    Future<dynamic> runAPICallBeaconData(String bID,{bool generateJSON = false}) async {
        Detail beaconDetail = apiDetails.buildingBeacons(dataBaseManager.getAccessToken(), bID);
        Response dataFromAPI = await networkManager.api.request(beaconDetail);

        if(generateJSON){
            if(dataFromAPI.statusCode == 200){
                final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(beaconData, beaconDetail, bID);
                if(generateJSON) {
                    List<dynamic> JSONresponseBody = dataFromAPI.data;
                    String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("Beacon$bID", formattedJson);
                }
                if(kDebugMode) {
                    print("GENERATED JSON FOR BEACON $bID") ;
                }
            }
        }else{
            if (dataFromAPI.statusCode == 200) {
                if(SwitchDataBase().isGreenDataBaseActive()){
                    final beaconData = DB2BeaconAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveDataDB2(beaconData, beaconDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB2");
                }else{
                    final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(beaconData, beaconDetail, bID);
                    print("PATCH DATA FROM API STORED IN DB1");
                }
            }
        }


    }

    Future<dynamic> getSingleBuildingBeaconData(String bID,{bool generateJSON = false}) async {
        Detail beaconDetail = apiDetails.buildingBeacons(dataBaseManager.getAccessToken(), bID);
        final beaconBox = beaconDetail.dataBaseGetData!();

        if(switchDataBase.isGreenDataBaseActive()){
            // if(kDebugMode) print("${beaconDetail.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            print(StackTrace.current);
            BeaconAPIModel responseFromDatabase = DataBaseManager().getData(beaconDetail, bID);
            return beaconDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            if(generateJSON || !beaconBox.containsKey(bID)){
                Response dataFromAPI = await networkManager.api.request(beaconDetail);
                if (dataFromAPI.statusCode == 200) {
                    final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(beaconData, beaconDetail, bID);
                    if(generateJSON) {
                        List<dynamic> JSONresponseBody = dataFromAPI.data;
                        String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                        HelperClass().saveJsonToAndroidDownloads("Beacon$bID", formattedJson);
                    }
                    if (kDebugMode) {
                        generateJSON? print("GENERATED JSON FOR BEACON $bID") : print("BEACON DATA FROM API");
                    }
                    return dataFromAPI.data;
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            }else{
                if (kDebugMode) {
                    print("BEACON DATA FROM DATABASE");
                }
                BeaconAPIModel responseFromDatabase = DataBaseManager().getData(beaconDetail, bID);
                return beaconDetail.conversionFunction(responseFromDatabase.responseBody);
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

    Future<dynamic> getGlobalAnnotationData(String bID,{bool generateJSON = false}) async {
        Detail globalAnnotationDetail = apiDetails.globalAnnotation(dataBaseManager.getAccessToken(), bID);

        if(globalAnnotationDetail.dataBaseGetData == null){
            Response dataFromAPI = await networkManager.api.request(globalAnnotationDetail);
            if(dataFromAPI.statusCode == 200) {
                final globalAnnotationData = GlobalAnnotationAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(globalAnnotationData, globalAnnotationDetail, bID);
                if(generateJSON) {
                    Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                    String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("Beacon$bID", formattedJson);
                }
                if (kDebugMode) {
                    generateJSON? print("GENERATED JSON FOR GLOBAL ANNOTATION $bID") : print("GLOBAL ANNOTATION DATA FROM API");
                }
                return dataFromAPI.data;
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }
        }
        final globalAnnotationBox = globalAnnotationDetail.dataBaseGetData!();
        if(generateJSON || !globalAnnotationBox.containsKey(bID)){
            Response dataFromAPI = await networkManager.api.request(globalAnnotationDetail);
            if(dataFromAPI.statusCode == 200) {
                final globalAnnotationData = GlobalAnnotationAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(globalAnnotationData, globalAnnotationDetail, bID);
                if(generateJSON) {
                    Map<String,dynamic> JSONresponseBody = dataFromAPI.data;
                    String formattedJson = JsonEncoder.withIndent('  ').convert(JSONresponseBody);
                    HelperClass().saveJsonToAndroidDownloads("Beacon$bID", formattedJson);
                }
                if (kDebugMode) {
                    generateJSON? print("GENERATED JSON FOR GLOBAL ANNOTATION $bID") : print("GLOBAL ANNOTATION DATA FROM API");
                }
                return dataFromAPI.data;
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }
        }else{
            if (kDebugMode) {
                print("GLOBAL ANNOTATION DATA FROM DATABASE");
            }
            GlobalAnnotationAPIModel responseFromDatabase = DataBaseManager().getData(globalAnnotationDetail, bID);
            return globalAnnotationDetail.conversionFunction(responseFromDatabase.responseBody);
        }
    }

    Future<dynamic> getWaypointData(String bID,{bool generateJSON = false}) async {
        Detail waypointDetails = apiDetails.waypoint(dataBaseManager.getAccessToken(), bID);
        final waypointBox = waypointDetails.dataBaseGetData!();
        if(SwitchDataBase().isGreenDataBaseActive()){
            if(kDebugMode) print("${waypointDetails.getPreLoadPrefix} DATA FROM GREEN DATABASE");
            WayPointModel responseFromDatabase = DataBaseManager().getData(waypointDetails, bID);
            return waypointDetails.conversionFunction(responseFromDatabase.responseBody);
        }else {
            if (generateJSON || !waypointBox.containsKey(bID)) {
                Response dataFromAPI = await networkManager.api.request(
                    waypointDetails);
                if (dataFromAPI.statusCode == 200) {
                    final wayPointData = WayPointModel(
                        responseBody: dataFromAPI.data);
                    DataBaseManager().saveData(
                        wayPointData, waypointDetails, bID);
                    if (generateJSON) {
                        List<dynamic> JSONresponseBody = dataFromAPI.data;
                        String formattedJson = JsonEncoder.withIndent('  ')
                            .convert(JSONresponseBody);
                        HelperClass().saveJsonToAndroidDownloads(
                            "Waypoint$bID", formattedJson);
                    }
                    if (kDebugMode) {
                        generateJSON
                            ? print("GENERATED JSON FOR WAYPOINT $bID")
                            : print("WAYPOINT DATA FROM API");
                    }
                    return dataFromAPI.data;
                } else if (dataFromAPI.statusCode == 201) {
                    return null;
                } else {
                    return null;
                }
            } else {
                if (kDebugMode) {
                    print("WAYPOINT DATA FROM DATABASE");
                }
                WayPointModel responseFromDatabase = DataBaseManager().getData(
                    waypointDetails, bID);
                return waypointDetails.conversionFunction(
                    responseFromDatabase.responseBody);
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

