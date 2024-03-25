import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/beurer_device.dart';
import '../models/bm_77_measurement_data.dart';
import '../utils/logger.dart';

class BM77Connector extends BeurerDevice {
  BM77Connector(super.bluetoothDevice);

  BluetoothService? _bloodPressureService;
  BluetoothCharacteristic? _measurementCharacteristic;

  StreamSubscription<List<int>>? _subscription;

  Completer<List<BM77MeasurementData>>? _getMeasurementDataCompleter;

  final List<BM77MeasurementData> _measurementData = [];

  Timer? _debounce;

  @override
  Future<void> setServicesAndCharacteristic() async {
    llog('🔵 Prepare Services & Characteristic for $nameWithId');

    final services = await bluetoothDevice.discoverServices();
    _bloodPressureService = services.firstWhere((element) => element.uuid.toString() == '00001810-0000-1000-8000-00805f9b34fb');

    _measurementCharacteristic = _bloodPressureService!.characteristics.firstWhere((element) {
      return element.uuid.toString() == '00002a35-0000-1000-8000-00805f9b34fb';
    });

    llog('🟢 Services & Characteristic for $nameWithId is prepared.');
  }

  ///
  ///
  Future<List<BM77MeasurementData>> getMeasurementData() async {
    await setServicesAndCharacteristic();

    _getMeasurementDataCompleter = Completer<List<BM77MeasurementData>>();

    _measurementCharacteristic?.setNotifyValue(true);

    _subscription = _measurementCharacteristic?.lastValueStream.listen((event) {
      if (event.isEmpty) return;

      final flags = event[0];
      final systolic = event[1] + event[2];
      final diastolic = event[3] + event[4];
      final timestamp = DateTime((event[7] << 8) | event[8], event[9], event[10], event[11], event[12], event[13]);
      final pulseRate = event[14] + event[15];
      final userID = event[16] == 0 ? 1 : 2;

      final result = BM77MeasurementData(
        flags: flags,
        systolic: systolic,
        diastolic: diastolic,
        timestamp: timestamp,
        pulseRate: pulseRate,
        userID: userID,
        measurementStatus: '',
      );

      _measurementData.add(result);

      if (_debounce?.isActive ?? false) _debounce?.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        llog('🟢 Result for [getMeasurementData] is');

        for (var data in _measurementData) {
          llog('${data.toMap()}');
        }

        if (!_getMeasurementDataCompleter!.isCompleted) _getMeasurementDataCompleter!.complete([..._measurementData]);
        _measurementData.clear();
        _stopListen();
      });
    });

    llog('🔵 Write command [getMeasurementData] to $nameWithId');

    return _getMeasurementDataCompleter!.future;
  }

  ///
  ///
  Future<void> _stopListen() async {
    await _subscription?.cancel();
    _debounce?.cancel();
    llog('🔴 Stop listen to $nameWithId');
  }
}
