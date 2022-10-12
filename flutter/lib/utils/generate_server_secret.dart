import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerSecretGenerator {
  static const _chars = 'ABCDEF1234567890';
  static final Random _rnd = Random();

  static String generateSecret() {
    String serverSecret = getRandomString(32);
    return serverSecret;
  }

  static String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
