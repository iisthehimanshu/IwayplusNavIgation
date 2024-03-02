import 'package:google_maps_flutter/google_maps_flutter.dart';

class customMarker {
  // Your Marker class details

  static Marker rotate(double rotationParam, Marker marker ) {
    return Marker(
      markerId: marker.markerId,
      position: marker.position,
      icon: marker.icon,
      rotation: rotationParam ?? marker.rotation, // Use the new rotation value if provided, otherwise keep the old one
      anchor: marker.anchor
    );
  }

  static Marker move(LatLng position , Marker marker ) {
    return Marker(
        markerId: marker.markerId,
        position: position,
        icon: marker.icon,
        rotation: marker.rotation, // Use the new rotation value if provided, otherwise keep the old one
        anchor: marker.anchor
    );
  }

  static Marker visibility(bool visible , Marker marker ) {
    return Marker(
        markerId: marker.markerId,
        position: marker.position,
        icon: marker.icon,
        rotation: marker.rotation, // Use the new rotation value if provided, otherwise keep the old one
        anchor: marker.anchor,
        visible: visible
    );
  }

  static Marker toggleVisibility(Marker marker ) {
    return Marker(
        markerId: marker.markerId,
        position: marker.position,
        icon: marker.icon,
        rotation: marker.rotation, // Use the new rotation value if provided, otherwise keep the old one
        anchor: marker.anchor,
        visible: !marker.visible
    );
  }

  static Polygon Polygonvisibility(bool visible , Polygon polygon ) {
    return polygon.copyWith(visibleParam: visible);
  }
}