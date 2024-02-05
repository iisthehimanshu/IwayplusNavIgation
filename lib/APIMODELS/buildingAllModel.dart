class buildingAllModel {
  List<double>? pickupCoords;
  String? sId;
  String? initialBuildingName;
  String? initialVenueName;
  String? buildingName;
  String? buildingCode;
  String? venueName;
  String? category;
  List<double>? coordinates;
  String? address;
  bool? liveStatus;
  int? iV;
  String? photo;

  buildingAllModel(
      {this.pickupCoords,
        this.sId,
        this.initialBuildingName,
        this.initialVenueName,
        this.buildingName,
        this.buildingCode,
        this.venueName,
        this.category,
        this.coordinates,
        this.address,
        this.liveStatus,
        this.iV,
        this.photo});

  buildingAllModel.fromJson(Map<String, dynamic> json) {
    pickupCoords = json['pickupCoords'].cast<double>();
    sId = json['_id'];
    initialBuildingName = json['initialBuildingName'];
    initialVenueName = json['initialVenueName'];
    buildingName = json['buildingName'];
    buildingCode = json['buildingCode'];
    venueName = json['venueName'];
    category = json['category'];
    coordinates = json['coordinates'].cast<double>();
    address = json['address'];
    liveStatus = json['liveStatus'];
    iV = json['__v'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pickupCoords'] = this.pickupCoords;
    data['_id'] = this.sId;
    data['initialBuildingName'] = this.initialBuildingName;
    data['initialVenueName'] = this.initialVenueName;
    data['buildingName'] = this.buildingName;
    data['buildingCode'] = this.buildingCode;
    data['venueName'] = this.venueName;
    data['category'] = this.category;
    data['coordinates'] = this.coordinates;
    data['address'] = this.address;
    data['liveStatus'] = this.liveStatus;
    data['__v'] = this.iV;
    data['photo'] = this.photo;
    return data;
  }
}