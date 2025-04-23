import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/outdoormodel.dart';
import '../Repository/RepositoryManager.dart';

class VenueManager{

  VenueManager._internal();

  // Single instance - lazily initialized
  static final VenueManager _instance = VenueManager._internal();

  // Factory constructor returns the same instance
  factory VenueManager() {
    return _instance;
  }

  RepositoryManager repository = RepositoryManager();
  String _venueName = "IIT Delhi";
  List<Buildingbyvenue> _buildings = [];

  String get venueName => _venueName;

  set venueName(String value) {
    _venueName = value;
  }

  List<Buildingbyvenue> get buildings => _buildings;

  set buildings(List<Buildingbyvenue> value) {
    _buildings = value;
  }

  Future<void> loadVenueData() async {
    buildings = await repository.getBuildingByVenue(venueName);

    for (final building in buildings) {
      final bid = building.sId;
      if (bid == null) continue;

      await Future.wait([
        repository.getPatchData(bid),
        repository.getPolylineData(bid),
        repository.getLandmarkData(bid),
        repository.getWaypointData(bid),
      ]);
    }

    loadCampusData();

  }

  Future<void> loadCampusData() async {
    List<String> bids = buildings
        .map((building) => building.sId)
        .whereType<String>() // filters out nulls if any
        .toList();

    final campus = await repository.getCampusData(bids);
    final campusId = campus?.data?.campusId;

    if (campus != null) {
      final hasGlobalAnnotation = campus.data?.globalAnnotation ?? false;

      if (!hasGlobalAnnotation && campusId != null) {
        await Future.wait([
          repository.getPatchData(campusId),
          repository.getPolylineData(campusId),
          repository.getLandmarkData(campusId),
          repository.getWaypointData(campusId),
        ]);
      }
    }
  }
}