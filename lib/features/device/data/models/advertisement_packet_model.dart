import 'package:airlink/features/device/domain/entities/advertisement_packet.dart';

class AdvertisementPacketModel extends AdvertisementPacket {
  AdvertisementPacketModel({
    required super.rv,
    required super.ft,
    required super.did,
    required super.gts,
    required super.pst,
    required super.fv,
    required super.cr,
    required super.pu,
    required super.gid,
    required super.gmid,
    required super.lt,
    required super.ln,
    required super.la,
    required super.dss,
    required super.s1,
    required super.mac,
  });

  factory AdvertisementPacketModel.fromEntity(
      AdvertisementPacket advertisementPacket) {
    return AdvertisementPacketModel(
      rv: advertisementPacket.rv,
      ft: advertisementPacket.ft,
      did: advertisementPacket.did,
      gts: advertisementPacket.gts,
      pst: advertisementPacket.pst,
      fv: advertisementPacket.fv,
      cr: advertisementPacket.cr,
      pu: advertisementPacket.pu,
      gid: advertisementPacket.gid,
      gmid: advertisementPacket.gmid,
      lt: advertisementPacket.lt,
      ln: advertisementPacket.ln,
      la: advertisementPacket.la,
      dss: advertisementPacket.dss,
      s1: advertisementPacket.s1,
      mac: advertisementPacket.mac,
    );
  }

  static toEntity(AdvertisementPacketModel advertisementPacketModel) {
    return AdvertisementPacket(
      rv: advertisementPacketModel.rv,
      ft: advertisementPacketModel.ft,
      did: advertisementPacketModel.did,
      gts: advertisementPacketModel.gts,
      pst: advertisementPacketModel.pst,
      fv: advertisementPacketModel.fv,
      cr: advertisementPacketModel.cr,
      pu: advertisementPacketModel.pu,
      gid: advertisementPacketModel.gid,
      gmid: advertisementPacketModel.gmid,
      lt: advertisementPacketModel.lt,
      ln: advertisementPacketModel.ln,
      la: advertisementPacketModel.la,
      dss: advertisementPacketModel.dss,
      s1: advertisementPacketModel.s1,
      mac: advertisementPacketModel.mac,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rv': rv,
      'ft': ft,
      'did': did,
      'gts': gts,
      'pst': pst,
      'fv': fv,
      'cr': cr,
      'pu': pu,
      'gid': gid,
      'gmid': gmid,
      'lt': lt,
      'ln': ln,
      'la': la,
      'dss': dss,
      's1': s1,
      'mac': mac,
    };
  }
}
