import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/characteristic.dart';

class ReadCharacteristic implements UseCase<String, Characteristic> {
  final DeviceRepository _repository;

  ReadCharacteristic(this._repository);

  @override
  Future<Either<Failure, String>> call(Characteristic c) async {
    return await _repository.readCharacteristic(c.characteristic.uuid.toString());
  }
}
