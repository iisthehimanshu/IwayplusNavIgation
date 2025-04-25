import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/patchDataModel.dart';
import '../APIMODELS/polylinedata.dart';
import '../Repository/RepositoryManager.dart';

class VenueManager{

  VenueManager._internal();

  // Single instance - lazily initialized
  static final VenueManager _instance = VenueManager._internal();

  // Factory constructor returns the same instance
  factory VenueManager() {
    return _instance;
  }

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

  Future<List<polylinedata>?> getPolylinePolygonData() async {
    print("buildings $buildings");
    if(buildings.isEmpty) return null;
    List<polylinedata> data = [];
    for (var building in buildings) {
      polylinedata buildingData = await RepositoryManager().getPolylineData(building.sId!);
      data.add(buildingData);
    }
    return data;
  }

  Future<List<patchDataModel>?> getPatchData() async {
    print("buildings $buildings");
    if(buildings.isEmpty) return null;
    List<patchDataModel> data = [];
    for (var building in buildings) {
      patchDataModel buildingData = await RepositoryManager().getPatchData(building.sId!);
      data.add(buildingData);
    }
    return data;
  }

}