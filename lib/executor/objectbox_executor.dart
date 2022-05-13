import 'dart:async';
import 'dart:io';

import 'package:isar_benchmark/executor/executor.dart';
import 'package:isar_benchmark/models/model.dart';
import 'package:isar_benchmark/models/objectbox_model.dart';
import 'package:isar_benchmark/objectbox.g.dart';
import 'package:isar_benchmark/runner.dart';

class ObjectBoxExecutor extends Executor<Store> {
  @override
  final supportedBenchmarks = {
    Benchmark.insertSync,
    Benchmark.insertAsync,
    Benchmark.deleteSync,
  };

  ObjectBoxExecutor(super.directory, super.repetitions);

  String get storeDirectory => '$directory/objectbox';

  @override
  FutureOr<Store> prepareDatabase() {
    return Store(
      getObjectBoxModel(),
      directory: storeDirectory,
    );
  }

  @override
  FutureOr<void> finalizeDatabase(Store db) async {
    db.close();
    Directory(storeDirectory).deleteSync(recursive: true);
  }

  @override
  Future<int> insertSync(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    return runBenchmark((store) {
      store.box<ObjectBoxModel>().putMany(obModels);
    });
  }

  @override
  Future<int> insertAsync(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    return runBenchmark((store) async {
      await store.runAsync<List<ObjectBoxModel>, void>(
        (store, obModels) {
          store.box<ObjectBoxModel>().putMany(obModels);
        },
        obModels,
      );
    });
  }

  @override
  Future<int> deleteSync(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    final idsToDelete =
        obModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (store) {
        store.box<ObjectBoxModel>().putMany(obModels);
      },
      (store) {
        store.box<ObjectBoxModel>().removeMany(idsToDelete);
      },
    );
  }

  @override
  Future<int> deleteAsync(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    final idsToDelete =
        obModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (store) {
        store.box<ObjectBoxModel>().putMany(obModels);
      },
      (store) async {
        await store.runAsync<List<ObjectBoxModel>, void>(
          (store, obModels) {
            store.box<ObjectBoxModel>().removeMany(idsToDelete);
          },
          obModels,
        );
      },
    );
  }
}
