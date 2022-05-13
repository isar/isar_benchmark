import 'dart:async';
import 'dart:io';

import 'package:isar_benchmark/executor/executor.dart';
import 'package:isar_benchmark/models/model.dart';
import 'package:isar_benchmark/models/realm_model.dart';
import 'package:isar_benchmark/runner.dart';
import 'package:realm/realm.dart' hide RealmModel;

class RealmExecutor extends Executor<Realm> {
  @override
  final supportedBenchmarks = {
    Benchmark.insertSync,
    Benchmark.deleteSync,
  };

  RealmExecutor(super.directory, super.repetitions);

  String get realmFile => '$directory/db.realm';

  @override
  FutureOr<Realm> prepareDatabase() {
    final config = Configuration([RealmModel.schema, RealmIndexModel.schema]);
    config.path = realmFile;
    return Realm(config);
  }

  @override
  FutureOr<void> finalizeDatabase(Realm db) async {
    db.close();
    File(realmFile).deleteSync();
  }

  @override
  Future<int> insertSync(List<Model> models) {
    late List<RealmModel> realmModels;
    return runBenchmark(prepare: (realm) {
      realmModels = models.map(modelToRealm).toList();
    }, (realm) {
      realm.write(() {
        realm.addAll(realmModels);
      });
    });
  }

  @override
  Future<int> insertAsync(List<Model> models) => throw UnimplementedError();

  @override
  Future<int> deleteSync(List<Model> models) {
    late List<RealmModel> modelsToDelete;
    return runBenchmark(
      prepare: (realm) {
        final realmModels = models.map(modelToRealm).toList();
        modelsToDelete = realmModels.where((e) => e.id % 2 == 0).toList();
        realm.write(() {
          realm.addAll(realmModels);
        });
      },
      (realm) {
        realm.write(() {
          // TODO use delete by id when available
          realm.deleteMany(modelsToDelete);
        });
      },
    );
  }

  @override
  Future<int> deleteAsync(List<Model> models) => throw UnimplementedError();
}
