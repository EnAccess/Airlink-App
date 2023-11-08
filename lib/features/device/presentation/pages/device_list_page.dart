import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/device_model.dart';
import '../providers/device_provider.dart';
import '../widgets/ble_device_tile.dart';
import '../widgets/search_field.dart';
import 'device_details_page.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchField(deviceProvider: deviceProvider),
        ),
        FutureBuilder(
          future: deviceProvider.getDevices(context: context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Expanded(
              child: Consumer<DeviceProvider>(
                builder: (context, deviceProvider, _) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await deviceProvider.clearDevices().then(
                          (_) => deviceProvider.getDevices(context: context));
                    },
                    child: ListView.builder(
                      itemCount: deviceProvider.devices.length,
                      itemBuilder: (context, index) {
                        final bleDevice = deviceProvider.devices[index];
                        return BLEDeviceTile(
                            model: bleDevice,
                            onTap: () => _navigateToDetailsPage(
                                context: context, model: bleDevice));
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _navigateToDetailsPage({
    required BuildContext context,
    required DeviceModel model,
  }) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailsPage(model: model),
      ),
    );
  }
}
