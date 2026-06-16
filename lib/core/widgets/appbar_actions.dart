import 'package:airlink/features/device/presentation/providers/device_provider.dart';
import 'package:flutter/material.dart';

class AppbarActions extends StatelessWidget {
  const AppbarActions({super.key, required this.deviceProvider});

  final DeviceProvider deviceProvider;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      onSelected: (String result) async {
        if (result == 'postAdvtData') {
          //post advt data
          deviceProvider.postAdvertData(context: context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'postAdvtData',
          child: Text('Post Advt Data'),
        ),
      ],
    );
  }
}
