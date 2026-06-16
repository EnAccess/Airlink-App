import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  /// Gets a value from storage
  Future<String?> get(String key);

  /// Sets a value to storage
  Future<void> set(String key, String value);
}

class SecureStorageImpl implements SecureStorage {

 final FlutterSecureStorage _flutterSecureStorage = const FlutterSecureStorage();

  @override
  Future<String?> get(String key) {
    try {
      return _flutterSecureStorage.read(key: key);
    }
    catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<void> set(String key, String value) {
    try {
      return _flutterSecureStorage.write(key: key, value: value);
    }
    catch (e) {
      throw Exception(e);
    }
  }

}