import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/profile/domain/usecases/usecase.dart';
import 'package:airlink/features/profile/domain/entities/angaza_user.dart';
import 'package:airlink/features/profile/domain/repositories/angaza_repository.dart';
import 'package:dartz/dartz.dart';

class SaveAngazaCredentials implements UseCase<void, AngazaUser> {
  final AngazaRepository _angazaRepository;

  SaveAngazaCredentials(this._angazaRepository);

  @override
  Future<Either<Failure, void>> call(AngazaUser angazaUser) async {
    return await _angazaRepository.saveAngazaCredentials(angazaUser);
  }


}