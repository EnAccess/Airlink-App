import 'package:http/http.dart' as http;

import '../utils/enums/enums.dart';
import 'angaza_base_client.dart';

class AngazaAPIService {
  final AngazaBaseClient _angazaBaseClient;

  AngazaAPIService(this._angazaBaseClient);

  /// Record billing changes for a unit.
  /// Setting a unit to `is_billable: true` permits a Platform to update the unit's desired credit.
  /// Units with is_billable set to `true` are considered "active" and billed to the respective Manufacturer as such.
  Future<http.Response> recordBillingChangeForUnit(
      {required String unitNumber, required bool isBillable}) async {
    String endpointPostModifier = 'unit_billing_changes';

    Map<String, dynamic> body = {
      'unit_number': unitNumber,
      'is_billable': isBillable,
    };

    return await _angazaBaseClient.handleRequest(
        method: Method.post,
        body: body,
        endpointPostModifier: endpointPostModifier);
  }

  /// Update a unit's PAYG credit and obtain Angaza's updated PAYG credit information.
  Future<http.Response> updateUnitPayGCredit(
      {required String unitNumber, required int numberOfDays}) async {
    String endpointPostModifier = 'unit_credit';

    //get date number of days from now
    final DateTime now = DateTime.now();
    final DateTime numberOfDaysFromNow = now.add(Duration(days: numberOfDays));
    final String numberOfDaysFromNowString =
        numberOfDaysFromNow.toIso8601String();

    Map<String, dynamic> body = {
      'unit_number': unitNumber,
      'state': {
        'desired': {'credit_until_dt': numberOfDaysFromNowString}
      },
    };

    return await _angazaBaseClient.handleRequest(
        method: Method.put,
        body: body,
        endpointPostModifier: endpointPostModifier);
  }
}
