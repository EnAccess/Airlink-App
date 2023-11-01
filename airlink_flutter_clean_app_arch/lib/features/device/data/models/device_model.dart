import 'package:airlink/features/device/data/models/advertisement_packet_model.dart';
import 'package:airlink/features/device/domain/entities/device.dart';

import 'characteristic_model.dart';

class DeviceModel extends Device {
  DeviceModel({
    required super.device,
    required super.advertisementPacket,
    super.characteristics,
  });

  factory DeviceModel.fromEntity(Device d) {
    return DeviceModel(
      device: d.device,
      advertisementPacket:
          AdvertisementPacketModel.fromEntity(d.advertisementPacket),
      characteristics: d.characteristics
          .map((e) => CharacteristicModel.fromEntity(e))
          .toList(),
    );
  }
}
