import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/entities/device.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

class DisconnectBLEDevice implements UseCase<void, Device> {
  final DeviceRepository _repository;

  DisconnectBLEDevice(this._repository);

  @override
  Future<Either<Failure, void>> call(Device bleDevice) async {
    return await _repository.disconnectDevice(bleDevice);
  }
}
