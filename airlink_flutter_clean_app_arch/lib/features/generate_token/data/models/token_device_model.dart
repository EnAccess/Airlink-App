import 'package:airlink/features/generate_token/domain/entities/token_device.dart';

class TokenDeviceModel extends TokenDevice {
  TokenDeviceModel({super.deviceUuid = '', super.angazaUnitNumber = '', required super.numberOfDays, super.method = 'Add Credit', required super.paygType});

  static TokenDeviceModel fromEntity(TokenDevice tokenDevice) {
    return TokenDeviceModel(
      deviceUuid: tokenDevice.deviceUuid,
      angazaUnitNumber: tokenDevice.angazaUnitNumber,
      numberOfDays: tokenDevice.numberOfDays,
      method: tokenDevice.method,
      paygType: tokenDevice.paygType,
    );
  }

  @override
  String toString() => 'TokenDeviceModel(deviceUuid: $deviceUuid, angazaUnitNumber: $angazaUnitNumber, numberOfDays: $numberOfDays, method: $method, paygType: $paygType)';

}