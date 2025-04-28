import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/data/models/telemetry_model.dart';
import 'package:airlink/features/device/domain/entities/advertisement_packet.dart';
import 'package:airlink/features/device/domain/entities/device.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/provisioned_device.dart';
import '../data_sources/local/ble_device_local_data_source.dart';
import '../data_sources/remote/device_remote_data_source.dart';
import '../models/advertisement_packet_model.dart';
import '../models/device_model.dart';
import '../models/provisioned_device_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource _localDataSource;
  final DeviceRemoteDataSource _remoteDataSource;

  DeviceRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, Device>> connectToDevice(Device bleDevice) async {
    try {
      final device = await _localDataSource.connectToDevice(DeviceModel.fromEntity(bleDevice));
      return Right(device);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectDevice(Device bleDevice) async {
    try {
      await _localDataSource.disconnectDevice(DeviceModel.fromEntity(bleDevice));
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Device>>> getBLEDevices() async {
    try {
      final bleDevices = await _localDataSource.getBLEDevices();
      return Right(bleDevices);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> authorizeDevice(Device bleDevice) async {
    try {
      await _localDataSource.authorizeDevice(DeviceModel.fromEntity(bleDevice));
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> readCharacteristic(String characteristicUUID) async {
    try {
      final value = await _localDataSource.readCharacteristic(characteristicUUID);
      return Right(value);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> writeCharacteristic(String characteristicUUID, Map<String, dynamic> data) async {
    try {
      await _localDataSource.writeCharacteristic(characteristicUUID, data);
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> provisionDevice(ProvisionedDevice provisionedDevice) async {
    try {
      await _remoteDataSource.postDevice(ProvisionedDeviceModel.fromEntity(provisionedDevice));
      await _localDataSource.serializeDevice(ProvisionedDeviceModel.fromEntity(provisionedDevice));
      return const Right(null);
    } catch (e) {
      if(e is AirLinkFailure) {
        return Left(AirLinkFailure(message: e.toString()));
      }
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getDeviceAccessToken(Device bleDevice) async {
    try {
      final accessToken = await _localDataSource.getDeviceAccessToken(DeviceModel.fromEntity(bleDevice));
      return Right(accessToken);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> transferToken(String payGToken) async {
    try {
      await _localDataSource.transferToken(payGToken);
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAdvertisementData(AdvertisementPacket advertisementPacket) async {
    try {
      await _localDataSource.saveAdvertisementData(AdvertisementPacketModel.fromEntity(advertisementPacket));
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> postAdvertisementData() async {
    try {
      await _remoteDataSource.postAdvertisementData();
      return const Right(null);
    } catch (e) {
      return Left(AirLinkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> gatewayAndBLEDeviceSync(String deviceName) async {
    try {
      //get timeseries data from BLE device
      final timeseriesData = await _localDataSource.readDeviceTimeseriesData();

      if(timeseriesData.isNotEmpty) {
        //save timeseries data to local db
        await _localDataSource.saveDeviceTimeseriesData(deviceName, timeseriesData);
      }
      //get device data (attributes) from local db
      List<dynamic>? dataList = await _localDataSource.getDeviceDataFromLocalStorage(deviceName);

      if(dataList != null && dataList.isNotEmpty) {
        //post device data to BLE device
        await _localDataSource.pushDeviceData(dataList);
      }
      return const Right(null);

    }
    catch(e) {
      return Left(AirLinkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> serverAndGatewaySync(String deviceName) async {
    try {
      //gets device shared attributes data from airlink server
      final data = await _remoteDataSource.getDeviceData(deviceName);

      if(data.isNotEmpty) {
        //save the attributes from airlink server to local db
        await _localDataSource.saveDeviceData(deviceName, data);
      }

      //fetch telemetry data from local db
      final telemetryData = await _localDataSource.getDeviceTimeseriesData(deviceName);

      if(telemetryData.isNotEmpty) {
        //post telemetry data to airlink server
        await _remoteDataSource.postBLEData(TelemetryModel(deviceName: deviceName, data: telemetryData));
      }

      return const Right(null);
    } catch (e) {
      return Left(AirLinkFailure(message: e.toString()));
    }
  }
}
