class beacon {
  Element? element;
  Properties? properties;
  String? sId;
  String? buildingID;
  int? coordinateX;
  int? coordinateY;
  String? featureType;
  String? type;
  int? floor;
  String? geometryType;
  String? name;
  List<Lifts>? lifts;
  List<Stairs>? stairs;
  List<Others>? others;
  int? iV;
  int? doorX;
  int? doorY;
  String? createdAt;
  String? updatedAt;

  beacon(
      {this.element,
        this.properties,
        this.sId,
        this.buildingID,
        this.coordinateX,
        this.coordinateY,
        this.featureType,
        this.type,
        this.floor,
        this.geometryType,
        this.name,
        this.lifts,
        this.stairs,
        this.others,
        this.iV,
        this.doorX,
        this.doorY,
        this.createdAt,
        this.updatedAt
      });

  beacon.fromJson(Map<dynamic, dynamic> json) {
    element =
    json['element'] != null ? new Element.fromJson(json['element']) : null;
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
    sId = json['_id'];
    buildingID = json['building_ID'];
    coordinateX = json['coordinateX'].toInt();
    coordinateY = json['coordinateY'].toInt();
    featureType = json['feature_type'];
    type = json['type'];
    floor = json['floor'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    geometryType = json['geometryType'];
    name = json['name'];
    if (json['lifts'] != null) {
      lifts = <Lifts>[];
      json['lifts'].forEach((v) {
        lifts!.add(new Lifts.fromJson(v));
      });
    }
    if (json['stairs'] != null) {
      stairs = <Stairs>[];
      json['stairs'].forEach((v) {
        stairs!.add(new Stairs.fromJson(v));
      });
    }
    if (json['others'] != null) {
      others = <Others>[];
      json['others'].forEach((v) {
        others!.add(new Others.fromJson(v));
      });
    }
    iV = json['__v'];
    doorX = json['doorX'];
    doorY = json['doorY'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (this.element != null) {
      data['element'] = this.element!.toJson();
    }
    if (this.properties != null) {
      data['properties'] = this.properties!.toJson();
    }
    data['_id'] = this.sId;
    data['building_ID'] = this.buildingID;
    data['coordinateX'] = this.coordinateX;
    data['coordinateY'] = this.coordinateY;
    data['feature_type'] = this.featureType;
    data['type'] = this.type;
    data['floor'] = this.floor;
    data['geometryType'] = this.geometryType;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['name'] = this.name;
    if (this.lifts != null) {
      data['lifts'] = this.lifts!.map((v) => v.toJson()).toList();
    }
    if (this.stairs != null) {
      data['stairs'] = this.stairs!.map((v) => v.toJson()).toList();
    }
    if (this.others != null) {
      data['others'] = this.others!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    data['doorX'] = this.doorX;
    data['doorY'] = this.doorY;
    return data;
  }
}

class Element {
  String? type;
  String? subType;

  Element({this.type, this.subType});

  Element.fromJson(Map<dynamic, dynamic> json) {
    type = json['type'];
    subType = json['subType'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['type'] = this.type;
    data['subType'] = this.subType;
    return data;
  }
}

class Properties {
  String? latitude;
  String? longitude;
  String? node;
  String? nodeId;
  String? macId;
  List<Null>? nonWalkableGrids;
  List<Null>? flrDistMatrix;
  List<Null>? frConn;
  List<Null>? clickedPoints;
  List<Null>? polygonId;

  Properties(
      {this.latitude,
        this.longitude,
        this.node,
        this.nodeId,
        this.macId,
        this.nonWalkableGrids,
        this.flrDistMatrix,
        this.frConn,
        this.clickedPoints,
        this.polygonId});

  Properties.fromJson(Map<dynamic, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    node = json['node'];
    nodeId = json['nodeId'];
    macId = json['macId'];
    if (json['nonWalkableGrids'] != null) {
      nonWalkableGrids = <Null>[];
      json['nonWalkableGrids'].forEach((v) {
        nonWalkableGrids!.add(new Null.fromJson(v));
      });
    }
    if (json['flr_dist_matrix'] != null) {
      flrDistMatrix = <Null>[];
      json['flr_dist_matrix'].forEach((v) {
        flrDistMatrix!.add(new Null.fromJson(v));
      });
    }
    if (json['frConn'] != null) {
      frConn = <Null>[];
      json['frConn'].forEach((v) {
        frConn!.add(new Null.fromJson(v));
      });
    }
    if (json['clickedPoints'] != null) {
      clickedPoints = <Null>[];
      json['clickedPoints'].forEach((v) {
        clickedPoints!.add(new Null.fromJson(v));
      });
    }
    if (json['polygonId'] != null) {
      polygonId = <Null>[];
      json['polygonId'].forEach((v) {
        polygonId!.add(new Null.fromJson(v));
      });
    }
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['node'] = this.node;
    data['nodeId'] = this.nodeId;
    data['macId'] = this.macId;
    if (this.nonWalkableGrids != null) {
      data['nonWalkableGrids'] =
          this.nonWalkableGrids!.map((v) => v.toJson()).toList();
    }
    if (this.flrDistMatrix != null) {
      data['flr_dist_matrix'] =
          this.flrDistMatrix!.map((v) => v.toJson()).toList();
    }
    if (this.frConn != null) {
      data['frConn'] = this.frConn!.map((v) => v.toJson()).toList();
    }
    if (this.clickedPoints != null) {
      data['clickedPoints'] =
          this.clickedPoints!.map((v) => v.toJson()).toList();
    }
    if (this.polygonId != null) {
      data['polygonId'] = this.polygonId!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lifts {
  String? name;
  int? distance;

  Lifts({this.name, this.distance});

  Lifts.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    distance = json['distance'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['name'] = this.name;
    data['distance'] = this.distance;
    return data;
  }
}

class Stairs {
  String? name;
  int? distance;

  Stairs({this.name, this.distance});

  Stairs.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    distance = json['distance'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['name'] = this.name;
    data['distance'] = this.distance;
    return data;
  }
}

class Others {
  String? name;
  int? distance;

  Others({this.name, this.distance});

  Others.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    distance = json['distance'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['name'] = this.name;
    data['distance'] = this.distance;
    return data;
  }
}
class Null {
  String? name;
  int? distance;

  Null({this.name, this.distance});

  Null.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    distance = json['distance'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['name'] = this.name;
    data['distance'] = this.distance;
    return data;
  }
}
