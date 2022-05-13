import 'package:isar_benchmark/executor/executor.dart';

import 'models/model.dart';

class BenchmarkRunner {
  final String directory;
  final int repetitions;

  late final Map<Database, Executor> executors = {
    for (var database in Database.values)
      database: Executor.getExecutor(database, directory, repetitions)
  };

  BenchmarkRunner(this.directory, this.repetitions);

  Stream<RunnerResult> runBenchmark(
      Benchmark benchmark, int objectCount, bool big) async* {
    final models = Model.generateModels(objectCount, big);
    for (var database in Database.values) {
      final executor = executors[database]!;
      if (executor.supportedBenchmarks.contains(benchmark)) {
        yield RunnerResult(
          database,
          await _exec(benchmark, executor, models),
        );
      }
    }
  }

  Future<int> _exec(
      Benchmark benchmark, Executor executor, List<Model> models) {
    switch (benchmark) {
      case Benchmark.insertSync:
        return executor.insertSync(models);
      case Benchmark.insertAsync:
        return executor.insertAsync(models);
      case Benchmark.deleteSync:
        return executor.deleteSync(models);
      case Benchmark.deleteAsync:
        return executor.deleteAsync(models);
    }
  }
}

class RunnerResult {
  final Database database;

  final int value;

  const RunnerResult(this.database, this.value);
}

enum Benchmark {
  insertSync('Insert Sync', 'ms'),
  insertAsync('Insert Async', 'ms'),
  deleteSync('Delete Sync', 'ms'),
  deleteAsync('Delete Async', 'ms');

  final String name;

  final String unit;

  const Benchmark(this.name, this.unit);
}
