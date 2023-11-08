import 'package:airlink/features/profile/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<void, NoParams> {
  final ProfileRepository _profileRepository;

  GetProfile(this._profileRepository);

  @override
  Future<Either<Failure, Profile>> call(NoParams params) async {
    return await _profileRepository.getProfile();
  }
}
