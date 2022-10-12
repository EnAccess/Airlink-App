import 'dart:collection';

import 'package:airlink/models/resource_model.dart';
import 'package:flutter/material.dart';

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

  void removeAllDevices() {
    _devices.clear();
    // notifyListeners();
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
    // notifyListeners();
  }

}