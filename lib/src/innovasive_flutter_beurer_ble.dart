import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../innovasive_flutter_beurer_ble.dart';

class InnovasiveFlutterBeurerBle {
  /// All bluetooth devices that scanned.
  ///
  static final _bleDevices = ValueNotifier<List<BluetoothDevice>>([]);

  /// All Beurer devices that scanned.
  ///
  static final scannedDevices = ValueNotifier<List<BeurerDevice>>([]);

  /// Request permissions to use BLE.
  ///
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = await DeviceInfoPlugin().androidInfo;

      // Android >= 12
      if (android.version.sdkInt > 30) {
        final results = <Permission, PermissionStatus>{};
        final permission1 = await Permission.bluetoothConnect.request();
        final permission2 = await Permission.bluetoothAdvertise.request();
        final permission3 = await Permission.bluetoothScan.request();

        results[Permission.bluetoothConnect] = permission1;
        results[Permission.bluetoothAdvertise] = permission2;
        results[Permission.bluetoothScan] = permission3;

        if (results.containsValue(PermissionStatus.denied) || results.containsValue(PermissionStatus.permanentlyDenied)) {
          return false;
        }

        return true;
      }

      // Android <= 11
      final permission = await Permission.bluetooth.request();
      return permission == PermissionStatus.granted;
    }

    if (Platform.isIOS) {
      final result = await Permission.bluetooth.request();

      if (result != PermissionStatus.granted) return false;

      return true;
    }

    return false;
  }

  /// Check is requested permissions is granted.
  ///
  static Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      return [
        await Permission.location.isGranted,
        await Permission.bluetoothConnect.isGranted,
        await Permission.bluetoothScan.isGranted,
      ].all((isGranted) => isGranted);
    }

    if (Platform.isIOS) {
      return await Permission.bluetooth.isGranted;
    }

    return false;
  }

  /// Scan Beurer devices using BLE, only Beurer device will call [onScanned].
  ///
  static void scanDevices({
    void Function(List<BeurerDevice> devices)? onScanned,
  }) async {
    FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!_bleDevices.value.contains(r.device) && r.device.localName != 'unknown') {
          _bleDevices.value = _bleDevices.value.toList()..add(r.device);

          if (r.device.localName == SupportBeurerDevice.PO60.name) {
            scannedDevices.value = scannedDevices.value.toList()..add(PO60Connector(r.device));
            onScanned?.call(scannedDevices.value);
          }
          if (r.device.localName == SupportBeurerDevice.FT95.name) {
            scannedDevices.value = scannedDevices.value.toList()..add(FT95Connector(r.device));
            onScanned?.call(scannedDevices.value);
          }
          if (r.device.localName == SupportBeurerDevice.BM77.name) {
            scannedDevices.value = scannedDevices.value.toList()..add(BM77Connector(r.device));
            onScanned?.call(scannedDevices.value);
          }
          if (r.device.localName == SupportBeurerDevice.BF600.name) {
            scannedDevices.value = scannedDevices.value.toList()..add(BF600Connector(r.device));
            onScanned?.call(scannedDevices.value);
          }
          if (r.device.localName.contains(SupportBeurerDevice.GL50.name)) {
            scannedDevices.value = scannedDevices.value.toList()..add(GL50Connector(r.device));
            onScanned?.call(scannedDevices.value);
          }
        }
      }
    });
  }

  /// Stop BLE scan.
  ///
  static Future<dynamic> stopScanDevices() {
    return FlutterBluePlus.stopScan();
  }

  /// List all bonded Beurer devices.
  ///
  static Future<List<BeurerDevice>> bondedDevices() async {
    final devices = await FlutterBluePlus.bondedDevices;
    final bonded = <BeurerDevice>[];

    for (final d in devices) {
      if (d.localName == SupportBeurerDevice.PO60.name) bonded.add(PO60Connector(d));
      if (d.localName == SupportBeurerDevice.FT95.name) bonded.add(FT95Connector(d));
      if (d.localName == SupportBeurerDevice.BM77.name) bonded.add(BM77Connector(d));
      if (d.localName == SupportBeurerDevice.BF600.name) bonded.add(BF600Connector(d));
      if (d.localName.contains(SupportBeurerDevice.GL50.name)) bonded.add(GL50Connector(d));
    }

    return bonded;
  }

  /// Get first bonded PO60Connector
  ///
  static Future<PO60Connector?> bondedPO60Connector() async {
    final bonded = await bondedDevices();
    final po60 = bonded.firstOrNullWhere((d) => d.name == 'PO60');
    return po60 == null ? null : (po60 as PO60Connector);
  }

  /// Get first bonded FT95Connector
  ///
  static Future<FT95Connector?> bondedFT95Connector() async {
    final bonded = await bondedDevices();
    final ft95 = bonded.firstOrNullWhere((d) => d.name == 'FT95');
    return ft95 == null ? null : (ft95 as FT95Connector);
  }

  /// Note: BM77 is not being bonded, we must do scan only
  ///
  /// Get first bonded BM77Connector
  ///
  // static Future<BM77Connector?> bondedBM77Connector() async {
  //   final bonded = await bondedDevices();
  //   final bm77 = bonded.firstOrNullWhere((d) => d.name == 'BM77');
  //   return bm77 == null ? null : (bm77 as BM77Connector);
  // }

  /// Get first bonded GL50Connector
  ///
  static Future<GL50Connector?> bondedGL50Connector() async {
    final bonded = await bondedDevices();
    final gl50 = bonded.firstOrNullWhere((d) => d.name.contains('GL50'));
    return gl50 == null ? null : (gl50 as GL50Connector);
  }

  /// Get first bonded BF600Connector
  ///
  static Future<BF600Connector?> bondedBF600Connector() async {
    final bonded = await bondedDevices();
    final bf600 = bonded.firstOrNullWhere((d) => d.name == 'BF600');
    return bf600 == null ? null : (bf600 as BF600Connector);
  }
}
