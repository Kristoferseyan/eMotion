import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class DatabaseService {
  final SupabaseClient _client;

  DatabaseService(this._client);

  Future<void> insertSessionData({
    required String userId,
    required String sessionId,
    required String emotion,
    required Map<String, double> emotionDistribution,
    required int duration,
  }) async {
    final emotionDistributionJson = jsonEncode(emotionDistribution);
    final timestamp = DateTime.now().toIso8601String(); // Use current timestamp

    final response = await _client
        .from('emotion_tracking')
        .insert({
          'user_id': userId,
          'session_id': sessionId,
          'timestamp': timestamp,
          'duration': duration,
          'emotion': emotion,
          'emotion_distribution': emotionDistributionJson,
          'user_feedback': '', // Add user feedback if available
        });

    if (response != null) {
      throw Exception('Error inserting session data: ${response['error']!.message}');
    }
  }
}
