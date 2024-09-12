class patchDataModel {
  bool? patchExist;
  PatchData? patchData;

  patchDataModel({this.patchExist, this.patchData});

  patchDataModel.fromJson(Map<dynamic, dynamic> json) {
    patchExist = json['patchExist'];
    patchData = json['patchData'] != null
        ? new PatchData.fromJson(json['patchData'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['patchExist'] = this.patchExist;
    if (this.patchData != null) {
      data['patchData'] = this.patchData!.toJson();
    }
    return data;
  }
}

class PatchData {
  String? sId;
  String? buildingID;
  String? breadth;
  String? fileName;
  String? length;
  List<Coordinates>? coordinates;
  List<ParkingCoords>? parkingCoords;
  List<PickupCoords>? pickupCoords;
  String? createdAt;
  String? updatedAt;
  String? buildingAngle;
  String? buildingName;
  String? corridorWidth;
  String? realtimeLocalisationThreshold;
  int? iV;

  PatchData(
      {this.sId,
        this.buildingID,
        this.breadth,
        this.fileName,
        this.length,
        this.coordinates,
        this.parkingCoords,
        this.pickupCoords,
        this.createdAt,
        this.updatedAt,
        this.buildingAngle,
        this.buildingName,
        this.corridorWidth,
        this.realtimeLocalisationThreshold,
        this.iV});

  PatchData.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    buildingID = json['building_ID'];
    breadth = json['breadth'];
    fileName = json['fileName'];
    length = json['length'];
    if (json['coordinates'] != null) {
      coordinates = <Coordinates>[];
      json['coordinates'].forEach((v) {
        coordinates!.add(new Coordinates.fromJson(v));
      });
    }
    if (json['parkingCoords'] != null) {
      parkingCoords = <ParkingCoords>[];
      json['parkingCoords'].forEach((v) {
        parkingCoords!.add(new ParkingCoords.fromJson(v));
      });
    }
    if (json['pickupCoords'] != null) {
      pickupCoords = <PickupCoords>[];
      json['pickupCoords'].forEach((v) {
        pickupCoords!.add(new PickupCoords.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    buildingAngle = json['buildingAngle'];
    buildingName = json['buildingName'];
    corridorWidth = json['corridorWidth'];
    realtimeLocalisationThreshold = json['realtimeLocalisationThreshold'];
    iV = json['__v'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['_id'] = this.sId;
    data['building_ID'] = this.buildingID;
    data['breadth'] = this.breadth;
    data['fileName'] = this.fileName;
    data['length'] = this.length;
    if (this.coordinates != null) {
      data['coordinates'] = this.coordinates!.map((v) => v.toJson()).toList();
    }
    if (this.parkingCoords != null) {
      data['parkingCoords'] =
          this.parkingCoords!.map((v) => v.toJson()).toList();
    }
    if (this.pickupCoords != null) {
      data['pickupCoords'] = this.pickupCoords!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['buildingAngle'] = this.buildingAngle;
    data['buildingName'] = this.buildingName;
    data['__v'] = this.iV;
    data['corridorWidth'] = this.corridorWidth;
    data['realtimeLocalisationThreshold'] = this.realtimeLocalisationThreshold;
    return data;
  }
}

class Coordinates {
  LocalRef? localRef;
  LocalRef? globalRef;

  Coordinates({this.localRef, this.globalRef});

  Coordinates.fromJson(Map<dynamic, dynamic> json) {
    localRef = json['localRef'] != null
        ? new LocalRef.fromJson(json['localRef'])
        : null;
    globalRef = json['globalRef'] != null
        ? new LocalRef.fromJson(json['globalRef'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (this.localRef != null) {
      data['localRef'] = this.localRef!.toJson();
    }
    if (this.globalRef != null) {
      data['globalRef'] = this.globalRef!.toJson();
    }
    return data;
  }
}

class LocalRef {
  String? lat;
  String? lng;

  LocalRef({this.lat, this.lng});

  LocalRef.fromJson(Map<dynamic, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}

class ParkingCoords {
  String? lat;
  String? lon;

  ParkingCoords({this.lat, this.lon});

  ParkingCoords.fromJson(Map<dynamic, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    return data;
  }
}
class PickupCoords {
  String? lat;
  String? lon;

  PickupCoords({this.lat, this.lon});

  PickupCoords.fromJson(Map<dynamic, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    return data;
  }
}