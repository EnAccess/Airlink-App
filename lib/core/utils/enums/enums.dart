import 'package:flutter/foundation.dart';

enum Method {
  get, post, put,
}

enum Scope {
  server,
  client,
  shared
}

enum EntityType {
  asset,
  device,
}

enum SnackbarType {
  error,
  success,
  info,
  warning, loading
}

enum AlertAction {
  bluetooth,
  location
}

enum Sync {
  serverToPhone,
  phoneToDevice,
}

extension ScopeToString on Scope {
  String get name => '${describeEnum(this)}_scope'.toUpperCase();
}

extension EntityTypeToString on EntityType {
  String get name => describeEnum(this).toUpperCase();
}