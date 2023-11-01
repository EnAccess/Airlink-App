import 'dart:convert';

import 'package:airlink/constants/constants.dart';
import 'package:airlink/services/HttpsEndpoint.dart';
import 'package:airlink/utils/generate_server_access_token.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/api_response/jwt_token_model.dart';

class AirLinkServer {
  final storage = const FlutterSecureStorage();
  var client = http.Client();

  Future jwtLoginRequest(String username, String password) async {
    final contents = jsonEncode({'username': username, 'password': password});

    String apiUrl = await HttpsEndpoint().apiEndpoint('login');

    var url = Uri.parse(apiUrl);

    http.Response response;

    response = await client.post(url, body: contents, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    });

    if (response.statusCode == 401) {
      //retry to generate a new token
      await jwtLoginRequest(username, password);
    }

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

    final contents = jsonEncode({
      'name': deviceName,
      'type': profileType,
      'deviceProfileId': {'id': profileId, 'entityType': 'DEVICE_PROFILE'}
    });

    String apiUrl = await HttpsEndpoint().apiEndpoint(postType);

    http.Response response =
        await postToAirLinkServer(postType, apiUrl, contents);

    return response;
  }

  Future postToAirLinkServer(
      String action, String endpointUrl, String contents) async {
    var url = Uri.parse(endpointUrl);

    String jwtToken = await storage.read(key: 'jwtToken') ?? '';

    http.Response response;
    response = await client.post(url, body: contents, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Authorization": "Bearer $jwtToken"
    });

    if (response.statusCode == 401) {
      //retry to generate a new token
      await generateNewToken().then((_) async =>
          response = await client.post(url, body: contents, headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-Authorization": "Bearer $jwtToken"
          }));
    }

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
      await generateNewToken().then((_) async => {
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
  Future saveEntityAttributes(String entityType, String entityID, Scope scope,
      String attributes) async {
    String jwtToken = await storage.read(key: 'jwtToken') ?? '';
    String apiUrl = await HttpsEndpoint().apiEndpoint('saveEntityAttributes') +
        '$entityType/$entityID/attributes/${scope.name}';
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

    String apiUrl = await HttpsEndpoint().apiEndpoint('telemetry') +
        '$entityType/$entityId/timeseries/ANY?scope=ANY';
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

  //function that checks if a certain device exists on the server. Will return it's UUID if it exists
  //else, it will return null
  Future getTenantDevice(String deviceName) async {
    String apiUrl =
        await HttpsEndpoint().apiEndpoint('getTenantDevice') + deviceName;

    String jwtToken = await storage.read(key: 'jwtToken') ?? '';

    var url = Uri.parse(apiUrl);
    var response = await client.get(url, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Authorization": "Bearer $jwtToken"
    });

    if (response.statusCode == 401) {
      //retry to generate a new token
      await generateNewToken().then((_) => getTenantDevice(deviceName));
    } else {
      final decodedResponse = json.decode(response.body);
      try {
        var deviceUUID = json.encode(decodedResponse['id']['id']);
        return deviceUUID.replaceAll('"', '');
      } catch (e) {
        if (kDebugMode) {
          print('Error getting device!');
        }
        return null;
      }
    }
  }

  //function that returns the device credentials (access token for now) from ThingsBoard server
  //based on the device Id
  Future getDeviceCredentials(String deviceID) async {
    await storage.write(key: 'provisionedDeviceUUID', value: deviceID);

    String apiUrl = await HttpsEndpoint().apiEndpoint('getDeviceCredentials');

    String jwtToken = await storage.read(key: 'jwtToken') ?? '';

    var url = Uri.parse(apiUrl);
    var response = await client.get(url, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Authorization": "Bearer $jwtToken"
    });

    final decodedResponse = json.decode(response.body);
    try {
      String credentialsId = json.encode(decodedResponse['credentialsId']);
      return credentialsId;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device credentials!');
      }
      return null;
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
