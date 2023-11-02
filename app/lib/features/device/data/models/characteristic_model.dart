import 'package:airlink/features/device/domain/entities/characteristic.dart';

class CharacteristicModel extends Characteristic {
  CharacteristicModel({required super.characteristic,required super.descriptorName, super.data = const {}});

  factory CharacteristicModel.fromEntity(
      Characteristic characteristic) {
    return CharacteristicModel(
      characteristic: characteristic.characteristic,
      descriptorName: characteristic.descriptorName,
      data: characteristic.data,
    );
  }

  static Characteristic toEntity(CharacteristicModel c) {
    return Characteristic(
      characteristic: c.characteristic,
      descriptorName: c.descriptorName,
      data: c.data,
    );
  }

}