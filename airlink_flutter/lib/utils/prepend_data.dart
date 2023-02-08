import 'dart:convert';

class PrependData{
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
}