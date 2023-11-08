import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:airlink/features/generate_token/domain/entities/device_suggestion.dart';
import 'package:airlink/features/generate_token/domain/repositories/token_device_repository.dart';
import 'package:dartz/dartz.dart';

class GetDeviceSuggestion implements UseCase<List<DeviceSuggestion>, String> {

  final TokenDeviceRepository _tokenDeviceRepository;

  GetDeviceSuggestion(this._tokenDeviceRepository);

  @override
  Future<Either<Failure, List<DeviceSuggestion>>> call(String deviceName) async {
    return await _tokenDeviceRepository.getDevicesByQuery(deviceName);
  }
}