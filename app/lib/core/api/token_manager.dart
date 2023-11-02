import 'dart:convert';

import 'package:airlink/core/errors/failures.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../features/profile/data/data_sources/local/profile_local_data_source_impl.dart';
import '../../service_locator.dart';

//this class gets JWT token for authorizing API calls
//checks if there's no token saved or the saved one has expired (thingsboard jwt token, by default, expires after 2.5hrs)
//(ref: https://thingsboard.io/docs/reference/rest-api/#jwt-tokens)
//then generates a new one

class TokenManager {
  //initialize http client
  var client = http.Client();

  late Duration timeDifference;
  late DateTime currentTime;

  //gets token if old one has expired
  Future<String> getToken() async {
    //token expiration time (the 2.5hrs)
    timeDifference = const Duration(hours: 2, minutes: 30);

    //get current time
    currentTime = DateTime.now();
    //gets the exact time exactly 2.5hrs before now
    DateTime pastTime = currentTime.subtract(timeDifference);

    //checks for token and time generated from secure storage
    String? jwtToken = await sl<FlutterSecureStorage>().read(key: 'jwtToken');
    String? jwtTokenGeneratedTime =
        await sl<FlutterSecureStorage>().read(key: 'jwtTokenGeneratedTime');

    //if no token available or is expired, get a new one
    if (jwtToken == null ||
        jwtTokenGeneratedTime == null ||
        DateTime.parse(jwtTokenGeneratedTime).isBefore(pastTime)) {
      await _generateToken();
    }

    //return token
    return jwtToken!;
  }

  Future<void> _generateToken() async {
    // Make an API request to get a new token
    await jwtLogin().then((_) => getToken());
  }

  //logs in to the server and get token and refresh token on response
  Future<String?> jwtLogin() async {
    //get profile data
    final profileModel = await sl<ProfileLocalDataSourceImpl>().getProfile();

    final String baseUrl = profileModel.airlinkServerUrl!;
    final String email = profileModel.email!;
    final String password = profileModel.password!;

    //encode contents
    final contents = jsonEncode({'username': email, 'password': password});

    //parse endpoint url
    var url = Uri.parse('$baseUrl/api/auth/login');

    var response = await client.post(url, body: contents, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    });

    if (response.statusCode == 200) {
      // Parse the JSON string into a Dart Map.
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      // Extract the "token" value from the map.
      String token = jsonData["token"];

      //save token and generated time to storage
      await sl<FlutterSecureStorage>()
          .write(key: 'jwtTokenGeneratedTime', value: currentTime.toString());

      await sl<FlutterSecureStorage>().write(key: 'jwtToken', value: token);

      return token;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw AirLinkFailure(message: 'AirLink server error: ${errorResponse['message']}');
    }
  }
}
