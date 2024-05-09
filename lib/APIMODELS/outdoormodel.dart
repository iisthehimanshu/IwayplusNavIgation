class outdoormodel {
  bool? status;
  Data? data;

  outdoormodel({this.status, this.data});

  outdoormodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? campusId;
  List<String>? buildingIds;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? floor;
  bool? visibility;

  Data(
      {this.sId,
        this.campusId,
        this.buildingIds,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.floor,
        this.visibility});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    campusId = json['campusId'];
    buildingIds = json['buildingIds'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    floor = json['floor'];
    visibility = json['visibility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['campusId'] = this.campusId;
    data['buildingIds'] = this.buildingIds;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['floor'] = this.floor;
    data['visibility'] = this.visibility;
    return data;
  }
}
