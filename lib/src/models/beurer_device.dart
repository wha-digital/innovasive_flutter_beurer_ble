// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../constants/connection_state.dart';
import '../utils/logger.dart';

abstract class BeurerDevice {
  final BluetoothDevice bluetoothDevice;

  BeurerDevice(
    this.bluetoothDevice,
  );

  String get name => bluetoothDevice.platformName;
  String get id => bluetoothDevice.remoteId.toString();
  String get nameWithId => '${bluetoothDevice.platformName} (${bluetoothDevice.remoteId})';

  /// Connect with device via BLE.
  ///
  Future<void> connect() async {
    try {
      llog('🔵 Connecting with $nameWithId');
      await bluetoothDevice.connect();
      await Future.delayed(const Duration(seconds: 1)); // must delay to make sure its connected.
      llog('🟢 Connected with $nameWithId');
    } on FlutterBluePlusException catch (e) {
      // Code (133):ANDROID_SPECIFIC_ERROR means connecting error. We will try to connect again.
      if (e.code == 133) connect();
    } on PlatformException catch (e) {
      // if already connected means it's ready.
      if (e.code == 'already_connected') llog('🟡 Already connected with $nameWithId');
    }
  }

  /// Connect and pair with device via BLE.
  ///
  Future<void> pair() async {
    await connect();
    llog('🔵 Creating bond with $nameWithId');
    await bluetoothDevice.createBond();
    llog('🟢 Bonded with $nameWithId');
  }

  /// Connect with device via BLE.
  ///
  Future<void> disconnect() async {
    llog('🔵 Disconnecting from $nameWithId');
    await bluetoothDevice.disconnect();
    llog('🔴 Disconnected from $nameWithId');
  }

  /// Set Services & Characteristic
  ///
  Future<void> setServicesAndCharacteristic();

  ///
  ///
  Future<DeviceConnectionState> getConnectionState() {
    final completer = Completer<DeviceConnectionState>();

    final subscribe = bluetoothDevice.connectionState.listen(null);

    subscribe.onData((BluetoothConnectionState data) {
      if (data.name == DeviceConnectionState.connecting.name) completer.complete(DeviceConnectionState.connecting);
      if (data.name == DeviceConnectionState.connected.name) completer.complete(DeviceConnectionState.connected);
      if (data.name == DeviceConnectionState.disconnecting.name) completer.complete(DeviceConnectionState.disconnecting);
      if (data.name == DeviceConnectionState.disconnected.name) completer.complete(DeviceConnectionState.disconnected);
      subscribe.cancel();
    });

    return completer.future;
  }

  ///
  ///
  Stream<DeviceConnectionState> listenConnectionState() {
    final controller = StreamController<DeviceConnectionState>();

    onBluetoothDeviceStateChanged(BluetoothConnectionState data) {
      if (data.name == DeviceConnectionState.connecting.name) controller.add(DeviceConnectionState.connecting);
      if (data.name == DeviceConnectionState.connected.name) controller.add(DeviceConnectionState.connected);
      if (data.name == DeviceConnectionState.disconnecting.name) controller.add(DeviceConnectionState.disconnecting);
      if (data.name == DeviceConnectionState.disconnected.name) controller.add(DeviceConnectionState.disconnected);
    }

    startListenBluetoothState() {
      final subscribe = bluetoothDevice.connectionState.listen(onBluetoothDeviceStateChanged);
      controller.onPause = subscribe.cancel;
      controller.onCancel = subscribe.cancel;
    }

    controller.onListen = startListenBluetoothState;

    return controller.stream;
  }

  ///
  ///
  @override
  bool operator ==(covariant BeurerDevice other) {
    if (identical(this, other)) return true;

    return other.bluetoothDevice == bluetoothDevice;
  }

  ///
  ///
  @override
  int get hashCode => bluetoothDevice.hashCode;
}
