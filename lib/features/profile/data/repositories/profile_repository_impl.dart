import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:airlink/features/profile/domain/entities/profile.dart';
import 'package:airlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

import '../data_sources/remote/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final profile = await localDataSource.getProfile();
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> provisionGateway(Profile profile) async {
    try {
      //cache gateway device locally
      await localDataSource.cacheProfile(ProfileModel.fromEntity(profile));

      //post gateway device to server
      await remoteDataSource.provisionGateway(ProfileModel.fromEntity(profile));

      return const Right(null);
    } catch (e) {
      if (e is AirLinkFailure) {
        return Left(AirLinkFailure(message: e.message));
      } else if (e is CacheFailure) {
        return Left(CacheFailure(message: e.message));
      } else {
        return Left(ServerFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> getGatewayDeviceId() async {
    try {
      final profile = await localDataSource.getGatewayDeviceId();
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
