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
    for (var emotion in savedData) {
      emotionCounts.update(emotion, (value) => value + 1, ifAbsent: () => 1);
    }
    final emotionProbabilities = emotionCounts.map(
      (emotion, count) => MapEntry(emotion, count / totalEmotions),
    );
    return normalizeProbabilities(emotionProbabilities);
    
  }
Map<String, double> normalizeProbabilities(Map<String, double> probabilities) {
  if (probabilities.isEmpty) {
    return {};
  }

  
  const surpriseBias = 0.3; 
  probabilities.update("Surprise", (value) => (value - surpriseBias).clamp(0.0, 1.0),
      ifAbsent: () => 0.0);

  
  final sum = probabilities.values.reduce((value, element) => value + element);
  if (sum == 0) {
    return probabilities.map((key, value) => MapEntry(key, 0.0));
  }

  return probabilities.map((key, value) => MapEntry(key, value / sum));
}
  Map<String, int> mapProbabilitiesToScores(Map<String, double> probabilities) {
    return probabilities.map((key, value) => MapEntry(key, (value * 100).round()));
  }
  String getMostFrequentEmotion() {
    final probabilities = calculateEmotionProbabilities();
    final scores = mapProbabilitiesToScores(probabilities);
    if (scores.isEmpty) {
      return '';
    }
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  void logProbabilities(Map<String, double> probabilities) {
    probabilities.forEach((emotion, probability) {
      print('Emotion: $emotion, Probability: $probability');
    });
  }
}
