import 'dart:convert';

import 'package:airlink/core/api/token_manager.dart';
import 'package:http/http.dart' as http;

import '../../features/profile/data/data_sources/local/profile_local_data_source_impl.dart';
import '../../service_locator.dart';
import '../utils/enums/enums.dart';

//this service handles all API requests to the server
//generates JWT token and proceeds with the method call

class BaseApiService {
  //instantiate TokenManager
  static final tokenManager = TokenManager();

  //handles requests to the server
  Future<http.Response> handleRequest(
      {required Method method,
      required String endpointPostModifier,
      dynamic body}) async {

    //get profile model
    final profileModel = await sl<ProfileLocalDataSourceImpl>().getProfile();

    //get base url
    final String baseUrl = profileModel.airlinkServerUrl!;

    //get uri
    var uri = Uri.parse('$baseUrl/api/$endpointPostModifier');

    //get jwt token
    final token = await tokenManager.getToken();

    //set headers
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
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
        return await http.put(uri, body: jsonEncode(body), headers: headers);
    }
  }
}
