// To parse this JSON data, do
//
//     final getAttributeByScopeResponse = getAttributeByScopeResponseFromJson(jsonString);

import 'dart:convert';

List<GetAttributeByScopeResponse> getAttributeByScopeResponseFromJson(String str) => List<GetAttributeByScopeResponse>.from(json.decode(str).map((x) => GetAttributeByScopeResponse.fromJson(x)));

String getAttributeByScopeResponseToJson(List<GetAttributeByScopeResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAttributeByScopeResponse {
  GetAttributeByScopeResponse({
    required this.lastUpdateTs,
    required this.key,
    required this.value,
  });

  int lastUpdateTs;
  String key;
  dynamic value;

  factory GetAttributeByScopeResponse.fromJson(Map<String, dynamic> json) => GetAttributeByScopeResponse(
    lastUpdateTs: json["lastUpdateTs"],
    key: json["key"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "lastUpdateTs": lastUpdateTs,
    "key": key,
    "value": value,
  };
}
