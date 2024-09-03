class land {
  bool? landmarkExist;
  List<Landmarks>? landmarks;
  Map<String, Landmarks>? landmarksMap; // Add this line
  Map<String, String>? landmarksNameMap; // Add this line
  List<String>? landmarkNames;


  land({this.landmarkExist, this.landmarks, this.landmarksMap,this.landmarkNames, this.landmarksNameMap}); // Update the constructor

  land.fromJson(Map<dynamic, dynamic> json) {
    landmarkExist = json['landmarkExist'];
    if (json['landmarks'] != null) {
      landmarks = <Landmarks>[];
      landmarksMap = {}; // Initialize the map
      landmarkNames = [];
      landmarksNameMap = {};
      json['landmarks'].forEach((v) {
        Landmarks landmark = Landmarks.fromJson(v);
        landmarks!.add(landmark);
        if(landmark.properties!.polyId != null){
          landmarksMap![landmark.properties!.polyId!] = landmark; // Add to the map using polyID as the key
        }
        if(landmark.name != null){
          landmarkNames!.add(landmark.name!);
          if(landmark.properties!.polyId != null){
            landmarksNameMap![landmark.name!] = landmark.properties!.polyId!;
          }
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['landmarkExist'] = this.landmarkExist;
    if (this.landmarks != null) {
      data['landmarks'] = this.landmarks!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  void mergeLandmarks(List<Landmarks>? landmarksList) {
    if (landmarksList != null) {
      landmarks ??= [];
      landmarks!.addAll(landmarksList);
      // Update landmarksMap and landmarksNameMap accordingly
      landmarksMap ??= {};
      landmarksNameMap ??= {};
      for (var landmark in landmarksList) {
        if (landmark.properties!.polyId != null) {
          landmarksMap![landmark.properties!.polyId!] = landmark;
        }
        if (landmark.name != null) {
          landmarkNames ??= [];
          landmarkNames!.add(landmark.name!);
          if (landmark.properties!.polyId != null) {
            landmarksNameMap![landmark.name!] = landmark.properties!.polyId!;
          }
        }
      }
      print("Himanshuchecker ${landmarksMap!.length}");
    }
  }
}


class Landmarks {
  Element? element;
  Properties? properties;
  String? sId;
  int? priority;
  String? buildingID;
  int? coordinateX;
  int? coordinateY;
  int? doorX;
  int? doorY;
  String? featureType;
  String? type;
  int? floor;
  String? geometryType;
  String? name;
  List<Lifts>? lifts;
  List<Stairs>? stairs;
  List<Others>? others;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? buildingName;
  String? venueName;
  bool? wasPolyIdNull ;

  Landmarks(
      {this.element,
        this.properties,
        this.priority,
        this.sId,
        this.buildingID,
        this.coordinateX,
        this.coordinateY,
        this.doorX,
        this.doorY,
        this.featureType,
        this.type,
        this.floor,
        this.geometryType,
        this.name,
        this.lifts,
        this.stairs,
        this.others,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.buildingName,
        this.venueName,
        this.wasPolyIdNull});

  Landmarks.fromJson(Map<dynamic, dynamic> json) {
    element =
    json['element'] != null ? new Element.fromJson(json['element']) : null;
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
    sId = json['_id'];
    wasPolyIdNull = false;
    if(properties!.polyId == null){
      wasPolyIdNull = true;
      properties!.polyId = json['_id'];
    }
    buildingID = json['building_ID'];
    coordinateX = json['coordinateX']!=null?json['coordinateX'].toInt():json['coordinateX'];
    coordinateY = json['coordinateY']!=null?json['coordinateY'].toInt():json['coordinateY'];
    doorX = json['doorX'] != null ? json['doorX'].toInt():json['doorX'];
    doorY = json['doorY']!=null? json['doorY'].toInt():json['doorY'];
    featureType = json['feature_type'];
    type = json['type'];
    floor = json['floor'];
    geometryType = json['geometryType'];
    name = json['name'];
    if(name == null && element!.subType!=null && element!.type != "Floor" && element!.subType != "beacons"){
      name = element!.subType;
    }
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
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    priority = json['priority'];
    buildingName = json['buildingName'];
    venueName = json['venueName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['doorX'] = this.doorX;
    data['doorY'] = this.doorY;
    data['feature_type'] = this.featureType;
    data['type'] = this.type;
    data['floor'] = this.floor;
    data['geometryType'] = this.geometryType;
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
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['priority'] = this.priority;
    data['buildingName'] = this.buildingName;
    data['venueName'] = this.venueName;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['subType'] = this.subType;
    return data;
  }
}

class Properties {
  String? contactNo;
  String? daysOpen;
  String? direction;
  String? doorMaterial;
  String? doorType;
  String? email;
  String? endTime;
  String? latitude;
  String? longitude;
  String? motion;
  String? node;
  String? nodeId;
  String? openingMechanism;
  String? protocol;
  String? startTime;
  String? timings;
  String? url;
  String? macId;
  String? arName;
  String? arValue;
  String? approxHeight;
  String? tapDirection;
  String? tapType;
  String? basinClock;
  bool? blowDryer;
  String? cubicleClock;
  bool? handShower;
  bool? liquidSoap;
  String? numCubicles;
  String? numUrinals;
  String? numWashbasin;
  bool? paperNapkins;
  bool? sanitaryNapkins;
  bool? soapbar;
  bool? tapMug;
  bool? toiletRolls;
  String? urinalClock;
  String? washroomType;
  String? wheelChairAccessibility;
  String? downwardSteps;
  String? name;
  String? stepHeight;
  String? stepsNumber;
  String? upwardSteps;
  String? stairsPoint;
  String? audio;
  String? brailleAvailability;
  String? capacity;
  String? callLocation;
  String? panelDir;
  String? shopNature;
  String? photo;
  bool? polygonExist;
  String? polyId;
  String? filename;
  List<String>? nonWalkableGrids;
  int? floorLength;
  int? floorBreadth;
  List<String>? flrDistMatrix;
  List<String>? frConn;
  List<String>? clickedPoints;
  int? floorAngle;
  List<String>? polygonId;

  Properties(
      {this.contactNo,
        this.daysOpen,
        this.direction,
        this.doorMaterial,
        this.doorType,
        this.email,
        this.endTime,
        this.latitude,
        this.longitude,
        this.motion,
        this.node,
        this.nodeId,
        this.openingMechanism,
        this.protocol,
        this.startTime,
        this.timings,
        this.url,
        this.macId,
        this.arName,
        this.arValue,
        this.approxHeight,
        this.tapDirection,
        this.tapType,
        this.basinClock,
        this.blowDryer,
        this.cubicleClock,
        this.handShower,
        this.liquidSoap,
        this.numCubicles,
        this.numUrinals,
        this.numWashbasin,
        this.paperNapkins,
        this.sanitaryNapkins,
        this.soapbar,
        this.tapMug,
        this.toiletRolls,
        this.urinalClock,
        this.washroomType,
        this.wheelChairAccessibility,
        this.downwardSteps,
        this.name,
        this.stepHeight,
        this.stepsNumber,
        this.upwardSteps,
        this.stairsPoint,
        this.audio,
        this.brailleAvailability,
        this.capacity,
        this.callLocation,
        this.panelDir,
        this.shopNature,
        this.photo,
        this.polygonExist,
        this.polyId,
        this.filename,
        this.nonWalkableGrids,
        this.floorLength,
        this.floorBreadth,
        this.flrDistMatrix,
        this.frConn,
        this.clickedPoints,
        this.floorAngle,
        this.polygonId});

  Properties.fromJson(Map<dynamic, dynamic> json) {
    contactNo = json['contactNo'];
    daysOpen = json['daysOpen'];
    direction = json['direction'];
    doorMaterial = json['doorMaterial'];
    doorType = json['doorType'];
    email = json['email'];
    endTime = json['endTime'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    motion = json['motion'];
    node = json['node'];
    nodeId = json['nodeId'];
    openingMechanism = json['openingMechanism'];
    protocol = json['protocol'];
    startTime = json['startTime'];
    timings = json['timings'];
    url = json['url'];
    macId = json['macId'];
    arName = json['arName'];
    arValue = json['arValue'];
    approxHeight = json['approxHeight'];
    tapDirection = json['tapDirection'];
    tapType = json['tapType'];
    basinClock = json['basinClock'];
    blowDryer = json['blowDryer'];
    cubicleClock = json['cubicleClock'];
    handShower = json['handShower'];
    liquidSoap = json['liquidSoap'];
    numCubicles = json['numCubicles'];
    numUrinals = json['numUrinals'];
    numWashbasin = json['numWashbasin'];
    paperNapkins = json['paperNapkins'];
    sanitaryNapkins = json['sanitaryNapkins'];
    soapbar = json['soapbar'];
    tapMug = json['tapMug'];
    toiletRolls = json['toiletRolls'];
    urinalClock = json['urinalClock'];
    washroomType = json['washroomType'];
    wheelChairAccessibility = json['wheelChairAccessibility'];
    downwardSteps = json['downwardSteps'];
    name = json['name'];
    stepHeight = json['stepHeight'];
    stepsNumber = json['stepsNumber'];
    upwardSteps = json['upwardSteps'];
    stairsPoint = json['stairsPoint'];
    audio = json['audio'];
    brailleAvailability = json['brailleAvailability'];
    capacity = json['capacity'];
    callLocation = json['callLocation'];
    panelDir = json['panelDir'];
    shopNature = json['shopNature'];
    photo = json['photo'];
    polygonExist = json['polygonExist'];
    polyId = json['polyId'];
    filename = json['filename'];
    nonWalkableGrids = json['nonWalkableGrids'].cast<String>();
    floorLength = json['floorLength'];
    floorBreadth = json['floorBreadth'];
    flrDistMatrix = json['flr_dist_matrix'].cast<String>();
    frConn = json['frConn'].cast<String>();
    clickedPoints = json['clickedPoints'].cast<String>();
    floorAngle = json['floorAngle'];
    polygonId = json['polygonId'].cast<String>();
  }

  Map<dynamic, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contactNo'] = this.contactNo;
    data['daysOpen'] = this.daysOpen;
    data['direction'] = this.direction;
    data['doorMaterial'] = this.doorMaterial;
    data['doorType'] = this.doorType;
    data['email'] = this.email;
    data['endTime'] = this.endTime;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['motion'] = this.motion;
    data['node'] = this.node;
    data['nodeId'] = this.nodeId;
    data['openingMechanism'] = this.openingMechanism;
    data['protocol'] = this.protocol;
    data['startTime'] = this.startTime;
    data['timings'] = this.timings;
    data['url'] = this.url;
    data['macId'] = this.macId;
    data['arName'] = this.arName;
    data['arValue'] = this.arValue;
    data['approxHeight'] = this.approxHeight;
    data['tapDirection'] = this.tapDirection;
    data['tapType'] = this.tapType;
    data['basinClock'] = this.basinClock;
    data['blowDryer'] = this.blowDryer;
    data['cubicleClock'] = this.cubicleClock;
    data['handShower'] = this.handShower;
    data['liquidSoap'] = this.liquidSoap;
    data['numCubicles'] = this.numCubicles;
    data['numUrinals'] = this.numUrinals;
    data['numWashbasin'] = this.numWashbasin;
    data['paperNapkins'] = this.paperNapkins;
    data['sanitaryNapkins'] = this.sanitaryNapkins;
    data['soapbar'] = this.soapbar;
    data['tapMug'] = this.tapMug;
    data['toiletRolls'] = this.toiletRolls;
    data['urinalClock'] = this.urinalClock;
    data['washroomType'] = this.washroomType;
    data['wheelChairAccessibility'] = this.wheelChairAccessibility;
    data['downwardSteps'] = this.downwardSteps;
    data['name'] = this.name;
    data['stepHeight'] = this.stepHeight;
    data['stepsNumber'] = this.stepsNumber;
    data['upwardSteps'] = this.upwardSteps;
    data['stairsPoint'] = this.stairsPoint;
    data['audio'] = this.audio;
    data['brailleAvailability'] = this.brailleAvailability;
    data['capacity'] = this.capacity;
    data['callLocation'] = this.callLocation;
    data['panelDir'] = this.panelDir;
    data['shopNature'] = this.shopNature;
    data['photo'] = this.photo;
    data['polygonExist'] = this.polygonExist;
    data['polyId'] = this.polyId;
    data['filename'] = this.filename;
    data['nonWalkableGrids'] = this.nonWalkableGrids;
    data['floorLength'] = this.floorLength;
    data['floorBreadth'] = this.floorBreadth;
    data['flr_dist_matrix'] = this.flrDistMatrix;
    data['frConn'] = this.frConn;
    data['clickedPoints'] = this.clickedPoints;
    data['floorAngle'] = this.floorAngle;
    data['polygonId'] = this.polygonId;
    return data;
  }
}

class Lifts {
  String? name;
  int? distance;
  int? x;
  int? y;

  Lifts({this.name, this.distance, this.x, this.y});

  Lifts.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    distance = json['distance'];
    x = json['x'].toInt();
    y = json['y'].toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['distance'] = this.distance;
    data['x'] = this.x;
    data['y'] = this.y;
    return data;
  }
}
class CommonConnection {
  String? name;
  int? d1;
  int? d2;
  int? x1;
  int? x2;
  int? y1;
  int? y2;

  CommonConnection({this.name, this.x1, this.y1,this.x2,this.y2,this.d1, this.d2});

}
class CommonStairs {
  String? name;
  int? distance;
  int? x1;
  int? x2;
  int? y1;
  int? y2;

  CommonStairs({this.name, this.distance, this.x1, this.y1, this.x2, this.y2});
}

class CommonRamp {
  String? name;
  int? distance;
  int? x1;
  int? x2;
  int? y1;
  int? y2;

  CommonRamp({this.name, this.distance, this.x1, this.y1, this.x2, this.y2});
}
class Stairs {
  String? name;
  int? distance;
  int? x;
  int? y;

  Stairs({this.name, this.distance, this.x, this.y});

  Stairs.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    distance = json['distance'];
    x = json['x'].toInt();
    y = json['y'].toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['distance'] = this.distance;
    data['x'] = this.x;
    data['y'] = this.y;
    return data;
  }
}

class Others {
  String? name;
  int? distance;
  int? x;
  int? y;

  Others({this.name, this.distance, this.x, this.y});

  Others.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    distance = json['distance'];
    x = json['x'].toInt();
    y = json['y'].toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['distance'] = this.distance;
    data['x'] = this.x;
    data['y'] = this.y;
    return data;
  }
}