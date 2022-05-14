import 'package:isar_benchmark/models/model.dart';
import 'package:realm/realm.dart' hide RealmModel;
import 'package:realm/realm.dart' as realm;

part 'realm_model.g.dart';

@realm.RealmModel()
class _RealmIndexModel {
  @PrimaryKey()
  late int id;

  @Indexed()
  late String title;

  late List<String> words;

  late bool archived;
}

RealmIndexModel modelToRealmIndex(Model model) {
  return RealmIndexModel(
    model.id,
    model.title,
    model.archived,
    words: model.words,
  );
}

@realm.RealmModel()
class _RealmModel {
  @PrimaryKey()
  late int id;

  late String title;

  late List<String> words;

  late bool archived;
}

RealmModel modelToRealm(Model model) {
  return RealmModel(
    model.id,
    model.title,
    model.archived,
    words: model.words,
  );
}

Model realmToModel(RealmModel model) {
  return Model(
    id: model.id,
    title: model.title,
    archived: model.archived,
    words: model.words,
  );
}
