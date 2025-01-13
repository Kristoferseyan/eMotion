import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionChartData {
  static final supabase = Supabase.instance.client;

  static Future<Map<String, List<FlSpot>>> fetchEmotionData(
      String userId, List<String> emotions, String timeRange) async {
    try {
      DateTime startDate;
      if (timeRange == 'Weekly') {
        startDate = DateTime.now().subtract(const Duration(days: 7));
      } else if (timeRange == 'Monthly') {
        startDate = DateTime.now().subtract(const Duration(days: 30));
      } else if (timeRange == 'Yearly') {
        startDate = DateTime.now().subtract(const Duration(days: 365));
      } else {
        throw ArgumentError('Invalid time range: $timeRange');
      }

      final response = await supabase
          .from('emotion_tracking')
          .select('emotion, timestamp')
          .eq('user_id', userId)
          .gte('timestamp', startDate.toIso8601String())
          .order('timestamp', ascending: true);

      if (response.isEmpty) {
        return {};
      }

      
      Map<String, Map<int, int>> dailyEmotionCounts = {};
      for (var emotion in emotions) {
        dailyEmotionCounts[emotion] = {};
        for (var i = 0; i < 7; i++) {
          dailyEmotionCounts[emotion]![i] = 0; 
        }
      }

      
      for (var entry in response) {
        DateTime timestamp = DateTime.parse(entry['timestamp']);
        int dayOfWeek = timestamp.weekday - 1; 

        String dominantEmotion = _sanitizeEmotion(entry['emotion']); 

        
        if (emotions.contains(dominantEmotion)) {
          dailyEmotionCounts[dominantEmotion]![dayOfWeek] = dailyEmotionCounts[dominantEmotion]![dayOfWeek]! + 1;
        }
      }

      
      Map<String, List<FlSpot>> spotsMap = {};
      for (var emotion in emotions) {
        List<FlSpot> spots = [];
        for (var i = 0; i < 7; i++) {
          int count = dailyEmotionCounts[emotion]![i] ?? 0;
          spots.add(FlSpot(i.toDouble(), count.toDouble()));
        }
        spotsMap[emotion] = spots;
      }

      return spotsMap;
    } catch (e) {
      print('Error fetching emotion data: $e');
      return {};
    }
  }

  
  static String _sanitizeEmotion(String emotion) {
    final trimmedEmotion = emotion.trim().toLowerCase();

    final corrections = {
      'happyness': 'Happiness',
      'hapiness': 'Happiness',
      'sadness': 'Sadness',
      'anger': 'Anger',
      'suprise': 'Surprise',
      'disguist': 'Disgust',
      'fear': 'Fear',
      'neutral': 'Neutral',
      'happy': 'Happiness',
      'sad': 'Sadness',
      'angry': 'Anger',
      'surprised': 'Surprise',
      'disgusted': 'Disgust',
      'afraid': 'Fear',
    };

    return corrections[trimmedEmotion] ?? _capitalize(trimmedEmotion);
  }

  static String _capitalize(String text) {
    return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
