import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:airlink/features/generate_token/domain/entities/token_device.dart';
import 'package:airlink/features/generate_token/domain/repositories/token_device_repository.dart';
import 'package:dartz/dartz.dart';

class GenerateToken implements UseCase<String, TokenDevice> {
  final TokenDeviceRepository _tokenDeviceRepository;

  GenerateToken(this._tokenDeviceRepository);

  @override
  Future<Either<Failure, String>> call(TokenDevice tokenDevice) async {
    return await _tokenDeviceRepository.generateToken(tokenDevice);
  }
}