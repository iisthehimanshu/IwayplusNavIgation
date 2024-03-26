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

  static Future<BitmapDescriptor> _getClusterMarker(
      int clusterSize,
      Color clusterColor,
      Color textColor,
      int width,
      String venueText,
      ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint circlePaint = Paint()..color = clusterColor;
    final Paint rectanglePaint = Paint()..color = Colors.black26; // Background color of the rectangle
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double radius = width / 2;
    final double rectWidth = 80 * 2;
    final double rectHeight = 80; // Height of the rectangle, adjust as needed
    final double spacing = 15; // Spacing between the circle and rectangle

    // Draw circle
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      circlePaint,
    );

    // Draw rectangle
    final double rectX = radius * 2 + spacing; // Position the rectangle to the right of the circle
    final double rectY = radius - rectHeight / 2;
    final double borderRadius = 10; // Adjust the border radius as needed
    canvas.drawRRect(
      RRect.fromLTRBR(
        rectX,
        rectY,
        rectX + rectWidth,
        rectY + rectHeight,
        Radius.circular(borderRadius),
      ),
      rectanglePaint,
    );

    // Draw venue text inside rectangle
    textPainter.text = TextSpan(
      text: venueText,
      style: TextStyle(
        fontFamily: "Roboto",
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: Color(0xffFFFFFF),
        height: 20/14,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rectX + (rectWidth - textPainter.width) / 2, rectY + (rectHeight - textPainter.height) / 2),
    );

    // Draw cluster size text inside circle
    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontFamily: "Roboto",
        fontSize: radius - 5,
        fontWeight: FontWeight.w400,
        color: Color(0xffFFFFFF),
        height: 20/14,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final image = await pictureRecorder.endRecording().toImage(
      (radius * 2 + rectWidth + spacing).toInt(), // Adjust width to accommodate circle and rectangle
      (radius * 2).toInt(),
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
            childMarkerId: cluster.childMarkerId, icon: null,
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
          "Venues",
        );
      }

      return mapMarker.toMarker();
    }).toList());
  }
}