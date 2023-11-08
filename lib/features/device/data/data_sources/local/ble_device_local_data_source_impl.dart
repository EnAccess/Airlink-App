import 'dart:convert';

import 'package:airlink/core/bluetooth/bluetooth_info.dart';
import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/core/location/location_info.dart';
import 'package:airlink/core/utils/constants/characteristic_uuids.dart';
import 'package:airlink/features/device/data/data_sources/local/ble_device_local_data_source.dart';
import 'package:airlink/features/device/data/models/advertisement_packet_model.dart';
import 'package:airlink/features/device/data/models/characteristic_model.dart';
import 'package:cbor/cbor.dart';
import 'package:cbor/simple.dart' as simple_cbor;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';

import '../../../../../core/device_info/device_info.dart';
import '../../../../../core/storage/storage.dart';
import '../../../../../core/utils/helper_functions.dart';
import '../../models/device_model.dart';
import '../../models/provisioned_device_model.dart';

class BLEDeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final BluetoothInfo bluetoothInfo;

  final LocationInfo locationInfo;

  final SecureStorage secureStorage;

  final DeviceInfo deviceInfo;

  BLEDeviceLocalDataSourceImpl({
    required this.bluetoothInfo,
    required this.locationInfo,
    required this.secureStorage,
    required this.deviceInfo,
  });

  //get the references to the storage boxes
  final _telemetryBox = Hive.box('telemetry');
  final _attributesBox = Hive.box('attributes');
  final _profileBox = Hive.box('profiles');

  //list of BLE devices
  final List<DeviceModel> _bleDevices = [];

  //ble device model
  DeviceModel? _deviceModel;

  //device authorization status
  bool _isAuthorized = false;

  @override
  Future<DeviceModel> connectToDevice(DeviceModel deviceModel) async {
    if (await bluetoothInfo.isAvailable) {
      try {
        late DeviceModel device;
        List<BluetoothService> services = [];
        List<BluetoothCharacteristic> characteristics = [];
        List<CharacteristicModel> characteristicModels = [];

        // connect to device
        await deviceModel.device
            .connect(autoConnect: false)
            .catchError((error) async {
          deviceModel.device.disconnect();
        });

        // discover services
        services = await deviceModel.device.discoverServices();

        // discover characteristics and descriptors
        for (var service in services) {
          for (var c in service.characteristics) {
            //skip generic characteristics
            if (c.uuid.toString().startsWith('00002a')) {
              continue;
            } else {
              //get the descriptors

              for (BluetoothDescriptor d in c.descriptors) {
                //read the descriptor
                List<int> bytes = await d.read();

                //convert the bytes to string
                String value = const AsciiDecoder().convert(bytes);

                //descriptors value contain an unknown char at the end so removing it
                if (value.isNotEmpty) {
                  value = value.substring(0, value.length - 1);
                }

                //enable indication for the descriptor
                if (d.uuid.toString() !=
                    '00002901-0000-1000-8000-00805f9b34fb') {
                  await d.write([02, 00]);
                  continue;
                }

                //create characteristic model
                CharacteristicModel characteristicModel = CharacteristicModel(
                  characteristic: c,
                  descriptorName: value,
                );

                //add characteristic model to list
                characteristicModels.add(characteristicModel);
              }

              //add characteristic to list
              characteristics.add(c);
            }
          }
        }

        //ble device model
        device = DeviceModel(
          device: deviceModel.device,
          advertisementPacket: deviceModel.advertisementPacket,
          characteristics: characteristicModels,
        );

        _deviceModel = device;

        //return ble device
        return device;
      } catch (e) {
        throw const BLEDeviceFailure(message: 'Failed to connect to device');
      }
    } else {
      throw const BLEDeviceFailure(message: 'Bluetooth is disabled');
    }
  }

  @override
  Future<void> disconnectDevice(DeviceModel deviceModel) async {
    try {
      deviceModel.device.disconnect();
      _isAuthorized = false;
    } catch (e) {
      throw const BLEDeviceFailure(message: 'Failed to disconnect device');
    }
  }

  @override
  Future<List<DeviceModel>> getBLEDevices() async {

    if (await bluetoothInfo.isAvailable &&
        await bluetoothInfo.isScannable &&
        await locationInfo.isEnabled) {
      try {
        //get location data
        final locationResult = await locationInfo.getLocation();

        //start scanning for BLE devices
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

        // Listen to scan results
        FlutterBluePlus.scanResults.listen((results) async {
          // do something with scan results
          for (ScanResult r in results) {
            Map<int, List<int>> manufacturerData =
                r.advertisementData.manufacturerData;

            try {
              List<int> data =
                  Uint8List.fromList(manufacturerData.values.first);
              List<Object?> advertisementData;
              advertisementData =
                  simple_cbor.cbor.decode(data) as List<Object?>;

              //advertisement data model
              AdvertisementPacketModel advertisementPacketModel =
                  AdvertisementPacketModel(
                mac: r.device.remoteId.str,
                rv: advertisementData[0],
                ft: advertisementData[1],
                did: int.parse(advertisementData[2].toString()),
                gts: advertisementData[3],
                pst: advertisementData[4],
                fv: advertisementData[5],
                cr: advertisementData[6],
                pu: advertisementData[7],
                gid: manufacturerData.keys.first.toString(),
                gmid: manufacturerData.keys.first.toString(),
                lt: locationResult?.latitude.toStringAsFixed(5),
                ln: locationResult?.longitude.toStringAsFixed(5),
                la: locationResult?.accuracy.toStringAsFixed(2),
                dss: r.rssi,
                s1: -60,
              );

              //ble device model
              DeviceModel deviceModel = DeviceModel(
                device: r.device,
                advertisementPacket:
                    AdvertisementPacketModel.toEntity(advertisementPacketModel),
              );

              //add ble device to list
              int existingDeviceIndex = _bleDevices.indexWhere(
                  (ble) => ble.device.remoteId.str == deviceModel.device.remoteId.str);

              if (existingDeviceIndex != -1) {
                // Replace the existing device with the new device
                _bleDevices[existingDeviceIndex] = deviceModel;
              } else {
                // Add the new device to the list
                _bleDevices.add(deviceModel);
              }
            } catch (e) {
              // if (kDebugMode) {
              //   print(e);
              // }
              continue;
            }
          }
        });

        //save advertisement data
        for(var device in _bleDevices) {
          await saveAdvertisementData(AdvertisementPacketModel.fromEntity(device.advertisementPacket));
        }

        //return list of BLE devices
        return _bleDevices;
      } catch (e) {
        throw const BLEDeviceFailure(message: 'Failed to get BLE devices');
      }
    } else {
      throw const BLEDeviceFailure(
          message: 'Bluetooth or Location is disabled');
    }
  }

  @override
  Future<void> authorizeDevice(DeviceModel deviceModel) async {
    try {
      //get time in epoch format
      DateTime now = DateTime.now();
      var epochTime =
          now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

      //read the device provision status
      int provisionStatus = deviceModel.advertisementPacket.pst;

      //pst 1 means device is not provisioned and not serialized
      //pst 2 means device is not provisioned but serialized
      //pst 3+ means device is provisioned and serialized

      //if device is not provisioned, use a default access token to authorize
      String? accessToken;
      if (provisionStatus < 3) {
        //get android device id
        final androidDeviceId = await deviceInfo.androidDeviceId;
        //get the access token
        accessToken =  _profileBox.get(androidDeviceId)['defaultAccessToken'];
      } else {
        //get device access token
        accessToken = await secureStorage
            .get('${deviceModel.advertisementPacket.did}_access_token');
      }

      if (accessToken != null) {
        //write access token to device
        await writeCharacteristic(
          CharacteristicUUID.dfu,
          {'sat': accessToken},
        );

        _isAuthorized = true;

        //write time to device
        await writeCharacteristic(
          CharacteristicUUID.dcfg,
          {'cut': epochTime},
        );
      } else {
        throw const BLEDeviceFailure(message: 'No access token found');
      }
    } catch (e) {
      throw BLEDeviceFailure(message: e.toString());
    }
  }

  @override
  Future<String> readCharacteristic(String characteristicUUID) async {
    if (_deviceModel == null) {
      throw const BLEDeviceFailure(message: 'Device not connected');
    }
    if (_isAuthorized || characteristicUUID == CharacteristicUUID.dfu) {
      try {
        for (var c in _deviceModel!.characteristics) {
          if (c.characteristic.uuid.toString() == characteristicUUID) {
            List<int> value = await c.characteristic.read();
            return cbor.decode(value).toString();
          }
        }
        throw const BLEDeviceFailure(message: 'Characteristic not found');
      } catch (e) {
        throw const BLEDeviceFailure(message: 'Failed to read characteristic');
      }
    } else {
      throw const BLEDeviceFailure(message: 'Device not authorized');
    }
  }

  @override
  Future<void> writeCharacteristic(
      String characteristicUUID, Map<String, dynamic> data) async {
    if (_deviceModel == null) {
      throw const BLEDeviceFailure(message: 'Device not connected');
    }
    if (_isAuthorized || characteristicUUID == CharacteristicUUID.dfu) {
      try {
        //mapping the key and value from the property object to cbor
        final input = CborValue(data);

        //encoding the cbor to bytes
        final bytes = cbor.encode(input);

        // print data to be written
        if (kDebugMode) {
          print(const CborJsonEncoder().convert(input));
        }

        //write to the characteristic
        for (var c in _deviceModel!.characteristics) {
          if (c.characteristic.uuid.toString() == characteristicUUID) {
            if (c.characteristic.properties.write) {
              await c.characteristic.write(bytes, allowLongWrite: true);
            }
          }
        }
      } catch (e) {
        throw BLEDeviceFailure(message: e.toString());
      }
    } else {
      throw const BLEDeviceFailure(message: 'Device not authorized');
    }
  }

  @override
  Future<void> serializeDevice(
      ProvisionedDeviceModel provisionedDeviceModel) async {
    if (_deviceModel == null) {
      throw const BLEDeviceFailure(message: 'Device not connected');
    }
    if (_isAuthorized) {
      try {
        int provisionStatus = _deviceModel!.advertisementPacket.pst;
        if (provisionStatus > 2) {
          throw const BLEDeviceFailure(message: 'Device already provisioned');
        } else {
          //convert the hex string of the serverSecret into bytes
          List<int> deviceSecret =
              hex.decode(provisionedDeviceModel.deviceSecret);

          //device serial number
          int dNumber = provisionedDeviceModel.deviceSerialNumber;

          //get device access token
          final accessToken =
              await secureStorage.get('${dNumber}_access_token');

          if (accessToken == null) {
            throw const BLEDeviceFailure(message: 'No access token found');
          }

          await writeCharacteristic(
            CharacteristicUUID.dcfg,
            {
              'dsc': CborBytes(deviceSecret),
              'did': dNumber,
              'sat': accessToken
            },
          );
        }
      } catch (e) {
        throw const BLEDeviceFailure(message: 'Failed to serialize device');
      }
    } else {
      throw const BLEDeviceFailure(message: 'Device not authorized');
    }
  }

  @override
  Future<String?> getDeviceAccessToken(DeviceModel bleDevice) async {
    try {
      //device serial number
      final dNumber = bleDevice.advertisementPacket.did;

      //get device access token
      String? accessToken = await secureStorage.get('${dNumber}_access_token');

      return accessToken;
    } catch (e) {
      throw const StorageFailure(message: 'Failed to get device access token');
    }
  }

  @override
  Future<void> transferToken(String payGToken) async {
    if (_isAuthorized) {
      try {
        //get current time in unix format
        var epochTime = DateTime.now().millisecondsSinceEpoch ~/
            Duration.millisecondsPerSecond;
        String token = payGToken.replaceAll(' ', '');

        //write the payG token(tkn) and current local time(lt) to device
        await writeCharacteristic(
          CharacteristicUUID.pc,
          {'tkn': token, 'lt': epochTime},
        );
      } catch (e) {
        throw const BLEDeviceFailure(message: 'Failed to transfer token');
      }
    } else {
      throw const BLEDeviceFailure(message: 'Device not authorized');
    }
  }

  @override
  Future<void> pushDeviceData(List dataList) async {
    if (_deviceModel == null) {
      throw const BLEDeviceFailure(message: 'Device not connected');
    }
    try {

      if (dataList.isNotEmpty) {
        for (Map data in dataList) {
          //get key
          String key = data['key'];

          //get the name (descriptor's) before the underscore
          List<String> parts = key.split('_');
          String descName = parts.first.toLowerCase();

          //get the name after the underscore
          String propKey = parts.last.toLowerCase();

          late dynamic value;

          //get value
          if (propKey == 'tkn') {
            //if it's the payg token, remove the spaces between
            value = data['value'].toString().replaceAll(' ', '');
          } else {
            value = data['value'];
          }

          switch (descName) {
            case 'pc':
              await writeCharacteristic(
                CharacteristicUUID.pc,
                {propKey: value},
              );
              break;
            case 'dcfg':
              await writeCharacteristic(
                CharacteristicUUID.dcfg,
                {propKey: value},
              );
              break;
            case 'ccfg':
              await writeCharacteristic(
                CharacteristicUUID.ccfg,
                {propKey: value},
              );
              break;
            case 'temp':
              await writeCharacteristic(
                CharacteristicUUID.temp,
                {propKey: value},
              );
              break;
          }
        }
      } else {
        throw const CacheFailure(message: 'No data available');
      }
    } catch (e) {
      throw const BLEDeviceFailure(message: 'Failed to push data');
    }
  }

  @override
  Future<void> saveDeviceData(String deviceName, List<dynamic> data) async {
    try {
      _attributesBox.put(deviceName, data);
    } catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<void> saveAdvertisementData(AdvertisementPacketModel ad) async {
    try {
      _telemetryBox.put('advt_${ad.did}', ad.toMap());
    }
    catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<List> getDeviceTimeseriesData(String deviceName) async {
    try {
      List dataList = await _telemetryBox.get(deviceName);
      return dataList;
    }
    catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<List> readDeviceTimeseriesData() async {
    if (_deviceModel == null) {
      throw const BLEDeviceFailure(message: 'Device not connected');
    }

    if (_isAuthorized) {
      try {
        List dataList = [];
        //read all data from the ble device
        for (var c in _deviceModel!.characteristics) {
          //read characteristic data
          List<int> value = await c.characteristic.read();

          if (value.isNotEmpty) {
            //convert bytes to cbor to json
            var jsonString = json.encode(cbor.decode(value)).toString();

            //decode json and convert it to map
            var res = jsonDecode(jsonString) as Map;

            if (res.containsKey('thi')) {
              int thiValue;
              //read the same characteristic until the 'thi' value is 0. Implying all data is read
              do {
                //read characteristic data
                List<int> bytes = await c.characteristic.read();
                //convert bytes to cbor to json
                var tsJsonString = json.encode(cbor.decode(bytes)).toString();
                //decode the json
                var tsDecodedResult = await json.decode(tsJsonString);
                //get the 'thi' value (timeseries index)
                thiValue = int.parse(json.encode(tsDecodedResult['thi']));
                //get the 'ts' value (timestamp)
                BigInt tsValue =
                    BigInt.parse(json.encode(tsDecodedResult['ts'])) *
                        (BigInt.parse(1000.toString()));
                //prepare the data to be posted to the server
                String tsJsonData = prepend(tsJsonString, c.descriptorName);
                final data =
                    '{"ts": ${int.parse(tsValue.toString())}, "values": $tsJsonData}';

                // if (thiValue != 0) {
                dataList.add(data);
                // }
              } while (thiValue > 0);
            } else {
              String notTimeSeriesJsonData =
              prepend(jsonString, c.descriptorName);
              //add to List
              dataList.add(notTimeSeriesJsonData);
            }
          }
        }

        return Future.value(dataList);
      } catch (e) {
        throw BLEDeviceFailure(message: e.toString());
      }
    } else {
      throw const BLEDeviceFailure(message: 'Device not authorized');
    }
  }

  @override
  Future<void> saveDeviceTimeseriesData(String deviceName, List data) async {
    try {
      //save data to local storage
      _telemetryBox.put(deviceName, data);
    } catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }

  @override
  Future<List>? getDeviceDataFromLocalStorage(String deviceName) async {
    try {
      List? dataList = await _attributesBox.get(deviceName);
      return dataList ?? [];
    }
    catch (e) {
      throw CacheFailure(message: e.toString());
    }
  }
}
