import 'package:isar/isar.dart';
import 'package:isar_benchmark/models/model.dart';

part 'isar_model.g.dart';

@Collection()
class IsarIndexModel {
  final int id;

  @Index()
  final String title;

  @Index(type: IndexType.hashElements)
  final List<String> words;

  @Index(composite: [CompositeIndex('title')])
  final bool archived;

  const IsarIndexModel({
    required this.id,
    required this.title,
    required this.words,
    required this.archived,
  });

  factory IsarIndexModel.fromModel(Model model) {
    return IsarIndexModel(
      id: model.id,
      title: model.title,
      words: model.words,
      archived: model.archived,
    );
  }
}

@Collection()
class IsarModel {
  final int id;

  final String title;

  final List<String> words;

  final bool archived;

  const IsarModel({
    required this.id,
    required this.title,
    required this.words,
    required this.archived,
  });

  factory IsarModel.fromModel(Model model) {
    return IsarModel(
      id: model.id,
      title: model.title,
      words: model.words,
      archived: model.archived,
    );
  }
}
