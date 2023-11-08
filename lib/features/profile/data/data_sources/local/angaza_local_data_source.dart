import 'package:airlink/features/profile/data/models/angaza_user_model.dart';

abstract class AngazaLocalDataSource {
  /// Saves the angaza credentials to the local storage
  Future<void> saveAngazaCredentials(AngazaUserModel angazaUserModel);

  /// Gets the angaza credentials from the local storage
  Future<AngazaUserModel> getAngazaCredentials();

}