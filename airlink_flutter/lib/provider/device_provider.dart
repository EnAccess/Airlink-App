import 'dart:collection';

import 'package:airlink/models/resource_model.dart';
import 'package:flutter/foundation.dart';

import '../models/device_model.dart';

class DeviceProvider extends ChangeNotifier {
  final List<Device> _devices = [];

  UnmodifiableListView<Device> get devices => UnmodifiableListView(_devices);

  void addDevice(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  void removeDevice(Device device) {
    _devices.remove(device);
    notifyListeners();
  }

  void removeAllDevices() async {
    _devices.clear();
    notifyListeners();
    print('removeAllDevices()');
  }

  final List<Resource> _deviceResources = [];

  UnmodifiableListView<Resource> get deviceResources => UnmodifiableListView(_deviceResources);

  void addResource(Resource r) {
    _deviceResources.add(r);
    notifyListeners();
  }
  void removeResource(Resource r) {
    _deviceResources.remove(r);
    notifyListeners();
  }
  void removeAllResources() {
    _deviceResources.clear();
    notifyListeners();
    print('removeAllResources()');
  }

  //device resource data
  final List<Map<String, String>> _resourceData = [];

  UnmodifiableListView<Map<String, String>> get resourceData =>
      UnmodifiableListView(_resourceData);

  void addResourceData(Map<String, String> resourceData) {
    _resourceData.add(resourceData);
    notifyListeners();
  }

  void removeResourceData(Map<String, String> resourceData) {
    _resourceData.remove(resourceData);
    notifyListeners();
  }

  void removeAllResourceData() {
    _resourceData.clear();
    notifyListeners();
    print('removeAllResourceData()');
  }

  void updateResourceData(Map<String, String> map) {
    for (var entry in map.entries) {
      if (kDebugMode) {
        print('UPDATED: ${entry.key} -> ${entry.value}');
      }

      for (var data in _resourceData) {
        if (data.containsKey(entry.key)) {
          data.update(entry.key, (dynamic value) => entry.value);
        }
      }
    }

    notifyListeners();
  }

}