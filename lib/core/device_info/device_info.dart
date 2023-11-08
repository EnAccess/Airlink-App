import 'package:device_info_plus/device_info_plus.dart';

abstract class DeviceInfo {
  Future<String> get androidDeviceId;
}

class DeviceInfoImpl implements DeviceInfo {
  final DeviceInfoPlugin _deviceInfo;

  DeviceInfoImpl(this._deviceInfo);

  @override
  Future<String> get androidDeviceId => _deviceInfo.androidInfo
      .then((androidDeviceInfo) => androidDeviceInfo.androidId!);
}
