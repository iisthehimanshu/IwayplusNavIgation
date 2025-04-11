class Buildingbyvenue {
  List<String>? adminIds;
  String? sId;
  String? initialBuildingName;
  String? initialVenueName;
  String? buildingName;
  String? venueName;
  String? venueCategory;
  String? buildingCategory;
  List<double>? coordinates;
  List<double>? pickupCoords;
  String? address;
  bool? liveStatus;
  bool? geofencing;
  String? description;
  List<String>? features;
  String? phone;
  String? website;
  String? venuePhoto;
  String? buildingPhoto;
  List<String>? workingDays;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? locked;
  List<String>? contributorIds;
  String? ownerId;

  Buildingbyvenue(
      {this.adminIds,
        this.sId,
        this.initialBuildingName,
        this.initialVenueName,
        this.buildingName,
        this.venueName,
        this.venueCategory,
        this.buildingCategory,
        this.coordinates,
        this.pickupCoords,
        this.address,
        this.liveStatus,
        this.geofencing,
        this.description,
        this.features,
        this.phone,
        this.website,
        this.venuePhoto,
        this.buildingPhoto,
        this.workingDays,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.locked,
        this.contributorIds,
        this.ownerId});

  Buildingbyvenue.fromJson(Map<String, dynamic> json) {
    adminIds = json['adminIds'].cast<String>();
    sId = json['_id'];
    initialBuildingName = json['initialBuildingName'];
    initialVenueName = json['initialVenueName'];
    buildingName = json['buildingName'];
    venueName = json['venueName'];
    venueCategory = json['venueCategory'];
    buildingCategory = json['buildingCategory'];
    coordinates = json['coordinates'].cast<double>();
    pickupCoords = json['pickupCoords'].cast<double>();
    address = json['address'];
    liveStatus = json['liveStatus'];
    geofencing = json['geofencing'];
    description = json['description'];
    features = json['features'].cast<String>();
    phone = json['phone'];
    website = json['website'];
    venuePhoto = json['venuePhoto'];
    buildingPhoto = json['buildingPhoto'];
    workingDays = json['workingDays'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    locked = json['locked'];
    contributorIds = json['contributorIds'].cast<String>();
    ownerId = json['ownerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adminIds'] = this.adminIds;
    data['_id'] = this.sId;
    data['initialBuildingName'] = this.initialBuildingName;
    data['initialVenueName'] = this.initialVenueName;
    data['buildingName'] = this.buildingName;
    data['venueName'] = this.venueName;
    data['venueCategory'] = this.venueCategory;
    data['buildingCategory'] = this.buildingCategory;
    data['coordinates'] = this.coordinates;
    data['pickupCoords'] = this.pickupCoords;
    data['address'] = this.address;
    data['liveStatus'] = this.liveStatus;
    data['geofencing'] = this.geofencing;
    data['description'] = this.description;
    data['features'] = this.features;
    data['phone'] = this.phone;
    data['website'] = this.website;
    data['venuePhoto'] = this.venuePhoto;
    data['buildingPhoto'] = this.buildingPhoto;
    data['workingDays'] = this.workingDays;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['locked'] = this.locked;
    data['contributorIds'] = this.contributorIds;
    data['ownerId'] = this.ownerId;
    return data;
  }
}
