import 'package:example/bf600_page.dart';
import 'package:example/po60_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:innovasive_flutter_beurer_ble/innovasive_flutter_beurer_ble.dart';

import 'bm77_page.dart';
import 'ft95_page.dart';
import 'gl50_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends HookWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isScanning = useState<bool>(false);

    final devices = useState<List<BeurerDevice>>([]);
    final bondedState = useState<List<BeurerDevice>>([]);

    useEffect(() {
      InnovasiveFlutterBeurerBle.bondedDevices().then((value) => bondedState.value = value);
      return null;
    }, []);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scan device'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                ///
                ///
                ///
                if (!isScanning.value)
                  FilledButton(
                    onPressed: () async {
                      final isPass = await InnovasiveFlutterBeurerBle.requestPermissions();

                      if (isPass) {
                        InnovasiveFlutterBeurerBle.scanDevices(
                          onScanned: (values) {
                            final newDevice = values.where((element) => !bondedState.value.contains(element)).toList();
                            devices.value = newDevice;

                            InnovasiveFlutterBeurerBle.bondedDevices().then((value) => bondedState.value = value);
                          },
                        );

                        isScanning.value = true;
                      }
                    },
                    child: const Text('Start scan'),
                  ),

                ///
                ///
                ///
                if (isScanning.value)
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () {
                          InnovasiveFlutterBeurerBle.stopScanDevices();
                          isScanning.value = false;
                        },
                        child: const Text('Stop scan'),
                      ),
                      const SizedBox(width: 24),
                      const CircularProgressIndicator(),
                      const SizedBox(width: 24),
                      const Text('Scanning for Beurer devices...'),
                    ],
                  ),
              ],
            ),

            ///
            ///
            ///
            const Text('Bonded:'),
            Expanded(
              child: ListView.builder(
                itemCount: bondedState.value.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: bondedState.value[index].getConnectionState(),
                    builder: (context, snapshot) {
                      return ListTile(
                        onTap: () async {
                          if (snapshot.data == DeviceConnectionState.connected) {
                            if (bondedState.value[index] is PO60Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PO60Page(beurerDevice: bondedState.value[index])));
                            }

                            if (bondedState.value[index] is FT95Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => FT95Page(beurerDevice: bondedState.value[index])));
                            }

                            if (bondedState.value[index] is BM77Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BM77Page(beurerDevice: bondedState.value[index])));
                            }

                            if (bondedState.value[index] is BF600Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BF600Page(beurerDevice: bondedState.value[index])));
                            }

                            if (bondedState.value[index] is GL50Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => GL50Page(beurerDevice: bondedState.value[index])));
                            }

                            bondedState.value = bondedState.value.toList();
                          }

                          if (snapshot.data == DeviceConnectionState.disconnected) {
                            await bondedState.value[index].connect();
                            bondedState.value = bondedState.value.toList();
                          }
                        },
                        title: Text(bondedState.value[index].name),
                        subtitle: Text('status: ${snapshot.data}'),
                      );
                    },
                  );
                },
              ),
            ),

            ///
            ///
            ///
            const Text('Scanned:'),
            Expanded(
              child: ListView.builder(
                itemCount: devices.value.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: devices.value[index].getConnectionState(),
                    builder: (context, snapshot) {
                      return ListTile(
                        onTap: () async {
                          if (snapshot.data == DeviceConnectionState.connected) {
                            if (devices.value[index] is PO60Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PO60Page(beurerDevice: devices.value[index])));
                            }

                            if (devices.value[index] is FT95Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => FT95Page(beurerDevice: devices.value[index])));
                            }

                            if (devices.value[index] is BM77Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BM77Page(beurerDevice: devices.value[index])));
                            }

                            if (devices.value[index] is BF600Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BF600Page(beurerDevice: devices.value[index])));
                            }

                            if (devices.value[index] is GL50Connector) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => GL50Page(beurerDevice: devices.value[index])));
                            }

                            devices.value = devices.value.toList();
                          }

                          if (snapshot.data == DeviceConnectionState.disconnected) {
                            await devices.value[index].connect();
                            devices.value = devices.value.toList();
                          }
                        },
                        title: Text(devices.value[index].name),
                        subtitle: Text('status: ${snapshot.data}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
