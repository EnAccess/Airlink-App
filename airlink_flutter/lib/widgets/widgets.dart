import 'dart:async';
import 'dart:convert';

import 'package:airlink/provider/device_provider.dart';
import 'package:airlink/widgets/AlertWidgets.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../models/resource_model.dart';
import '../models/device_model.dart';
import '../pages/DeviceDetailsPage.dart';
import '../services/BleServices.dart';
import '../utils/format_duration.dart';

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

class DeviceTile extends StatefulWidget {
  const DeviceTile({Key? key, required this.device, required this.onTap}) : super(key: key);

  final Device device;
  final VoidCallback onTap;

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {

  @override
  Widget build(BuildContext context) {

    // int swVer = widget.device.advertisementData.fv;
    // int swVerMajor = swVer >> 8;
    // int swVerMinor = swVer & 0xff;
    //
    // String firmwareVersion = '$swVerMajor.$swVerMinor';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => {
          showAdvertData(context, widget.device)
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.advertisementData.aid.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 30.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.device.advertisementData.mac.toString(),
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

  showAdvertData(BuildContext context, Device device) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {

        int swVer = device.advertisementData.fv;
        int swVerMajor = swVer >> 8;
        int swVerMinor = swVer & 0xff;

        String firmwareVersion = '$swVerMajor.$swVerMinor';

        var daysRemaining = FormatDuration.format(context, Duration(seconds: device.advertisementData.cr));

        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(vertical: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: const [
                            SizedBox(height: 4.0,),
                            Text('Advertisement Data', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      ListTile(
                        leading: const Text('Device name'),
                        trailing: Text(device.device!.name),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Bluetooth device type'),
                        trailing: Text(device.device!.type.name),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Device Serial Number'),
                        trailing: Text(device.advertisementData.aid.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Device ID'),
                        trailing: Text(device.advertisementData.mac.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Resource version'),
                        trailing: Text(device.advertisementData.rv.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Fault status'),
                        trailing: Text(device.advertisementData.ft.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Provision status'),
                        trailing: Text(device.advertisementData.pst.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Firmware version'),
                        trailing: Text(firmwareVersion),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Device credit'),
                        trailing: Text(daysRemaining.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('PayG Unit'),
                        trailing: Text(device.advertisementData.pu.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: 125.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child:  const Text('Ok'),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

    final mtu = await bluetoothDevice?.mtu.first;
    if (kDebugMode) {
      print('mtu: $mtu');
    }
    await bluetoothDevice?.requestMtu(200);

    final mtuChanged = Completer<void>();
    final mtuStreamSubscription = bluetoothDevice?.mtu.listen((mtu) {
      if (mtu == 200) mtuChanged.complete();
    });
    await mtuChanged.future.timeout(const Duration(seconds: 2)).catchError(
            (dynamic error) =>
            debugPrint(error.toString())); // set timeout and catch exception
    mtuStreamSubscription?.cancel();

    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    //clear resources on model
    deviceProvider.removeAllResources();

    late Resource resource;

    List<BluetoothService>? services = await bluetoothDevice?.discoverServices();

    for (var service in services!) {
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        // Reads all descriptors
        var descriptors = c.descriptors;
        for (BluetoothDescriptor d in descriptors) {
          List<int> value = await d.read();
          var descName = const AsciiDecoder().convert(value);

          // if (descName.isNotEmpty) {
          //   descName = descName.substring(0, descName.length - 1);
          // }

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


