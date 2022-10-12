class PropertyObj {
  final String descriptorName;
  final String key;
  final dynamic value;

  PropertyObj({
    required this.descriptorName,
    required this.key,
    required this.value,
  });

  static PropertyObj propertyObj(String descriptorName, String key, dynamic value) {
    return PropertyObj(
      descriptorName: descriptorName,
      key: key,
      value: value,
    );
  }
}