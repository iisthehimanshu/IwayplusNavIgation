
import 'dart:convert';

OutBuildingModel buildingData(String str)=>OutBuildingModel.fromJson(json.decode(str));

class OutBuildingModel {
  bool? status;
  Data? data;

  OutBuildingModel({this.status, this.data});

  OutBuildingModel.fromJson(Map<String, dynamic> json) {
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
  List<Path>? path;
  int? distanceMeters;
  String? duration;
  String? pathId;

  Data({this.path, this.distanceMeters, this.duration, this.pathId});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['path'] != null) {
      path = <Path>[];
      json['path'].forEach((v) {
        path!.add(new Path.fromJson(v));
      });
    }
    distanceMeters = json['distanceMeters'];
    duration = json['duration'];
    pathId = json['pathId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.path != null) {
      data['path'] = this.path!.map((v) => v.toJson()).toList();
    }
    data['distanceMeters'] = this.distanceMeters;
    data['duration'] = this.duration;
    data['pathId'] = this.pathId;
    return data;
  }
}

class Path {
  double? lat;
  double? lng;

  Path({this.lat, this.lng});

  Path.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}
