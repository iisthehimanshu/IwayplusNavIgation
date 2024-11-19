class Building {
  bool? status;
  List<BuildingAPIInsideModel>? data;

  Building({this.status, this.data});

  Building.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <BuildingAPIInsideModel>[];
      json['data'].forEach((v) {
        print("v $v");
        if(v['initialBuildingName'] != null) {
          data!.add(new BuildingAPIInsideModel.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BuildingAPIInsideModel {
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
  List<WorkingDays>? workingDays;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? favourite;

  BuildingAPIInsideModel(
      {this.sId,
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
        this.favourite
      });

  BuildingAPIInsideModel.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    initialBuildingName = json['initialBuildingName'];
    initialVenueName = json['initialVenueName'];
    buildingName = json['buildingName'];
    venueName = json['venueName'];
    venueCategory = json['venueCategory'];
    buildingCategory = json['buildingCategory'];
    coordinates = json['coordinates'].cast<double>();
    if (json['pickupCoords'] != null) {
      pickupCoords = <double>[];
      json['pickupCoords'].forEach((v) {
        pickupCoords!.add(v??"");
      });
    }
    address = json['address'];
    liveStatus = json['liveStatus'];
    geofencing = json['geofencing'];
    description = json['description'];
    features = json['features'].cast<String>();
    phone = json['phone'];
    website = json['website'];
    venuePhoto = json['venuePhoto'];
    buildingPhoto = json['buildingPhoto'];
    if (json['workingDays'] != null) {
      workingDays = <WorkingDays>[];
      json['workingDays'].forEach((v) {
        workingDays!.add(new WorkingDays.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
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
    if (this.workingDays != null) {
      data['workingDays'] = this.workingDays!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
class WorkingDays {
  String? day;
  String? openingTime;
  String? closingTime;
  String? sId;

  WorkingDays({this.day, this.openingTime, this.closingTime, this.sId});

  WorkingDays.fromJson(Map<dynamic, dynamic> json) {
    day = json['day'];
    openingTime = json['openingTime'];
    closingTime = json['closingTime'];
    sId = json['_id'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['day'] = this.day;
    data['openingTime'] = this.openingTime;
    data['closingTime'] = this.closingTime;
    data['_id'] = this.sId;
    return data;
  }
}