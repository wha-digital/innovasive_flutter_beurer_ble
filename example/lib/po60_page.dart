import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:innovasive_flutter_beurer_ble/innovasive_flutter_beurer_ble.dart';

class PO60Page extends HookWidget {
  const PO60Page({
    super.key,
    required this.beurerDevice,
  });

  final BeurerDevice beurerDevice;

  @override
  Widget build(BuildContext context) {
    final device = beurerDevice as PO60Connector;

    final dateState = useState<DateTime?>(null);

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
                      await device.listen();
                    },
                    child: const Text('listen'),
                  ),
                  FilledButton(
                    onPressed: () {
                      device.stopListen();
                    },
                    child: const Text('stop listen'),
                  ),
                ],
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      dateState.value = await device.getTime();
                    },
                    child: const Text('get device time'),
                  ),
                  if (dateState.value != null) Text(dateState.value.toString()),
                ],
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      await device.getMeasurementData();
                    },
                    child: const Text('get measurement data'),
                  ),
                ],
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      device.deleteAllMeasurementData();
                    },
                    child: const Text('delete all'),
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
