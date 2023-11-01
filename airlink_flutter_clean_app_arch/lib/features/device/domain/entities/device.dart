import 'package:airlink/features/device/domain/entities/advertisement_packet.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'characteristic.dart';

class Device {
  final BluetoothDevice device;
  final AdvertisementPacket advertisementPacket;
  List<Characteristic> characteristics;

  Device({
    required this.device,
    required this.advertisementPacket,
    this.characteristics = const [],
  });
}
