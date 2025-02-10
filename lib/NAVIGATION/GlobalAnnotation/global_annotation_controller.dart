import '../APIMODELS/GlobalAnnotationModel.dart';
import '../APIMODELS/landmark.dart';
import '../APIMODELS/polylinedata.dart';
import '../navigation_api_controller.dart';
import '../waypoint.dart' as way;
import 'global_rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;


class GlobalAnnotationController {
  GlobalModel data;
  Function polygonTap = (List<geo.LatLng> coordinates, String id) {};
  NavigationAPIController apiController;
  GlobalAnnotationController({required this.data, required this.polygonTap, required this.apiController});

  List<way.PathModel>? wrapWayPoint() {
    print("wrapWayPoint");
    PathNetwork? pathNetwork = data.pathNetwork;
    if(pathNetwork == null){
      return null;
    }
    Map<String, dynamic> JSONPathNetwork = pathNetwork.toJson();
    JSONPathNetwork["floor"] = 0;
    JSONPathNetwork["building_ID"] = data.mappingElements?.first.buildingID;
    way.PathModel wayPointList = way.PathModel.fromJson(JSONPathNetwork as Map<dynamic, dynamic>);
    print("wayPointList returned is $wayPointList");
    return [wayPointList];
  }

  Future<void> wrapPatch() async {
    await apiController.patchAPIController(data.mappingElements!.first.buildingID!, false);
    await apiController.landmarkAPIController(data.mappingElements!.first.buildingID!, false);
  }

  Future<List<Landmarks>?> wrapLandmarks() async {
    List<Landmarks>? landmarks = null;

    data.mappingElements?.forEach((element){
      if(element.geometry?.type == "Point"){
        print("associatedPolygons are ${element.associatedPolygons}");
        Map<dynamic, dynamic> JSON = {
          "element": {
            "type": "Rooms",
            "subType": "room door"
          },
          "properties": {
            "nonWalkableGrids": [],
            "flr_dist_matrix": [],
            "frConn": [],
            "clickedPoints": [],
            "polygonId": [],
            "polygonExist": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty),
            "polyId": (element.associatedPolygons != null && element.associatedPolygons!.isNotEmpty)?element.associatedPolygons![0]:null,
            "latitude": "${element.geometry?.coordinates?[1]}",
            "node": null,
            "longitude": "${element.geometry?.coordinates?[0]}"
          },
          "_id": element.id,
          "building_ID": element.buildingID,
          "coordinateX": element.geometry?.coordinatesLocal?[0],
          "coordinateY": element.geometry?.coordinatesLocal?[1],
          "doorX": element.geometry?.coordinatesLocal?[0],
          "doorY": element.geometry?.coordinatesLocal?[1],
          "type": element.type,
          "floor": 0,
          "name": element.properties?.name,
          "buildingName": data.buildingName,
          "venueName": data.venueName
        };
        Landmarks landmark = Landmarks.fromJson(JSON);
        print(landmark.properties!.polyId);
        landmarks ??= [];
        landmarks?.add(landmark);
      }
    });

    return landmarks;
  }

  Future<Set<geo.Polygon>?> renderCampus() async {
    return await globalRendering(data,polygonTap);
  }

}
