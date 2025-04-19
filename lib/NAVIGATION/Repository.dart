
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/DBManager.dart';
import 'package:iwaymaps/NAVIGATION/Network/APIDetails.dart';
import 'package:iwaymaps/NAVIGATION/Network/NetworkManager.dart';
import 'package:iwaymaps/NAVIGATION/waypoint.dart';

import '../IWAYPLUS/API/buildingAllApi.dart';
import 'API/response.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/Buildingbyvenue.dart';
import 'APIMODELS/GlobalAnnotationModel.dart';
import 'APIMODELS/beaconData.dart';
import 'APIMODELS/outdoormodel.dart';
import 'APIMODELS/patchDataModel.dart';
import 'APIMODELS/polylinedata.dart';

class Repository{
    Networkmanager networkManager = Networkmanager();
    DataBaseManager dataBaseManager = DataBaseManager();
    Apidetails apiDetails = Apidetails();


    Future<land> getLandmarkData(String bID) async {
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(landmarkBox.containsKey(bID)){
            Map<String, dynamic> responseBody = landmarkBox.get(bID)!.responseBody;
            print("Data from DB");
            return landmarkDetail.conversionFunction(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(landmarkDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<polylinedata> getPolylineData(String bID) async {
        Detail polylineDetail = apiDetails.polyline(dataBaseManager.getAccessToken(), bID);
        final polylineBox = polylineDetail.dataBaseGetData!();

        if(polylineBox.containsKey(bID)){
            Map<String, dynamic> responseBody = polylineBox.get(bID)!.responseBody;
            print("Data from DB");
            return polylineDetail.conversionFunction(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(polylineDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<patchDataModel> getPatchData(String bID) async {
        Detail patchDetail = apiDetails.patch(dataBaseManager.getAccessToken(), bID);
        final patchBox = patchDetail.dataBaseGetData!();

        if(patchBox.containsKey(bID)){
            Map<String, dynamic> responseBody = patchBox.get(bID)!.responseBody;
            print("Data from DB");
            return patchDetail.conversionFunction(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(patchDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<List<beacon>> getBeaconData(String bID) async {
        Detail beaconDetail = apiDetails.beacons(dataBaseManager.getAccessToken(), bID);
        final beaocnBox = beaconDetail.dataBaseGetData!();

        if(beaocnBox.containsKey(bID)){
            Map<String, dynamic> responseBody = beaocnBox.get(bID)!.responseBody;
            print("Data from DB");
            return beaconDetail.conversionFunction(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(beaconDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<List<Buildingbyvenue>> getBuildingByVenue(String bID) async {
        Detail buildingByVenueDetail = apiDetails.buildingByVenueApi(dataBaseManager.getAccessToken(), bID);
        final buildingByVenueBox = buildingByVenueDetail.dataBaseGetData!();

        if(buildingByVenueBox.containsKey(bID)){
            Map<String, dynamic> responseBody = buildingByVenueBox.get(bID)!.responseBody;
            print("Data from DB");
            return buildingByVenueDetail.conversionFunction(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(buildingByVenueDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<GlobalModel> getGlobalAnnotationData(String bID) async {
        Detail globaAnnotaionDetail = apiDetails.globalAnnotation(dataBaseManager.getAccessToken(), bID);
        final globaAnnotaionBox = globaAnnotaionDetail.dataBaseGetData!();

        if(globaAnnotaionBox.containsKey(bID)){
            Map<String, dynamic> responseBody = globaAnnotaionBox.get(bID)!.responseBody;
            print("Data from DB");
            return globaAnnotaionDetail.conversionFunction(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(globaAnnotaionDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<List<PathModel>> getWaypointData(String bID) async {
        Detail waypointDetails = apiDetails.waypoint(dataBaseManager.getAccessToken(), bID);
        final waypointBox = waypointDetails.dataBaseGetData!();

        if(waypointBox.containsKey(bID)){
            Map<String, dynamic> responseBody = waypointBox.get(bID)!.responseBody;
            print("Data from DB");
            return waypointBox.conversionFunction(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(waypointDetails);
            print("Data from API");
            return dataFromAPI.data;
        }
    }
}