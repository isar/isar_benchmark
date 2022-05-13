import 'dart:async';

import 'package:isar_benchmark/executor/realm_executor.dart';
import 'package:isar_benchmark/models/model.dart';
import 'package:isar_benchmark/runner.dart';

import 'isar_executor.dart';
import 'objectbox_executor.dart';

abstract class Executor<T> {
  final String directory;
  final int repetitions;

  Executor(this.directory, this.repetitions);

  Set<Benchmark> get supportedBenchmarks;

  FutureOr<T> prepareDatabase();

  FutureOr<void> finalizeDatabase(T db);

  Future<int> runBenchmark(
    FutureOr<void> Function(T db) benchmark, {
    FutureOr<void> Function(T db)? prepare,
  }) async {
    final s = Stopwatch();
    for (var i = 0; i < repetitions; i++) {
      final db = await prepareDatabase();
      await prepare?.call(db);
      s.start();
      final result = benchmark(db);
      if (result is Future) {
        await result;
      }
      s.stop();
      await finalizeDatabase(db);
    }
    return (s.elapsedMilliseconds.toDouble() / repetitions).round();
  }

  static Executor getExecutor(
      Database database, String directory, int repetitions) {
    switch (database) {
      case Database.isar:
        return IsarExecutor(directory, repetitions);
      case Database.objectbox:
        return ObjectBoxExecutor(directory, repetitions);
      case Database.realm:
        return RealmExecutor(directory, repetitions);
    }
  }

  Future<int> insertSync(List<Model> models);

  Future<int> insertAsync(List<Model> models);

  Future<int> deleteSync(List<Model> models);

  Future<int> deleteAsync(List<Model> models);
}

enum Database {
  isar('Isar'),
  objectbox('ObjectBox'),
  realm('Realm');

  final String name;

  const Database(this.name);
}
