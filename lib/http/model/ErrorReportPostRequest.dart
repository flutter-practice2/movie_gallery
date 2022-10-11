import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ErrorReportPostRequest{
  String message;
  String stacktrace;

  ErrorReportPostRequest({
    required this.message,
    required this.stacktrace,
  });

  factory ErrorReportPostRequest.fromJson(Map<String, dynamic> json) {
    return ErrorReportPostRequest(
      message: json["message"],
      stacktrace: json["stacktrace"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": this.message,
      "stacktrace": this.stacktrace,
    };
  }

}
