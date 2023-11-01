import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/device_repository.dart';

class PostAdvertisementData implements UseCase<void, NoParams> {
  final DeviceRepository _repository;

  PostAdvertisementData(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams noParams) async {
    return await _repository.postAdvertisementData();
  }
}
