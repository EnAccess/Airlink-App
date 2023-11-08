import '../../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  /// Registers the gateway to the server
  Future<void> provisionGateway(ProfileModel profileModel);
}