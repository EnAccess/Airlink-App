import 'dart:convert';

import 'package:airlink/models/property_object_model.dart';
import 'package:airlink/widgets/AlertWidgets.dart';
import 'package:airlink/widgets/widgets.dart';
import 'package:cbor/cbor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../models/resource_model.dart';
import '../models/descriptors_model.dart';
import '../provider/device_provider.dart';

class BleServices {
  // Future<bool> writeToProperty(BluetoothDevice device,
  //     String descriptorNameAndKey, dynamic value) async {
  //   bool isComplete = false;
  //   bool write = true;
  //   String descriptorName = descriptorNameAndKey
  //       .substring(0, descriptorNameAndKey.indexOf("_"))
  //       .toLowerCase();
  //   String descriptorKey = descriptorNameAndKey
  //       .substring(descriptorNameAndKey.indexOf("_") + 1)
  //       .toLowerCase();
  //
  //   final input = CborValue({descriptorKey: value, descriptorKey: value});
  //   final bytes = cbor.encode(input);
  //
  //   await bleFunctions(device, write, descriptorName, bytes)
  //       .whenComplete(() => isComplete = true);
  //
  //   return isComplete;
  // }

  // Future<void> bleFunctions(BluetoothDevice device, bool write,
  //     String descriptorName, List<int> bytes) async {
  //   List<BluetoothService> services = await device.discoverServices();
  //   for (var service in services) {
  //     // Reads all characteristics
  //     var characteristics = service.characteristics;
  //     for (BluetoothCharacteristic c in characteristics) {
  //       // Reads all descriptors
  //       var descriptors = c.descriptors;
  //       for (BluetoothDescriptor d in descriptors) {
  //         //read all descriptors
  //         try {
  //           List<int> value = await d.read();
  //           var descName = const AsciiDecoder().convert(value);
  //           if (write) {
  //             descName = descName.substring(0, descName.length - 1);
  //
  //             if (descriptorName == descName.toString()) {
  //               //write bytes to characteristic
  //               if (c.properties.write) {
  //                 await c.write(bytes);
  //               } else {
  //                 if (kDebugMode) {
  //                   print(
  //                       'Cannot perform READ operations on this characteristic.');
  //                 }
  //               }
  //             }
  //           }
  //         } catch (e) {
  //           print('Descriptor Read Error: $e');
  //         }
  //       }
  //     }
  //   }
  // }

  ///Authorize device
  Future authorizeDevice(BuildContext ctx, String deviceId) async {

    //show loading widget
    AlertWidgets.showLoading(ctx, 'Loading...', 'Authorizing device, please wait.');

    //TODO: change the default SAT below on production app
    String defaultServerAccessToken = '92WwT5ZYXtKuUtZrJZAs';

    //save default access token to secure storage
    const storage = FlutterSecureStorage();
    storage.write(key: 'defaultServerAccessToken', value: defaultServerAccessToken);

    //get device provision status
    var deviceProvider = Provider.of<DeviceProvider>(ctx, listen: false);
    var resource = deviceProvider.devices.firstWhere((e) => e.did.toString() == deviceId);

    int provisionStatus = resource.pst;

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
    var epochTime = now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

    //add system uptime and auth token to their respective property objects
    PropertyObj epochProperty = PropertyObj.propertyObj('dcfg', 'cut', epochTime);
    PropertyObj satProperty = PropertyObj.propertyObj('dfu', 'sat', authenticationToken);

    if(authenticationToken != null) {
      //write uptime and token to device
      await writeToCharacteristic(ctx, resource.device!, epochProperty).then((value) async => await writeToCharacteristic(ctx, resource.device!, satProperty));
    }
    else {
      print('Authentication Token is null');
    }

    //hide loading dialog
    AlertWidgets.hideLoading(ctx);

  }

  ///write to characteristic
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
  Future writeToCharacteristic<bool>(BuildContext context, BluetoothDevice device, PropertyObj property) async {

    //get characteristic uuid with descriptor name
    String characteristicUuid = BleServices().getCharacteristicUuid(context, property.descriptorName);

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
  String getCharacteristicUuid(BuildContext ctx, String descriptorName) {

    var deviceProvider = Provider.of<DeviceProvider>(ctx, listen: false);

    var resource = deviceProvider.deviceResources.firstWhere((e) => e.descriptorName.toUpperCase() == descriptorName.toUpperCase());

    return resource.uuid;
  }

}
