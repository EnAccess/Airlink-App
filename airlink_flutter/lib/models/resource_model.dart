import 'package:flutter_blue/flutter_blue.dart';

class Resource {
  final BluetoothCharacteristic characteristic;
  final String uuid;
  final String deviceId;
  final List<BluetoothDescriptor> descriptors;
  final String descriptorName;
  final CharacteristicProperties properties;
  final String serviceUuid;

  Resource({
    required this.characteristic,
    required this.uuid,
    required this.deviceId,
    required this.descriptors,
    required this.descriptorName,
    required this.properties,
    required this.serviceUuid,
  });

  //create a toJson method
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'deviceId': deviceId,
    'descriptors': descriptors,
    'descriptorName': descriptorName,
    'properties': properties.toString(),
    'serviceUuid': serviceUuid,
  };
}
