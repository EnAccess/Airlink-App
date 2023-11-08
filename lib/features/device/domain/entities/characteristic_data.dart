class CharacteristicData {
  final String characteristicUuid;
  Map<String, dynamic> data;

  CharacteristicData({
    required this.characteristicUuid,
    this.data = const {},
  });
}