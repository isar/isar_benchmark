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
    for (var i = 0; i < Database.values.length; i++) {
      final database = Database.values[i];
      final executor = executors[database]!;
      try {
        final resultStream = _exec(benchmark, executor, models);
        yield* resultStream
            .map((e) => RunnerResult(database, benchmark, e))
            .handleError((e) {});
      } on UnimplementedError {
        // ignore
      }

      if (i != Database.values.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Stream<int> _exec(
      Benchmark benchmark, Executor executor, List<Model> models) {
    switch (benchmark) {
      case Benchmark.get:
        return executor.get(models);
      case Benchmark.insert:
        return executor.insert(models);
      case Benchmark.update:
        return executor.update(models);
      case Benchmark.delete:
        return executor.delete(models);
      case Benchmark.filterQuery:
        return executor.filterQuery(models);
      case Benchmark.filterSortQuery:
        return executor.filterSortQuery(models);
      case Benchmark.dbSize:
        return executor.dbSize(models);
    }
  }
}

class RunnerResult {
  final Database database;

  final Benchmark benchmark;

  final int value;

  const RunnerResult(this.database, this.benchmark, this.value);
}

enum Benchmark {
  get('Get', 'ms'),
  insert('Insert', 'ms'),
  update('Update', 'ms'),
  delete('Delete', 'ms'),
  filterQuery('Filter Query', 'ms'),
  filterSortQuery('Filter & Sort Query', 'ms'),
  dbSize('Database Size', 'KB');

  final String name;

  final String unit;

  const Benchmark(this.name, this.unit);
}
