const String tableAdvertData = 'advert_data';

class AdvertPacketFields {
  static final List<String> values = [
    id,
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

class AdvertisementPacket {
  final int? id;
  final dynamic mac;
  final dynamic rv;
  final dynamic ft;
  final dynamic aid;
  final dynamic gts;
  final dynamic pst;
  final dynamic fv;
  final dynamic cr;
  final dynamic pu;
  final dynamic gid;
  final dynamic gmid;
  final dynamic lt;
  final dynamic ln;
  final dynamic la;
  final dynamic dss;
  final dynamic s1;

  AdvertisementPacket({
    this.id,
    required this.mac,
    required this.rv,
    required this.ft,
    required this.aid,
    required this.gts,
    required this.pst,
    required this.fv,
    required this.cr,
    required this.pu,
    required this.gid,
    required this.gmid,
    required this.lt,
    required this.ln,
    required this.la,
    required this.dss,
    required this.s1,
  });

  Map<String, Object?> toJson() => {
        AdvertPacketFields.id: id,
        AdvertPacketFields.mac: mac,
        AdvertPacketFields.rv: rv,
        AdvertPacketFields.ft: ft,
        AdvertPacketFields.aid: aid,
        AdvertPacketFields.gts: gts,
        AdvertPacketFields.pst: pst,
        AdvertPacketFields.fv: fv,
        AdvertPacketFields.cr: cr,
        AdvertPacketFields.pu: pu,
        AdvertPacketFields.gid: gid,
        AdvertPacketFields.gmid: gmid,
        AdvertPacketFields.lt: lt,
        AdvertPacketFields.ln: ln,
        AdvertPacketFields.la: la,
        AdvertPacketFields.dss: dss,
        AdvertPacketFields.s1: s1,
      };

  AdvertisementPacket copy({
    int? id,
    String? mac,
    String? rv,
    String? ft,
    String? aid,
    String? gts,
    String? pst,
    String? fv,
    String? cr,
    String? pu,
    String? gid,
    String? gmid,
    String? lt,
    String? ln,
    String? la,
    String? dss,
    String? s1,
  }) =>
      AdvertisementPacket(
        id: id ?? this.id,
        mac: mac ?? this.mac,
        rv: rv ?? this.rv,
        ft: ft ?? this.ft,
        aid: aid ?? this.aid,
        gts: gts ?? this.gts,
        pst: pst ?? this.pst,
        fv: fv ?? this.fv,
        cr: cr ?? this.cr,
        pu: pu ?? this.pu,
        gid: gid ?? this.gid,
        gmid: gmid ?? this.gmid,
        lt: lt ?? this.lt,
        ln: ln ?? this.ln,
        la: la ?? this.la,
        dss: dss ?? this.dss,
        s1: s1 ?? this.s1,
      );

  static AdvertisementPacket fromJson(Map<String, Object?> json) =>
      AdvertisementPacket(
        id: json[AdvertPacketFields.id] as int,
        mac: json[AdvertPacketFields.mac],
        rv: json[AdvertPacketFields.rv],
        ft: json[AdvertPacketFields.ft],
        aid: json[AdvertPacketFields.aid],
        gts: json[AdvertPacketFields.gts],
        pst: json[AdvertPacketFields.pst],
        fv: json[AdvertPacketFields.fv],
        cr: json[AdvertPacketFields.cr],
        pu: json[AdvertPacketFields.pu],
        gid: json[AdvertPacketFields.gid],
        gmid: json[AdvertPacketFields.gmid],
        lt: json[AdvertPacketFields.lt],
        ln: json[AdvertPacketFields.ln],
        la: json[AdvertPacketFields.la],
        dss: json[AdvertPacketFields.dss],
        s1: json[AdvertPacketFields.s1],
      );
}
