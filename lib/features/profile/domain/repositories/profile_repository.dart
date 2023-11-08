import 'package:airlink/features/profile/domain/entities/profile.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class ProfileRepository {
  /// Get device Id
  Future<Either<Failure, String>> getGatewayDeviceId();

  /// Registers the gateway to the server
  Future<Either<Failure, void>> provisionGateway(Profile profile);

  /// Gets the device/user profile from local storage
  Future<Either<Failure, Profile>> getProfile();
}