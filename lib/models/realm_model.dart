import 'package:isar_benchmark/models/model.dart';
import 'package:realm/realm.dart' hide RealmModel;
import 'package:realm/realm.dart' as realm;

part 'realm_model.g.dart';

@realm.RealmModel()
class _RealmModel {
  @PrimaryKey()
  late int id;

  late String title;

  late List<String> words;

  late int wordCount;

  late double averageWordLength;

  late bool archived;
}

RealmModel modelToRealm(Model model) {
  return RealmModel(
    model.id,
    model.title,
    model.wordCount,
    model.averageWordLength,
    model.archived,
    words: model.words,
  );
}

Model realmToModel(RealmModel model) {
  return Model(
    id: model.id,
    title: model.title,
    words: model.words,
    wordCount: model.wordCount,
    averageWordLength: model.averageWordLength,
    archived: model.archived,
  );
}
