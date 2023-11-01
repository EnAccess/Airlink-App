import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/storage.dart';
import '../utils/enums/enums.dart';

class AngazaBaseClient {

  final SecureStorage secureStorage;

  AngazaBaseClient({required this.secureStorage});

  //handles requests to the server
  Future<http.Response> handleRequest(
      {required Method method,
        required String endpointPostModifier,
        dynamic body}) async {

    //get base url
    const String baseUrl = 'https://payg.angazadesign.com/nexus/v1';

    //get uri
    var uri = Uri.parse('$baseUrl/$endpointPostModifier');

    //get auth key
    final authKey = await secureStorage.get('angazaAuthKey');

    //set headers
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Basic $authKey",
    };

    //switch methods
    switch (method) {
      case Method.get:
      //call the get method
        return await http.get(uri, headers: headers);

      case Method.post:
      //call the post method
        return await http.post(uri, body: jsonEncode(body), headers: headers);

      case Method.put:
      //call the post method
        return await http.put(uri, body: jsonEncode(body), headers: headers);
    }
  }
}