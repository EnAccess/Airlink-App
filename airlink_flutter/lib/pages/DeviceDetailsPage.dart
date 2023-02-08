import 'dart:convert';
import 'package:airlink/constants/constants.dart';
import 'package:airlink/models/timeseries_model.dart';
import 'package:airlink/widgets/AlertWidgets.dart';
import 'package:cbor/cbor.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;
import 'package:airlink/models/device_model.dart';
import 'package:airlink/services/BleServices.dart';
import 'package:airlink/utils/generate_server_secret.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:airlink/db/advertisement_database.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/api_response/get_attributes_by_scope_response.dart';
import '../models/api_response/provision_response_model.dart';
import '../models/api_response/server_response.dart';
import '../models/property_object_model.dart';
import '../provider/device_provider.dart';
import '../services/AirLinkServer.dart';
import '../utils/prepend_data.dart';
import '../widgets/widgets.dart';

class DeviceDetailsPage extends StatefulWidget {
  final Device? device;

  const DeviceDetailsPage({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  _DeviceDetailsPageState createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  String deviceSerialNumber = '';
  String authToken = '';
  String paygToken = '';
  late Future _loadDeviceConfigsFuture;

  TextEditingController authController = TextEditingController();
  TextEditingController barcodeScanResController = TextEditingController();

  final GlobalKey<FormState> _snFormKey = GlobalKey<FormState>();

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadDeviceConfigsFuture = loadDeviceConfigs();
  }

  @override
  Widget build(BuildContext context) {
    widget.device?.device!.connect(autoConnect: false);

    return WillPopScope(
      onWillPop: () async {
        widget.device?.device!.disconnect();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.device?.device?.name}'),
          actions: [
            StreamBuilder<BluetoothDeviceState>(
                stream: widget.device?.device!.state,
                initialData: BluetoothDeviceState.disconnected,
                builder: (c, snapshot) {
                  if (snapshot.data == BluetoothDeviceState.connected) {
                    return IconButton(
                      onPressed: () {},
                      icon: const Icon(LineIcons.dotCircle),
                      color: Colors.green,
                    );
                  } else {
                    return IconButton(
                      onPressed: () {},
                      icon: const Icon(LineIcons.dotCircle),
                      color: Colors.red,
                    );
                  }
                }),
          ],
        ),
        body: FutureBuilder(
          future: _loadDeviceConfigsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _deviceDetails();
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _deviceDetails() {
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 15,
        ),
        padding: const EdgeInsets.all(15.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 33,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.device!.advertisementData.aid.toString(),
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 33,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: style,
                          onPressed: () async => _syncDeviceData(),
                          child: const Text('Sync'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 33,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: style,
                          onPressed: () async {
                            int pst = widget.device!.advertisementData.pst;

                            //check if the device is already provisioned
                            if (pst <= 2) {
                              //show serialization dialog
                              return showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _showSerializationDialog(),
                              );
                            } else {
                              AlertWidgets.showAlert(context, AlertStatus.info,
                                  'Info!', 'Device is already provisioned.');
                            }
                          },
                          child: const Text('Provision'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 33,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Access Token"),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 33,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: authController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'auth',
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 33,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: style,
                          onPressed: () async {
                            //authorize device
                            await BleServices().authorizeDevice(
                                context,
                                widget.device!.advertisementData.aid
                                    .toString());
                          },
                          child: const Text('Authorize'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      flex: 33,
                      child: Column(
                        children: const [
                          SizedBox(
                            width: 0.01,
                          ),
                        ],
                      )),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 66,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: style,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => _showPaygDialog());
                          },
                          child: const Text('Enter PayG Token'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "Resources",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder<BluetoothDeviceState>(
            stream: widget.device?.device!.state,
            initialData: BluetoothDeviceState.disconnected,
            builder: (c, snapshot) {
              if (snapshot.data == BluetoothDeviceState.connected) {
                return Property(
                  bluetoothDevice: widget.device?.device,
                  context: context,
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ],
    );
  }

  Widget _showSerializationDialog() {
    return SimpleDialog(
      title: const Text(
        'Device not serialized. Select your choice for serialization.',
        style: TextStyle(fontSize: 18.0),
      ),
      children: <Widget>[
        const SizedBox(
          height: 5.0,
        ),
        SimpleDialogOption(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          onPressed: () async {
            //dismiss previous dialog
            Navigator.pop(context);

            //show dialog to scan barcode
            showDialog(
                context: context,
                builder: (context) => _showBarcodeScannerDialog());

            //begin barcode scanning process
            scanBarcode();
          },
          child: const Text('Scan barcode', style: TextStyle(fontSize: 16.0)),
        ),
        SimpleDialogOption(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          onPressed: () {
            //dismiss previous dialog
            Navigator.pop(context);

            //show dialog to enter serial number
            showDialog(
                context: context,
                builder: (context) => _showManualInputDialog());
          },
          child: const Text('Type serial number',
              style: TextStyle(fontSize: 16.0)),
        ),
      ],
    );
  }

  Widget _showBarcodeScannerDialog() {
    return Form(
      key: _snFormKey,
      child: AlertDialog(
        title: const Text('Confirm device serial number'),
        content: TextFormField(
          controller: barcodeScanResController,
          maxLength: 10,
          decoration: const InputDecoration(hintText: "Eg.800021"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              //dismiss previous dialog
              Navigator.pop(context);

              String did = barcodeScanResController.text;

              //provision device
              await doProvisioning(did);
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  Widget _showManualInputDialog() {
    return Form(
      key: _snFormKey,
      child: AlertDialog(
        title: const Text('Enter serial number'),
        content: TextFormField(
          maxLength: 10,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'A serial number is required';
            } else if (value.length < 5) {
              return 'Must be 5-10 characters';
            }
            return null;
          },
          onChanged: (value) {
            deviceSerialNumber = value;
          },
          decoration: const InputDecoration(hintText: "Eg.800021"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              //if the input is valid
              if (_snFormKey.currentState!.validate()) {
                //dismiss previous dialog
                Navigator.pop(context);

                //provision device with the serial number provided  by the user
                await doProvisioning(deviceSerialNumber);
              }
            },
            child: const Text('ENTER'),
          ),
        ],
      ),
    );
  }

  loadAuthTkn() async {
    final authTkn = await storage.read(
            key: 'D_${widget.device?.advertisementData.aid.toString()}') ??
        '';
    setState(() {
      authController.text = authTkn;
    });
  }

  doProvisioning(String deviceID) async {
    //show loading widget
    AlertWidgets.showLoading(
        context, 'Loading...', 'Provisioning device, please wait.');

    //provision device with the serial number provided  by the user
    http.Response response =
        await AirLinkServer().provisionDevice(deviceID, 'device');

    if (response.statusCode == 200) {
      //save device UUID to secure storage
      final provisionResponse = provisionResponseFromJson(response.body);
      await storage.write(key: 'deviceUUID', value: provisionResponse.id.id);

      //write the device access token, device id and server secret to the device
      await writeValuesToDevice(deviceID);

      AlertWidgets.hideLoading(context);
      AlertWidgets.showAlert(context, AlertStatus.success, 'Success!',
          'Device provisioned successfully');
    } else {
      final serverResponse = serverResponseFromJson(response.body);
      AlertWidgets.hideLoading(context);
      AlertWidgets.showAlert(
          context, AlertStatus.error, 'Error!', serverResponse.message);
    }
  }

  scanBarcode() async {
    String barcodeScanRes;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, barcode.ScanMode.BARCODE);

      barcodeScanResController.text = barcodeScanRes;

      if (kDebugMode) {
        print(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  writeValuesToDevice(String deviceID) async {
    //get device access token to write it to device
    String deviceAccessToken =
        await storage.read(key: 'deviceAccessToken') ?? '';

    //display auth token (sat) to its field
    if (deviceAccessToken.isNotEmpty) {
      await storage.write(key: 'D_$deviceID', value: deviceAccessToken);
      authController.text = deviceAccessToken;
    }

    //write the serial number(did) and server access token(sat) to device
    PropertyObj didProperty =
        PropertyObj.propertyObj('dcfg', 'did', int.parse(deviceID));
    PropertyObj satProperty =
        PropertyObj.propertyObj('dcfg', 'sat', deviceAccessToken);

    BluetoothDevice? bluetoothDevice = widget.device?.device;

    await BleServices()
        .writeToCharacteristic(context, bluetoothDevice!, didProperty)
        .then((_) async => await BleServices()
            .writeToCharacteristic(context, bluetoothDevice, satProperty));

    //get serverSecret and write it to device
    String serverSecret = ServerSecretGenerator.generateSecret();

    //convert the hex string of the serverSecret into bytes
    List<int> deviceSecret = hex.decode(serverSecret);

    //create a property structure
    PropertyObj deviceSecretProperty =
        PropertyObj.propertyObj('dcfg', 'dsc', CborBytes(deviceSecret));

    //write device secret to device
    await BleServices()
        .writeToCharacteristic(context, bluetoothDevice, deviceSecretProperty);

    //post to server on device shared attributes
    await postDeviceServerAttributes(deviceAccessToken, serverSecret);
  }

  postDeviceServerAttributes(String sat, secret) async {
    //json string to write to server attributes
    final attributes = jsonEncode({
      'device_secret': secret,
      'msg_id': 0,
      'device_sat': sat,
      'PAYG_Type': 'AirLink'
    });

    final deviceUUID = await storage.read(key: 'deviceUUID') ?? '';

    //post to server side attributes
    http.Response response = await AirLinkServer().saveEntityAttributes(
        'DEVICE', deviceUUID, Scope.SERVER_SCOPE, attributes);

    //should be null if successful posted
    if (kDebugMode) {
      print('response body: ${response.body}');
    }
  }

  _syncDeviceData() async {
    //check if device is provisioned
    if (widget.device?.advertisementData.pst > 2) {
      //show loading widget
      AlertWidgets.showLoading(
          context, 'Loading...', 'Syncing device data, please wait.');

      //post device data to server
      await postDeviceDataToServer();

      //get data from server and write to the device
      await getDeviceDataFromServer();

      //show success message
      if (mounted) {
        AlertWidgets.hideLoading(context);
      }
      AlertWidgets.showAlert(context, AlertStatus.success, 'Success!',
          'Device data synced successfully');
    } else {
      AlertWidgets.showAlert(
          context, AlertStatus.error, 'Error', 'Device not provisioned');
    }
  }

  getDeviceDataFromServer() async {
    //get device uuid
    var deviceUUID = await AirLinkServer()
        .getTenantDevice(widget.device!.advertisementData.aid.toString());

    //fetch all shared attributes from the server
    http.Response response = await AirLinkServer()
        .getAttributesByScope('DEVICE', deviceUUID, 'SHARED_SCOPE');
    final sharedAttributes = getAttributeByScopeResponseFromJson(response.body);

    for (var attribute in sharedAttributes) {
      //get descriptor name and key
      String descriptorName =
          attribute.key.substring(0, attribute.key.indexOf('_')).toLowerCase();
      String descriptorKey =
          attribute.key.substring(attribute.key.indexOf('_') + 1).toLowerCase();

      //remove white spaces from the token
      if (descriptorKey.toLowerCase() == 'tkn') {
        attribute.value = attribute.value.toString().replaceAll(' ', '');
      }

      //create a property object
      PropertyObj obj = PropertyObj.propertyObj(
          descriptorName, descriptorKey, attribute.value);

      //write data from server to device
      BluetoothDevice? bluetoothDevice = widget.device?.device;
      try {
        await BleServices()
            .writeToCharacteristic(context, bluetoothDevice!, obj);
      } catch (e) {
        if (kDebugMode) {
          print('error: $e');
        }
      }
    }
  }

  postDeviceDataToServer() async {
    //get timeseries data
    List<String> timeseriesData = await getTimeseriesDataFromDevice();

    //add timeseries data to timeseries data model
    TimeSeriesData timeSeriesData = TimeSeriesData(
        did: widget.device!.advertisementData.aid,
        json: timeseriesData.toString());

    //check if the device exists in the DB
    var data =
        await DeviceDatabase.instance.readTimeSeriesData(timeSeriesData.did);
    if (data != null) {
      //device exists - update it's data
      await DeviceDatabase.instance.updateTimeSeriesData(timeSeriesData);
    } else {
      //device does not exist - add it to the DB
      TimeSeriesData data =
          await DeviceDatabase.instance.createTimeSeriesData(timeSeriesData);
      if (kDebugMode) {
        print('Timeseries data added: ${data.did.toString()}');
      }
    }

    //read new data in the DB
    var result = await DeviceDatabase.instance
        .readTimeSeriesData(widget.device!.advertisementData.aid);
    if (result != null) {
      //get device UUID
      var deviceUUID = await AirLinkServer()
          .getTenantDevice(widget.device!.advertisementData.aid.toString());

      //post data to telemetry section on server
      http.Response response = await AirLinkServer()
          .sendDataToTelemetry('DEVICE', deviceUUID, result.json);

      //delete the data once it is successfully posted
      if (response.statusCode == 200) {
        await DeviceDatabase.instance
            .deleteTimeSeriesData(int.parse(result.did));
      } else {
        if (kDebugMode) {
          print(response.body);
        }
      }
    } else {
      if (kDebugMode) {
        print('No data available in DB');
      }
    }
  }

  getTimeseriesDataFromDevice() async {
    var timeSeriesData = <String>[];

    //get all device resources
    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    for (var resource in deviceProvider.deviceResources) {
      try {
        //if resource has read rights
        if (resource.properties.read) {
          //read characteristic data
          List<int> value = await resource.characteristic.read();

          if (value.isNotEmpty) {
            //convert bytes to cbor to json
            var jsonString = json.encode(cbor.decode(value)).toString();
            // var decodedResult = await json.decode(jsonString);
            //decode json and convert it to map
            var res = jsonDecode(jsonString) as Map;

            //check if the resource is a timeseries. timeseries data contain a 'thi' key in the JSON
            if (res.containsKey('thi')) {
              int thiValue;
              //read the same characteristic until the 'thi' value is 0. Implying all data is read
              do {
                //read characteristic data
                List<int> bytes = await resource.characteristic.read();
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
                String tsJsonData = PrependData()
                    .prepend(tsJsonString, resource.descriptorName);
                final data =
                    '{"ts": ${int.parse(tsValue.toString())}, "values": $tsJsonData}';

                // if (thiValue != 0) {
                timeSeriesData.add(data);
                // }
              } while (thiValue > 0);
            } else {
              String notTimeSeriesJsonData =
                  PrependData().prepend(jsonString, resource.descriptorName);
              //add to List
              timeSeriesData.add(notTimeSeriesJsonData);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    return timeSeriesData;
  }

  Widget _showPaygDialog() {
    return Form(
      key: _snFormKey,
      child: AlertDialog(
        title: const Text('Enter your token'),
        content: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'PayG token is required.';
            } else if (value.length < 4 || value.length > 16) {
              return 'PayG token is invalid.';
            }
            return null;
          },
          onChanged: (value) {
            paygToken = value.replaceAll(' ', '');
          },
          decoration: const InputDecoration(hintText: "*59979149319443#"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async => await _enterPaygToken(),
            child: const Text('ENTER'),
          ),
        ],
      ),
    );
  }

  _enterPaygToken() async {
    //if the input is valid
    if (_snFormKey.currentState!.validate()) {
      //hide the dialog
      Navigator.pop(context);

      //show loading dialog
      AlertWidgets.showLoading(
          context, 'Loading...', 'Sending token to device, please wait.');

      //get current time in unix format
      DateTime now = DateTime.now();
      var epochTime =
          now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

      //property objects for data to be written to device
      PropertyObj epochObj = PropertyObj.propertyObj('pc', 'lt', epochTime);
      PropertyObj tknObj = PropertyObj.propertyObj('pc', 'tkn', paygToken);

      //write the payG token(tkn) and current local time(lt) to device
      BluetoothDevice? bluetoothDevice = widget.device?.device;
      try {
        await BleServices()
            .writeToCharacteristic(context, bluetoothDevice!, epochObj)
            .then((value) async => await BleServices()
                .writeToCharacteristic(context, bluetoothDevice, tknObj));
      } catch (e) {
        if (kDebugMode) {
          print('error: $e');
        }
      }

      AlertWidgets.hideLoading(context);
      AlertWidgets.showAlert(
          context, AlertStatus.success, 'Success!', 'Token sent successfully.');
    }
    // _snFormKey.currentState!.save();
  }

  Future loadDeviceConfigs() async {
    //load authentication token
    loadAuthTkn();
  }
}
