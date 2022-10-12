import 'dart:convert';

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
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
     CREATE TABLE $tableDeviceData (
     ${DeviceDataFields.name} $textType,
     ${DeviceDataFields.id} $textType,
     ${DeviceDataFields.rssi} $textType,
     ${DeviceDataFields.rv} $integerType,
     ${DeviceDataFields.ft} $integerType,
     ${DeviceDataFields.did} $integerType,
     ${DeviceDataFields.gts} $textType,
     ${DeviceDataFields.pst} $integerType,
     ${DeviceDataFields.fv} $integerType, 
     ${DeviceDataFields.cr} $integerType,
     ${DeviceDataFields.pu} $textType
     )
     ''');

    await db.execute('''
     CREATE TABLE $tableTimeSeries (
     ${TimeSeriesFields.did} $textType,
     ${TimeSeriesFields.json} $textType
     )
     ''');

  }

  Future<Device> create(Device device) async {
    final db = await instance.database;
    final id = await db.insert(tableDeviceData, device.toJson());
    return device.copy(did: id);
  }

  Future<Device?> readDevice(int did) async {
    final db = await instance.database;
    final maps = await db.query(
      tableDeviceData,
      columns: DeviceDataFields.values,
      where: '${DeviceDataFields.did} = ?',
      whereArgs: [did],
    );

    if (maps.isNotEmpty) {
      return Device.fromJson(maps.first);
    } else {
      print('Device Id: $did not found.');
      return null;
    }
  }

  Future<int> update(Device device) async {
    final db = await instance.database;

    return db.update(
      tableDeviceData,
      device.toJson(),
      where: '${DeviceDataFields.did} = ?',
      whereArgs: [device.did],
    );
  }

  Future<int> delete(int did) async {
    final db = await instance.database;
    return await db.delete(
      tableDeviceData,
      where: '${DeviceDataFields.did} = ?',
      whereArgs: [did],
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
        print('Device Id: $did not found.');
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
