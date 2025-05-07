class Response{
  int statusCode;
  dynamic data;
  Response(this.statusCode, this.data );

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      json['statusCode'] as int,
      json['data'], // You can add more type handling if needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data,
    };
  }
}