

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Characteristic {
  final BluetoothCharacteristic characteristic;
  final String descriptorName;
  Map<String, dynamic> data;

  Characteristic({
    required this.characteristic,
    required this.descriptorName,
    this.data = const {},
  });
}