import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionChartData {
  static final supabase = Supabase.instance.client;

static Future<Map<String, List<FlSpot>>> fetchEmotionData(String userId, List<String> emotions) async {
  try {
    // Fetch only data related to the logged-in user
    final response = await supabase
        .from('emotion_tracking')
        .select('emotion_distribution, timestamp')
        .eq('user_id', userId)
        .gte('timestamp', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
        .order('timestamp', ascending: true);

    if (response.isEmpty) {
      print("No data found for user: $userId");
      return {};
    }

    Map<String, Map<int, double>> dailyEmotionSum = {};
    Map<String, Map<int, int>> dailyEmotionCounts = {};

    for (var emotion in emotions) {
      dailyEmotionSum[emotion] = {};
      dailyEmotionCounts[emotion] = {};
      for (var i = 0; i < 7; i++) {
        dailyEmotionSum[emotion]![i] = 0.0;
        dailyEmotionCounts[emotion]![i] = 0;
      }
    }

    for (var entry in response) {
      DateTime timestamp = DateTime.parse(entry['timestamp']);
      
      // Get the weekday index (Monday = 1, ..., Sunday = 7)
      int dayOfWeek = timestamp.weekday;

      // Map Monday to 0, Tuesday to 1, ..., Sunday to 6 for the chart
      int chartIndex = dayOfWeek - 1;

      final emotionDistributionJson = entry['emotion_distribution'];
      final Map<String, dynamic> emotionDistributionMap = _sanitizeJsonKeys(jsonDecode(emotionDistributionJson));

      for (var emotion in emotions) {
        double emotionValue = (emotionDistributionMap[emotion] ?? 0.0).toDouble();
        dailyEmotionSum[emotion]![chartIndex] = dailyEmotionSum[emotion]![chartIndex]! + emotionValue;
        dailyEmotionCounts[emotion]![chartIndex] = dailyEmotionCounts[emotion]![chartIndex]! + 1;
      }
    }


    Map<String, List<FlSpot>> spotsMap = {};
    for (var emotion in emotions) {
      List<FlSpot> spots = [];
      for (var i = 0; i < 7; i++) {
        double averageEmotionValue = dailyEmotionCounts[emotion]![i] != 0
            ? dailyEmotionSum[emotion]![i]! / dailyEmotionCounts[emotion]![i]!
            : 0.0;
        spots.add(FlSpot(i.toDouble(), averageEmotionValue));
      }
      spotsMap[emotion] = spots;
    }

    return spotsMap;
  } catch (e) {
    print('Error fetching emotion data: $e');
    return {};
  }
}

// Utility function to remove leading/trailing spaces from JSON keys
static Map<String, dynamic> _sanitizeJsonKeys(Map<String, dynamic> json) {
  return json.map((key, value) {
    // Trim spaces from the key
    final sanitizedKey = key.trim();
    return MapEntry(sanitizedKey, value);
  });
}

}
