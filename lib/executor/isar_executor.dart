import 'dart:async';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:isar_benchmark/executor/executor.dart';
import 'package:isar_benchmark/models/isar_model.dart';
import 'package:isar_benchmark/models/model.dart';

class IsarExecutor extends Executor<Isar> {
  IsarExecutor(super.directory, super.repetitions, this.engine);

  final IsarEngine engine;

  @override
  FutureOr<Isar> prepareDatabase() {
    return Isar.open(
      schemas: [IsarModelSchema],
      directory: directory,
      engine: engine,
      maxSizeMiB: 1024,
    );
  }

  @override
  FutureOr<void> finalizeDatabase(Isar db) async {
    db.close(deleteFromDisk: true);
  }

  @override
  Stream<int> get(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToGet =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeAsync((isar) {
          isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.write((isar) {
          isar.isarModels.getAll(idsToGet);
        });
      },
    );
  }

  @override
  Stream<int> insert(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark((isar) {
      isar.write((isar) {
        isar.isarModels.putAll(isarModels);
      });
    });
  }

  @override
  Stream<int> update(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeAsync((isar) {
          isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.write((isar) {
          isar.isarModels
              .where()
              .archivedEqualTo(true)
              .build()
              .updateAll(archived: false);
        });
      },
    );
  }

  @override
  Stream<int> delete(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final idsToDelete =
        isarModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeAsync((isar) {
          isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.write((isar) {
          isar.isarModels.deleteAll(idsToDelete);
        });
      },
    );
  }

  @override
  Stream<int> filterQuery(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeAsync((isar) {
          isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.isarModels
            .where()
            .wordsElementEqualTo('time')
            .or()
            .titleContains('a')
            .findAll(offset: 40000);
      },
    );
  }

  @override
  Stream<int> filterSortQuery(List<Model> models) {
    final isarModels = models.map(IsarModel.fromModel).toList();
    return runBenchmark(
      prepare: (isar) {
        return isar.writeAsync((isar) {
          isar.isarModels.putAll(isarModels);
        });
      },
      (isar) {
        isar.isarModels.where().archivedEqualTo(true).sortByTitle().findAll();
      },
    );
  }

  @override
  Stream<int> dbSize(List<Model> models) async* {
    final isarModels = models.map(IsarModel.fromModel).toList();
    final isar = await prepareDatabase();
    try {
      await isar.writeAsync((isar) {
        isar.isarModels.putAll(isarModels);
      });
      if (engine == IsarEngine.isar) {
        final stat = await File('$directory/default.isar').stat();
        yield (stat.size / 1000).round();
      } else {
        print(Directory(directory).listSync());
        final sqliteStat = await File('$directory/default.sqlite').stat();
        final sqliteShmStat =
            await File('$directory/default.sqlite-shm').stat();
        yield ((sqliteStat.size + sqliteShmStat.size) / 1000).round();
      }
    } finally {
      await finalizeDatabase(isar);
    }
  }
}
