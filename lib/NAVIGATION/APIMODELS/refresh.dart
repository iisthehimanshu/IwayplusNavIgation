class refresh {
  bool? error;
  String? accessToken;
  String? refreshToken;
  String? message;

  refresh({this.error, this.accessToken, this.refreshToken, this.message});

  refresh.fromJson(dynamic json) {
    error = json['error'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['message'] = this.message;
    return data;
  }
}
