import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

class GetDeviceAccessToken implements UseCase<String?, Device> {
  final DeviceRepository _repository;

  GetDeviceAccessToken(this._repository);

  @override
  Future<Either<Failure, String?>> call(Device device) async {
    return await _repository.getDeviceAccessToken(device);
  }
}