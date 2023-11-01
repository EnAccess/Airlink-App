import 'package:airlink/features/device/domain/entities/telemetry.dart';

class TelemetryModel extends Telemetry {
  TelemetryModel({required super.deviceName, super.data = const []});

  factory TelemetryModel.fromEntity(
      Telemetry t) {
    return TelemetryModel(
      deviceName: t.deviceName,
      data: t.data,
    );
  }

  static Telemetry toEntity(TelemetryModel t) {
    return Telemetry(
      deviceName: t.deviceName,
      data: t.data,
    );
  }

  @override
  toString() => 'deviceName: $deviceName, data: $data';

}