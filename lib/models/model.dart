import 'dart:math';

import 'package:english_words/english_words.dart';

class Model {
  final int id;

  final String title;

  final List<String> words;

  final int wordCount;

  final double averageWordLength;

  final bool archived;

  const Model({
    required this.id,
    required this.title,
    required this.words,
    required this.wordCount,
    required this.averageWordLength,
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
      final words = generateWords(big ? 50 : 5);
      final wordsLengthSum = words.isEmpty
          ? 0
          : words
              .map((e) => e.length)
              .reduce((value, element) => value + element);
      models.add(Model(
        id: i,
        title: generateWords(big ? 50 : 5).join(' '),
        words: words,
        wordCount: words.length,
        averageWordLength: wordsLengthSum / words.length,
        archived: rand.nextBool(),
      ));
    }

    return models;
  }
}
