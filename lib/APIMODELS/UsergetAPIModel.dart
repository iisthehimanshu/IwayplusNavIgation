class UsergetAPIModel {
  String? sId;
  String? name;
  String? email;
  Null? mobile;
  String? username;
  bool? emailVerification;
  bool? mobileVerification;
  Null? photo;
  Null? gender;
  Null? dob;
  List<Null>? disabilities;
  String? language;
  Null? googleId;
  String? appId;
  List<String>? roles;
  List<Null>? favourites;
  String? createdAt;
  String? updatedAt;
  int? iV;

  UsergetAPIModel(
      {this.sId,
        this.name,
        this.email,
        this.mobile,
        this.username,
        this.emailVerification,
        this.mobileVerification,
        this.photo,
        this.gender,
        this.dob,
        this.disabilities,
        this.language,
        this.googleId,
        this.appId,
        this.roles,
        this.favourites,
        this.createdAt,
        this.updatedAt,
        this.iV});

  UsergetAPIModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    username = json['username'];
    emailVerification = json['emailVerification'];
    mobileVerification = json['mobileVerification'];
    photo = json['photo'];
    gender = json['gender'];
    dob = json['dob'];
    if (json['disabilities'] != null) {
      disabilities = [];
      json['disabilities'].forEach((v) {
        disabilities!.add(v);
      });
    }
    language = json['language'];
    googleId = json['googleId'];
    appId = json['appId'];
    roles = json['roles'].cast<String>();
    if (json['favourites'] != null) {
      favourites = [];
      json['favourites'].forEach((v) {
        favourites!.add(v);
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['username'] = this.username;
    data['emailVerification'] = this.emailVerification;
    data['mobileVerification'] = this.mobileVerification;
    data['photo'] = this.photo;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    if (this.disabilities != null) {
      data['disabilities'] = this.disabilities!.map((v) => v).toList();
    }
    data['language'] = this.language;
    data['googleId'] = this.googleId;
    data['appId'] = this.appId;
    data['roles'] = this.roles;
    if (this.favourites != null) {
      data['favourites'] = this.favourites!.map((v) => v).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}