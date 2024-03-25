import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:innovasive_flutter_beurer_ble/innovasive_flutter_beurer_ble.dart';

class BF600Page extends HookWidget {
  const BF600Page({
    super.key,
    required this.beurerDevice,
  });

  final BeurerDevice beurerDevice;

  @override
  Widget build(BuildContext context) {
    final device = beurerDevice as BF600Connector;

    return Scaffold(
      appBar: AppBar(
        title: Text('Device: ${beurerDevice.nameWithId}'),
      ),
      body: Column(
        children: [
          FilledButton(
            onPressed: () {
              device.disconnect();
              Navigator.of(context).pop();
            },
            child: const Text('disconnect'),
          ),
          Column(
            children: [
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      await device.setServicesAndCharacteristic();
                    },
                    child: const Text('set services'),
                  ),
                ],
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      await device.setTime();
                    },
                    child: const Text('set time'),
                  ),
                ],
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      await device.setUser(6495); // change the code follow user-1 on BF600
                    },
                    child: const Text('set user'),
                  ),
                ],
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      await device.getMeasurementData();
                    },
                    child: const Text('get measurement data... (but plz set user first!)'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
