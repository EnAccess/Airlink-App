import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/token_device_provider.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final tokenProvider =
        Provider.of<TokenDeviceProvider>(context, listen: false);

    return Column(
      children: [
        SearchBar(
          controller: _searchController,
          onChanged: (deviceName) {
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              tokenProvider.getDeviceSuggestions(
                  context: context, deviceName: deviceName);
            });
            setState(() {});
          },
          leading: Container(
            margin: const EdgeInsets.only(left: 10.0),
            child: const Icon(Icons.search),
          ),
          trailing: [
            _searchController.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      tokenProvider.clearToken();
                      tokenProvider.clearSelectedDevice();
                      setState(() {});
                    },
                  ),
          ],
          hintText: 'Search by name',
          onSubmitted: (deviceName) {
            tokenProvider.getDeviceSuggestions(
                context: context, deviceName: deviceName);
          },
        ),
        Expanded(
          child: Consumer<TokenDeviceProvider>(
            builder: (context, tokenProvider, _) {
              if (_searchController.text.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Start typing to search',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (tokenProvider.filteredSuggestions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No devices found'),
                );
              } else {
                return Column(children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: tokenProvider.filteredSuggestions.length,
                      itemBuilder: (context, index) {
                        final d = tokenProvider.filteredSuggestions[index];
                        return ListTile(
                          title: Text(d.name),
                          subtitle: Text(d.paygType),
                          onTap: () {
                            tokenProvider.setSelectedDevice(d);
                            tokenProvider.clearToken();
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ]);
              }
            },
          ),
        ),
      ],
    );
  }
}
