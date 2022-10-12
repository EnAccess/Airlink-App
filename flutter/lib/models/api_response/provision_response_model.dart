// To parse this JSON data, do
//
//     final provisionResponse = provisionResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ProvisionResponse provisionResponseFromJson(String str) => ProvisionResponse.fromJson(json.decode(str));

String provisionResponseToJson(ProvisionResponse data) => json.encode(data.toJson());

class ProvisionResponse {
  ProvisionResponse({
    required this.id,
    required this.createdTime,
    required this.additionalInfo,
    required this.tenantId,
    required this.customerId,
    required this.name,
    required this.type,
    required this.label,
    required this.deviceProfileId,
    required this.deviceData,
    required this.firmwareId,
    required this.softwareId,
    required this.ownerId,
  });

  final CustomerId id;
  final int createdTime;
  final dynamic additionalInfo;
  final CustomerId tenantId;
  final CustomerId customerId;
  final String name;
  final String type;
  final dynamic label;
  final CustomerId deviceProfileId;
  final DeviceData deviceData;
  final dynamic firmwareId;
  final dynamic softwareId;
  final CustomerId ownerId;

  factory ProvisionResponse.fromJson(Map<String, dynamic> json) => ProvisionResponse(
    id: CustomerId.fromJson(json["id"]),
    createdTime: json["createdTime"],
    additionalInfo: json["additionalInfo"],
    tenantId: CustomerId.fromJson(json["tenantId"]),
    customerId: CustomerId.fromJson(json["customerId"]),
    name: json["name"],
    type: json["type"],
    label: json["label"],
    deviceProfileId: CustomerId.fromJson(json["deviceProfileId"]),
    deviceData: DeviceData.fromJson(json["deviceData"]),
    firmwareId: json["firmwareId"],
    softwareId: json["softwareId"],
    ownerId: CustomerId.fromJson(json["ownerId"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id.toJson(),
    "createdTime": createdTime,
    "additionalInfo": additionalInfo,
    "tenantId": tenantId.toJson(),
    "customerId": customerId.toJson(),
    "name": name,
    "type": type,
    "label": label,
    "deviceProfileId": deviceProfileId.toJson(),
    "deviceData": deviceData.toJson(),
    "firmwareId": firmwareId,
    "softwareId": softwareId,
    "ownerId": ownerId.toJson(),
  };
}

class CustomerId {
  CustomerId({
    required this.entityType,
    required this.id,
  });

  final String entityType;
  final String id;

  factory CustomerId.fromJson(Map<String, dynamic> json) => CustomerId(
    entityType: json["entityType"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "entityType": entityType,
    "id": id,
  };
}

class DeviceData {
  DeviceData({
    required this.configuration,
    required this.transportConfiguration,
  });

  final Configuration configuration;
  final Configuration transportConfiguration;

  factory DeviceData.fromJson(Map<String, dynamic> json) => DeviceData(
    configuration: Configuration.fromJson(json["configuration"]),
    transportConfiguration: Configuration.fromJson(json["transportConfiguration"]),
  );

  Map<String, dynamic> toJson() => {
    "configuration": configuration.toJson(),
    "transportConfiguration": transportConfiguration.toJson(),
  };
}

class Configuration {
  Configuration({
    required this.type,
  });

  final String type;

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
  };
}
