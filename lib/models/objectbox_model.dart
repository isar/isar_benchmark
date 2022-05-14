import 'package:objectbox/objectbox.dart';

import 'model.dart';

@Entity()
class ObjectBoxIndexModel {
  @Id(assignable: true)
  int id;

  @Index()
  final String title;

  final List<String> words;

  @Index()
  final bool archived;

  ObjectBoxIndexModel({
    required this.id,
    required this.title,
    required this.words,
    required this.archived,
  });

  factory ObjectBoxIndexModel.fromModel(Model model) {
    return ObjectBoxIndexModel(
      id: model.id,
      title: model.title,
      words: model.words,
      archived: model.archived,
    );
  }
}

@Entity()
class ObjectBoxModel {
  @Id(assignable: true)
  int id;

  final String title;

  final List<String> words;

  @Index()
  final bool archived;

  ObjectBoxModel({
    required this.id,
    required this.title,
    required this.words,
    required this.archived,
  });

  factory ObjectBoxModel.fromModel(Model model) {
    return ObjectBoxModel(
      id: model.id,
      title: model.title,
      words: model.words,
      archived: model.archived,
    );
  }
}
