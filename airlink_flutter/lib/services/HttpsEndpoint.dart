import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpsEndpoint {
  Future<String> apiEndpoint(String action) async {
    const storage = FlutterSecureStorage();

    final serverUrl = await storage.read(key: 'serverUrl');

    String urlPreModifier;
    String token;
    String urlPostModifier;

    switch (action) {
      case 'login':
        urlPreModifier = '/api';
        token = '';
        urlPostModifier = '/auth/login';
        break;
      case 'provisionGateway':
        urlPreModifier = '/api/device?accessToken=';
        final gatewayAccessToken =
            await storage.read(key: 'gatewayAccessToken');
        token = gatewayAccessToken.toString();
        urlPostModifier = '';
        break;
      case 'provisionDevice':
        urlPreModifier = '/api/device?accessToken=';
        final deviceAccessToken = await storage.read(key: 'deviceAccessToken');
        token = deviceAccessToken.toString();
        urlPostModifier = '';
        break;
      case 'serverScope':
        urlPreModifier = '/api/plugins/telemetry/DEVICE/';
        final deviceUUID = await storage.read(key: 'deviceUUID');
        token = deviceUUID.toString();
        urlPostModifier = '/SERVER_SCOPE';
        break;
      case 'getAttributes':
        urlPreModifier = '/api/v1/';
        final deviceAccessToken = await storage.read(key: 'deviceAccessToken');
        token = deviceAccessToken.toString();
        urlPostModifier = '/attributes';
        break;
      case 'telemetry':
        urlPreModifier = '/api/plugins/telemetry/';
        token = '';
        urlPostModifier = '';
        break;
      case 'advtPost':
        urlPreModifier = '/api/v1/';
        final gatewayAccessToken =
            await storage.read(key: 'gatewayAccessToken');
        token = gatewayAccessToken.toString();
        urlPostModifier = '/telemetry';
        break;
      case 'getAttributesByScope':
        urlPreModifier = '/api/plugins/telemetry/';
        token = '';
        urlPostModifier = '';
        break;
      case 'saveEntityAttributes':
        urlPreModifier = '/api/plugins/telemetry/';
        token = '';
        urlPostModifier = '';
        break;
      case 'getTenantDevice':
        urlPreModifier = '/api/tenant/devices?deviceName=';
        urlPostModifier = '';
        token = '';
        break;
      default:
        urlPreModifier = '';
        token = '';
        urlPostModifier = '';
        break;
    }

    String _endPointApi =
        '${serverUrl}${urlPreModifier}${token}${urlPostModifier}';
    return _endPointApi;
  }
}
