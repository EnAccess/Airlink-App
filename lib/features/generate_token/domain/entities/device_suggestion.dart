class DeviceSuggestion {
  final String name;
  final String entityId;
  final String entityType;
  final String paygType;
  final String angazaUnitNumber;

  DeviceSuggestion({
    required this.name,
    required this.entityId,
    required this.entityType,
    required this.paygType,
    this.angazaUnitNumber = '',
  });
}