import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/entities/advertisement_packet.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/device_repository.dart';

class SaveAdvertisementData implements UseCase<void, AdvertisementPacket> {
  final DeviceRepository _repository;

  SaveAdvertisementData(this._repository);

  @override
  Future<Either<Failure, void>> call(AdvertisementPacket ad) async {
    return await _repository.saveAdvertisementData(ad);
  }
}
