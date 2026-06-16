class ProvisionedDevice {
  final int deviceSerialNumber;
  final String type;
  final String productCode;
  final String deviceSecret;

  ProvisionedDevice({
    required this.deviceSerialNumber,
    required this.type,
    required this.productCode,
    required this.deviceSecret,
  });
}