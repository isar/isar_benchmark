import 'dart:async';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:isar_benchmark/executor/executor.dart';
import 'package:isar_benchmark/models/isar_model.dart';
import 'package:isar_benchmark/models/model.dart';

class IsarExecutor extends Executor<Isar> {
  IsarExecutor(super.directory, super.repetitions);

  @override
  FutureOr<Isar> prepareDatabase() {
    return Isar.open(
      [IsarIndexModelSchema, IsarModelSchema],
      directory: directory,
    );
  }

  @override
  FutureOr<void> finalizeDatabase(Isar db) async {
    await db.close(deleteFromDisk: true);
  }

  @override
  Stream<int> insertSync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark((isar) {
      isar.writeTxnSync(() {
        isar.isarModels.putAllSync(isarModels);
      });
    });
  }

  @override
  Stream<int> insertAsync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark((isar) {
      return isar.writeTxn(() {
        return isar.isarModels.putAll(isarModels);
      });
    });
  }

  @override
  Stream<int> getSync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToGet =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.writeTxnSync(() {
          isar.isarModels.getAllSync(idsToGet);
        });
      },
    );
  }

  @override
  Stream<int> getAsync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToGet =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.getAll(idsToGet);
        });
      },
    );
  }

  @override
  Stream<int> deleteSync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToDelete =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.writeTxnSync(() {
          isar.isarModels.deleteAllSync(idsToDelete);
        });
      },
    );
  }

  @override
  Stream<int> deleteAsync(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToDelete =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.deleteAll(idsToDelete);
        });
      },
    );
  }

  @override
  Stream<int> filterQuery(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.isarModels
            .filter()
            .wordsElementEqualTo('time')
            .or()
            .titleContains('a')
            .findAllSync();
      },
    );
  }

  @override
  Stream<int> filterSortQuery(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeTxn(() {
          return isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.isarModels
            .filter()
            .archivedEqualTo(true)
            .sortByTitle()
            .findAllSync();
      },
    );
  }

  @override
  Stream<int> dbSize(List<Model> models) async* {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final isar = await prepareDatabase();
    try {
      await isar.writeTxn(() {
        return isar.isarModels.putAll(isarModels);
      });
      final stat = await File('$directory/default.isar').stat();
      yield (stat.size / 1000).round();
    } finally {
      await finalizeDatabase(isar);
    }
  }
}
