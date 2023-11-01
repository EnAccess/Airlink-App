import 'package:airlink/features/device/data/models/advertisement_packet_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/helper_functions.dart';
import '../../data/models/device_model.dart';

class BLEDeviceTile extends StatefulWidget {
  const BLEDeviceTile({Key? key, required this.model, required this.onTap})
      : super(key: key);

  final DeviceModel model;
  final VoidCallback onTap;

  @override
  State<BLEDeviceTile> createState() => _BLEDeviceTileState();
}

class _BLEDeviceTileState extends State<BLEDeviceTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4.0,
        left: 12.0,
        right: 12.0,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => {
          showAdvertData(
              context,
              AdvertisementPacketModel.fromEntity(
                  widget.model.advertisementPacket))
        },
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.model.advertisementPacket.did.toString(),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.model.device.platformName,),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        widget.model.advertisementPacket.mac.toString(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAdvertData(BuildContext context, AdvertisementPacketModel advertisementPacket) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        int swVer = advertisementPacket.fv;
        int swVerMajor = swVer >> 8;
        int swVerMinor = swVer & 0xff;

        String firmwareVersion = '$swVerMajor.$swVerMinor';

        var daysRemaining = formatDuration(
            duration: Duration(seconds: advertisementPacket.cr));

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(vertical: 24.0),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              'Advertisement Data',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      ListTile(
                        leading: const Text('Device Serial Number'),
                        trailing: Text(advertisementPacket.did.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Device ID'),
                        trailing: Text(advertisementPacket.mac.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Resource version'),
                        trailing: Text(advertisementPacket.rv.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Fault status'),
                        trailing: Text(advertisementPacket.ft.toString()),
                        dense: true,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Text('Provision status'),
                        trailing: Text(advertisementPacket.pst.toString()),
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
                        trailing: Text(advertisementPacket.pu.toString()),
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
                          child: const Text('Ok'),
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
