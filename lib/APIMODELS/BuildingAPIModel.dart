class BuildingAPIModel {
  bool? status;
  List<BuildingAPIInsideModel>? data;

  BuildingAPIModel({this.status, this.data});

  BuildingAPIModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <BuildingAPIInsideModel>[];
      json['data'].forEach((v) {
        data!.add(new BuildingAPIInsideModel.fromJson(v));
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
  String? buildingCode;
  String? venueName;
  String? category;
  List<double>? coordinates;
  List<Null>? pickupCoords;
  String? address;
  bool? liveStatus;
  String? photo;
  int? iV;

  BuildingAPIInsideModel(
      {this.sId,
        this.initialBuildingName,
        this.initialVenueName,
        this.buildingName,
        this.buildingCode,
        this.venueName,
        this.category,
        this.coordinates,
        this.pickupCoords,
        this.address,
        this.liveStatus,
        this.photo,
        this.iV});

  BuildingAPIInsideModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    initialBuildingName = json['initialBuildingName'];
    initialVenueName = json['initialVenueName'];
    buildingName = json['buildingName'];
    buildingCode = json['buildingCode'];
    venueName = json['venueName'];
    category = json['category'];
    coordinates = json['coordinates'].cast<double>();
    if (json['pickupCoords'] != null) {
      pickupCoords = <Null>[];
      json['pickupCoords'].forEach((v) {
        pickupCoords!.add(v??"");
      });
    }
    address = json['address'];
    liveStatus = json['liveStatus'];
    photo = json['photo'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['initialBuildingName'] = this.initialBuildingName;
    data['initialVenueName'] = this.initialVenueName;
    data['buildingName'] = this.buildingName;
    data['buildingCode'] = this.buildingCode;
    data['venueName'] = this.venueName;
    data['category'] = this.category;
    data['coordinates'] = this.coordinates;
    if (this.pickupCoords != null) {
      data['pickupCoords'] = this.pickupCoords!.map((v) => v).toList();
    }
    data['address'] = this.address;
    data['liveStatus'] = this.liveStatus;
    data['photo'] = this.photo;
    data['__v'] = this.iV;
    return data;
  }
}