import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/device.dart';

class AuthorizeDevice implements UseCase<void, Device> {
  final DeviceRepository _repository;

  AuthorizeDevice(this._repository);

  @override
  Future<Either<Failure, void>> call(Device device) async {
    return await _repository.authorizeDevice(device);
  }
}
