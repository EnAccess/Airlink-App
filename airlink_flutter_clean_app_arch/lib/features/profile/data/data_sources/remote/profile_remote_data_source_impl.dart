import 'dart:convert';

import 'package:airlink/core/device_info/device_info.dart';
import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/core/network/network_info.dart';
import 'package:airlink/core/storage/storage.dart';
import 'package:airlink/core/utils/helper_functions.dart';
import 'package:airlink/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:airlink/features/profile/data/models/profile_model.dart';

import '../../../../../core/api/airlink_api_service.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DeviceInfo deviceInfo;
  final NetworkInfo networkInfo;
  final SecureStorage secureStorage;
  final AirLinkAPIService airlinkApiService;

  ProfileRemoteDataSourceImpl(
      {required this.deviceInfo,
      required this.networkInfo,
      required this.secureStorage,
      required this.airlinkApiService});

  @override
  Future<void> provisionGateway(ProfileModel profileModel) async {
    //check if there is network connection
    if (await networkInfo.isConnected) {
      try {
        //get android device id
        final androidDeviceId = await deviceInfo.androidDeviceId;

        //format device name
        final formattedName = 'DEVICE_ID: ${androidDeviceId.toUpperCase()}';

        //payload
        Map<String, dynamic> body = {
          "name": formattedName,
          "type": "Gateway Phones",
          "deviceProfileId": {
            "id": profileModel.gatewayProfileId,
            "entityType": "DEVICE_PROFILE"
          }
        };

        //generate gateway access token
        final accessToken = generateSAT();

        //make api call to create device on the server
        final createDeviceRes = await airlinkApiService.createDevice(body: body, accessToken: accessToken);

        //check if device was provisioned successfully
        if (createDeviceRes.statusCode == 200) {
          //save access token
          await secureStorage.set('gateway_access_token', accessToken);
          //return success
          return;
        } else {
          final errorResponse = jsonDecode(createDeviceRes.body);
          throw AirLinkFailure(message: '${errorResponse['message']}');
        }
      } catch (e) {
        throw ServerFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No network connection');
    }
  }
}
