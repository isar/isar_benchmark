import 'dart:async';

import 'package:isar/isar.dart';
import 'package:isar_benchmark/executor/executor.dart';
import 'package:isar_benchmark/models/isar_model.dart';
import 'package:isar_benchmark/models/model.dart';
import 'package:isar_benchmark/runner.dart';

class IsarExecutor extends Executor<Isar> {
  @override
  final supportedBenchmarks = {
    Benchmark.insertSync,
    Benchmark.insertAsync,
    Benchmark.deleteSync,
    Benchmark.deleteAsync,
  };

  IsarExecutor(super.directory, super.repetitions);

  @override
  FutureOr<Isar> prepareDatabase() {
    return Isar.openSync(
      directory: directory,
      schemas: [IsarIndexModelSchema, IsarModelSchema],
    );
  }

  @override
  FutureOr<void> finalizeDatabase(Isar db) async {
    await db.close(deleteFromDisk: true);
  }

  @override
  Future<int> insertSync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark((isar) {
      isar.writeTxnSync((isar) {
        isar.isarModels.putAllSync(isarModels);
      });
    });
  }

  @override
  Future<int> insertAsync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark((isar) async {
      await isar.writeTxn((isar) async {
        await isar.isarModels.putAll(isarModels);
      });
    });
  }

  @override
  Future<int> deleteSync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToDelete =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        isar.writeTxnSync((isar) {
          isar.isarModels.putAllSync(isarModels);
        });
      },
      (isar) {
        isar.writeTxnSync((isar) {
          isar.isarModels.deleteAllSync(idsToDelete);
        });
      },
    );
  }

  @override
  Future<int> deleteAsync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToDelete =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        isar.writeTxnSync((isar) {
          isar.isarModels.putAllSync(isarModels);
        });
      },
      (isar) async {
        await isar.writeTxn((isar) async {
          await isar.isarModels.deleteAll(idsToDelete);
        });
      },
    );
  }
}
