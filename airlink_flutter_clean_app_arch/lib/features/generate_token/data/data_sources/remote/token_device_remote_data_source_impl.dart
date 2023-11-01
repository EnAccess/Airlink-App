import 'dart:convert';
import 'dart:developer';

import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/core/network/network_info.dart';
import 'package:airlink/features/generate_token/data/data_sources/remote/token_device_remote_data_source.dart';
import 'package:airlink/features/generate_token/data/models/device_suggestion_model.dart';
import 'package:airlink/features/generate_token/data/models/token_device_model.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/api/airlink_api_service.dart';
import '../../../../../core/api/angaza_api_service.dart';

class TokenDeviceRemoteDataSourceImpl implements TokenDeviceRemoteDataSource {
  final NetworkInfo networkInfo;
  final AirLinkAPIService airLinkAPIService;
  final AngazaAPIService angazaAPIService;

  TokenDeviceRemoteDataSourceImpl({
    required this.networkInfo,
    required this.airLinkAPIService,
    required this.angazaAPIService,
  });

  @override
  Future<String> generateToken(TokenDeviceModel tokenDeviceModel) async {
    if (await networkInfo.isConnected) {
      try {
        // send request to generate token
        http.Response generateTokenRes = await _generatePayGToken(tokenDeviceModel);

        //check if response was not successful i.e Unit is not currently billable
        if (generateTokenRes.statusCode == 403) {
          //send request to update unit billable
          http.Response updateUnitBillableRes =
              await angazaAPIService.recordBillingChangeForUnit(
            unitNumber: tokenDeviceModel.angazaUnitNumber,
            isBillable: true,
          );

          if(updateUnitBillableRes.statusCode == 200){
            //send request to generate token
            generateTokenRes = await _generatePayGToken(tokenDeviceModel);
          }
        }

        // extract token from response
        return _extractToken(generateTokenRes, tokenDeviceModel);
      } catch (e) {
        log(e.toString());
        throw AirLinkFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No Internet Connection');
    }
  }

  @override
  Future<List<DeviceSuggestionModel>> getDevicesByQuery(
      String deviceName) async {
    if (await networkInfo.isConnected) {
      try {
        final body = {
          'entityFilter': {
            'type': 'entityName',
            'entityType': 'DEVICE',
            'entityNameFilter': deviceName
          },
          'entityFields': [
            {'type': 'ENTITY_FIELD', 'key': 'name'}
          ],
          'latestValues': [
            {'type': 'ATTRIBUTE', 'key': 'payg_type'},
            {'type': 'ATTRIBUTE', 'key': 'PAYG_Type'},
            {'type': 'ATTRIBUTE', 'key': 'angaza_unitnumber'},
          ],
          'pageLink': {
            'page': 0,
            'pageSize': 10,
            'sortOrder': {
              'key': {'key': 'name', 'type': 'ENTITY_FIELD'},
              'direction': 'ASC'
            }
          }
        };

        //send request to get devices by query
        final getDevicesByQueryRes =
            await airLinkAPIService.findEntityDataByQuery(body: body);

        //check if response is successful and return list of devices
        if (getDevicesByQueryRes.statusCode == 200) {
          //decode response body
          final decodedResponse = jsonDecode(getDevicesByQueryRes.body);
          final devices = decodedResponse['data'] as List;
          return devices
              .map((device) => DeviceSuggestionModel.fromJson(device))
              .toList();
        } else {
          throw const AirLinkFailure(message: 'Something went wrong');
        }
      } catch (e, st) {
        log(e.toString());
        log(st.toString());
        throw AirLinkFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No Internet Connection');
    }
  }

  //checks if the device is Angaza or Airlink and sends request to generate token
  Future<http.Response> _generatePayGToken(
      TokenDeviceModel tokenDeviceModel) async {
    http.Response generateTokenRes;

    //check if the device is Angaza
    if (tokenDeviceModel.paygType == 'Angaza') {
      generateTokenRes = await angazaAPIService.updateUnitPayGCredit(
          unitNumber: tokenDeviceModel.angazaUnitNumber,
          numberOfDays: tokenDeviceModel.numberOfDays);
    } else {
      //payload
      final body = {
        'method': tokenDeviceModel.method,
        'credit': tokenDeviceModel.numberOfDays,
      };
      //send request to generate token for airlink devices
      generateTokenRes = await airLinkAPIService.generateToken(
        deviceUuid: tokenDeviceModel.deviceUuid,
        body: body,
      );
    }
    return generateTokenRes;
  }

  //extracts token from response
  String _extractToken(
      http.Response generateTokenRes, TokenDeviceModel tokenDeviceModel) {
    if (generateTokenRes.statusCode == 200) {
      final decodedResponse = jsonDecode(generateTokenRes.body);

      late String token;

      if (tokenDeviceModel.paygType == 'Angaza') {
        token = decodedResponse['_embedded']['latest_keycode']['keycode'];
      } else {
        token = decodedResponse['token'];
      }
      return token;
    } else {
      final decodedResponse = jsonDecode(generateTokenRes.body);
      throw ServerFailure(
          message: tokenDeviceModel.paygType == 'Angaza'
              ? decodedResponse['context']['reason']
              : generateTokenRes.body.isEmpty
                  ? 'Something went wrong'
                  : decodedResponse['message']);
    }
  }
}
