import 'package:airlink/features/profile/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class GetGatewayDeviceId implements UseCase<void, NoParams> {

  final ProfileRepository _profileRepository;

  GetGatewayDeviceId(this._profileRepository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await _profileRepository.getGatewayDeviceId();
  }
}