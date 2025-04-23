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
}