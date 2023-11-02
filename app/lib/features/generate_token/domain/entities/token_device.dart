class TokenDevice {
  /// The method of token to be generated. Default is Add Credit.
  /// E.g. Add Credit, Set Credit, Unlock PAYG.
  final String method;

  /// The PAYG type of the device to be added credit to.
  final String paygType;

  /// The device uuid of the AirLink device to be added credit to.
  final String deviceUuid;

  /// The Angaza unit number of the Angaza device to be added credit to.
  final String angazaUnitNumber;

  /// The number of days to be added to the device.
  final int numberOfDays;

  TokenDevice({
    this.method = 'Add Credit',
    this.deviceUuid = '',
    this.angazaUnitNumber = '',
    required this.paygType,
    required this.numberOfDays,
  });
}