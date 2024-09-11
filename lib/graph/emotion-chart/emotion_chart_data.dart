import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionChartData {
  static final supabase = Supabase.instance.client;

  static Future<Map<String, List<FlSpot>>> fetchEmotionData(String userId, List<String> emotions) async {
    try {
      // Fetch records related to the logged-in user for the past 7 days
      final response = await supabase
          .from('emotion_tracking')
          .select('emotion, timestamp')
          .eq('user_id', userId)
          .gte('timestamp', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('timestamp', ascending: true);

      if (response.isEmpty) {
        print("No data found for user: $userId");
        return {};
      }

      // Initialize maps for each emotion with zero values for the week (Mon-Sun)
      Map<String, Map<int, int>> dailyEmotionCounts = {};
      for (var emotion in emotions) {
        dailyEmotionCounts[emotion] = {};
        for (var i = 0; i < 7; i++) {
          dailyEmotionCounts[emotion]![i] = 0; // Initialize with zero counts
        }
      }

      // Iterate through the fetched records and count the occurrences of each emotion per day
      for (var entry in response) {
        DateTime timestamp = DateTime.parse(entry['timestamp']);
        int dayOfWeek = timestamp.weekday - 1; // Map Monday = 0, Tuesday = 1, etc.

        String dominantEmotion = _sanitizeEmotion(entry['emotion']); // Sanitize emotion by trimming spaces

        // Increment the count for the dominant emotion
        if (emotions.contains(dominantEmotion)) {
          dailyEmotionCounts[dominantEmotion]![dayOfWeek] = dailyEmotionCounts[dominantEmotion]![dayOfWeek]! + 1;
        }
      }

      // Prepare the chart data with raw counts
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

  // Helper method to trim spaces around emotion names
  static String _sanitizeEmotion(String emotion) {
    return emotion.trim(); // Remove leading/trailing spaces from the emotion name
  }
}
