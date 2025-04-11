import 'dart:async';

class PositionFusion {
  final Stream<Map<String, double>> gpsStream;
  final Stream<Map<String, double>> pdrStream;
  final StreamController<Map<String, double>> _resultStreamController =
  StreamController<Map<String, double>>();

  PositionFusion({
    required this.gpsStream,
    required this.pdrStream,
  }) {
    _combineStreams();
  }

  Stream<Map<String, double>> get resultStream => _resultStreamController.stream;

  void _combineStreams() {
    late Map<String, double> lastGPS;
    late Map<String, double> lastPDR;

    gpsStream.listen((gpsData) {
      lastGPS = gpsData;
      _calculateResult(lastGPS, lastPDR);
    });

    pdrStream.listen((pdrData) {
      lastPDR = pdrData;
      _calculateResult(lastGPS, lastPDR);
    });
  }

  void _calculateResult(
      Map<String, double>? gpsData,
      Map<String, double>? pdrData,
      ) {
    if (gpsData == null || pdrData == null) return;

    final gpsVariance = gpsData['accuracy']!; // From GPS data
    final pdrVariance = pdrData['stepVariance']!; // Derived from PDR data

    final gpsWeight = 1 / gpsVariance;
    final pdrWeight = 1 / pdrVariance;

    final totalWeight = gpsWeight + pdrWeight;

    final fusedLatitude = (gpsWeight * gpsData['latitude']! +
        pdrWeight * pdrData['latitude']!) /
        totalWeight;
    final fusedLongitude = (gpsWeight * gpsData['longitude']! +
        pdrWeight * pdrData['longitude']!) /
        totalWeight;

    _resultStreamController.add({
      'latitude': fusedLatitude,
      'longitude': fusedLongitude,
    });
  }

  void dispose() {
    _resultStreamController.close();
  }
}