import 'dart:convert';

import 'package:airlink/pages/DeviceDetailsPage.dart';
import 'package:airlink/provider/device_provider.dart';
import 'package:airlink/widgets/AlertWidgets.dart';
import 'package:app_settings/app_settings.dart';
import 'package:cbor/simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../models/resource_model.dart';
import '../models/device_model.dart';
import '../services/BleServices.dart';

class DeviceAlert extends StatelessWidget {
  const DeviceAlert(
      {Key? key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.action})
      : super(key: key);

  final IconData icon;
  final String title;
  final String subtitle;
  final AlertAction action;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 80.0,
          color: Colors.redAccent.withOpacity(0.3),
          child: ListTile(
            leading: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13.0,
              ),
            ),
            trailing: SizedBox(
              width: 90.0,
              child: Builder(builder: (context) {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size.fromHeight(32.0),
                    ),
                  ),
                  onPressed: () {
                    openSettings(action);
                  },
                  child: const Text(
                    'Turn on',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }),
            ),
            onTap: () {
              openSettings(action);
            },
          ),
        ),
        const Divider(
          height: 0,
          color: Colors.white,
        ),
      ],
    );
  }

  openSettings(AlertAction action) async {
    switch (action) {
      case AlertAction.bluetooth:
        // open bluetooth settings
        AppSettings.openBluetoothSettings();

        break;
      case AlertAction.location:
        // open location settings.
        AppSettings.openLocationSettings();
        break;
    }
  }
}

class DeviceTile extends StatelessWidget {
  const DeviceTile({Key? key, required this.device}) : super(key: key);

  final Device device;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DeviceDetailsPage(
                model: device,
              ),
            ),
          ),
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.did.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 30.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      device.id.toString(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Property extends StatelessWidget {
  const Property(
      {Key? key, required this.bluetoothDevice, required this.context})
      : super(key: key);

  final BluetoothDevice? bluetoothDevice;
  final BuildContext context;

  Future loadProperties() async {
    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    //clear resources on model
    deviceProvider.removeAllResources();

    late Resource resource;

    List<BluetoothService>? services =
        await bluetoothDevice?.discoverServices();

    for (var service in services!) {
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        // Reads all descriptors
        var descriptors = c.descriptors;
        for (BluetoothDescriptor d in descriptors) {
          List<int> value = await d.read();
          var descName = const AsciiDecoder().convert(value);
          if (descName.isNotEmpty) {
            descName = descName.substring(0, descName.length - 1);
          }
          if (d.uuid.toString() != '00002901-0000-1000-8000-00805f9b34fb') {
            await d.write([02, 00]);
            continue;
          }

          //add characteristic data to it's respective model
          resource = Resource(
            characteristic: c,
            uuid: c.uuid.toString(),
            deviceId: c.deviceId.toString(),
            descriptors: c.descriptors,
            descriptorName: descName,
            properties: c.properties,
            serviceUuid: c.serviceUuid.toString(),
          );

          deviceProvider.addResource(resource);
          
          //check if list contains the characteristic
          // if (deviceProvider.deviceResources
          //     .where((element) => element.descriptorName == descName)
          //     .isEmpty) {
          //   deviceProvider.addResource(resource);
          // }

          //check if characteristics data are to be sent to the server
          // if (postToServer) {
          //   //read only characteristics that are readable i.e read=true
          //   if (c.properties.read) {
          //     List<int> characteristicsValue = await c.read();
          //     //check if the read value contains data
          //     if (characteristicsValue.isNotEmpty) {
          //       try {
          //         //create a json string format from the read data
          //         var jsonString =
          //         json.encode(cbor.decode(characteristicsValue)).toString();
          //         var decodedResult = await json.decode(jsonString);
          //
          //         var res = jsonDecode(jsonString) as Map;
          //
          //         if (res.containsKey('thi')) {
          //
          //           int thiValue;
          //
          //           do {
          //             List<int> bytes = await c.read();
          //             var tsJsonString =
          //             json.encode(cbor.decode(bytes)).toString();
          //
          //             var tsDecodedResult = await json.decode(tsJsonString);
          //
          //             thiValue = int.parse(json.encode(tsDecodedResult['thi']));
          //
          //             BigInt tsValue =
          //                 BigInt.parse(json.encode(tsDecodedResult['ts'])) *
          //                     (BigInt.parse(1000.toString()));
          //
          //             String tsJsonData =
          //             PrependData().prepend(tsJsonString, descName);
          //
          //             final data =
          //                 '{"ts": ${int.parse(tsValue.toString())}, "values": $tsJsonData}';
          //
          //             if (thiValue != 0) {
          //               timeSeriesData.add(data);
          //             }
          //           } while (thiValue > 0);
          //         } else {
          //           //if the data does not contain the key 'thi', it is not a time series history data
          //           String notTimeSeriesJsonData =
          //           PrependData().prepend(jsonString, descName);
          //           //add to List
          //           timeSeriesData.add(notTimeSeriesJsonData);
          //         }
          //       } catch (e) {
          //         if (kDebugMode) {
          //           print(e);
          //         }
          //       }
          //
          //       // print(characteristicsValue);
          //     }
          //
          //     // var hexString = hex.encode(characteristicsValue);
          //     // print(hexString);
          //
          //   }
          // }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Consumer<DeviceProvider>(
            builder: (context, deviceProvider, child) {
              return Expanded(
                child: ListView.builder(
                  itemCount: deviceProvider.deviceResources.length,
                  itemBuilder: (context, index) {
                    return ResourceTile(
                        resource: deviceProvider.deviceResources[index]);
                  },
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class ResourceTile extends StatelessWidget {
  const ResourceTile({Key? key, required this.resource}) : super(key: key);

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 15,
        ),
        padding: const EdgeInsets.all(15.0));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: () async {
          //read descriptor
          String data  = await BleServices().readCharacteristic(resource);

          //display descriptor data in a dialog
          AlertWidgets.showAlert(
              context, AlertStatus.info, resource.descriptorName, data);
        },
        child: Text(resource.descriptorName.toUpperCase()),
      ),
    );
  }
}
