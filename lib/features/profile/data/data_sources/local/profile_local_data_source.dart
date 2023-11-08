import 'package:airlink/features/profile/data/models/profile_model.dart';

abstract class ProfileLocalDataSource {

  /// Save the device/user profile to local storage
  Future<void> cacheProfile(ProfileModel profileModel);

  /// Gets the device/user profile from local storage
  Future<ProfileModel> getProfile();

  /// Get device Id
  Future<String> getGatewayDeviceId();

}