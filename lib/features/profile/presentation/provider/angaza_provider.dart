import 'package:airlink/core/utils/enums/enums.dart';
import 'package:airlink/core/widgets/snackbars.dart';
import 'package:airlink/features/profile/data/models/angaza_user_model.dart';
import 'package:airlink/features/profile/domain/usecases/get_angaza_credentials.dart';
import 'package:airlink/features/profile/domain/usecases/save_angaza_credentials.dart';
import 'package:airlink/features/profile/domain/usecases/usecase.dart';
import 'package:flutter/material.dart';

class AngazaProvider extends ChangeNotifier {
  final SaveAngazaCredentials saveAngazaCredentials;
  final GetAngazaCredentials getAngazaCredentials;

  AngazaProvider({
    required this.saveAngazaCredentials,
    required this.getAngazaCredentials,
  });

  AngazaUserModel? _angazaUserModel;

  AngazaUserModel? get angazaUserModel => _angazaUserModel;

  Future<void> saveAngazaCredentialsToLocalStorage(
      {required BuildContext context,
      required AngazaUserModel angazaUserModel}) async {
    final result = await saveAngazaCredentials(angazaUserModel);

    result.fold((failure) {
      Snackbar.show(
          context: context,
          type: SnackbarType.error,
          message: failure.toString());
    }, (success) {
      Snackbar.show(
          context: context,
          type: SnackbarType.success,
          message: 'Credentials saved');
    });
  }

  Future<void> getAngazaCredentialsFromLocalStorage(
      {required BuildContext context}) async {

    final result = await getAngazaCredentials(NoParams());

    result.fold((failure) {
    }, (angazaUser) {
      _angazaUserModel = AngazaUserModel.fromEntity(angazaUser);
      notifyListeners();
    });
  }
}
