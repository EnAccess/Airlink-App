import 'package:airlink/features/generate_token/data/models/token_device_model.dart';
import 'package:airlink/features/generate_token/domain/entities/device_suggestion.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/token_device.dart';
import '../../domain/repositories/token_device_repository.dart';
import '../data_sources/remote/token_device_remote_data_source.dart';

class TokenDeviceRepositoryImpl implements TokenDeviceRepository {
  final TokenDeviceRemoteDataSource tokenDeviceDataSource;

  TokenDeviceRepositoryImpl({required this.tokenDeviceDataSource});

  @override
  Future<Either<Failure, String>> generateToken(TokenDevice tokenDevice) async {
    try {
      String token = await tokenDeviceDataSource.generateToken(TokenDeviceModel.fromEntity(tokenDevice));
      return Right(token);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeviceSuggestion>>> getDevicesByQuery(String deviceName) async {
    try {
      final devices = await tokenDeviceDataSource.getDevicesByQuery(deviceName);
      return Right(devices);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

}