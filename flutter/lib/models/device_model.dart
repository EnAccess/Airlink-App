import 'package:flutter_blue/flutter_blue.dart';

const String tableDeviceData = 'device_data';

class DeviceDataFields {

  static final List<String> values = [
    name, id, rssi, rv, ft, did, gts, pst, fv, cr, pu
  ];

  static const String name = 'name';
  static const String id = 'id';
  static const String rssi = 'rssi';

  //from advert packet
  static const dynamic rv = 'rv';
  static const dynamic ft = 'ft';
  static const dynamic did = 'did';
  static const dynamic gts = 'gts';
  static const dynamic pst = 'pst';
  static const dynamic fv = 'fv';
  static const dynamic cr = 'cr';
  static const dynamic pu = 'pu';

  //from location
  static const String lt = 'lt';
  static const String ln = 'ln';
  static const String la = 'la';
}

class Device {
  final BluetoothDevice? device;
  final String name;
  final String? type;
  final String? id;
  final String rssi;
  final String? mfg;

  //from advert packet
  final dynamic rv;
  final dynamic ft;
  final dynamic did;
  final dynamic gts;
  final dynamic pst;
  final dynamic fv;
  final dynamic cr;
  final dynamic pu;

  Device({
    this.device,
    required this.name,
    this.type,
    this.id,
    required this.rssi,
    this.mfg,


    required this.rv,
    required this.ft,
    required this.did,
    required this.gts,
    required this.pst,
    required this.fv,
    required this.cr,
    required this.pu,
  });

  Map<String, Object?> toJson() => {
    DeviceDataFields.name: name,
    DeviceDataFields.id: id,
    DeviceDataFields.rssi: rssi,
    DeviceDataFields.rv: rv,
    DeviceDataFields.ft: ft,
    DeviceDataFields.did: did,
    DeviceDataFields.gts: gts,
    DeviceDataFields.pst: pst,
    DeviceDataFields.fv: fv,
    DeviceDataFields.cr: cr,
    DeviceDataFields.pu: pu
  };

  Device copy({
    int? did,
    String? name,
    String? rssi,
    int? rv,
    int? ft,
    String? id,
    String? gts,
    int? pst,
    int? fv,
    int? cr,
    String? pu,
    String? lt,
    String? ln,
    String? la,

  }) => Device(
      device: device,
      name: name ?? this.name,
      type: type,
      id: id ?? this.id,
      rssi: rssi ?? this.rssi,
      mfg: mfg,
      rv: rv ?? this.rv,
      ft: ft ?? this.ft,
      did: did ?? this.did,
      gts: gts ?? this.gts,
      pst: pst ?? this.pst,
      fv: fv ?? this.fv,
      cr: cr ?? this.cr,
      pu: pu ?? this.pu,
  );

  static Device fromJson(Map<String, Object?> json) => Device(
      name: json[DeviceDataFields.name] as String,
      id: json[DeviceDataFields.id] as String,
      rssi: json[DeviceDataFields.rssi] as String,
      rv: json[DeviceDataFields.rv],
      ft: json[DeviceDataFields.ft],
      did: json[DeviceDataFields.did],
      gts: json[DeviceDataFields.gts],
      pst: json[DeviceDataFields.pst],
      fv: json[DeviceDataFields.fv],
      cr: json[DeviceDataFields.cr],
      pu: json[DeviceDataFields.pu],
  );
}
