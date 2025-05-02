
import 'package:flutter/foundation.dart';
import 'package:iwaymaps/NAVIGATION/API/GlobalAnnotationapi.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/outbuildingmodel.dart';
import '../APIMODELS/DataVersion.dart';
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
    Apidetails apiDetails = Apidetails();
    bool shouldBeInjected = false;


    Future<void> loadBuildings() async {
        List<dynamic> list = await getBuildingByVenue(VenueManager().venueName);
        VenueManager().buildings = list.whereType<Buildingbyvenue>().toList();
        print("VenueManager().buildings ${VenueManager().buildings}");
        VenueManager().buildings.forEach((buildingData){
            getDataVersionData(buildingData.sId!);
        });

    }


    Future<dynamic> getLandmarkData(String bID) async {
        if (bID.isEmpty) return null;

        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(landmarkBox.containsKey(bID)){
            if (kDebugMode) {
                print("Data from DB");
            }
            LandMarkApiModel responseFromDatabase = DataBaseManager().getData(landmarkDetail, bID);
            return landmarkDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(landmarkDetail);
            if (kDebugMode) {
                print("Data from API");
            }
            if(dataFromAPI.statusCode == 200){
                final landmarkData = LandMarkApiModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(landmarkData,landmarkDetail,bID);
                return landmarkDetail.conversionFunction(dataFromAPI.data);
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
                //open new screen
            }
        }
    }

    Future<dynamic> getPolylineData(String bID) async {
        if (bID.isEmpty) return null;

        Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), bID);
        final polylineBox = polylineDetail.dataBaseGetData!();

        if(polylineBox.containsKey(bID)){
            if (kDebugMode) {
              print("Data from DB");
            }
            PolyLineAPIModel responseFromDatabase = DataBaseManager().getData(polylineDetail, bID);
            return polylineDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(polylineDetail);
            if (kDebugMode) {
              print("Data from API");
            }
            if(dataFromAPI.statusCode == 200) {
                final polyLineData = PolyLineAPIModel(
                    responseBody: dataFromAPI.data);
                DataBaseManager().saveData(polyLineData, polylineDetail, bID);
                return polylineDetail.conversionFunction(dataFromAPI.data);
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }
        }
    }

    Future<dynamic> getDataVersionData(String bID) async {
        Detail dataVersionDetails = await apiDetails.dataVersion(dataBaseManager.getAccessToken(), bID);
        final DataBox = dataVersionDetails.dataBaseGetData!();

        Response dataVersionDataFromAPI = await networkManager.api.request(dataVersionDetails);
        if(dataVersionDataFromAPI.statusCode == 200){
            final apiData = dataVersionDetails.conversionFunction(dataVersionDataFromAPI.data);
            print("dataVersion ${apiData.versionData!.buildingID}");
            if (DataBox.containsKey(apiData.versionData!.buildingID)) {
                print('DATA ALREADY PRESENT');
                final databaseData = DataVersion.fromJson(DataBox.get(apiData.versionData!.buildingID)!.responseBody);
                if (apiData.versionData!.buildingDataVersion !=
                    databaseData.versionData!.buildingDataVersion) {
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
                    final dataVersionData = DataVersionLocalModel(
                        responseBody: dataVersionDataFromAPI.data);
                    DataBox.delete(DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID);
                    print("database deleted ${DataBox.containsKey(DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID)}");
                    DataBox.put(DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID, dataVersionData);
                    print("New Data ${DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID} ${dataVersionData}");
                    dataVersionData.save();
                }
            } else {
                print('DATA NOT PRESENT');
                VersionInfo.buildingBuildingDataVersionUpdate[apiData.versionData!.buildingID!] = false;
                VersionInfo.buildingPatchDataVersionUpdate[apiData.versionData!
                    .buildingID!] = false;
                VersionInfo.buildingLandmarkDataVersionUpdate[apiData.versionData!
                    .buildingID!] = false;
                VersionInfo.buildingPolylineDataVersionUpdate[apiData.versionData!
                    .buildingID!] = false;
                if (!shouldBeInjected) {
                    print('DATA INJECTED');
                    final dataVersionData = DataVersionLocalModel(
                        responseBody: dataVersionDataFromAPI.data);
                    DataBox.put(DataVersion
                        .fromJson(dataVersionDataFromAPI.data)
                        .versionData!
                        .buildingID, dataVersionData);
                    dataVersionData.save();
                }
            }
        }
    }

    Future<dynamic> getPatchData(String bID) async {
        Detail patchDetail = await apiDetails.patch(dataBaseManager.getAccessToken(), bID);
        final patchBox = patchDetail.dataBaseGetData!();

        if(patchBox.containsKey(bID)){
            if (kDebugMode) {
              print("Data from DB");
            }
            PatchAPIModel responseFromDatabase = DataBaseManager().getData(patchDetail, bID);
            return patchDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(patchDetail);
            if (kDebugMode) {
              print("Data from API");
            }
            if(dataFromAPI.statusCode == 200) {
                final patchData = PatchAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(patchData, patchDetail, bID);
                return patchDetail.conversionFunction(dataFromAPI.data);
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
            }
        }
    }

    Future<dynamic> getSingleBuildingBeaconData(String bID) async {
        Detail beaconDetail = apiDetails.buildingBeacons(dataBaseManager.getAccessToken(), bID);
        final beaconBox = beaconDetail.dataBaseGetData!();

        if(beaconBox.containsKey(bID)){
            if (kDebugMode) {
              print("Data from DB");
            }
            BeaconAPIModel responseFromDatabase = DataBaseManager().getData(beaconDetail, bID);
            return beaconDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(beaconDetail);
            if (kDebugMode) {
              print("Data from API");
            }
            if(dataFromAPI.statusCode == 200) {
                final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
                DataBaseManager().saveData(beaconData, beaconDetail, bID);
                return dataFromAPI.data;
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
                return null;
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

        if(waypointBox.containsKey(bID)){
            if (kDebugMode) {
              print("Data from DB");
            }
            WayPointModel responseFromDatabase = DataBaseManager().getData(waypointDetails, bID);
            return waypointDetails.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(waypointDetails);
            if (kDebugMode) {
              print("Data from API");
            }
            if(dataFromAPI.statusCode == 200) {
                final wayPointData = WayPointModel(
                    responseBody: dataFromAPI.data);
                DataBaseManager().saveData(wayPointData, waypointDetails, bID);
                return dataFromAPI.data;
            }else if(dataFromAPI.statusCode == 201){
                return null;
            }else{
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

}

