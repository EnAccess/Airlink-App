import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:airlink/features/profile/data/models/profile_model.dart';
import 'package:hive/hive.dart';

import '../../../../../core/device_info/device_info.dart';
import '../../../../../core/storage/storage.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final DeviceInfo deviceInfo;
  final SecureStorage secureStorage;

  ProfileLocalDataSourceImpl({
    required this.deviceInfo,
    required this.secureStorage,
  });

  final _profilesBox = Hive.box('profiles');

  @override
  Future<ProfileModel> getProfile() async {
    try {
      //get android device id
      final androidDeviceId = await deviceInfo.androidDeviceId;

      //get profile from box
      final profile = await _profilesBox.get(androidDeviceId);

      //check if profile is not null. if null, return error
      if (profile != null) {
        return ProfileModel.fromMap(profile);
      } else {
        throw const CacheFailure(message: 'No profile found');
      }
    } catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profileModel) async {
    try {
      //get android device id
      final androidDeviceId = await deviceInfo.androidDeviceId;
      //cache profile
      _profilesBox.put(androidDeviceId, profileModel.toMap());
    } catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<String> getGatewayDeviceId() async {
    try {
      //get android device id
      final androidDeviceId = await deviceInfo.androidDeviceId;
      return androidDeviceId;
    } catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }
}
