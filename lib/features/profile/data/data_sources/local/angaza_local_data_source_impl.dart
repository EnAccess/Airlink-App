import 'package:airlink/core/storage/storage.dart';
import 'package:airlink/features/profile/data/models/angaza_user_model.dart';
import 'package:hive/hive.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/utils/helper_functions.dart';
import 'angaza_local_data_source.dart';

class AngazaLocalDataSourceImpl implements AngazaLocalDataSource {

  final SecureStorage secureStorage;

  AngazaLocalDataSourceImpl({required this.secureStorage});

  final _angazaBox = Hive.box('angaza_credentials');

  @override
  Future<void> saveAngazaCredentials(AngazaUserModel angazaUserModel) async {
    try {
      //save data to local storage
      _angazaBox.put('angaza_credentials', angazaUserModel.toMap());

      //get base64 string from the user credentials
      final base64String = _encodeCredentials(angazaUserModel);

      //save base64 string to secure storage
      secureStorage.set('angazaAuthKey', base64String);
    } catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<AngazaUserModel> getAngazaCredentials() async {
    try {
      final angazaUserModel = _angazaBox.get('angaza_credentials');
      if (angazaUserModel != null) {
        return AngazaUserModel.fromMap(angazaUserModel);
      } else {
        throw const CacheFailure(message: 'No angaza credentials found');
      }
    } catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  String _encodeCredentials(AngazaUserModel angazaUserModel) {
    return encodeCredentials(angazaUserModel.username, angazaUserModel.password);
  }
}
