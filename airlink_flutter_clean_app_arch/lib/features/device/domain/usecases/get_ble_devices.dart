import 'package:airlink/features/device/domain/entities/device.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class GetBLEDevices implements UseCase<List<Device>, NoParams> {
  final DeviceRepository _repository;

  GetBLEDevices(this._repository);

  @override
  Future<Either<Failure, List<Device>>> call(NoParams noParams) async {
    return await _repository.getBLEDevices();
  }
}
