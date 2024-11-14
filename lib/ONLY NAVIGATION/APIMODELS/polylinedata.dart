class polylinedata {
  bool? polylineExist;
  Polyline? polyline;

  polylinedata({this.polylineExist, this.polyline});

  polylinedata.fromJson(Map<dynamic, dynamic> json) {
    polylineExist = json['polylineExist'];
    polyline = json['polyline'] != null
        ? new Polyline.fromJson(json['polyline'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['polylineExist'] = this.polylineExist;
    if (this.polyline != null) {
      data['polyline'] = this.polyline!.toJson();
    }
    return data;
  }
}

class Polyline {
  String? sId;
  String? buildingID;
  List<Floors>? floors;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Polyline(
      {this.sId,
        this.buildingID,
        this.floors,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Polyline.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    buildingID = json['building_ID'];
    if (json['floors'] != null) {
      floors = <Floors>[];
      json['floors'].forEach((v) {
        floors!.add(new Floors.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['_id'] = this.sId;
    data['building_ID'] = this.buildingID;
    if (this.floors != null) {
      data['floors'] = this.floors!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Floors {
  String? floor;
  List<PolyArray>? polyArray;
  String? sId;

  Floors({this.floor, this.polyArray, this.sId});

  Floors.fromJson(Map<dynamic, dynamic> json) {
    floor = json['floor'];
    if (json['poly_array'] != null) {
      polyArray = <PolyArray>[];
      json['poly_array'].forEach((v) {
        polyArray!.add(new PolyArray.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['floor'] = this.floor;
    if (this.polyArray != null) {
      data['poly_array'] = this.polyArray!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class PolyArray {
  String? contact;
  String? cubicleContact;
  String? cubicleName;
  String? floor;
  String? floorElement;
  String? id;
  String? name;
  List<Nodes>? nodes;
  List<double>? centroid;
  String? polygonType;
  String? wallNature;
  String? cubicleHeight;
  String? cubicleColor;
  String? walkableType;
  String? visibilityType = "visible";
  String? sId;

  PolyArray(
      {this.contact,
        this.cubicleContact,
        this.cubicleName,
        this.floor,
        this.floorElement,
        this.id,
        this.name,
        this.nodes,
        this.centroid,
        this.polygonType,
        this.wallNature,
        this.cubicleHeight,
        this.cubicleColor,
        this.walkableType,
        this.visibilityType,
        this.sId});

  PolyArray.fromJson(Map<dynamic, dynamic> json) {
    contact = json['contact'];
    cubicleContact = json['cubicleContact'];
    cubicleName = json['cubicleName'];
    floor = json['floor'];
    floorElement = json['floorElement'];
    id = json['id'];
    name = json['name'];
    if (json['nodes'] != null) {
      nodes = <Nodes>[];
      json['nodes'].forEach((v) {
        nodes!.add(new Nodes.fromJson(v));
      });
    }
    centroid = json['centroid'].cast<double>();
    polygonType = json['polygonType'];
    wallNature = json['wallNature'];
    cubicleHeight = json['cubicleHeight'];
    cubicleColor = json['cubicleColor'];
    walkableType = json['walkableType'];
    if(json['visibilityType'] != null){
      visibilityType = json['visibilityType'];
    }
    sId = json['_id'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['contact'] = this.contact;
    data['cubicleContact'] = this.cubicleContact;
    data['cubicleName'] = this.cubicleName;
    data['floor'] = this.floor;
    data['floorElement'] = this.floorElement;
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.nodes != null) {
      data['nodes'] = this.nodes!.map((v) => v.toJson()).toList();
    }
    data['centroid'] = this.centroid;
    data['polygonType'] = this.polygonType;
    data['wallNature'] = this.wallNature;
    data['cubicleHeight'] = this.cubicleHeight;
    data['cubicleColor'] = this.cubicleColor;
    data['walkableType'] = this.walkableType;
    data['visibilityType'] = this.visibilityType;
    data['_id'] = this.sId;
    return data;
  }
}

class Nodes {
  int? coordx;
  int? coordy;
  double? lat;
  double? lon;
  String? indexNode;
  String? sId;

  Nodes(
      {this.coordx, this.coordy, this.lat, this.lon, this.indexNode, this.sId});

  Nodes.fromJson(Map<dynamic, dynamic> json) {
    coordx = json['coordx'];
    coordy = json['coordy'];
    lat = json['lat'];
    lon = json['lon'];
    indexNode = json['indexNode'];
    sId = json['_id'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['coordx'] = this.coordx;
    data['coordy'] = this.coordy;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['indexNode'] = this.indexNode;
    data['_id'] = this.sId;
    return data;
  }
}
