import 'dart:async';

import 'package:isar_benchmark/executor/realm_executor.dart';
import 'package:isar_benchmark/models/model.dart';

import 'isar_executor.dart';
import 'objectbox_executor.dart';

abstract class Executor<T> {
  final String directory;
  final int repetitions;

  Executor(this.directory, this.repetitions);

  FutureOr<T> prepareDatabase();

  FutureOr<void> finalizeDatabase(T db);

  Stream<int> runBenchmark(
    FutureOr<void> Function(T db) benchmark, {
    FutureOr<void> Function(T db)? prepare,
  }) async* {
    final s = Stopwatch();
    for (var i = 0; i < repetitions; i++) {
      final db = await prepareDatabase();

      try {
        await prepare?.call(db);
        s.start();
        final result = benchmark(db);
        if (result is Future) {
          await result;
        }
        s.stop();
      } finally {
        await finalizeDatabase(db);
      }
      yield (s.elapsedMilliseconds.toDouble() / (i + 1)).round();
      if (i != repetitions - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
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

  Stream<int> insertSync(List<Model> models);

  Stream<int> insertAsync(List<Model> models);

  Stream<int> getSync(List<Model> models);

  Stream<int> getAsync(List<Model> models);

  Stream<int> deleteSync(List<Model> models);

  Stream<int> deleteAsync(List<Model> models);

  Stream<int> filterQuery(List<Model> models);

  Stream<int> filterSortQuery(List<Model> models);

  Stream<int> dbSize(List<Model> models);
}

enum Database {
  isar('Isar'),
  objectbox('ObjectBox'),
  realm('Realm');

  final String name;

  const Database(this.name);
}
