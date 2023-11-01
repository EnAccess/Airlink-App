import 'dart:async';
import 'dart:typed_data';
import 'package:airlink/constants/constants.dart';
import 'package:airlink/services/BackgroudService.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:airlink/db/advertisement_database.dart';
import 'package:cbor/simple.dart' as simple_cbor;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/advertisement_packet_model.dart';
import '../models/device_model.dart';
import '../provider/device_provider.dart';
import '../services/LocationService.dart';
import '../widgets/widgets.dart';
import 'DeviceDetailsPage.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final storage = const FlutterSecureStorage();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late Future deviceFuture;
  BluetoothDevice? device;
  late Device deviceItem;

  @override
  void initState() {
    super.initState();
    deviceFuture = scanForBle();
  }

  @override
  void dispose() {
    super.dispose();
    flutterBlue.stopScan();
  }

  Future scanForBle() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var androidInfo = await deviceInfo.androidInfo;

    int? androidVersion = androidInfo.version.sdkInt;
    // print('android version: $androidVersion');
    if (androidVersion! > 30) {
      //request bluetooth permission
      bool isPermitted = await _requestBluetoothPermission();

      if (isPermitted) {
        //scan for ble devices
        await _scanForBleDevices();
      }
    } else {
      //scan for ble devices
      await _scanForBleDevices();
    }
  }

  //scan for ble devices
  _scanForBleDevices() async {
    //latitude, longitude and location accuracy
    String lt = '';
    String ln = '';
    String la = '';

    //enable location services and get lat, long, and accuracy
    LocationData locationData =
        await LocationService.getLocation().timeout(const Duration(seconds: 5));

    lt = locationData.latitude.toString();
    ln = locationData.longitude.toString();
    la = locationData.accuracy.toString();

    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    //clear device list
    deviceProvider.removeAllDevices();
    deviceProvider.removeAllResourceData();

    //start scan for available devices
    flutterBlue.startScan(
        timeout: const Duration(seconds: 4), allowDuplicates: false);

    FlutterBlue.instance.scanResults.listen((results) async {
      for (ScanResult r in results) {
        Map<int, List<int>> manufacturerData =
            r.advertisementData.manufacturerData;

        try {
          List<int> data = Uint8List.fromList(manufacturerData.values.first);
          List<Object?> advertisementData;
          advertisementData = simple_cbor.cbor.decode(data) as List<Object?>;

          AdvertisementPacket advertData = AdvertisementPacket(
            mac: r.device.id.toString(),
            rv: advertisementData[0],
            ft: advertisementData[1],
            aid: advertisementData[2],
            gts: advertisementData[3],
            pst: advertisementData[4],
            fv: advertisementData[5],
            cr: advertisementData[6],
            pu: advertisementData[7],
            gid: manufacturerData.keys.first.toString(),
            gmid: manufacturerData.keys.first.toString(),
            lt: lt,
            ln: ln,
            la: la,
            dss: r.rssi.toString(),
            s1: '',
          );

          //adds data to model
          deviceItem = Device(
              device: r.device,
              name: r.device.name,
              advertisementData: advertData);

          //add device to list if it does not exist
          if (deviceProvider.devices
              .where((device) =>
                  device.advertisementData.aid.toString() ==
                  advertisementData[2].toString())
              .isEmpty) {
            //add device to list
            deviceProvider.addDevice(deviceItem);
          }
        } catch (e) {
          if (kDebugMode) {
            //print(e);
          }
          continue;
        }
      }
    });
    flutterBlue.stopScan();

    //delay stream to allow for data to be added to list
    Future.delayed(const Duration(seconds: 4), () {
      //save advert data to database
      saveDeviceToDatabase(deviceProvider.devices);
    });
  }

  Future refreshPage() async {
    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    //clear device list
    deviceProvider.removeAllDevices();
    deviceProvider.removeAllResourceData();

    scanForBle();
  }

  Future saveDeviceToDatabase(List<Device> devices) async {
    if (devices.isNotEmpty) {
      //save device data to database
      for (Device device in devices) {
        var data = await DeviceDatabase.instance
            .readDevice(device.advertisementData.aid.toString());
        if (data != null) {
          //device exists - update it.
          if (kDebugMode) {
            print(
                'device ${device.advertisementData.aid} exists! - updating it');
          }
          await DeviceDatabase.instance.updateDevice(device);
        } else {
          //device does not exist - create a new one
          if (kDebugMode) {
            print(
                'device ${device.advertisementData.aid} does not exist! - creating a new one');
          }
          await DeviceDatabase.instance.createDevice(device);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //todo: remove this
    //     ElevatedButton(onPressed: () async {
    //       await BackgroundService().postAdvertisementData();
    //
    // }, child: const Text('test')),

        StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.off) {
                return const DeviceAlert(
                    icon: Icons.bluetooth_disabled,
                    title: 'Bluetooth is Off',
                    subtitle: 'Turn on bluetooth to see nearby devices',
                    action: AlertAction.bluetooth);
              }
              return const SizedBox.shrink();
            }),
        Expanded(
          child: Consumer<DeviceProvider>(
            builder: (context, deviceProvider, child) {
              return RefreshIndicator(
                onRefresh: refreshPage,
                child: ListView(
                  children: [
                    deviceProvider.devices.isNotEmpty
                        ? ListView.builder(
                            itemCount: deviceProvider.devices.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return DeviceTile(
                                device: deviceProvider.devices[index],
                                onTap: () async {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DeviceDetailsPage(
                                                  device: deviceProvider
                                                      .devices[index]),
                                        ),
                                      )
                                      .then((_) => setState(() {
                                            refreshPage();
                                          }));
                                },
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _requestBluetoothPermission() async {
    bool bcs = false;
    bool bss = false;

    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    var bluetoothScanStatus = await Permission.bluetoothScan.status;

    if (!bluetoothConnectStatus.isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        bcs = true;
      }
    } else if (bluetoothConnectStatus.isGranted) {
      bcs = true;
    }

    if (!bluetoothScanStatus.isGranted) {
      if (await Permission.bluetoothScan.request().isGranted) {
        bss = true;
      }
    } else if (bluetoothScanStatus.isGranted) {
      bss = true;
    }

    return bcs && bss;
  }
}
