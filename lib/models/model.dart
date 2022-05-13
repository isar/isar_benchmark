import 'dart:math';

import 'package:english_words/english_words.dart';

class Model {
  final int id;

  final String title;

  final List<String> words;

  final bool archived;

  const Model({
    required this.id,
    required this.title,
    required this.words,
    required this.archived,
  });

  static List<Model> generateModels(int count, bool big) {
    final rand = Random();
    final List<Model> models = [];

    List<String> generateWords(int max) {
      final words = <String>[];
      for (var i = 0; i < rand.nextInt(max); i++) {
        words.add(nouns[rand.nextInt(nouns.length)]);
      }
      return words;
    }

    for (var i = 1; i < count + 1; i++) {
      models.add(Model(
        id: i,
        title: generateWords(big ? 50 : 5).join(' '),
        words: generateWords(big ? 50 : 5),
        archived: rand.nextBool(),
      ));
    }

    return models;
  }
}
