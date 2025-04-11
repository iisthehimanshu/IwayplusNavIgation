class VenueModel{
  String? imageURL;
  String? Tag;
  String? venueName;
  int? distance;
  int? buildingNumber;
  String? address;
  String? phoneNo;
  String? description;
  String? website;
  List<double> coordinates;
  int dist;



  VenueModel({
    required this.imageURL,
    required this.Tag,
    required this.venueName,
    required this.distance,
    required this.buildingNumber,
    required this.address,
    required this.phoneNo,
    required this.description,
    required this.website,
    required this.coordinates,
    required this.dist
  });

}