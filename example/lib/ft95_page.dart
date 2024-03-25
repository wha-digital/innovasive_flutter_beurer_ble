import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:innovasive_flutter_beurer_ble/innovasive_flutter_beurer_ble.dart';

class FT95Page extends HookWidget {
  const FT95Page({
    super.key,
    required this.beurerDevice,
  });

  final BeurerDevice beurerDevice;

  @override
  Widget build(BuildContext context) {
    final device = beurerDevice as FT95Connector;

    return Scaffold(
      appBar: AppBar(
        title: Text('Device: ${beurerDevice.nameWithId}'),
      ),
      body: Column(
        children: [
          FilledButton(
            onPressed: () {
              beurerDevice.disconnect();
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
                      await device.getMeasurementData();
                    },
                    child: const Text('getMeasurementData'),
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
