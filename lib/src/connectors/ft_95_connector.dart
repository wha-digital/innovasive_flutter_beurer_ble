import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:innovasive_flutter_beurer_ble/src/models/ft_95_measurement_data.dart';

import '../models/beurer_device.dart';
import '../utils/logger.dart';

class FT95Connector extends BeurerDevice {
  FT95Connector(super.bluetoothDevice);

  BluetoothService? _healthThermometerService;
  BluetoothCharacteristic? _temperatureMeasurementCharacteristic;

  StreamSubscription<List<int>>? _subscription;

  Completer<List<FT95MeasurementData>>? _getMeasurementDataCompleter;
  Timer? _getMeasurementDataTimer;

  final List<FT95MeasurementData> _measurementData = [];

  @override
  Future<void> setServicesAndCharacteristic() async {
    llog('🔵 Prepare Services & Characteristic for $nameWithId');

    final services = await bluetoothDevice.discoverServices();
    _healthThermometerService = services.firstWhere((element) => element.uuid.toString() == '00001809-0000-1000-8000-00805f9b34fb');

    _temperatureMeasurementCharacteristic = _healthThermometerService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a1c-0000-1000-8000-00805f9b34fb';
    });

    llog('🟢 Services & Characteristic for $nameWithId is prepared.');
  }

  ///
  ///
  Future<List<FT95MeasurementData>> getMeasurementData() async {
    await setServicesAndCharacteristic();

    _getMeasurementDataCompleter = Completer<List<FT95MeasurementData>>();

    _temperatureMeasurementCharacteristic?.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 500));

    _subscription = _temperatureMeasurementCharacteristic?.lastValueStream.listen((event) {
      if (event.isEmpty) return;

      final flags = event[0];
      final temperature = (event[1] + event[2] + event[3] + event[4]) / 10;
      final timestamp = DateTime((event[6] << 8) | event[5], event[7], event[8], event[9], event[10], event[11]);
      final type = event[12];

      final result = FT95MeasurementData(
        flags: flags,
        temperature: temperature,
        timestamp: timestamp,
        type: type,
      );

      _measurementData.add(result);

      _getMeasurementDataTimer?.cancel();

      _getMeasurementDataTimer = Timer(const Duration(seconds: 1), () {
        llog('🟢 Result for [getMeasurementData] is');

        for (var data in _measurementData) {
          llog('${data.toMap()}');
        }

        if (!_getMeasurementDataCompleter!.isCompleted) _getMeasurementDataCompleter!.complete([..._measurementData]);

        _measurementData.clear();
        _stopListen();
      });
    });

    return _getMeasurementDataCompleter!.future;
  }

  ///
  ///
  Future<void> _stopListen() async {
    _temperatureMeasurementCharacteristic?.setNotifyValue(false);
    await Future.delayed(const Duration(milliseconds: 500));

    await _subscription?.cancel();

    llog('🔴 Stop listen to $nameWithId');
  }
}
