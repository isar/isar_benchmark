import 'dart:async';
import 'dart:io';

import 'package:isar_benchmark/executor/executor.dart';
import 'package:isar_benchmark/models/model.dart';
import 'package:isar_benchmark/models/objectbox_model.dart';
import 'package:isar_benchmark/objectbox.g.dart';

class ObjectBoxExecutor extends Executor<Store> {
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
  FutureOr finalizeDatabase(Store db) {
    db.close();
    return Directory(storeDirectory).delete(recursive: true);
  }

  @override
  Stream<int> get(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    final idsToGet =
        obModels.map((e) => e.id).where((e) => e % 2 == 0).toList();
    return runBenchmark(
      prepare: (store) {
        store.box<ObjectBoxModel>().putMany(obModels);
      },
      (store) {
        store.box<ObjectBoxModel>().getMany(idsToGet);
      },
    );
  }

  @override
  Stream<int> insert(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    return runBenchmark((store) {
      store.box<ObjectBoxModel>().putMany(obModels);
    });
  }

  @override
  Stream<int> update(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    return runBenchmark(
      prepare: (store) {
        store.box<ObjectBoxModel>().putMany(obModels);
      },
      (store) {
        final objects = store
            .box<ObjectBoxModel>()
            .query(ObjectBoxModel_.archived.equals(true))
            .build()
            .find();

        final updatedObjects = objects.map((e) {
          return ObjectBoxModel(
            id: e.id,
            title: e.title,
            words: e.words,
            wordCount: e.wordCount,
            averageWordLength: e.averageWordLength,
            archived: false,
          );
        }).toList();
        store.box<ObjectBoxModel>().putMany(updatedObjects);
      },
    );
  }

  @override
  Stream<int> delete(List<Model> models) {
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
  Stream<int> filterQuery(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    return runBenchmark(
      prepare: (store) {
        store.box<ObjectBoxModel>().putMany(obModels);
      },
      (store) {
        final q = store
            .box<ObjectBoxModel>()
            .query(
              ObjectBoxModel_.words.containsElement('time').or(
                    ObjectBoxModel_.title.contains('a'),
                  ),
            )
            .build();
        q.offset = 40000;
        q.find();
      },
    );
  }

  @override
  Stream<int> filterSortQuery(List<Model> models) {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    return runBenchmark(
      prepare: (store) {
        store.box<ObjectBoxModel>().putMany(obModels);
      },
      (store) {
        (store
                .box<ObjectBoxModel>()
                .query(ObjectBoxModel_.archived.equals(true))
              ..order(ObjectBoxModel_.title))
            .build()
            .find();
      },
    );
  }

  @override
  Stream<int> dbSize(List<Model> models) async* {
    final obModels = models.map(ObjectBoxModel.fromModel).toList();
    final store = await prepareDatabase();
    try {
      store.box<ObjectBoxModel>().putMany(obModels);
      final stat = await File('$storeDirectory/data.mdb').stat();
      yield (stat.size / 1000).round();
    } finally {
      await finalizeDatabase(store);
    }
  }
}
