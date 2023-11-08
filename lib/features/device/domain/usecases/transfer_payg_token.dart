import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/device_repository.dart';

class TransferPayGToken implements UseCase<void, String> {

  final DeviceRepository _repository;

  TransferPayGToken(this._repository);

  @override
  Future<Either<Failure, void>> call(String paygToken) async {
    return await _repository.transferToken(paygToken);
  }

}