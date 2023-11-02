import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/profile/domain/entities/angaza_user.dart';
import 'package:dartz/dartz.dart';

abstract class AngazaRepository {
  /// Saves the angaza credentials to the local storage
  Future<Either<Failure, void>> saveAngazaCredentials(AngazaUser angazaUser);

  /// Gets the angaza credentials from the local storage
  Future<Either<Failure, AngazaUser>> getAngazaCredentials();
}