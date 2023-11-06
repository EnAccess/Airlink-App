import 'package:airlink/features/device/data/models/telemetry_model.dart';

import '../../models/provisioned_device_model.dart';

abstract class DeviceRemoteDataSource {
  /// Registers a device to the server
  Future<void> postDevice(ProvisionedDeviceModel provisionedDeviceModel);

  /// Get Data from Server to local DB
  Future<List<dynamic>> getDeviceData(String deviceName);

  /// Upload BLE device data to server
  Future<void> postBLEData(TelemetryModel telemetryModel);

  /// Post Advertisement data
  Future<void> postAdvertisementData();
}