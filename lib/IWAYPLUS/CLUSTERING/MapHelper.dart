import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'MapMarkers.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is possible using the [DefaultCacheManager] package and is useful
  /// to improve load times on the next map loads, the first time will always take more
  /// time to download the file and set the marker image.
  ///
  /// You can resize the marker image by providing a [targetWidth].
  static Future<BitmapDescriptor> getMarkerImageFromUrl(String url, {int? targetWidth,}) async {
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    if (targetWidth != null) {
      markerImageBytes = await _resizeImageBytes(
        markerImageBytes,
        targetWidth,
      );
    }

    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  /// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
  ///
  /// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
  /// to be used on the cluster marker icons.

  static Future<ui.Image> loadImage(Uint8List imgBytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imgBytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  static Future<BitmapDescriptor> _getClusterMarker(
      int clusterSize,
      Color clusterColor,
      Color textColor,
      int width,
      String iconPath, // Path to the icon image in assets
      ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint circlePaint = Paint()..color = clusterColor;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = width / 2;

    // Load icon image
    final ByteData byteData = await rootBundle.load(iconPath);
    final Uint8List iconBytes = byteData.buffer.asUint8List();
    final ui.Image iconImage = await loadImage(iconBytes);
    final double iconSize = radius * 2.5; // Adjust the size as needed
    final double iconX = radius - iconSize / 2 ;
    final double iconY = radius - iconSize / 2;

    // Draw circle


    // Draw the icon image
    paintImage(
      canvas: canvas,
      image: iconImage,
      rect: Rect.fromLTWH(iconX, iconY-1, iconSize, iconSize+18),
    );
    canvas.drawCircle(
      Offset(radius, radius-6),
      radius-12,
      circlePaint,
    );

    // Draw cluster size text inside circle
    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontFamily: "Roboto",
        fontSize: radius ,
        fontWeight: FontWeight.w400,
        color: Color(0xff000000),
        height: 20 / 14,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2 -8),
    );

    final image = await pictureRecorder.endRecording().toImage(
      (radius * 2).toInt(), // Adjust width to accommodate circle
      (radius*2 + 15).toInt(),
    );
    final data = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }





  /// Resizes the given [imageBytes] with the [targetWidth].
  ///
  /// We don't want the marker image to be too big so we might need to resize the image.
  static Future<Uint8List> _resizeImageBytes(
      Uint8List imageBytes,
      int targetWidth,
      ) async {
    final ui.Codec imageCodec = await instantiateImageCodec(
      imageBytes,
      targetWidth: targetWidth,
    );

    final FrameInfo frameInfo = await imageCodec.getNextFrame();

    final data = await frameInfo.image.toByteData(format: ImageByteFormat.png);

    return data!.buffer.asUint8List();
  }

  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.
  static Future<Fluster<MapMarker>> initClusterManager(
      List<MapMarker> markers,
      int minZoom,
      int maxZoom,
      GoogleMapController? mapController,
      ) async {
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (
          BaseCluster? cluster,
          double? lng,
          double? lat,
          ) =>
          MapMarker(
            id: cluster!.id.toString(),
            position: LatLng(lat!, lng!),
            isCluster: cluster.isCluster,
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId, icon: null, Landmarkname: '',
            mapController: mapController,
          ),
    );
  }

  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].
  static Future<List<Marker>> getClusterMarkers(
      Fluster<MapMarker>? clusterManager,
      double currentZoom,
      Color clusterColor,
      Color clusterTextColor,
      int clusterWidth,
      GoogleMapController? mapController,
      ) {
    if (clusterManager == null) return Future.value([]);

    return Future.wait(clusterManager.clusters(
      [-180, -85, 180, 85],
      currentZoom.toInt(),
    ).map((mapMarker) async {

      if (mapMarker.isCluster!) {
        mapMarker.icon = await _getClusterMarker(
          mapMarker.pointsSize!,
          clusterColor,
          clusterTextColor,
          clusterWidth,
          'assets/pyramids.png',
        );
      }
      mapMarker.mapController = mapController;


      return mapMarker.toMarker();
    }).toList());
  }
}