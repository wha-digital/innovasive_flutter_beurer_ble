import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/beurer_device.dart';
import '../utils/logger.dart';

class GL50Connector extends BeurerDevice {
  GL50Connector(super.bluetoothDevice);

  BluetoothService? _glucoseService;
  BluetoothCharacteristic? _glucoseMeasurementCharacteristic;
  BluetoothCharacteristic? _glucoseMeasurementContextCharacteristic;
  BluetoothCharacteristic? _recordAccessCharacteristic;

  StreamSubscription<List<int>>? _glucoseMeasurementSubscription;
  StreamSubscription<List<int>>? _glucoseMeasurementContextSubscription;
  StreamSubscription<List<int>>? _recordAccessSubscription;

  Completer<int>? _getMeasurementDataCompleter;

  @override
  Future<void> setServicesAndCharacteristic() async {
    llog('🔵 Prepare Services & Characteristic for $nameWithId');

    final services = await bluetoothDevice.discoverServices();

    _glucoseService = services.firstWhere((element) => element.uuid.toString() == '00001808-0000-1000-8000-00805f9b34fb');

    _glucoseMeasurementCharacteristic = _glucoseService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a18-0000-1000-8000-00805f9b34fb';
    });
    _glucoseMeasurementContextCharacteristic = _glucoseService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a34-0000-1000-8000-00805f9b34fb';
    });
    _recordAccessCharacteristic = _glucoseService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a52-0000-1000-8000-00805f9b34fb';
    });

    llog('🟢 Services & Characteristic for $nameWithId is prepared.');
  }

  ///
  ///
  Future<int> getMeasurementData() async {
    await setServicesAndCharacteristic();

    _getMeasurementDataCompleter = Completer<int>();

    _glucoseMeasurementCharacteristic?.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 500));

    _glucoseMeasurementContextCharacteristic?.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 500));

    _recordAccessCharacteristic?.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 500));

    _glucoseMeasurementSubscription = _glucoseMeasurementCharacteristic?.lastValueStream.listen((event) {
      if (event.isEmpty) return;

      if (event.length == 13) {
        llog('🟢 Result for [getMeasurementData] is ${event[10]} mg/dL');

        if (_getMeasurementDataCompleter != null) {
          if (!_getMeasurementDataCompleter!.isCompleted) _getMeasurementDataCompleter?.complete(event[10]);
        }

        _stopListen();
      }
    });

    _glucoseMeasurementContextSubscription = _glucoseMeasurementContextCharacteristic?.lastValueStream.listen((event) {
      if (event.isEmpty) return;
    });

    _recordAccessSubscription = _recordAccessCharacteristic?.lastValueStream.listen((event) {
      if (event.isEmpty) return;
    });

    await _recordAccessCharacteristic?.write([0x01, 0x06]);

    return _getMeasurementDataCompleter!.future;
  }

  ///
  ///
  Future<void> _stopListen() async {
    await _glucoseMeasurementSubscription?.cancel();
    await _glucoseMeasurementContextSubscription?.cancel();
    await _recordAccessSubscription?.cancel();
    llog('🔴 Stop listen to $nameWithId');
  }
}
