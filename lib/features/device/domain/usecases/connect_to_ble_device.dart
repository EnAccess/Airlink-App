import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/entities/device.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

class ConnectToBLEDevice implements UseCase<Device, Device> {
  final DeviceRepository _repository;

  ConnectToBLEDevice(this._repository);

  @override
  Future<Either<Failure, Device>> call(Device bleDevice) async {
    return await _repository.connectToDevice(bleDevice);
  }
}
