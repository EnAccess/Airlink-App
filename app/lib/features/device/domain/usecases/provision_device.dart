import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/entities/provisioned_device.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

class ProvisionDevice implements UseCase<void, ProvisionedDevice> {
  final DeviceRepository _repository;

  ProvisionDevice(this._repository);

  @override
  Future<Either<Failure, void>> call(ProvisionedDevice provisionedDevice) async {
    return await _repository.provisionDevice(provisionedDevice);
  }

}