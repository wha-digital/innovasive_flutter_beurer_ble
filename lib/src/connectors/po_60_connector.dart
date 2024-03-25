import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:innovasive_flutter_beurer_ble/src/models/po_60_measurement_data.dart';

import '../models/beurer_device.dart';
import '../utils/checksum_for.dart';
import '../utils/logger.dart';
import '../utils/value_at.dart';

enum PO60Command {
  setTime,
  getTime,
  getDeviceVersion,
  getMeasurementData,
  deleteAllMeasurementData;

  @override
  toString() => name;
}

class PO60Connector extends BeurerDevice {
  PO60Connector(super.bluetoothDevice);

  BluetoothService? _service;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;

  PO60Command? _lastCommand;

  Completer<bool>? _setTime;
  Completer<List<String>>? _getDeviceVersion;
  Completer<DateTime>? _getTimeCompleter;
  Completer<List<PO60MeasurementData>>? _getMeasurementData;

  StreamSubscription<List<int>>? _listener;

  List<int> measurementDataList = [];

  Timer? _getMeasurementDataDebounce;
  Timer? _debounce;

  Future<void> listen() async {
    llog('🔵 Listening to $nameWithId');

    await setServicesAndCharacteristic();

    _lastCommand = null;
    _notifyCharacteristic?.setNotifyValue(true);

    _listener ??= _notifyCharacteristic?.lastValueStream.listen((event) {
      if (_lastCommand == PO60Command.getDeviceVersion) _onGetDeviceVersion(event);
      if (_lastCommand == PO60Command.setTime) _onSetTime(event);
      if (_lastCommand == PO60Command.getTime) _onGetTime(event);
      if (_lastCommand == PO60Command.getMeasurementData) _onGetMeasurementData(event);
    });

    await Future.delayed(const Duration(seconds: 1)); // must delay to make sure its listening.

    llog('🟢 Listened to $nameWithId');
  }

  Future<void> stopListen() async {
    llog('🔵 Stoping listening to $nameWithId');
    _listener?.cancel();
    llog('🔴 Stopped listen to $nameWithId');
  }

  @override
  Future<void> setServicesAndCharacteristic() async {
    llog('🔵 Prepare Services & Characteristic for $nameWithId');

    final services = await bluetoothDevice.discoverServices();
    _service = services.firstWhere((element) => element.uuid.toString() == '0000ff12-0000-1000-8000-00805f9b34fb');

    _writeCharacteristic = _service!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '0000ff01-0000-1000-8000-00805f9b34fb';
    });

    _notifyCharacteristic = _service!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '0000ff02-0000-1000-8000-00805f9b34fb';
    });

    llog('🟢 Services & Characteristic for $nameWithId is prepared.');
  }

  /// Send value to device
  ///
  void _write(List<int> value) {
    _writeCharacteristic?.write(value);
  }

  /// Set device time
  ///
  Future<bool> setTime(DateTime dateTime) {
    llog('🔵 Send [setTime] to $nameWithId');

    _setTime = Completer<bool>();
    _lastCommand = PO60Command.setTime;

    final year = int.parse(dateTime.year.toString().substring(2, 4));
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final second = dateTime.second;

    final values = [0x83, year, month, day, hour, minute, second, 0, 0];
    final checksum = checksumFor(values);

    _write([...values, checksum]);

    return _setTime!.future;
  }

  ///
  ///
  void _onSetTime(List<int> event) {
    final success = event[1] == 0;

    llog('🟢 Result for [setTime] from $nameWithId is ${success ? 'Success' : 'Failed'}');

    _setTime?.complete(success);
  }

  /// Get current device time.
  ///
  Future<DateTime> getTime() {
    llog('🔵 Send [getTime] to $nameWithId');

    _getTimeCompleter = Completer<DateTime>();

    _lastCommand = PO60Command.getTime;
    _write([0x89, 0x09]);

    return _getTimeCompleter!.future;
  }

  ///
  ///
  void _onGetTime(List<int> event) {
    final year = 2000 + event[1];
    final month = event[2];
    final day = event[3];
    final hour = event[4];
    final minute = event[5];
    final second = event[6];

    final dateTime = DateTime(year, month, day, hour, minute, second);

    llog('🟢 Result for [getTime] from $nameWithId is ${dateTime.toString()}');

    _getTimeCompleter?.complete(dateTime);
  }

  /// Get device hardware and software version.
  ///
  Future<List<String>> getDeviceVersion() {
    llog('🔵 Send [getDeviceVersion] to $nameWithId');

    _getDeviceVersion = Completer<List<String>>();

    _lastCommand = PO60Command.getDeviceVersion;
    _write([0x82, 0x02]);

    return _getDeviceVersion!.future;
  }

  ///
  ///
  void _onGetDeviceVersion(List<int> event) {
    final hardwareVersion = '${event[3]}.${event[2]}.${event[1]}';
    final softwareVersion = '${event[6]}.${event[5]}.${event[4]}';

    llog('🟢 Result for [getDeviceVersion] from $nameWithId is');
    llog('Hardware version: $hardwareVersion');
    llog('Software version: $softwareVersion');

    _getDeviceVersion?.complete([hardwareVersion, softwareVersion]);
  }

  /// Get all measurement data store in device.
  ///
  Future<List<PO60MeasurementData>> getMeasurementData() {
    llog('🔵 Send [getMeasurementData] to $nameWithId');

    measurementDataList = [];
    _getMeasurementData = Completer<List<PO60MeasurementData>>();

    _lastCommand = PO60Command.getMeasurementData;
    _write([0x99, 0x00, 0x19]);

    // when data on device is empty, it's not response to listener we need to set this timeout.
    _getMeasurementDataDebounce = Timer(const Duration(seconds: 2), () async {
      llog('🟢 Result for [getMeasurementData] from $nameWithId is empty');
      if (!_getMeasurementData!.isCompleted) _getMeasurementData!.complete([]);
      return;
    });

    return _getMeasurementData!.future;
  }

  ///
  ///
  void _onGetMeasurementData(List<int> event) {
    measurementDataList.addAll(event);

    if (_getMeasurementDataDebounce?.isActive ?? false) _getMeasurementDataDebounce?.cancel();
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!_getMeasurementData!.isCompleted) {
        if (measurementDataList.isEmpty) {
          llog('🟢 Result for [getMeasurementData] from $nameWithId is empty');
          _getMeasurementData!.complete([]);
          return;
        }

        final chuckedList = measurementDataList.chunked(24).toList();
        final results = <PO60MeasurementData>[];

        for (final d in chuckedList) {
          final start = DateTime(2000 + valueAt(d, 2), valueAt(d, 3), valueAt(d, 4), valueAt(d, 5), valueAt(d, 6), valueAt(d, 7));
          final end = DateTime(2000 + valueAt(d, 8), valueAt(d, 9), valueAt(d, 1), valueAt(d, 1), valueAt(d, 1), valueAt(d, 1));

          final data = PO60MeasurementData(
            start: start,
            end: end,
            storageTimePeriod: valueAt(d, 15) + valueAt(d, 16),
            sp02Max: valueAt(d, 17),
            sp02Min: valueAt(d, 18),
            sp02Avg: valueAt(d, 19),
            prMax: valueAt(d, 20),
            prMin: valueAt(d, 21),
            prAvg: valueAt(d, 22),
          );

          results.add(data);
        }

        llog('🟢 Result for [getMeasurementData] from $nameWithId is');

        for (final r in results) {
          llog(r.toMap());
        }

        _getMeasurementData!.complete(results);
      }
    });

    if (measurementDataList.length % 240 == 0) {
      _getNextMeasurementData();
    }
  }

  ///
  ///
  void _getNextMeasurementData() {
    final values = [0x99, 0x01];
    final checksum = checksumFor(values);

    _write([...values, checksum]);
  }

  ///
  ///
  void deleteAllMeasurementData() {
    llog('🔵 Send [deleteAllMeasurementData] to $nameWithId');

    _lastCommand = PO60Command.deleteAllMeasurementData;

    final values = [0x99, 127];
    final checksum = checksumFor(values);

    _write([...values, checksum]);
  }
}
