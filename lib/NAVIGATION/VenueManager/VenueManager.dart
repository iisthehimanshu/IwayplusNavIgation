import '../APIMODELS/Buildingbyvenue.dart';
import '../APIMODELS/outdoormodel.dart';
import '../Repository/RepositoryManager.dart';

class Venuemanager{
  RepositoryManager repository = RepositoryManager();
  String _venueName = "IIT Delhi";

  String get venueName => _venueName;

  set venueName(String value) {
    _venueName = value;
  }

  Future<void> loadVenueData() async {
    List<Buildingbyvenue> buildings = await getAllBuildingIDS();
    List<String> bids = [];
    for (var building in buildings) {
      bids.add(building.sId!);
      await repository.getPatchData(building.sId!);
      await repository.getPolylineData(building.sId!);
      await repository.getLandmarkData(building.sId!);
      await repository.getWaypointData(building.sId!);
    }
    outdoormodel? campus = await repository.getCampusData(bids);
    if(campus != null){

    }
  }
  
  Future<List<Buildingbyvenue>> getAllBuildingIDS() async {
    return await repository.getBuildingByVenue(venueName);
  }

  void loadCampusData(){

  }
}