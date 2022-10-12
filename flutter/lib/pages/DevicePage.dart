import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:airlink/constants/constants.dart';
import 'package:cbor/cbor.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:airlink/db/advertisement_database.dart';
import 'package:airlink/services/AirLinkServer.dart';
import 'package:cbor/simple.dart' as simple_cbor;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../provider/device_provider.dart';
import '../services/HttpsEndpoint.dart';
import '../services/LocationService.dart';
import '../widgets/widgets.dart';
import 'DeviceDetailsPage.dart';

// startService() async {
//   //initialize bg/fg service
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeService();
//
//   final service = FlutterBackgroundService();
//   bool isRunning = await service.isRunning();
//   if (!isRunning) {
//     Fluttertoast.showToast(
//         msg: "Foreground service started", toastLength: Toast.LENGTH_LONG);
//     FlutterBackgroundService().sendData({"action": "setAsForeground"});
//   }
// }
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will executed when app is in foreground or background in separated isolate
//       onStart: onStart,
//
//       // auto start service
//       autoStart: true,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       autoStart: true,
//
//       // this will executed when app is in foreground in separated isolate
//       onForeground: onStart,
//
//       // you have to enable background fetch capability on xcode project
//       onBackground: onIosBackground,
//     ),
//   );
// }
//
// // run app from xcode, then from xcode menu, select Simulate Background Fetch
// void onIosBackground() {
//   WidgetsFlutterBinding.ensureInitialized();
// }
//
// void onStart() {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   if (Platform.isAndroid) FlutterBackgroundServiceAndroid.registerWith();
//
//   final service = FlutterBackgroundService();
//   service.onDataReceived.listen((event) {
//     //run as foreground service
//     if (event!["action"] == "setAsForeground") {
//       service.setAsForegroundService();
//       return;
//     }
//
//     //run as background service
//     if (event["action"] == "setAsBackground") {
//       service.setAsBackgroundService();
//     }
//
//     //stop service
//     if (event["action"] == "stopService") {
//       service.stopService();
//     }
//   });
//
//   // bring to foreground.
//   service.setAsForegroundService();
//
//   //TODO: To change notification icon (for bg/fg service), add drawable icon with name ic_bg_service_small
//   service.setNotificationInfo(
//     title: 'BLE foreground service',
//     content: 'Posting advert data to AirLink server.',
//   );
//
//   Timer.periodic(const Duration(seconds: 3), (timer) async {
//     if (!(await service.isRunning())) timer.cancel();
//
//     //function set to execute after every 15minutes (hence 60 x 15)
//     // await AirLinkServer().postAdvertData();
//     print("Posting advert data to AirLink server.");
//   });
// }

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final storage = const FlutterSecureStorage();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late Future deviceFuture;
  List<Device?> devices = [];
  BluetoothDevice? device;
  late Device deviceList;

  // String name = '';
  // String id = '';
  // String rssi = '';

  // dynamic rv = '';
  // dynamic ft = '';
  // dynamic did = '';
  // dynamic gts = '';
  // dynamic pst = '';
  // dynamic fv = '';
  // dynamic cr = '';
  // dynamic pu = '';

  // String lt = '';
  // String ln = '';
  // String la = '';

  @override
  void initState() {
    super.initState();
    deviceFuture = discoverNearbyDevices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future discoverNearbyDevices() async {
    //enable location
    await LocationService.enableLocation();

    bool isScannable = await checkScanStatus();

    //check if bluetooth and location are enabled is enabled
    if (isScannable) {
      //scan for ble devices
      await scanForBle();
    }
  }

  //scan for ble devices
  scanForBle() async {
    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    //clear device list
    deviceProvider.removeAllDevices();

    //start scan for available devices
    flutterBlue.startScan(
        timeout: const Duration(seconds: 4), allowDuplicates: false);

    FlutterBlue.instance.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name.toUpperCase() == "AIRLINK") {
          dynamic advertData = r.advertisementData.manufacturerData;
          try {
            List<int> manufacturerData = Uint8List.fromList(advertData[89]);
            advertData = simple_cbor.cbor.decode(manufacturerData);
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
            continue;
          }

          //adds data to model
          deviceList = Device(
              device: r.device,
              name: r.device.name,
              id: r.device.id.toString(),
              rssi: r.rssi.toString(),
              rv: advertData[0],
              ft: advertData[1],
              did: advertData[2],
              gts: advertData[3],
              pst: advertData[4],
              fv: advertData[5],
              cr: advertData[6],
              pu: advertData[7]);

          //add device to list if it does not exist
          if (deviceProvider.devices
              .where((element) => element.id == deviceList.id)
              .isEmpty) {
            //add device to list
            deviceProvider.addDevice(deviceList);

            //add device to database
            addDeviceToDatabase(advertData[2]);
          }
        }
      }
    });
    flutterBlue.stopScan();
  }

  //add device to database
  addDeviceToDatabase(int did) async {
    //check if the device exists in the database
    var data = await DeviceDatabase.instance.readDevice(did);
    if (data != null) {
      //device exists - update it.
      if (kDebugMode) {
        print('device ${deviceList.did.toString()} exists! - updating it');
      }
      await DeviceDatabase.instance.update(deviceList);
    } else {
      //device does not exist - create a new one
      if (kDebugMode) {
        print(
            'device ${deviceList.did.toString()} does not exist! - creating a new one');
      }
      await DeviceDatabase.instance.create(deviceList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(builder: (context, model, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Text(
              model.devices.isNotEmpty ? 'Nearby devices' : '',
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: deviceFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return RefreshIndicator(
                      onRefresh: discoverNearbyDevices,
                      child: ListView.builder(
                          itemCount: model.devices.length,
                          itemBuilder: (context, index) {
                            Device device = model.devices[index];
                            return DeviceTile(device: device);
                          }),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ],
      );
    });
  }

  Future<bool> checkScanStatus() async {
    bool isBluetoothOn;
    bool isLocationOn;
    Location location = Location();

    if(await location.serviceEnabled()) {
      isLocationOn = true;
    }
    else {
      isLocationOn = false;
    }
    if (await flutterBlue.isOn) {
      isBluetoothOn = true;
    }
    else {
      isBluetoothOn = false;
    }

    if(isLocationOn && isBluetoothOn) {
      return true;
    } else {
      return false;
    }
  }
}
