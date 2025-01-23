import 'package:flutter/material.dart';

import '../APIMODELS/GlobalAnnotationModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as geo;

import '../navigationTools.dart';
import '../singletonClass.dart';


Future<Set<geo.Polygon>?> globalRendering(GlobalModel data, Function polygonTap) async {

  Set<geo.Polygon> polygons = Set();

  var mappingElements = data.mappingElements;

  if(mappingElements == null || mappingElements.isEmpty){
    return null;
  }

      for (var element in mappingElements) {
        print("element type ${element.type}");
        if(element.geometry!.type == "Polygon") {
            List<geo.LatLng> coordinates = [];

            for (var cords in element.geometry!.coordinates!.first) {
              //coordinates.add(LatLng(node.lat!,node.lon!));
              // List<double> globalCoordinates = tools.localtoglobal(
              //     cords[0],
              //     cords[1],
              //     SingletonFunctionController.building.patchData[element.buildingID]
              // );

              coordinates.add(geo.LatLng(cords[1], cords[0]));
            }
            coordinates.removeLast();

                if (coordinates.length > 2) {
                  polygons.add(geo.Polygon(
                      polygonId: geo.PolygonId(element.id??element.sId!),
                      points: coordinates,
                      strokeWidth: 1,
                    strokeColor: element.properties?.strokeColor != null &&
                        element.properties?.strokeColor != "undefined"
                        ? Color(int.parse(
                        '0xFF${(element.properties?.strokeColor)!.replaceAll('#', '')}'))
                        : Colors.black,
                      fillColor: element.properties?.fillColor != null &&
                          element.properties?.fillColor != "undefined"
                          ? Color(int.parse(
                          '0xFF${(element.properties?.fillColor)!.replaceAll('#', '')}'))
                          : Colors.black,
                      consumeTapEvents: true,
                    onTap: (){
                      polygonTap(coordinates, element.id);
                    }
                  ));
                }
            }

      }
      print("returning polygons ${polygons.length}");
    return polygons;
}