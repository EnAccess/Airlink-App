import 'package:airlink/features/device/presentation/providers/device_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../../data/models/device_model.dart';
import '../widgets/device_data.dart';

class DeviceDetailsPage extends StatefulWidget {
  const DeviceDetailsPage({super.key, required this.model});

  final DeviceModel model;

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  late Future connectToDevice;

  @override
  void initState() {
    super.initState();
    connectToDevice = _connectToDevice();
  }

  Future _connectToDevice() async {
    try {
      //connect to device
      await Provider.of<DeviceProvider>(context, listen: false)
          .connectToDevice(context: context, device: widget.model);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //disconnect from device
        await Provider.of<DeviceProvider>(context, listen: false)
            .disconnectDevice(context: context, device: widget.model);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.model.advertisementPacket.did.toString()),
        ),
        body: SafeArea(
          child: FutureBuilder(
              future: connectToDevice,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Consumer<DeviceProvider>(
                      builder: (context, deviceProvider, _) {
                    final connectedDevice = deviceProvider.connectedDevice;
                    if (connectedDevice != null) {
                      return StreamBuilder<BluetoothConnectionState>(
                          stream: connectedDevice.device.connectionState,
                          initialData: BluetoothConnectionState.connected,
                          builder: (context, state) {
                            if (state.data ==
                                BluetoothConnectionState.connected) {
                              return DeviceData(
                                  connectedDevice: connectedDevice);
                            } else {
                              return const Center(
                                  child: Text('Device disconnected'));
                            }
                          });
                    } else {
                      return const Center(child: Text('No device connected'));
                    }
                  });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }
}
