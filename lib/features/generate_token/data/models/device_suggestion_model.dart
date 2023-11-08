import 'package:airlink/features/generate_token/domain/entities/device_suggestion.dart';

class DeviceSuggestionModel extends DeviceSuggestion {
  DeviceSuggestionModel({required super.name, required super.entityId, required super.entityType, required super.paygType, super.angazaUnitNumber = ''});

  //fromEntity
  static DeviceSuggestionModel fromEntity(DeviceSuggestion deviceSuggestion) {
    return DeviceSuggestionModel(
      name: deviceSuggestion.name,
      entityId: deviceSuggestion.entityId,
      entityType: deviceSuggestion.entityType,
      paygType: deviceSuggestion.paygType,
      angazaUnitNumber: deviceSuggestion.angazaUnitNumber,
    );
  }

  factory DeviceSuggestionModel.fromJson(device) {
    String paygType1 = device['latest']['ATTRIBUTE']['payg_type']['value'];
    String paygType2 = device['latest']['ATTRIBUTE']['PAYG_Type']['value'];

    return DeviceSuggestionModel(
      name: device['latest']['ENTITY_FIELD']['name']['value'],
      entityId: device['entityId']['id'],
      entityType: device['entityId']['entityType'],
      paygType: paygType1.isEmpty ? paygType2 : paygType1,
      angazaUnitNumber: device['latest']['ATTRIBUTE']['angaza_unitnumber']['value'],
    );
  }
}