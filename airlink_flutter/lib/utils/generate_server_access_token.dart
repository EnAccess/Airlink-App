import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerAuthTknGenerator {
  static const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final Random _rnd = Random();

  generateSAT(String provisionType) async {
    const storage = FlutterSecureStorage();

    final serverAccessToken = getRandomString(20);

    if (provisionType == "gateway") {
      await storage.write(key: "gatewayAccessToken", value: serverAccessToken);
    } else {
      await storage.write(key: "deviceAccessToken", value: serverAccessToken);
    }
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
