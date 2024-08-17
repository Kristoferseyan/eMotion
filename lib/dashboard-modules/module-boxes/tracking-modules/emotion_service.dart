class EmotionService {
  List<String> savedData = [];

  void saveEmotion(String emotion) {
    savedData.add(emotion);
    print('Emotion saved: $emotion');
  }

  Map<String, double> calculateEmotionProbabilities() {
    final emotionCounts = <String, int>{};
    final totalEmotions = savedData.length;

    if (totalEmotions == 0) {
      return {};
    }

    // Count occurrences of each emotion
    for (var emotion in savedData) {
      emotionCounts.update(emotion, (value) => value + 1, ifAbsent: () => 1);
    }

    // Convert counts to probabilities
    final emotionProbabilities = emotionCounts.map(
      (emotion, count) => MapEntry(emotion, count / totalEmotions),
    );

    return normalizeProbabilities(emotionProbabilities);
  }

  Map<String, double> normalizeProbabilities(Map<String, double> probabilities) {
    if (probabilities.isEmpty) {
      return {};
    }

    final sum = probabilities.values.reduce((value, element) => value + element);
    return probabilities.map((key, value) => MapEntry(key, (value / sum) * 10));
  }

  Map<String, int> mapProbabilitiesToScores(Map<String, double> probabilities) {
    return probabilities.map((key, value) => MapEntry(key, value.round()));
  }

  void logProbabilities(Map<String, double> probabilities) {
    probabilities.forEach((emotion, probability) {
      print('Emotion: $emotion, Probability: $probability');
    });
  }
}
