import 'package:isar/isar.dart';
import 'package:isar_benchmark/models/model.dart';

part 'isar_model.g.dart';

@Collection()
class IsarModel {
  final int id;

  final String title;

  final List<String> words;

  final int wordCount;

  final double averageWordLength;

  final bool archived;

  const IsarModel({
    required this.id,
    required this.title,
    required this.words,
    required this.wordCount,
    required this.averageWordLength,
    required this.archived,
  });

  factory IsarModel.fromModel(Model model) {
    return IsarModel(
      id: model.id,
      title: model.title,
      words: model.words,
      wordCount: model.wordCount,
      averageWordLength: model.averageWordLength,
      archived: model.archived,
    );
  }
}
