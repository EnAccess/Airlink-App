import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class BluetoothInfo {
  /// Checks adapter availability
  Future<bool> get isAvailable;

  Future<bool> get isScannable;
}

class BluetoothInfoImpl implements BluetoothInfo {
  @override
  Future<bool> get isAvailable async =>
      await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;

  @override
  Future<bool> get isScannable async {
    bool bcs = false;
    bool bss = false;

    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    var bluetoothScanStatus = await Permission.bluetoothScan.status;

    if (!bluetoothConnectStatus.isGranted) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      if (await Permission.bluetoothConnect.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        bcs = true;
      }
    } else if (bluetoothConnectStatus.isGranted) {
      bcs = true;
    }

    if (!bluetoothScanStatus.isGranted) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      if (await Permission.bluetoothScan.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        bss = true;
      }
    } else if (bluetoothScanStatus.isGranted) {
      bss = true;
    }

    return bcs && bss;
  }
}
