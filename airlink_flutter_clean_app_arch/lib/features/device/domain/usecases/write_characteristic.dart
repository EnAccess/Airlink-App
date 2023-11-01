import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/characteristic.dart';
import '../repositories/device_repository.dart';

class WriteCharacteristic implements UseCase<void, Characteristic> {
  final DeviceRepository _repository;

  WriteCharacteristic(this._repository);

  @override
  Future<Either<Failure, void>> call(Characteristic c) async {
    return await _repository.writeCharacteristic(c.characteristic.uuid.toString(), c.data);
  }
}
