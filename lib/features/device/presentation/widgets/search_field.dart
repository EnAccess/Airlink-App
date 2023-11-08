import 'package:airlink/features/device/presentation/providers/device_provider.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.deviceProvider,
  });

  final DeviceProvider deviceProvider;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: deviceProvider.searchController,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon: deviceProvider.searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close,
                ),
                onPressed: () {
                  deviceProvider.filterDevice('');
                  deviceProvider.searchController.clear();
                },
              )
            : null,
        hintText: 'Search by name, S/N or MAC',
      ),
      onChanged: (value) => {
        deviceProvider.filterDevice(value),
      },
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
