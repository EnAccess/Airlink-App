import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:airlink/constants/constants.dart';
import 'package:airlink/services/HttpsEndpoint.dart';
import 'package:airlink/utils/generate_server_access_token.dart';
import 'package:cbor/cbor.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../db/advertisement_database.dart';
import '../models/api_response/jwt_token_model.dart';
import '../models/api_response/provision_response_model.dart';
import '../models/device_model.dart';

class AirLinkServer {
  final storage = const FlutterSecureStorage();
  var client = http.Client();

  Future jwtLoginRequest(String username, String password) async {
    final contents = jsonEncode({'username': username, 'password': password});

    String apiUrl = await HttpsEndpoint().apiEndpoint('login');

    http.Response response =
        await postToAirLinkServer('login', apiUrl, contents);

    final jwtToken = tokenFromJson(response.body).token;
    if (jwtToken.toString().isNotEmpty) {
      await storage.write(key: 'jwtToken', value: jwtToken.toString());
    } else {
      if (kDebugMode) {
        print('token is either expired and was not generated for some reason');
      }
    }
  }

  Future provisionDevice(String deviceName, String option) async {
    //get user email and password for jwt auth to server
    String jwtEmail = await storage.read(key: 'email') ?? '';
    String jwtPassword = await storage.read(key: 'password') ?? '';


    //login to server. generates jwt token and saves to secure storage
    await jwtLoginRequest(jwtEmail, jwtPassword);

    final deviceProfileId = await storage.read(key: 'deviceProfileId');
    final gatewayProfileId = await storage.read(key: 'gatewayProfileId');

    String profileId = '';
    String profileType = '';
    String postType = '';

    if (option == "gateway") {
      await ServerAuthTknGenerator().generateSAT(option);
      postType = "provisionGateway";
      profileId = gatewayProfileId.toString();
      profileType = "Gateway Phones";
    } else if (option == "device") {
      await ServerAuthTknGenerator().generateSAT(option);
      postType = "provisionDevice";
      profileId = deviceProfileId.toString();
      profileType = "Devices Profile";
    }

    // String deviceAccessToken = await storage.read(key: 'deviceAccessToken') ?? '';
    // print(deviceAccessToken);

    final contents = jsonEncode({
      'name': deviceName,
      'type': profileType,
      'deviceProfileId': {'id': profileId, 'entityType': 'DEVICE_PROFILE'}
    });

    print(contents.toString());

    String apiUrl = await HttpsEndpoint().apiEndpoint(postType);
    print(apiUrl.toString());

    http.Response response = await postToAirLinkServer(postType, apiUrl, contents);

    // try {
    //   final uuid = provisionResponseFromJson(response.body).id.id;
    //   if (option == 'device') {
    //     await storage.write(key: 'deviceUUID', value: uuid.toString());
    //     print('Success! Device UUID: $uuid');
    //   } else {
    //     await storage.write(key: 'gatewayUUID', value: uuid.toString());
    //     print('Success! Gateway UUID: $uuid');
    //   }
    // } catch (e) {
    //   var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    //   final msg = Uri.parse(decodedResponse['message']);
    //   if (msg.toString().isNotEmpty) {
    //     print('Error! $msg');
    //   }
    // }

    return response;
  }

  Future postToAirLinkServer(
      String action, String endpointUrl, String contents) async {
    var url = Uri.parse(endpointUrl);
    String jwtToken = await storage.read(key: 'jwtToken') ?? '';
    var response = await client.post(url, body: contents, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Authorization": "Bearer $jwtToken"
    });

    // print('response body: ${response.body}');

    return response;
  }

  /// Returns all attributes of a specified scope that belong to specified entity.
  /// entityType can be: DEVICE, CUSTOMER, ASSET
  /// entityID is the ID of that entity
  /// scope can be: SERVER_SCOPE or CLIENT_SCOPE or SHARED_SCOPE
  Future getAttributesByScope(
      String entityType, String entityID, String scope) async {
    String jwtToken = await storage.read(key: 'jwtToken') ?? '';

    String apiUrl = await HttpsEndpoint().apiEndpoint('getAttributesByScope') +
        '$entityType/$entityID/values/attributes/$scope';

    var url = Uri.parse(apiUrl);

    http.Response response;

    response = await client.get(url, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Authorization": "Bearer $jwtToken"
    });

    if (response.statusCode == 401) {
      //retry to generate a new token
      await generateNewToken().then((value) async => {
        response = await client.get(url, headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-Authorization": "Bearer $jwtToken"
        })
      });
    }

    return response;
  }

  ///Creates or updates the entity attributes based on Entity Id and the specified attribute scope.
  ///List of possible attribute scopes depends on the entity type:
  ///
  /// [SERVER_SCOPE] - supported for all entity types;
  ///
  /// [CLIENT_SCOPE] - supported for devices;
  ///
  /// [SHARED_SCOPE] - supported for devices.
  Future saveEntityAttributes(String entityType, String entityID, Scope scope, String attributes) async {
    String jwtToken = await storage.read(key: 'jwtToken') ?? '';
    String apiUrl = await HttpsEndpoint().apiEndpoint('saveEntityAttributes') + '$entityType/$entityID/attributes/${scope.name}';
    var url = Uri.parse(apiUrl);

    http.Response response;

    response = await client.post(url, body: attributes, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Authorization": "Bearer $jwtToken"
    });

    if (response.statusCode == 401) {
      //retry to generate a new token
      await generateNewToken().then((value) async => {
        response = await client.post(url, body: attributes, headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-Authorization": "Bearer $jwtToken"
        })
      });
    }
    return response;
  }

  ///Send data to telemetry
  Future sendDataToTelemetry(String entityType, entityId, telemetryData) async {

    String jwtToken = await storage.read(key: 'jwtToken') ?? '';

    String apiUrl = await HttpsEndpoint().apiEndpoint('telemetry') + '$entityType/$entityId/timeseries/ANY?scope=ANY';
    var url = Uri.parse(apiUrl);

    http.Response response;

    response = await client.post(url, body: telemetryData, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Authorization": "Bearer $jwtToken"
    });

    if (response.statusCode == 401) {
      //retry to generate a new token
      await generateNewToken().then((value) async => {
        response = await client.post(url, body: telemetryData, headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-Authorization": "Bearer $jwtToken"
        })
      });
    }

    return response;
  }

  ///post advertisement data to the server
  postAdvertData() async {
    //get all devices saved in DB
    List<Device> advertData = await DeviceDatabase.instance.readAllDevices();
    bool deviceKnown;
    for (var data in advertData) {
      log(data.toJson().toString());

      final deviceSAT = await storage.read(key: 'D_${data.did.toString()}') ?? '';

      final deviceCborValue = CborValue(
        {
          'ADVT_rv': data.rv,
          'ADVT_ft': data.ft,
          'ADVT_did': data.did,
          'ADVT_gts': data.gts,
          'ADVT_pst': data.pst,
          'ADVT_fv': data.fv,
          'ADVT_cr': data.cr,
          'ADVT_pu': data.pu,
          'ADVT_rssi': '${data.rssi.toString()}dBm',
        },
      );

      final sendCborValue = CborValue(
        {
          'ADVT_aDN': data.did,
          'ADVT_tms': deviceCborValue,
        },
      );

      if (deviceSAT.isNotEmpty) {
        deviceKnown = true;
      } else {
        deviceKnown = false;
      }

      // final bytes = deviceKnown ? cbor.encode(deviceCborValue) : cbor.encode(sendCborValue);
      // var cborHexString = hex.encode(bytes);
      // log(cborHexString);

      String contents =
      deviceKnown ? deviceCborValue.toString() : sendCborValue.toString();

      //post it's data to gateway telemetry
      //get apiUrl
      String apiUrl = await HttpsEndpoint().apiEndpoint('advtPost');

      //post to gateway telemetry
      http.Response response =
      await AirLinkServer().postToAirLinkServer('', apiUrl, contents);

      if (response.body.isEmpty) {
        if (kDebugMode) {
          print('posted advt data for: ${data.did}');
        }
        //delete entry from DB once successfully posted
        await DeviceDatabase.instance.delete(data.did);
      }
    }
  }

  ///Generates a new JWT token for the user.
  Future generateNewToken() async {
    String jwtEmail = await storage.read(key: 'email') ?? '';
    String jwtPassword = await storage.read(key: 'password') ?? '';

    //login to server. generates jwt token and saves to secure storage
    await jwtLoginRequest(jwtEmail, jwtPassword);
  }
}
