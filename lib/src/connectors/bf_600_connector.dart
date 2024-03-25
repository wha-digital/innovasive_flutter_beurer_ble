import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:innovasive_flutter_beurer_ble/src/utils/value_at.dart';

import '../../innovasive_flutter_beurer_ble.dart';
import '../utils/logger.dart';

class BF600Connector extends BeurerDevice {
  BF600Connector(super.bluetoothDevice);

  BluetoothService? _userDataService;
  BluetoothCharacteristic? _userControlPointCharacteristic;

  BluetoothService? _customService;
  BluetoothService? _weightScaleService;
  BluetoothService? _currentTimeService;

  BluetoothCharacteristic? _takeMeasurementCharacteristic;
  BluetoothCharacteristic? _weightMeasurementCharacteristic;
  BluetoothCharacteristic? _currentTimeCharacteristic;

  StreamSubscription<List<int>>? _subscription;
  StreamSubscription<List<int>>? _weightSubscription;
  StreamSubscription<List<int>>? _userSubscription;

  Completer<BF600MeasurementData?>? _getMeasurementDataCompleter;
  Completer<bool>? _setUserCompleter;

  @override
  Future<void> setServicesAndCharacteristic() async {
    llog('🔵 Prepare Services & Characteristic for $nameWithId');

    final services = await bluetoothDevice.discoverServices();

    _userDataService = services.firstWhere((element) => element.uuid.toString() == '0000181c-0000-1000-8000-00805f9b34fb');

    _userControlPointCharacteristic = _userDataService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a9f-0000-1000-8000-00805f9b34fb';
    });

    _customService = services.firstWhere((element) => element.uuid.toString() == '0000fff0-0000-1000-8000-00805f9b34fb');
    _weightScaleService = services.firstWhere((element) => element.uuid.toString() == '0000181d-0000-1000-8000-00805f9b34fb');

    _takeMeasurementCharacteristic = _customService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '0000fff4-0000-1000-8000-00805f9b34fb';
    });

    _weightMeasurementCharacteristic = _weightScaleService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a9d-0000-1000-8000-00805f9b34fb';
    });

    _currentTimeService = services.firstWhere((element) => element.uuid.toString() == '00001805-0000-1000-8000-00805f9b34fb');

    _currentTimeCharacteristic = _currentTimeService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a2b-0000-1000-8000-00805f9b34fb';
    });

    llog('🟢 Services & Characteristic for $nameWithId is prepared.');
  }

  ///
  ///
  Future<BF600MeasurementData?> getMeasurementData() async {
    await setServicesAndCharacteristic();
    await setTime();

    _getMeasurementDataCompleter = Completer<BF600MeasurementData?>();

    _weightMeasurementCharacteristic?.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 500));

    _takeMeasurementCharacteristic?.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 500));

    _weightSubscription = _weightMeasurementCharacteristic?.lastValueStream.listen((event) {
      llog('🔵 [_weightMeasurementCharacteristic]: $event');
      if (event.isEmpty) return;

      final weight = ((0xff & valueAt(event, 2)) << 8 | (0xff & valueAt(event, 1)) << 0) * 0.005;

      if (!_getMeasurementDataCompleter!.isCompleted) {
        llog('🟢 Result for [getMeasurementData] from $nameWithId is $weight');
        _getMeasurementDataCompleter!.complete(BF600MeasurementData(weight: weight));
        _stopListen();
      }
    });

    _subscription = _takeMeasurementCharacteristic?.lastValueStream.listen((event) {
      llog('🔵 [_takeMeasurementCharacteristic]: $event');
      if (event.isEmpty) return;

      if (!_getMeasurementDataCompleter!.isCompleted) {
        llog('🟢 Result for [getMeasurementData] from $nameWithId is empty');
        _getMeasurementDataCompleter!.complete(null);
        _stopListen();
      }
    });

    await _takeMeasurementCharacteristic?.write([0x00]);

    return _getMeasurementDataCompleter!.future;
  }

  ///
  ///
  Future<void> _stopListen() async {
    await _subscription?.cancel();
    await _weightSubscription?.cancel();
    await _userSubscription?.cancel();
    llog('🔴 Stop listen to $nameWithId');
  }

  ///
  ///
  Future<bool> setUser(int code) async {
    await setServicesAndCharacteristic();

    _setUserCompleter = Completer<bool>();

    _userControlPointCharacteristic?.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 500));

    _userSubscription = _userControlPointCharacteristic?.lastValueStream.listen((event) async {
      llog('🔵 [_userControlPointCharacteristic]: $event');
      if (event.isEmpty) return;

      _userControlPointCharacteristic?.setNotifyValue(false);
      await Future.delayed(const Duration(milliseconds: 500));

      _userSubscription?.cancel();

      final result = valueAt(event, 2);

      if (result == 1) {
        if (!_setUserCompleter!.isCompleted) _setUserCompleter!.complete(true);
      } else {
        if (!_setUserCompleter!.isCompleted) _setUserCompleter!.complete(false);
      }
    });

    llog('🔵 Send [setUser] for $nameWithId');
    await _userControlPointCharacteristic?.write([0x02, 1, code & 0xff, (code >> 8) & 0xff]);

    return _setUserCompleter!.future;
  }

  ///
  ///
  Future<void> setTime() async {
    await setServicesAndCharacteristic();

    final charecter = _currentTimeCharacteristic;

    final year = [DateTime.now().year & 0xff, (DateTime.now().year >> 8) & 0xff];
    final month = DateTime.now().month;
    final day = DateTime.now().day;
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final second = DateTime.now().second;
    const dayOfWeek = 0x00; // Always 0
    const fraction256 = 0x00; // Always 0
    const adjustReason = 0x00; // Always 0

    llog('🔵 Send [setTime] for $nameWithId');
    await charecter!.write([...year, month, day, hour, minute, second, dayOfWeek, fraction256, adjustReason]);
  }
}
