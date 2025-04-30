class patchDataModel {
  bool? patchExist;
  PatchData? patchData;

  patchDataModel({this.patchExist, this.patchData});

  patchDataModel.fromJson(dynamic json) {
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
  List<ParkingCoords>? pickupCoords;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? corridorWidth;
  String? realtimeLocalisationThreshold;
  List<ParkingCoords>? walkingCoords;
  String? geoJsonMap;
  String? buildingAngle;
  String? buildingName;
  String? pdrThreshold;
  List<ArPatch>? arPatch;

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
        this.iV,
        this.corridorWidth,
        this.realtimeLocalisationThreshold,
        this.walkingCoords,
        this.geoJsonMap,
        this.buildingAngle,
        this.buildingName,
        this.pdrThreshold,
        this.arPatch});

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
      pickupCoords = <ParkingCoords>[];
      json['pickupCoords'].forEach((v) {
        pickupCoords!.add(new ParkingCoords.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    corridorWidth = json['corridorWidth'];
    realtimeLocalisationThreshold = json['realtimeLocalisationThreshold'];
    if (json['walkingCoords'] != null) {
      walkingCoords = <ParkingCoords>[];
      json['walkingCoords'].forEach((v) {
        walkingCoords!.add(new ParkingCoords.fromJson(v));
      });
    }
    geoJsonMap = json['geoJsonMap'];
    buildingAngle = json['buildingAngle'];
    buildingName = json['buildingName'];
    pdrThreshold = json['pdrThreshold'];
    if (json['arPatch'] != null) {
      arPatch = <ArPatch>[];
      json['arPatch'].forEach((v) {
        arPatch!.add(new ArPatch.fromJson(v));
      });
    }
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
    data['__v'] = this.iV;
    data['corridorWidth'] = this.corridorWidth;
    data['realtimeLocalisationThreshold'] = this.realtimeLocalisationThreshold;
    if (this.walkingCoords != null) {
      data['walkingCoords'] =
          this.walkingCoords!.map((v) => v.toJson()).toList();
    }
    data['geoJsonMap'] = this.geoJsonMap;
    data['buildingAngle'] = this.buildingAngle;
    data['buildingName'] = this.buildingName;
    data['pdrThreshold'] = this.pdrThreshold;
    if (this.arPatch != null) {
      data['arPatch'] = this.arPatch!.map((v) => v.toJson()).toList();
    }
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

class ArPatch {
  Properties? properties;
  String? sId;
  int? coordinateX;
  int? coordinateY;

  ArPatch({this.properties, this.sId, this.coordinateX, this.coordinateY});

  ArPatch.fromJson(Map<dynamic, dynamic> json) {
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
    sId = json['_id'];
    coordinateX = json['coordinateX'];
    coordinateY = json['coordinateY'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (this.properties != null) {
      data['properties'] = this.properties!.toJson();
    }
    data['_id'] = this.sId;
    data['coordinateX'] = this.coordinateX;
    data['coordinateY'] = this.coordinateY;
    return data;
  }
}

class Properties {
  String? latitude;
  String? longitude;
  String? arValue;

  Properties({this.latitude, this.longitude, this.arValue});

  Properties.fromJson(Map<dynamic, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    arValue = json['arValue'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['arValue'] = this.arValue;
    return data;
  }
}

