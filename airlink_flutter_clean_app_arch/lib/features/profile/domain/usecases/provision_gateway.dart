import 'package:airlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:airlink/features/profile/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';

class ProvisionGateway implements UseCase<void, Profile> {

  final ProfileRepository _profileRepository;

  ProvisionGateway(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(Profile profile) async {
    return await _profileRepository.provisionGateway(profile);
  }
}