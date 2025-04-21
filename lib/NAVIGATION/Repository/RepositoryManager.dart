
import 'package:flutter/foundation.dart';
import 'package:iwaymaps/NAVIGATION/API/GlobalAnnotationapi.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/APIMODELS/outbuildingmodel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/WayPointModel.dart';
import 'package:iwaymaps/NAVIGATION/DataBaseManager/DBManager.dart';
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

class RepositoryManager<T>{
    NetworkManager networkManager = NetworkManager();
    DataBaseManager dataBaseManager = DataBaseManager();
    Apidetails apiDetails = Apidetails();

    Future<T> getLandmarkData(String bID) async {
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
            final landmarkData = LandMarkApiModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(landmarkData,landmarkDetail,bID);
            return dataFromAPI.data;
        }
    }

    Future<polylinedata> getPolylineData(String bID) async {
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
            final polyLineData = PolyLineAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(polyLineData, polylineDetail, bID);
            return dataFromAPI.data;
        }
    }

    Future<patchDataModel> getPatchData(String bID) async {
        Detail patchDetail = apiDetails.patch(dataBaseManager.getAccessToken(), bID);
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
            final patchData = PatchAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(patchData, patchDetail, bID);
            return dataFromAPI.data;
        }
    }

    Future<List<beacon>> getBeaconData(String bID) async {
        Detail beaconDetail = apiDetails.beacons(dataBaseManager.getAccessToken(), bID);
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
            final beaconData = BeaconAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(beaconData, beaconDetail, bID);
            return dataFromAPI.data;
        }
    }

    Future<List<Buildingbyvenue>> getBuildingByVenue(String bID) async {
        Detail buildingByVenueDetail = apiDetails.buildingByVenueApi(dataBaseManager.getAccessToken(), bID);
        final buildingByVenueBox = buildingByVenueDetail.dataBaseGetData!();

        if(buildingByVenueBox.containsKey(bID)){
            if (kDebugMode) {
              print("Data from DB");
            }
            BuildingByVenueAPIModel responseFromDatabase = DataBaseManager().getData(buildingByVenueDetail, bID);
            return buildingByVenueDetail.conversionFunction(responseFromDatabase.responseBody);
        }else {
            Response dataFromAPI = await networkManager.api.request(buildingByVenueDetail);
            if (kDebugMode) {
              print("Data from API");
            }
            final buildingByVenueData = BuildingByVenueAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(buildingByVenueData, buildingByVenueDetail, bID);
            return dataFromAPI.data;
        }
    }

    Future<GlobalModel> getGlobalAnnotationData(String bID) async {
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
            final globalAnnotationData = GlobalAnnotationAPIModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(globalAnnotationData, globalAnnotationDetail, bID);
            return dataFromAPI.data;
        }
    }

    Future<List<PathModel>> getWaypointData(String bID) async {
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
            final wayPointData = WayPointModel(responseBody: dataFromAPI.data);
            DataBaseManager().saveData(wayPointData, waypointDetails, bID);
            return dataFromAPI.data;
        }
    }

    Future<outdoormodel> getCampusData(List<String> bIDS) async {
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
        final campusData = OutDoorModel(responseBody: dataFromAPI.data);
        DataBaseManager().saveData(campusData, campusDetails, bIDS[0]);
        return dataFromAPI.data;

    }

}