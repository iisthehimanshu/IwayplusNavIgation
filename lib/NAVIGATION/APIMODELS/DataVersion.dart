class DataVersion {
  bool? status;
  DataVersionModel? versionData;

  DataVersion({this.status, this.versionData});

  DataVersion.fromJson(Map<dynamic, dynamic> json) {
    status = json['status'];
    versionData = json['versionData'] != null
        ? new DataVersionModel.fromJson(json['versionData'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.versionData != null) {
      data['versionData'] = this.versionData!.toJson();
    }
    return data;
  }
}

class DataVersionModel {
  String? sId;
  String? buildingID;
  int? buildingDataVersion;
  int? patchDataVersion;
  int? polylineDataVersion;
  int? landmarksDataVersion;
  String? createdAt;
  String? updatedAt;
  int? iV;

  DataVersionModel(
      {this.sId,
        this.buildingID,
        this.buildingDataVersion,
        this.patchDataVersion,
        this.polylineDataVersion,
        this.landmarksDataVersion,
        this.createdAt,
        this.updatedAt,
        this.iV});

  DataVersionModel.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    buildingID = json['building_ID'];
    buildingDataVersion = json['buildingDataVersion'];
    patchDataVersion = json['patchDataVersion'];
    polylineDataVersion = json['polylineDataVersion'];
    landmarksDataVersion = json['landmarksDataVersion'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
    return data;
  }
}