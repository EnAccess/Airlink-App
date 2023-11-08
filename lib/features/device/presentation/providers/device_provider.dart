import 'package:airlink/features/device/data/models/characteristic_model.dart';
import 'package:airlink/features/device/domain/usecases/get_ble_devices.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/enums/enums.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../data/models/advertisement_packet_model.dart';
import '../../data/models/device_model.dart';
import '../../data/models/provisioned_device_model.dart';
import '../../domain/usecases/authorize_device.dart';
import '../../domain/usecases/connect_to_ble_device.dart';
import '../../domain/usecases/disconnect_ble_device.dart';
import '../../domain/usecases/get_device_access_token.dart';
import '../../domain/usecases/post_advertisement_data.dart';
import '../../domain/usecases/provision_device.dart';
import '../../domain/usecases/read_characteristic.dart';
import '../../domain/usecases/save_advertisement_data.dart';
import '../../domain/usecases/sync_gateway_and_device.dart';
import '../../domain/usecases/sync_server_and_gateway.dart';
import '../../domain/usecases/transfer_payg_token.dart';
import '../../domain/usecases/write_characteristic.dart';

class DeviceProvider extends ChangeNotifier {
  final GetBLEDevices getBLEDevices;
  final ConnectToBLEDevice connectToBLEDevice;
  final DisconnectBLEDevice disconnectBLEDevice;
  final AuthorizeDevice authorizeDevice;
  final ReadCharacteristic readCharacteristic;
  final WriteCharacteristic writeCharacteristic;
  final ProvisionDevice provisionDevice;
  final GetDeviceAccessToken getDeviceAccessToken;
  final TransferPayGToken transferPayGToken;
  final SaveAdvertisementData saveAdvertisementData;
  final PostAdvertisementData postAdvertisementData;
  final SyncGatewayAndDevice syncGatewayAndDevice;
  final SyncServerAndGateway syncServerAndGateway;

  DeviceProvider({
    required this.disconnectBLEDevice,
    required this.getBLEDevices,
    required this.connectToBLEDevice,
    required this.authorizeDevice,
    required this.readCharacteristic,
    required this.writeCharacteristic,
    required this.provisionDevice,
    required this.getDeviceAccessToken,
    required this.transferPayGToken,
    required this.saveAdvertisementData,
    required this.postAdvertisementData,
    required this.syncGatewayAndDevice,
    required this.syncServerAndGateway,
  });

  List<DeviceModel> _devices = [];

  late DeviceModel? _connectedDevice;

  String _keyword = '';

  final TextEditingController _searchController = TextEditingController();

  TextEditingController get searchController => _searchController;

  DeviceModel? get connectedDevice => _connectedDevice;

  List<DeviceModel> get devices => _keyword.isEmpty
      ? _devices
      : _devices.where((d) {
          final keywordToLower = _keyword.toLowerCase();
          final deviceName = d.device.platformName.toLowerCase();
          final serialNumber =
              d.advertisementPacket.did.toString().toLowerCase();
          final macAddress = d.device.remoteId.str.toLowerCase();

          return serialNumber.contains(keywordToLower) ||
              deviceName.contains(keywordToLower) ||
              macAddress.contains(keywordToLower);
        }).toList();

  Future<void> getDevices({required BuildContext context}) async {
    final result = await getBLEDevices(NoParams());
    result.fold((failure) {
      Snackbar.show(
          context: context,
          message: failure.toString(),
          type: SnackbarType.error);
    }, (devices) {
      _devices = devices.map((d) => d as DeviceModel).toList();
      notifyListeners();
    });
  }

  Future<void> connectToDevice(
      {required BuildContext context, required DeviceModel device}) async {
    final result = await connectToBLEDevice(device);
    result.fold((failure) {
      Snackbar.show(
          context: context,
          message: failure.toString(),
          type: SnackbarType.error);
    }, (connectedDevice) {
      _connectedDevice = DeviceModel.fromEntity(connectedDevice);
      notifyListeners();
      // Snackbar.show(
      //     context: context,
      //     message: 'Connected to ${device.device.name}',
      //     type: SnackbarType.success);
    });
  }

  Future<void> clearDevices() async {
    _devices.clear();
    notifyListeners();
  }

  void filterDevice(String keyword) {
    _keyword = keyword;
    notifyListeners();
  }

  //disconnect device
  Future<void> disconnectDevice(
      {required BuildContext context, required DeviceModel device}) async {
    final result = await disconnectBLEDevice(device);
    result.fold((failure) {
      Snackbar.show(
          context: context,
          message: failure.toString(),
          type: SnackbarType.error);
    }, (_) {
      _connectedDevice = null;
      notifyListeners();
    });
  }

  //authorize device
  Future<void> authorize(
      {required BuildContext context, required DeviceModel device}) async {
    //show loading
    Snackbar.show(
        context: context,
        message: 'Authorizing Device',
        type: SnackbarType.loading,
        timeoutInSeconds: 120);

    final result = await authorizeDevice(device);

    result.fold((failure) {
      //hide loading
      Snackbar.hide(context: context);

      //show error
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
    }, (_) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: 'Device Authorized',
        type: SnackbarType.success,
      );
    });
  }

  //read characteristic
  Future<String?> read(
      {required BuildContext context, required CharacteristicModel c}) async {
    final result = await readCharacteristic(c);

    return result.fold((failure) {
      //show error
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
      return null;
    }, (value) {
      return value;
    });
  }

  //provision device
  Future<void> provision(
      {required BuildContext context,
      required ProvisionedDeviceModel provisionedDeviceModel}) async {
    //show loading
    Snackbar.show(
        context: context,
        message: 'Provisioning device...',
        type: SnackbarType.loading,
        timeoutInSeconds: 120);

    final result = await provisionDevice(provisionedDeviceModel);
    result.fold((failure) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
    }, (_) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: 'Device provisioned',
        type: SnackbarType.success,
      );
    });
  }

  //get device token
  Future<String?> getAccessToken(
      {required BuildContext context, required DeviceModel deviceModel}) async {
    final result = await getDeviceAccessToken(deviceModel);

    String? value;

    result.fold((failure) {
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
      return null;
    }, (accessToken) {
      value = accessToken;
    });

    return value;
  }

  //transfer payg token
  Future<void> transferToken(
      {required BuildContext context, required String paygToken}) async {
    //show loading
    Snackbar.show(
        context: context,
        message: 'Transferring token...',
        type: SnackbarType.loading,
        timeoutInSeconds: 120);

    final result = await transferPayGToken(paygToken);
    result.fold((failure) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
    }, (_) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: 'Token transferred',
        type: SnackbarType.success,
      );
    });
  }

  //get device data
  // Future<void> getData(
  //     {required BuildContext context, required String deviceName}) async {
  //   //show loading
  //   Snackbar.show(
  //       context: context,
  //       message: 'Getting data...',
  //       type: SnackbarType.loading,
  //       timeoutInSeconds: 120);
  //
  //   final result = await getDeviceData(deviceName);
  //
  //   result.fold((failure) {
  //     //hide loading
  //     Snackbar.hide(context: context);
  //
  //     //show error
  //     Snackbar.show(
  //       context: context,
  //       message: failure.toString(),
  //       type: SnackbarType.error,
  //     );
  //   }, (data) {
  //     //hide loading
  //     Snackbar.hide(context: context);
  //
  //     //show success
  //     Snackbar.show(
  //       context: context,
  //       message: 'Data saved',
  //       type: SnackbarType.success,
  //     );
  //   });
  // }

  // //push data from local db to BLE device
  // Future<void> pushData(
  //     {required BuildContext context, required String deviceName}) async {
  //   //show loading
  //   Snackbar.show(
  //       context: context,
  //       message: 'Transferring data...',
  //       type: SnackbarType.loading,
  //       timeoutInSeconds: 500);
  //
  //   final result = await pushDeviceData(deviceName);
  //
  //   result.fold((failure) {
  //     //hide loading
  //     Snackbar.hide(context: context);
  //
  //     //show error
  //     Snackbar.show(
  //       context: context,
  //       message: failure.toString(),
  //       type: SnackbarType.error,
  //     );
  //   }, (_) {
  //     //hide loading
  //     Snackbar.hide(context: context);
  //
  //     //show success
  //     Snackbar.show(
  //       context: context,
  //       message: 'Data transferred',
  //       type: SnackbarType.success,
  //     );
  //   });
  // }

  // //upload BLE data to server
  // Future<void> uploadBLEDeviceData({
  //   required BuildContext context,
  //   required TelemetryModel telemetryModel,
  // }) async {
  //   //show loading
  //   Snackbar.show(
  //       context: context,
  //       message: 'Reading and uploading data...',
  //       type: SnackbarType.loading,
  //       timeoutInSeconds: 120);
  //
  //   final result = await uploadBLEData(telemetryModel);
  //
  //   result.fold((failure) {
  //     //hide loading
  //     Snackbar.hide(context: context);
  //
  //     //show error
  //     Snackbar.show(
  //       context: context,
  //       message: failure.toString(),
  //       type: SnackbarType.error,
  //     );
  //   }, (_) {
  //     //hide loading
  //     Snackbar.hide(context: context);
  //
  //     //show success
  //     Snackbar.show(
  //       context: context,
  //       message: 'Data uploaded',
  //       type: SnackbarType.success,
  //     );
  //   });
  // }

  //save advertisement data
  Future<void> saveAdvertData(
      {required BuildContext context,
      required AdvertisementPacketModel advertisementPacket}) async {
    final result = await saveAdvertisementData(advertisementPacket);

    result.fold((failure) {
      if (kDebugMode) {
        print(failure.toString());
      }
    }, (_) {
      if (kDebugMode) {
        print('Advertisement data saved');
      }
    });
  }

  //post advertisement data
  Future<void> postAdvertData({required BuildContext context}) async {

    //show loading
    Snackbar.show(
        context: context,
        message: 'Posting advertisement data...',
        type: SnackbarType.loading,
        timeoutInSeconds: 120);

    final result = await postAdvertisementData(NoParams());

    result.fold((failure) {

      //hide loading
      Snackbar.hide(context: context);

      //show error
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
    }, (_) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: 'Advertisement data posted',
        type: SnackbarType.success,
      );
    });
  }

  Future<void> gatewayAndDeviceSync({required BuildContext context, required String deviceName}) async {

    //show loading
    Snackbar.show(
        context: context,
        message: 'Syncing gateway and device...',
        type: SnackbarType.loading,
        timeoutInSeconds: 120);

    final result = await syncGatewayAndDevice(deviceName);

    result.fold((failure) {

      //hide loading
      Snackbar.hide(context: context);

      if (kDebugMode) {
        print(failure.toString());
      }
      //show error
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
    }, (_) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: 'Successfully synced',
        type: SnackbarType.success,
      );
    });
  }

  Future<void> serverAndGatewaySync({required BuildContext context, required String deviceName}) async {

    //show loading
    Snackbar.show(
        context: context,
        message: 'Syncing server and gateway...',
        type: SnackbarType.loading,
        timeoutInSeconds: 120);

    final result = await syncServerAndGateway(deviceName);

    result.fold((failure) {
      //hide loading
      Snackbar.hide(context: context);

      if (kDebugMode) {
        print(failure.toString());
      }
      //show error
      Snackbar.show(
        context: context,
        message: failure.toString(),
        type: SnackbarType.error,
      );
    }, (_) {
      //hide loading
      Snackbar.hide(context: context);

      //show success
      Snackbar.show(
        context: context,
        message: 'Successfully synced',
        type: SnackbarType.success,
      );
    });
  }
}
