import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar_benchmark/runner.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tempDir = await getTemporaryDirectory();
  final benchDir = Directory('${tempDir.path}/bench')
    ..createSync(recursive: true);
  print(benchDir);
  runApp(App(directory: benchDir.path));
}

class App extends StatelessWidget {
  final String directory;
  late final runner = BenchmarkRunner(directory, 10);

  App({Key? key, required this.directory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DB Benchmark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              runner
                  .runBenchmark(Benchmark.insertSync, 50000, true)
                  .listen((event) {
                print('${event.database} ${event.value}');
              });
            },
            child: Text('RUN'),
          ),
        ),
      ),
    );
  }
}
