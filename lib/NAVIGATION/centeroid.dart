import 'dart:math';

class GeoPoint {
  final double latitude;
  final double longitude;
  GeoPoint(this.latitude, this.longitude);
}

class Triangle {
  final GeoPoint a;
  final GeoPoint b;
  final GeoPoint c;
  Triangle(this.a, this.b, this.c);

  // Convert to Cartesian (x, y, z) for centroid calculation
  List<double> toCartesian(GeoPoint p) {
    double latRad = p.latitude * pi / 180;
    double lonRad = p.longitude * pi / 180;
    double x = cos(latRad) * cos(lonRad);
    double y = cos(latRad) * sin(lonRad);
    double z = sin(latRad);
    return [x, y, z];
  }

  GeoPoint calculateCentroid() {
    List<double> aCart = toCartesian(a);
    List<double> bCart = toCartesian(b);
    List<double> cCart = toCartesian(c);

    double centroidX = (aCart[0] + bCart[0] + cCart[0]) / 3;
    double centroidY = (aCart[1] + bCart[1] + cCart[1]) / 3;
    double centroidZ = (aCart[2] + bCart[2] + cCart[2]) / 3;

    // Convert back to latitude/longitude
    double lon = atan2(centroidY, centroidX) * 180 / pi;
    double hyp = sqrt(centroidX * centroidX + centroidY * centroidY);
    double lat = atan2(centroidZ, hyp) * 180 / pi;

    return GeoPoint(lat, lon);
  }

  double calculateArea() {
    // Use spherical excess formula for the area of a triangle on a sphere
    const double earthRadius = 6371.0; // Radius of Earth in kilometers
    double A = haversineDistance(a, b);
    double B = haversineDistance(b, c);
    double C = haversineDistance(c, a);

    double s = (A + B + C) / 2;
    double area = sqrt(s * (s - A) * (s - B) * (s - C));

    return area * earthRadius * earthRadius;
  }
}

// Haversine formula for distance between two points on a sphere
double haversineDistance(GeoPoint p1, GeoPoint p2) {
  const double earthRadius = 6371.0; // Radius of Earth in kilometers

  double dLat = (p2.latitude - p1.latitude) * pi / 180.0;
  double dLon = (p2.longitude - p1.longitude) * pi / 180.0;

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(p1.latitude * pi / 180) *
          cos(p2.latitude * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

bool isConvex(GeoPoint a, GeoPoint b, GeoPoint c) {
  // Convex check can stay the same, as it's based on cross product
  return (b.longitude - a.longitude) * (c.latitude - a.latitude) -
      (b.latitude - a.latitude) * (c.longitude - a.longitude) >
      0;
}

bool isPointInTriangle(GeoPoint p, Triangle t) {
  double denominator = (t.a.latitude - t.c.latitude) * (t.b.longitude - t.c.longitude) +
      (t.c.longitude - t.a.longitude) * (t.b.latitude - t.c.latitude);
  double a = ((t.b.latitude - t.c.latitude) * (p.longitude - t.c.longitude) +
      (t.c.longitude - t.b.longitude) * (p.latitude - t.c.latitude)) /
      denominator;
  double b = ((t.c.latitude - t.a.latitude) * (p.longitude - t.c.longitude) +
      (t.a.longitude - t.c.longitude) * (p.latitude - t.c.latitude)) /
      denominator;
  double c = 1 - a - b;
  return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1;
}

List<Triangle> earClippingTriangulation(List<GeoPoint> vertices) {
  List<GeoPoint> remainingVertices = List.from(vertices);
  List<Triangle> triangles = [];
  while (remainingVertices.length > 3) {
    bool earFound = false;
    for (int i = 0; i < remainingVertices.length; i++) {
      int prevIndex =
          (i - 1 + remainingVertices.length) % remainingVertices.length;
      int nextIndex = (i + 1) % remainingVertices.length;
      GeoPoint prev = remainingVertices[prevIndex];
      GeoPoint current = remainingVertices[i];
      GeoPoint next = remainingVertices[nextIndex];
      if (isConvex(prev, current, next)) {
        Triangle ear = Triangle(prev, current, next);
        bool isEar = true;
        for (GeoPoint p in remainingVertices) {
          if (p != prev &&
              p != current &&
              p != next &&
              isPointInTriangle(p, ear)) {
            isEar = false;
            break;
          }
        }
        if (isEar) {
          triangles.add(ear);
          remainingVertices.removeAt(i);
          earFound = true;
          break;
        }
      }
    }
    if (!earFound) {
      throw Exception("No ear found; the polygon might be invalid.");
    }
  }
  triangles.add(Triangle(
      remainingVertices[0], remainingVertices[1], remainingVertices[2]));
  return triangles;
}

GeoPoint calculatePolygonCentroid(List<GeoPoint> vertices) {
  List<Triangle> triangles = earClippingTriangulation(vertices);
  double weightedX = 0.0;
  double weightedY = 0.0;
  double weightedZ = 0.0;
  double totalArea = 0.0;

  for (Triangle triangle in triangles) {
    double area = triangle.calculateArea().abs();
    GeoPoint centroid = triangle.calculateCentroid();
    List<double> cartesian = triangle.toCartesian(centroid);
    weightedX += cartesian[0] * area;
    weightedY += cartesian[1] * area;
    weightedZ += cartesian[2] * area;
    totalArea += area;
  }

  // Normalize the weighted sum to get the centroid in Cartesian coordinates
  double centroidX = weightedX / totalArea;
  double centroidY = weightedY / totalArea;
  double centroidZ = weightedZ / totalArea;

  // Convert back to latitude/longitude
  double lon = atan2(centroidY, centroidX) * 180 / pi;
  double hyp = sqrt(centroidX * centroidX + centroidY * centroidY);
  double lat = atan2(centroidZ, hyp) * 180 / pi;

  return GeoPoint(lat, lon);
}
