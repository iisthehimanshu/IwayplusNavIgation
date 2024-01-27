class guestloginmodel {
  bool? status;
  String? accessToken;
  String? refreshToken;
  Data? data;

  guestloginmodel(
      {this.status, this.accessToken, this.refreshToken, this.data});

  guestloginmodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  bool? paidUser;
  List<String>? accessibilitySettings;
  List<String>? filters;
  List<String>? categories;
  List<String>? roles;
  int? iV;

  Data(
      {this.sId,
        this.name,
        this.paidUser,
        this.accessibilitySettings,
        this.filters,
        this.categories,
        this.roles,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    paidUser = json['paidUser'];
    accessibilitySettings = json['accessibilitySettings'].cast<String>();
    filters = json['filters'].cast<String>();
    categories = json['categories'].cast<String>();
    roles = json['roles'].cast<String>();
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['paidUser'] = this.paidUser;
    data['accessibilitySettings'] = this.accessibilitySettings;
    data['filters'] = this.filters;
    data['categories'] = this.categories;
    data['roles'] = this.roles;
    data['__v'] = this.iV;
    return data;
  }
}