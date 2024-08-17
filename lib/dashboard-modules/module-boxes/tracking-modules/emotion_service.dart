class EmotionService {
  List<String> savedData = [];

  // Save detected emotion to the list
  void saveEmotion(String emotion) {
    savedData.add(emotion);
    print('Emotion saved: $emotion');
  }

  // Calculate probabilities of each emotion
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

  // Normalize the probabilities so they sum to 1 (if needed)
  Map<String, double> normalizeProbabilities(Map<String, double> probabilities) {
    if (probabilities.isEmpty) {
      return {};
    }

    final sum = probabilities.values.reduce((value, element) => value + element);
    return probabilities.map((key, value) => MapEntry(key, value / sum));
  }

  // Convert normalized probabilities to scores
  Map<String, int> mapProbabilitiesToScores(Map<String, double> probabilities) {
    return probabilities.map((key, value) => MapEntry(key, (value * 100).round()));
  }

  // Determine the most frequent emotion based on the scores
  String getMostFrequentEmotion() {
    final probabilities = calculateEmotionProbabilities();
    final scores = mapProbabilitiesToScores(probabilities);

    if (scores.isEmpty) {
      return '';
    }

    // Find the emotion with the highest score
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Log the probabilities for debugging purposes
  void logProbabilities(Map<String, double> probabilities) {
    probabilities.forEach((emotion, probability) {
      print('Emotion: $emotion, Probability: $probability');
    });
  }
}
