class LocalNotificationAPIModel {
  List<NotificationsInLocalNotificationModule>? notifications;
  int? totalCount;

  LocalNotificationAPIModel({this.notifications, this.totalCount});

  LocalNotificationAPIModel.fromJson(Map<dynamic, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <NotificationsInLocalNotificationModule>[];
      json['notifications'].forEach((v) {
        notifications?.add(new NotificationsInLocalNotificationModule.fromJson(v));
      });
    }
    totalCount = json['totalCount'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (this.notifications != null) {
      data['notifications'] =
          this.notifications!.map((v) => v.toJson()).toList();
    }
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class NotificationsInLocalNotificationModule {
  String? sId;
  String? appId;
  String? title;
  String? body;
  String? filepath;
  int? iV;

  NotificationsInLocalNotificationModule(
      {this.sId, this.appId, this.title, this.body, this.filepath, this.iV});

  NotificationsInLocalNotificationModule.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    appId = json['appId'];
    title = json['title'];
    body = json['body'];
    filepath = json['filepath'];
    iV = json['__v'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['_id'] = this.sId;
    data['appId'] = this.appId;
    data['title'] = this.title;
    data['body'] = this.body;
    data['filepath'] = this.filepath;
    data['__v'] = this.iV;
    return data;
  }
}