import 'package:airlink/models/device_model.dart';
import 'package:airlink/models/timeseries_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DeviceDatabase {
  static final DeviceDatabase instance = DeviceDatabase._init();

  static Database? _database;

  DeviceDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('airlink.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT NULL';
    //const integerType = 'INTEGER NOT NULL';

    await db.execute('''
     CREATE TABLE $tableDeviceData (
     ${DeviceDataFields.id} $idType,
     ${DeviceDataFields.name} $textType, 
     ${DeviceDataFields.mac} $nullableTextType,
     ${DeviceDataFields.rv} $nullableTextType,
     ${DeviceDataFields.ft} $nullableTextType,
     ${DeviceDataFields.aid} $nullableTextType,
     ${DeviceDataFields.gts} $nullableTextType,
     ${DeviceDataFields.pst} $nullableTextType,
     ${DeviceDataFields.fv} $nullableTextType,
     ${DeviceDataFields.cr} $nullableTextType,
     ${DeviceDataFields.pu} $nullableTextType,
     ${DeviceDataFields.gid} $nullableTextType,
     ${DeviceDataFields.gmid} $nullableTextType,
     ${DeviceDataFields.lt} $nullableTextType,
     ${DeviceDataFields.ln} $nullableTextType,
     ${DeviceDataFields.la} $nullableTextType,
     ${DeviceDataFields.dss} $nullableTextType,
     ${DeviceDataFields.s1} $nullableTextType
     )
     ''');

    await db.execute('''
     CREATE TABLE $tableTimeSeries (
     ${TimeSeriesFields.did} $textType,
     ${TimeSeriesFields.json} $textType
     )
     ''');

  }

  Future<Device> createDevice(Device device) async {
    final db = await instance.database;
    final id = await db.insert(tableDeviceData, device.toJson());
    return device.copy(id: id);
  }

  Future<Device?> readDevice(String deviceId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableDeviceData,
      columns: DeviceDataFields.values,
      where: '${DeviceDataFields.aid} = ?',
      whereArgs: [deviceId],
    );

    if (maps.isNotEmpty) {
      return Device.fromJson(maps.first);
    } else {
      if (kDebugMode) {
        print('Device Id: $deviceId not found.');
      }
      return null;
    }
  }

  Future<int> updateDevice(Device device) async {
    final db = await instance.database;

    return db.update(
      tableDeviceData,
      device.toJson(),
      where: '${DeviceDataFields.id} = ?',
      whereArgs: [device.id],
    );
  }

  Future<int> deleteDevice(String deviceId) async {
    final db = await instance.database;
    return await db.delete(
      tableDeviceData,
      where: '${DeviceDataFields.aid} = ?',
      whereArgs: [deviceId],
    );
  }

  Future<List<Device>> readAllDevices() async {
    final db = await instance.database;
    final result = await db.query(tableDeviceData);
    return result.map((json) => Device.fromJson(json)).toList();
  }

  Future<TimeSeriesData> createTimeSeriesData(TimeSeriesData timeSeriesData) async {
    final db = await instance.database;
    final id = await db.insert(tableTimeSeries, timeSeriesData.toJson());
    return timeSeriesData.copy(id: id);
  }

  Future<TimeSeriesData?> readTimeSeriesData(int did) async {
    final db = await instance.database;
    final maps = await db.query(
      tableTimeSeries,
      columns: TimeSeriesFields.values,
      where: '${TimeSeriesFields.did} = ?',
      whereArgs: [did],
    );

    if (maps.isNotEmpty) {
      return TimeSeriesData.fromJson(maps.first);
    } else {
      if (kDebugMode) {
        print('Timeseries Device Id: $did not found.');
      }
      return null;
    }
  }

  Future<List<TimeSeriesData>> readAllTimeseriesData() async {
    final db = await instance.database;
    final result = await db.query(tableTimeSeries);
    return result.map((json) => TimeSeriesData.fromJson(json)).toList();
  }

  Future<int> updateTimeSeriesData(TimeSeriesData timeSeriesData) async {
    final db = await instance.database;

    return db.update(
      tableTimeSeries,
      timeSeriesData.toJson(),
      where: '${TimeSeriesFields.did} = ?',
      whereArgs: [timeSeriesData.did],
    );
  }

  Future<int> deleteTimeSeriesData(int did) async {
    final db = await instance.database;
    return await db.delete(
      tableTimeSeries,
      where: '${TimeSeriesFields.did} = ?',
      whereArgs: [did],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
