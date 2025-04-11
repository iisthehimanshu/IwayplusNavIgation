class NotificationData {
  String title;
  String body;
  String appId;
  String filepath;

  NotificationData({
    required this.title,
    required this.body,
    required this.appId,
    required this.filepath,
  });

  // Factory constructor to create an object from JSON
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      title: json['title'],
      body: json['body'],
      appId: json['appId'],
      filepath: json['filepath'],
    );
  }

  // Method to convert an object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'appId': appId,
      'filepath': filepath,
    };
  }
}