import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/profile/data/data_sources/local/angaza_local_data_source.dart';
import 'package:airlink/features/profile/domain/entities/angaza_user.dart';
import 'package:airlink/features/profile/domain/repositories/angaza_repository.dart';
import 'package:dartz/dartz.dart';

import '../models/angaza_user_model.dart';

class AngazaRepositoryImpl implements AngazaRepository {
  final AngazaLocalDataSource _angazaLocalDataSource;

  AngazaRepositoryImpl(this._angazaLocalDataSource);

  @override
  Future<Either<Failure, void>> saveAngazaCredentials(
      AngazaUser angazaUser) async {
    try {
      await _angazaLocalDataSource
          .saveAngazaCredentials(AngazaUserModel.fromEntity(angazaUser));
      return const Right(null);
    } catch (e) {
      return const Left(
          CacheFailure(message: 'Error saving angaza credentials'));
    }
  }

  @override
  Future<Either<Failure, AngazaUser>> getAngazaCredentials() async {
    try {
      final angazaUserModel =
          await _angazaLocalDataSource.getAngazaCredentials();
      return Right(angazaUserModel.toEntity());
    } catch (e) {
      return const Left(
          CacheFailure(message: 'Error getting angaza credentials'));
    }

  }
}
