import 'dart:async';
import 'dart:io';

import 'package:isar_benchmark/executor/executor.dart';
import 'package:isar_benchmark/models/model.dart';
import 'package:isar_benchmark/models/realm_model.dart';
import 'package:realm/realm.dart' hide RealmModel;

class RealmExecutor extends Executor<Realm> {
  RealmExecutor(super.directory, super.repetitions);

  String get realmFile => '$directory/db.realm';

  @override
  FutureOr<Realm> prepareDatabase() {
    final config = Configuration.local(
      [RealmModel.schema, RealmIndexModel.schema],
      path: realmFile,
    );
    return Realm(config);
  }

  @override
  FutureOr<void> finalizeDatabase(Realm db) async {
    db.close();
    File(realmFile).deleteSync();
  }

  @override
  Stream<int> insertSync(List<Model> models) {
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
  Stream<int> insertAsync(List<Model> models) => throw UnimplementedError();

  @override
  Stream<int> getSync(List<Model> models) {
    final idsToGet = models.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (realm) {
        final realmModels = models.map(modelToRealm).toList();
        realm.write(() {
          realm.addAll(realmModels);
        });
      },
      (realm) {
        for (var id in idsToGet) {
          realmToModel(realm.find<RealmModel>(id)!);
        }
      },
    );
  }

  @override
  Stream<int> getAsync(List<Model> models) => throw UnimplementedError();

  @override
  Stream<int> deleteSync(List<Model> models) {
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
  Stream<int> deleteAsync(List<Model> models) => throw UnimplementedError();

  @override
  Stream<int> filterQuery(List<Model> models) {
    return runBenchmark(
      prepare: (realm) {
        final realmModels = models.map(modelToRealm).toList();
        realm.write(() {
          realm.addAll(realmModels);
        });
      },
      (realm) {
        final results = realm.query<RealmModel>(
            "ANY words contains 'time' OR title CONTAINS 'a'");
        for (var result in results) {
          realmToModel(result);
        }
      },
    );
  }

  @override
  Stream<int> filterSortQuery(List<Model> models) {
    return runBenchmark(
      prepare: (realm) {
        final realmModels = models.map(modelToRealm).toList();
        realm.write(() {
          realm.addAll(realmModels);
        });
      },
      (realm) {
        final results =
            realm.query<RealmModel>('archived == true SORT(title ASCENDING)');
        for (var result in results) {
          realmToModel(result);
        }
      },
    );
  }

  @override
  Stream<int> dbSize(List<Model> models) async* {
    final realmModels = models.map(modelToRealm).toList();
    final realm = await prepareDatabase();
    try {
      realm.write(() {
        realm.addAll(realmModels);
      });
      final stat = await File(realmFile).stat();
      yield (stat.size / 1000).round();
    } finally {
      await finalizeDatabase(realm);
    }
  }
}
