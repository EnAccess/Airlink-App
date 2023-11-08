class Telemetry {
  final String deviceName;
  List data;

  Telemetry({
    required this.deviceName,
    this.data = const [],
  });
}
