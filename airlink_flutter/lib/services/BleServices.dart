import 'package:airlink/models/property_object_model.dart';
import 'package:airlink/widgets/AlertWidgets.dart';
import 'package:cbor/cbor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../models/resource_model.dart';
import '../provider/device_provider.dart';

class BleServices {
  ///Authorize device
  Future authorizeDevice(BuildContext ctx, String deviceId) async {
    //show loading widget
    AlertWidgets.showLoading(
        ctx, 'Loading...', 'Authorizing device, please wait.');

    //TODO: change the default SAT below on production app
    String? defaultServerAccessToken =
        dotenv.env['DEFAULT_SERVER_ACCESS_TOKEN'];

    //save default access token to secure storage
    const storage = FlutterSecureStorage();
    storage.write(
        key: 'defaultServerAccessToken', value: defaultServerAccessToken);

    //get device provision status
    var deviceProvider = Provider.of<DeviceProvider>(ctx, listen: false);
    var device = deviceProvider.devices
        .firstWhere((d) => d.advertisementData.aid.toString() == deviceId);

    int provisionStatus = device.advertisementData.pst;

    //token used to authorize the device
    String? authenticationToken;

    if (provisionStatus < 3) {
      //set to use default auth token
      authenticationToken = defaultServerAccessToken;
    } else {
      //get device access token from secure storage
      String? serverAccessToken = await storage.read(key: 'D_$deviceId');

      //set to use device access token
      authenticationToken = serverAccessToken;
    }

    //get time in epoch format
    DateTime now = DateTime.now();
    var epochTime =
        now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

    //add system uptime and auth token to their respective property objects
    PropertyObj epochProperty =
        PropertyObj.propertyObj('dcfg', 'cut', epochTime);
    PropertyObj satProperty =
        PropertyObj.propertyObj('dfu', 'sat', authenticationToken);

    if (authenticationToken != null) {
      //write uptime and token to device
      await writeToCharacteristic(ctx, device.device!, epochProperty).then(
          (_) async =>
              await writeToCharacteristic(ctx, device.device!, satProperty));
    } else {
      if (kDebugMode) {
        print('Authentication Token is null');
      }
    }

    //hide loading dialog
    AlertWidgets.hideLoading(ctx);
  }

  ///read characteristic
  Future readCharacteristic(Resource resource) async {
    late String data;

    //check if resource has read rights
    if (resource.properties.read) {
      List<int> value = await resource.characteristic.read();
      if (value.isNotEmpty) {
        data = cbor.decode(value).toString();
      } else {
        data = "No data available.";
      }
    }

    return data;
  }

  ///write to characteristic
  Future writeToCharacteristic<bool>(BuildContext context,
      BluetoothDevice device, PropertyObj property) async {
    //get characteristic uuid with descriptor name
    String? characteristicUuid =
        BleServices().getCharacteristicUuid(context, property.descriptorName);

    //mapping the key and value from the property object to cbor
    final input = CborValue({
      property.key: property.value,
    });

    //encoding the cbor to bytes
    final bytes = cbor.encode(input);

    List<BluetoothService>? services = await device.discoverServices();
    for (BluetoothService service in services) {
      List<BluetoothCharacteristic> characteristics = service.characteristics;
      for (BluetoothCharacteristic characteristic in characteristics) {
        if (characteristic.uuid.toString() == characteristicUuid) {
          try {
            if (characteristic.properties.write) {
              await characteristic.write(bytes);
              return true;
            }
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
            return false;
          }
          continue;
        }
      }
    }
  }

  ///get characteristic uuid
  String? getCharacteristicUuid(BuildContext ctx, String descriptorName) {
    var deviceProvider = Provider.of<DeviceProvider>(ctx, listen: false);
    String? uuid;
    for (var resource in deviceProvider.deviceResources) {
      if (resource.descriptorName == descriptorName ||
          resource.descriptorName
                  .substring(0, resource.descriptorName.length - 1) ==
              descriptorName) {
        uuid = resource.uuid;
      }
    }

    return uuid;
  }
}
