import 'dart:convert';
import 'dart:math';

String formatDuration({required Duration duration}) {
  var seconds = duration.inSeconds;
  final days = seconds ~/ Duration.secondsPerDay;
  seconds -= days * Duration.secondsPerDay;
  final hours = seconds ~/ Duration.secondsPerHour;
  seconds -= hours * Duration.secondsPerHour;
  final minutes = seconds ~/ Duration.secondsPerMinute;
  seconds -= minutes * Duration.secondsPerMinute;

  final List<String> tokens = [];
  if (days != 0) {
    tokens.add('${days}d');
  } else if (tokens.isNotEmpty && days == 0 || hours != 0) {
    tokens.add('${hours}h');
  }
// if (tokens.isNotEmpty || minutes != 0) {
//   tokens.add('${minutes}m');
// }
// tokens.add('${seconds}s');

  return tokens.join(':');
}

String generateSAT() => getRandomString(20);

String generateDeviceSecret() => getRandomString(32, true);

String getRandomString(int length, [bool isHexOnly = false]) {
  final Random rnd = Random();
  String chars;

  if (isHexOnly) {
    chars = 'ABCDEF123456789';
  } else {
    chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789';
  }

  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

//check if number is an integer
bool isInteger(num value) => value is int || value == value.roundToDouble();

prepend(String jsonString, String descriptorValue) {
  var data = <String>[];

  var decodedResult = json.decode(jsonString);
  decodedResult.forEach((key, value) {
    String contents;
    //if the value is an integer, do not surround it with quotes
    if (value.runtimeType == int) {
      contents =
      '"${descriptorValue.toLowerCase()}_$key": $value';
      data.add(contents);
    }
    //if the value's data type is a string, surround it with quotes
    else if (value.runtimeType == String) {
      contents =
      '"${descriptorValue.toLowerCase()}_$key": "$value"';
      data.add(contents);
    }
  });

  //replace square brackets with curly braces. preparing it for sending to server (telemetry data)
  final allData =
  data.toString().replaceAll('[', '{').replaceAll(']', '}');

  return allData;
}

//encode credentials to base64 string
String encodeCredentials(String username, String password) {
  final String credentials = '$username:$password';
  final List<int> utf8Bytes = utf8.encode(credentials);
  final String base64String = base64Encode(utf8Bytes);
  return base64String;
}
