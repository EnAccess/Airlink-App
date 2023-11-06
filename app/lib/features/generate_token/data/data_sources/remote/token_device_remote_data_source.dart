import '../../models/device_suggestion_model.dart';
import '../../models/token_device_model.dart';

abstract class TokenDeviceRemoteDataSource {
  /// Generates a token for a device
  Future<String> generateToken(TokenDeviceModel tokenDeviceModel);

  /// Gets a list of devices by query
  Future<List<DeviceSuggestionModel>> getDevicesByQuery(String deviceName);
}