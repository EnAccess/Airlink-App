import 'package:airlink/core/api/base_api_client.dart';
import 'package:http/http.dart' as http;

import '../utils/enums/enums.dart';

//this service contains required functions to send requests to Airlink server
class AirLinkAPIService {
  final BaseApiService _baseApiService;

  AirLinkAPIService(this._baseApiService);

  Future<http.Response> getTenantDevice({required String deviceName}) async {
    String endpointPostModifier = 'tenant/devices?deviceName=$deviceName';
    return await _baseApiService.handleRequest(
        method: Method.get, endpointPostModifier: endpointPostModifier);
  }

  //creates or updates the entity attributes based on Entity Id and the specified attribute scope.
  Future<http.Response> saveEntityAttributes(
      {required EntityType entityType,
      required String entityId,
      required Scope scope,
      required Map<String, dynamic> attributes}) async {
    String endpointPostModifier =
        'plugins/telemetry/${entityType.name}/$entityId/attributes/${scope.name}';

    return await _baseApiService.handleRequest(
        method: Method.post,
        body: attributes,
        endpointPostModifier: endpointPostModifier);
  }

  Future<http.Response> getAttributesByScope(
      {required EntityType entityType,
      required String entityId,
      required Scope scope,
      String? keys}) async {
    String endpointPostModifier =
        'plugins/telemetry/${entityType.name}/$entityId/values/attributes/${scope.name}${keys != null ? '?keys=$keys' : ''}';

    return await _baseApiService.handleRequest(
        method: Method.get, endpointPostModifier: endpointPostModifier);
  }

  //creates or updates the entity attributes based on Entity Id and the specified attribute scope.
  Future<http.Response> createDevice(
      {required Map<String, dynamic> body, required String accessToken}) async {
    String endpointPostModifier = 'device?accessToken=$accessToken';

    return await _baseApiService.handleRequest(
        method: Method.post,
        body: body,
        endpointPostModifier: endpointPostModifier);
  }

  ///Send data to telemetry
  Future<http.Response> saveTimeSeriesData({
    required EntityType entityType,
    required String entityId,
    required telemetryData,
  }) async {
    String endpointPostModifier =
        'plugins/telemetry/${entityType.name}/$entityId/timeseries/ANY?scope=ANY';

    return await _baseApiService.handleRequest(
        method: Method.post,
        body: telemetryData,
        endpointPostModifier: endpointPostModifier);
  }

  ///Send data to telemetry
  Future<http.Response> postTelemetry({
    required String accessToken,
    required Map<String, dynamic> telemetryData,
  }) async {
    String endpointPostModifier = 'v1/$accessToken/telemetry';

    return await _baseApiService.handleRequest(
        method: Method.post,
        body: telemetryData,
        endpointPostModifier: endpointPostModifier);
  }

  ///Send data to telemetry
  Future<http.Response> generateToken({
    required String deviceUuid,
    required body,
  }) async {
    String endpointPostModifier = 'rule-engine/DEVICE/$deviceUuid';

    return await _baseApiService.handleRequest(
        method: Method.post,
        body: body,
        endpointPostModifier: endpointPostModifier);
  }

  /// Find entity data by query
  Future<http.Response> findEntityDataByQuery({required body}) async {
    String endpointPostModifier = 'entitiesQuery/find';

    return await _baseApiService.handleRequest(
        method: Method.post,
        body: body,
        endpointPostModifier: endpointPostModifier);
  }
}
