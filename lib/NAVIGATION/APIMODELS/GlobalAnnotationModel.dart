class MappingElement {
  final String? id;
  final String? sId;
  final String? buildingID;
  final Geometry? geometry;
  final Properties? properties;
  final List<dynamic>? associatedPolygons;
  final List<dynamic>? associatedPoints;
  final String? type;
  final String? createdBy;
  final String? updatedBy;

  MappingElement({
    required this.id,
    required this.sId,
    required this.buildingID,
    required this.geometry,
    required this.properties,
    required this.associatedPolygons,
    required this.associatedPoints,
    required this.type,
    required this.createdBy,
    this.updatedBy,
  });

  factory MappingElement.fromJson(Map<dynamic, dynamic> json) {
    return MappingElement(
      id: json['id'],
      sId: json['_id'],
      buildingID: json['building_ID'],
      geometry: json['geometry'] != null?Geometry.fromJson(json['geometry']):json['geometry'],
      properties: json['properties'] != null?Properties.fromJson(json['properties']):json['properties'],
      associatedPoints: json['associatedPoints'],
      associatedPolygons: json['associatedPolygons'],
      type: json['type'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'id': id,
      'building_ID': buildingID,
      'geometry': geometry?.toJson(),
      'properties': properties?.toJson(),
      'associatedPoints': associatedPoints,
      'associatedPolygons': associatedPolygons,
      'type': type,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}

class Properties {
  final String? name;
  final String? strokeColor;
  final String? fillColor;

  Properties({
    required this.name,
    required this.strokeColor,
    required this.fillColor,
  });

  factory Properties.fromJson(Map<dynamic, dynamic> json) {
    return Properties(
      name: json['name'],
      strokeColor: json['strokeColor'],
      fillColor: json['fillColor'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'name': name,
      'strokeColor': strokeColor,
      'fillColor': fillColor,
    };
  }
}


class Geometry {
  final List<dynamic>? coordinates;
  final String? type;
  final List<dynamic>? coordinatesLocal;

  Geometry({
    required this.coordinates,
    required this.type,
    this.coordinatesLocal,
  });

  factory Geometry.fromJson(Map<dynamic, dynamic> json) {
    return Geometry(
      coordinates: json['coordinates'],
      type: json['type'],
      coordinatesLocal: json['coordinnatesLocal'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'coordinates': coordinates,
      'type': type,
      'coordinnatesLocal': coordinatesLocal,
    };
  }
}

class PathNetwork {
  final Map<String, List<dynamic>>? pathNetworkGlobal;
  final Map<String, List<dynamic>>? pathNetwork;

  PathNetwork({
    required this.pathNetworkGlobal,
    required this.pathNetwork,
  });

  factory PathNetwork.fromJson(Map<dynamic, dynamic> json) {
    return PathNetwork(
      pathNetworkGlobal: Map<String, List<dynamic>>.from(
        json['pathNetworkGlobal']??{}.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      pathNetwork: Map<String, List<dynamic>>.from(
        json['pathNetwork']??{}.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'pathNetworkGlobal': pathNetworkGlobal,
      'pathNetwork': pathNetwork,
    };
  }
}

class GlobalModel {
  final List<MappingElement>? mappingElements;
  final PathNetwork? pathNetwork;
  final String? buildingName;
  final String? venueName;

  GlobalModel({
    required this.mappingElements,
    required this.pathNetwork,
    required this.buildingName,
    required this.venueName,
  });

  factory GlobalModel.fromJson(dynamic json) {
    return GlobalModel(
      mappingElements: (json['mappingElements'] as List<dynamic>)
          .map((e) => MappingElement.fromJson(e))
          .toList(),
      pathNetwork: PathNetwork.fromJson({
        'pathNetworkGlobal': json['pathNetworkGlobal'],
        'pathNetwork': json['pathNetwork'],
      }),
        buildingName: json['buildingName'],
        venueName: json['venueName']
    );
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['mappingElements'] =this.mappingElements;
    data['pathNetwork'] = this.pathNetwork;
    data['buildingName'] = this.buildingName;
    data['venueName'] = this.venueName;
    return data;
  }
}
