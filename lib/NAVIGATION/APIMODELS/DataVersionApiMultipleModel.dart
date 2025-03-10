class DataVersionApiMultipleModel {
  String? sId;
  String? buildingID;
  int? buildingDataVersion;
  int? patchDataVersion;
  int? polylineDataVersion;
  int? landmarksDataVersion;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<double>? coordinates;

  DataVersionApiMultipleModel(
      {this.sId,
        this.buildingID,
        this.buildingDataVersion,
        this.patchDataVersion,
        this.polylineDataVersion,
        this.landmarksDataVersion,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.coordinates});

  DataVersionApiMultipleModel.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    buildingID = json['building_ID'];
    buildingDataVersion = json['buildingDataVersion'];
    patchDataVersion = json['patchDataVersion'];
    polylineDataVersion = json['polylineDataVersion'];
    landmarksDataVersion = json['landmarksDataVersion'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['_id'] = this.sId;
    data['building_ID'] = this.buildingID;
    data['buildingDataVersion'] = this.buildingDataVersion;
    data['patchDataVersion'] = this.patchDataVersion;
    data['polylineDataVersion'] = this.polylineDataVersion;
    data['landmarksDataVersion'] = this.landmarksDataVersion;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['coordinates'] = this.coordinates;
    return data;
  }
}
