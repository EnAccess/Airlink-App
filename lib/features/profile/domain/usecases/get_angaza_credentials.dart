import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/profile/domain/usecases/usecase.dart';
import 'package:airlink/features/profile/domain/entities/angaza_user.dart';
import 'package:airlink/features/profile/domain/repositories/angaza_repository.dart';
import 'package:dartz/dartz.dart';

class GetAngazaCredentials implements UseCase<AngazaUser, NoParams> {
  final AngazaRepository _angazaRepository;

  GetAngazaCredentials(this._angazaRepository);

  @override
  Future<Either<Failure, AngazaUser>> call(NoParams params) async {
    return await _angazaRepository.getAngazaCredentials();
  }

}
