import 'package:airlink/features/generate_token/domain/entities/device_suggestion.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/token_device.dart';

abstract class TokenDeviceRepository {

  /// Generates a token for a device
  Future<Either<Failure, String>> generateToken(TokenDevice tokenDevice);

  Future<Either<Failure, List<DeviceSuggestion>>> getDevicesByQuery(String deviceName);
}