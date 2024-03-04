class ResponseModel {

  ResponseModel({
    required this.timestamp,
    required this.status,
    required this.message,
  });

  String? timestamp;
  int? status;
  String? message;
}