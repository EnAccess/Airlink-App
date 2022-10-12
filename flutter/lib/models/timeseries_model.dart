const String tableTimeSeries = 'timeseries_data';

class TimeSeriesFields {

  static final List<String> values = [
    did, json,
  ];

  static const dynamic did = 'did';
  static const String json = 'json';
}

class TimeSeriesData {
  final dynamic did;
  final String json;

  const TimeSeriesData({
    required this.did,
    required this.json,
  });

  Map<String, Object?> toJson() => {
    TimeSeriesFields.did: did,
    TimeSeriesFields.json: json,
  };

  TimeSeriesData copy({
    int? id,
    String? did,
    String? json,

  }) => TimeSeriesData(
    did: did ?? this.did,
    json: json ?? this.json,
  );

  static TimeSeriesData fromJson(Map<String, Object?> json) => TimeSeriesData(
    did: json[TimeSeriesFields.did],
    json: json[TimeSeriesFields.json] as String,
  );

}
