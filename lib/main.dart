import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:isar_benchmark/runner.dart';
import 'package:path_provider/path_provider.dart';

import 'executor/executor.dart';
import 'ui/result_container.dart';

Future<String> getDeviceName() async {
  final info = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await info.androidInfo;
    return androidInfo.model;
  } else if (Platform.isIOS) {
    final iosInfo = await info.iosInfo;
    return iosInfo.utsname.machine;
  } else if (Platform.isLinux) {
    final linuxInfo = await info.linuxInfo;
    return linuxInfo.prettyName;
  } else if (Platform.isMacOS) {
    final macOsInfo = await info.macOsInfo;
    return macOsInfo.model;
  } else if (Platform.isWindows) {
    return 'Windows Device';
  }
  return 'Unknown Device';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tempDir = await getTemporaryDirectory();
  final benchDir = Directory('${tempDir.path}/bench')
    ..createSync(recursive: true);

  final deviceName = await getDeviceName();
  runApp(App(directory: benchDir.path, deviceName: deviceName));
}

class App extends StatelessWidget {
  final String deviceName;
  final String directory;

  const App({
    Key? key,
    required this.directory,
    required this.deviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DB Benchmark',
      theme: ThemeData.from(
        // generated using #67abfd
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xff99cbff),
          onPrimary: Color(0xff003256),
          secondary: Color(0xffbac8db),
          onSecondary: Color(0xff243140),
          error: Color(0xffffb4a9),
          onError: Color(0xff680003),
          background: Color(0xff1b1b1d),
          onBackground: Color(0xffe3e2e6),
          surface: Color(0xff1b1b1d),
          onSurface: Color(0xffe3e2e6),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: BenchmarkArea(
              deviceName: deviceName,
              directory: directory,
            ),
          ),
        ),
      ),
    );
  }
}

class BenchmarkArea extends StatefulWidget {
  final String deviceName;
  final String directory;

  const BenchmarkArea({
    Key? key,
    required this.directory,
    required this.deviceName,
  }) : super(key: key);

  @override
  State<BenchmarkArea> createState() => _BenchmarkAreaState();
}

class _BenchmarkAreaState extends State<BenchmarkArea> {
  late final runner = BenchmarkRunner(widget.directory, 10);
  final results = <Database, RunnerResult>{};

  var benchmark = Benchmark.values[0];
  var objectCount = 50000;
  var bigObjects = false;
  var running = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Benchmark>(
                value: benchmark,
                decoration: const InputDecoration(
                  label: Text('Benchmark'),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (var benchmark in Benchmark.values)
                    DropdownMenuItem(
                      value: benchmark,
                      child: Text(benchmark.name),
                    )
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      benchmark = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: running ? null : run,
              child: const Text('LET\'S GO!'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: results.isNotEmpty
                ? ResultContainer(
                    deviceName: widget.deviceName,
                    results: results.values.toList(),
                    objectCount: objectCount,
                  )
                : const Center(
                    child: Text('No results yet.'),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              running || results.isEmpty ? null : ResultContainer.shareAsImage,
          child: const Text('Share'),
        ),
      ],
    );
  }

  void run() {
    setState(() {
      running = true;
      results.clear();
    });

    final stream = runner.runBenchmark(benchmark, objectCount, bigObjects);
    stream.listen((event) {
      setState(() {
        results[event.database] = event;
      });
    }).onDone(() {
      setState(() {
        running = false;
      });
    });
  }
}
