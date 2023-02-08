// To parse this JSON data, do
//
//     final serverResponse = serverResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ServerResponse serverResponseFromJson(String str) => ServerResponse.fromJson(json.decode(str));

String serverResponseToJson(ServerResponse data) => json.encode(data.toJson());

class ServerResponse {
  ServerResponse({
    required this.status,
    required this.message,
    required this.errorCode,
    required this.timestamp,
    required this.subscriptionErrorCode,
    required this.subscriptionEntry,
    required this.subscriptionValue,
  });

  final int status;
  final String message;
  final int errorCode;
  final DateTime timestamp;
  final dynamic subscriptionErrorCode;
  final dynamic subscriptionEntry;
  final dynamic subscriptionValue;

  factory ServerResponse.fromJson(Map<String, dynamic> json) => ServerResponse(
    status: json["status"],
    message: json["message"],
    errorCode: json["errorCode"],
    timestamp: DateTime.parse(json["timestamp"]),
    subscriptionErrorCode: json["subscriptionErrorCode"],
    subscriptionEntry: json["subscriptionEntry"],
    subscriptionValue: json["subscriptionValue"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "errorCode": errorCode,
    "timestamp": timestamp.toIso8601String(),
    "subscriptionErrorCode": subscriptionErrorCode,
    "subscriptionEntry": subscriptionEntry,
    "subscriptionValue": subscriptionValue,
  };
}
