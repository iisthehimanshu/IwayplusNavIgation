
import 'package:iwaymaps/NAVIGATION/APIMODELS/landmark.dart';
import 'package:iwaymaps/NAVIGATION/DBManager.dart';
import 'package:iwaymaps/NAVIGATION/Network/APIDetails.dart';
import 'package:iwaymaps/NAVIGATION/Network/NetworkManager.dart';

import '../IWAYPLUS/API/buildingAllApi.dart';
import 'API/response.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/beaconData.dart';
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
            return landmarkDetail.conversionFunction!(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(landmarkDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<polylinedata> getPolylineData(String bID) async {
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(landmarkBox.containsKey(bID)){
            Map<String, dynamic> responseBody = landmarkBox.get(bID)!.responseBody;
            print("Data from DB");
            return polylinedata.fromJson(responseBody);
        }else {
            Response dataFromAPI = await networkManager.request(landmarkDetail);
            print("Data from API");
            return dataFromAPI.data;
        }
    }

    Future<patchDataModel> getPatchData(String bID) async {
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(landmarkBox.containsKey(bID)){
            Map<String, dynamic> responseBody = landmarkBox.get(bID)!.responseBody;
            print("Data from DB");
            return patchDataModel.fromJson(responseBody);
        }else {
            final dataFromAPI = await networkManager.request(landmarkDetail);
            print("Data from API");
            return patchDataModel.fromJson(dataFromAPI);
        }
    }

    Future<List<beacon>> getBeaconData(String bID) async {
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(landmarkBox.containsKey(bID)){
            Map<String, dynamic> responseBody = landmarkBox.get(bID)!.responseBody;
            print("Data from DB");
            return patchDataModel.fromJson(responseBody);
        }else {
            final dataFromAPI = await networkManager.request(landmarkDetail);
            print("Data from API");
            return patchDataModel.fromJson(dataFromAPI);
        }
    }

    Future<Building> get(String bID) async {
        Detail landmarkDetail = apiDetails.landmark(dataBaseManager.getAccessToken(), bID);
        final landmarkBox = landmarkDetail.dataBaseGetData!();

        if(landmarkBox.containsKey(bID)){
            Map<String, dynamic> responseBody = landmarkBox.get(bID)!.responseBody;
            print("Data from DB");
            return Building.fromJson(responseBody);
        }else {
            final dataFromAPI = await networkManager.request(landmarkDetail);
            print("Data from API");
            return patchDataModel.fromJson(dataFromAPI);
        }
    }





}