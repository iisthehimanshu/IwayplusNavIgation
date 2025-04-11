class SignInApiModel {
  Payload? payload;
  String? accessToken;
  String? refreshToken;
  // String? message;
  // String? exist;

  SignInApiModel({this.payload, this.accessToken, this.refreshToken});

  SignInApiModel.fromJson(Map<String, dynamic> json) {
    payload = json['payload'] != null ? new Payload.fromJson(json['payload']) : null;
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    // message = json['message'];
    // exist = json['exist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.payload != null) {
      data['payload'] = this.payload!.toJson();
    }
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    // data['message'] = this.message;
    // data['exist'] = this.exist;
    return data;
  }
}

class Payload {
  String? userId;
  List<String>? roles;

  Payload({this.userId, this.roles});

  Payload.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    roles = json['roles'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['roles'] = this.roles;
    return data;
  }
}