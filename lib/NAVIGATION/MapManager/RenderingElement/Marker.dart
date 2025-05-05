import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../APIMODELS/landmark.dart';

class ElementMarker {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  late Canvas canvas;

  ElementMarker() {
    canvas = Canvas(pictureRecorder);
  }

  Future<Map<String,Set<Marker>>?> createMarkers(land landmarkData, int floor) async {
    Map<String,Set<Marker>> markers = {};

    for (final landmark in landmarkData.landmarks ?? []) {
      if (landmark.floor != floor ||
          landmark.coordinateX == null ||
          landmark.coordinateY == null ||
          landmark.wasPolyIdNull != false) continue;

      final lat = double.tryParse(landmark.properties?.latitude ?? '');
      final lng = double.tryParse(landmark.properties?.longitude ?? '');
      final polyId = landmark.properties?.polyId ?? '';
      final name = landmark.name ?? '';
      final priority = landmark.priority ?? 0;
      final subType = landmark.element?.subType;
      final type = landmark.element?.type;

      if (lat == null || lng == null || polyId.isEmpty) continue;

      if (type == "Rooms") {
        final markerInfo = _markerInfoForSubType(subType, name, priority);
        if (markerInfo == null) continue;

        final icon = await _getIcon(markerInfo, priority);
        Marker marker = _buildMarker(name: "Room $polyId", lat: lat, lng: lng, icon: icon);
        if(priority>1){
          markers.putIfAbsent("high",()=> Set());
          markers["high"]!.add(marker);
        }else{
          markers.putIfAbsent("low",()=> Set());
          markers["low"]!.add(marker);
        }
      } else if (type == "Services" && subType == "restRoom") {
        final gender = _genderFromName(name);
        if (gender != null) {
          final asset = gender == "Male"
              ? 'assets/MapMaleWashroom.png'
              : 'assets/MapFemaleWashroom.png';
          final icon = BitmapDescriptor.fromBytes(await getImagesFromMarker(asset, 95));
          Marker marker = _buildMarker(name: "Room $polyId", lat: lat, lng: lng, icon: icon);
          markers.putIfAbsent("mid",()=> Set());
          markers["mid"]!.add(marker);
        }
      }
    }

    return markers;
  }

  Marker _buildMarker({required String name, required double lat, required double lng, required BitmapDescriptor icon}) {
    return Marker(
      markerId: MarkerId(name),
      position: LatLng(lat, lng),
      icon: icon,
      anchor: const Offset(0.5, 1.0),
      visible: true,
      onTap: () {
        print("marker tapped");
      },
    );
  }

  String? _genderFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains("male")) return "Male";
    if (lower.contains("female")) return "Female";
    return null;
  }

  Future<BitmapDescriptor> _getIcon(_MarkerInfo info, int priority) async {
    if (priority > 1 && info.assetPath != null) {
      return await bitmapDescriptorFromTextAndImage(
        info.label,
        info.assetPath,
        imageSize: const Size(85, 85),
        color: info.color,
      );
    } else if (info.assetPath != null) {
      return BitmapDescriptor.fromBytes(await getImagesFromMarker(info.assetPath!, 85));
    } else {
      // Fallback: text-only marker
      return await bitmapDescriptorFromTextAndImage(
        info.label,
        null,
        imageSize: const Size(85, 85),
        color: info.color,
      );
    }
  }

  _MarkerInfo? _markerInfoForSubType(String? subType, String name, int priority) {
    final label = name.split('-').first.trim();

    switch (subType) {
      case "Classroom":
        return _MarkerInfo(label, 'assets/Classroom.png', const Color(0xff544551));
      case "Cafeteria":
        return _MarkerInfo(label, 'assets/cutlery.png', const Color(0xfffb8c00));
      case "ATM":
        return _MarkerInfo(label, 'assets/ATM.png', const Color(0xffd32f2f));
      case "Consultation Room":
      case "Office":
        return _MarkerInfo(label, 'assets/${subType!.replaceAll(' ', '')}.png', const Color(0xff544551));
      case "Point of Interest":
      case "Counter":
        return _MarkerInfo(name, null, null);
      case "room door":
        return _MarkerInfo(name, 'assets/Generic Marker.png', null);
      case "main entry":
        return _MarkerInfo(name, 'assets/1.png', null);
      case "kiosk":
        final simplifiedLabel = name.contains('kiosk') ? 'Kiosk' : name.split(' ').elementAtOrNull(1) ?? name;
        return _MarkerInfo(simplifiedLabel, 'assets/check-in.png', null);
      case "lift":
        return _MarkerInfo(name, 'assets/entry.png', null);
      case "Male":
        return _MarkerInfo(name, 'assets/6.png', null);
      case "Female":
        return _MarkerInfo(name, 'assets/4.png', null);
      default:
        if (subType != null) {
          return _MarkerInfo(label, 'assets/Generic Marker.png', null);
        }
        return null;
    }
  }

  Future<BitmapDescriptor> bitmapDescriptorFromTextAndImage(
      String text,
      String? imagePath, {
        Size imageSize = const Size(50, 50),
        Color? color,
      }) async {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 30.0,
          color: color ?? const Color(0xff000000),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;
    final double canvasWidth = textWidth > imageSize.width ? textWidth : imageSize.width;
    final double canvasHeight = textHeight + (imagePath != null ? imageSize.height + 20.0 : 0.0);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    textPainter.paint(canvas, Offset((canvasWidth - textWidth) / 2, 0.0));

    if (imagePath != null) {
      final ByteData baseImageBytes = await rootBundle.load(imagePath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        baseImageBytes.buffer.asUint8List(),
        targetWidth: imageSize.width.toInt(),
        targetHeight: imageSize.height.toInt(),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      canvas.drawImage(frame.image, Offset((canvasWidth - imageSize.width) / 2, textHeight + 10.0), Paint());
    }

    final ui.Image image = await recorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<Uint8List> getImagesFromMarker(String path, int width) async {
    ByteData? data ;
    try{
      data = await rootBundle.load(path);
    }catch(e){
      data = await rootBundle.load("assets/Generic Marker.png");
    }
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}

class _MarkerInfo {
  final String label;
  final String? assetPath;
  final Color? color;

  _MarkerInfo(this.label, this.assetPath, this.color);
}
