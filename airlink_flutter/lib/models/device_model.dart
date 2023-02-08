import 'package:flutter_blue/flutter_blue.dart';

import 'advertisement_packet_model.dart';

const String tableDeviceData = 'device_data';

class DeviceDataFields {
  static final List<String> values = [
    id,
    name,
    mac,
    rv,
    ft,
    aid,
    gts,
    pst,
    fv,
    cr,
    pu,
    gid,
    gmid,
    lt,
    ln,
    la,
    dss,
    s1,
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String mac = 'mac';
  static const String rv = 'rv';
  static const String ft = 'ft';
  static const String aid = 'aid';
  static const String gts = 'gts';
  static const String pst = 'pst';
  static const String fv = 'fv';
  static const String cr = 'cr';
  static const String pu = 'pu';
  static const String gid = 'gid';
  static const String gmid = 'gmid';
  static const String lt = 'lt';
  static const String ln = 'ln';
  static const String la = 'la';
  static const String dss = 'dss';
  static const String s1 = 's1';
}

class Device {
  final int? id;
  final BluetoothDevice? device;
  final String name;
  final AdvertisementPacket advertisementData;

  Device(
      {this.id,
      this.device,
      required this.name,
      required this.advertisementData});

  Map<String, Object?> toJson() => {
        DeviceDataFields.id: id,
        DeviceDataFields.name: name,
        DeviceDataFields.mac: advertisementData.mac,
        DeviceDataFields.rv: advertisementData.rv,
        DeviceDataFields.ft: advertisementData.ft,
        DeviceDataFields.aid: advertisementData.aid,
        DeviceDataFields.gts: advertisementData.gts,
        DeviceDataFields.pst: advertisementData.pst,
        DeviceDataFields.fv: advertisementData.fv,
        DeviceDataFields.cr: advertisementData.cr,
        DeviceDataFields.pu: advertisementData.pu,
        DeviceDataFields.gid: advertisementData.gid,
        DeviceDataFields.gmid: advertisementData.gmid,
        DeviceDataFields.lt: advertisementData.lt,
        DeviceDataFields.ln: advertisementData.ln,
        DeviceDataFields.la: advertisementData.la,
        DeviceDataFields.dss: advertisementData.dss,
        DeviceDataFields.s1: advertisementData.s1,
      };

  Device copy({
    int? id,
    BluetoothDevice? device,
    String? name,
    AdvertisementPacket? advertisementData,
  }) =>
      Device(
        id: id ?? this.id,
        device: device ?? this.device,
        name: name ?? this.name,
        advertisementData: advertisementData ?? this.advertisementData,
      );

static Device fromJson(Map<String, Object?> json) => Device(
        id: json[DeviceDataFields.id] as int?,
        name: json[DeviceDataFields.name] as String,
        advertisementData: AdvertisementPacket.fromJson(json));

  @override
  String toString() {
    return 'Device{id: $id, name: $name, advertisementData: $advertisementData}';
  }
}

