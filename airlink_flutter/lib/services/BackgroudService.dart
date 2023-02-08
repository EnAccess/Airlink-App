import 'package:cbor/cbor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../db/advertisement_database.dart';
import '../models/device_model.dart';
import 'AirLinkServer.dart';
import 'HttpsEndpoint.dart';
import 'package:http/http.dart' as http;

class BackgroundService {
  final storage = const FlutterSecureStorage();

  postAdvertisementData() async {
    //get all advert data from db
    List<Device> devices = await DeviceDatabase.instance.readAllDevices();

    bool deviceKnown;

    //check if there is data to post
    if (devices.isNotEmpty) {
      for (Device device in devices) {
        final deviceSAT = await storage.read(
            key: 'D_${device.advertisementData.aid.toString()}');

        final deviceCborValue = CborValue(
          {
            'advt_mac': device.advertisementData.mac,
            'advt_rv': device.advertisementData.rv,
            'advt_ft': device.advertisementData.ft,
            'advt_aid': device.advertisementData.aid,
            'advt_gts': device.advertisementData.gts,
            'advt_pst': device.advertisementData.pst,
            'advt_fv': device.advertisementData.fv,
            'advt_cr': device.advertisementData.cr,
            'advt_pu': device.advertisementData.pu,
            'advt_gid': device.advertisementData.gid,
            'advt_gmid': device.advertisementData.gmid,
            'advt_lt': device.advertisementData.lt,
            'advt_ln': device.advertisementData.ln,
            'advt_la': device.advertisementData.la,
            'advt_dss': device.advertisementData.dss,
            'advt_s1': device.advertisementData.s1,
          },
        );

        final sendCborValue = CborValue(
          {
            'advt_adn': device.advertisementData.aid,
            'advt_tms': deviceCborValue,
          },
        );

        if (deviceSAT != null) {
          deviceKnown = true;
        } else {
          deviceKnown = false;
        }

        String contents = deviceKnown
            ? const CborJsonEncoder().convert(deviceCborValue)
            : const CborJsonEncoder().convert(sendCborValue);

        //post it's data to gateway telemetry
        String url = await HttpsEndpoint().apiEndpoint('advtPost');
        http.Response response =
            await AirLinkServer().postToAirLinkServer('', url, contents);

        if (response.statusCode == 200) {
          //delete entry from DB once successfully posted
          await DeviceDatabase.instance
              .deleteDevice(device.advertisementData.aid);
        } else {
          if (kDebugMode) {
            print(
                'failed to post advt data for: ${device.advertisementData.aid}');
            print(response.body);
          }
        }
      }
    }
  }
}
