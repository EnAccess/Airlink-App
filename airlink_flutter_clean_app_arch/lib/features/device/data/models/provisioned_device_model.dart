import 'package:airlink/features/device/domain/entities/provisioned_device.dart';

class ProvisionedDeviceModel extends ProvisionedDevice {
  ProvisionedDeviceModel({required super.deviceSerialNumber, required super.type, required super.deviceSecret, required super.productCode});

  factory ProvisionedDeviceModel.fromEntity(ProvisionedDevice provisionedDevice) {
    return ProvisionedDeviceModel(
      deviceSerialNumber: provisionedDevice.deviceSerialNumber,
      type: provisionedDevice.type,
      deviceSecret: provisionedDevice.deviceSecret,
      productCode: provisionedDevice.productCode,
    );
  }

  //copyWith method
  ProvisionedDeviceModel copyWith({
    int? deviceSerialNumber,
    String? type,
    String? deviceSecret,
    String? productCode,
  }) {
    return ProvisionedDeviceModel(
      deviceSerialNumber: deviceSerialNumber ?? this.deviceSerialNumber,
      type: type ?? this.type,
      deviceSecret: deviceSecret ?? this.deviceSecret,
      productCode: productCode ?? this.productCode,
    );
  }

  @override
  toString() => 'deviceSerialNumber: $deviceSerialNumber, type: $type, deviceSecret: $deviceSecret, productCode: $productCode';

}