class QRDataAPIModel {
  String? sId;
  String? code;
  String? landmarkId;
  String? landmarkName;
  String? buildingID;
  String? createdAt;
  String? updatedAt;
  int? iV;

  QRDataAPIModel(
      {this.sId,
        this.code,
        this.landmarkId,
        this.landmarkName,
        this.buildingID,
        this.createdAt,
        this.updatedAt,
        this.iV});

  QRDataAPIModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    landmarkId = json['landmarkId'];
    landmarkName = json['landmarkName'];
    buildingID = json['building_ID'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['code'] = this.code;
    data['landmarkId'] = this.landmarkId;
    data['landmarkName'] = this.landmarkName;
    data['building_ID'] = this.buildingID;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}