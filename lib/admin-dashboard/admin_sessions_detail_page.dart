import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSessionDetailPage extends StatefulWidget {
  final String sessionId;

  const AdminSessionDetailPage({
    Key? key,
    required this.sessionId, required emotion, required String date, required String time, required String duration, required String emotionDistributionJson,
  }) : super(key: key);

  @override
  _AdminSessionDetailPageState createState() => _AdminSessionDetailPageState();
}

class _AdminSessionDetailPageState extends State<AdminSessionDetailPage> {
  final supabase = Supabase.instance.client;

  
  String emotion = '';
  String date = '';
  String time = '';
  String duration = '';
  Map<String, double> emotionDistribution = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
  }

  
  Future<void> _fetchSessionDetails() async {
    try {
      final response = await supabase
          .from('emotion_tracking')
          .select()
          .eq('session_id', widget.sessionId)
          .single(); 

      if (response != null) {
        final session = response;

        setState(() {
          emotion = session['emotion'];
          date = _formatDate(session['timestamp']);
          time = _formatTime(session['timestamp']);
          duration = session['duration']?.toString() ?? 'Unknown';

          
          emotionDistribution = Map<String, double>.from(
            (jsonDecode(session['emotion_distribution']) as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, (value as num).toDouble() * 100)),
          );

          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session not found.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching session details: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF);
    final cardColor = isDarkMode ? const Color(0xFF1E4A54) : const Color(0xFFF3FCFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      backgroundColor: backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dominant Emotion: $emotion',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow('Date', date, isDarkMode),
                  _buildInfoRow('Time', time, isDarkMode),
                  _buildInfoRow('Duration', duration, isDarkMode),
                  const SizedBox(height: 20),
                  Text(
                    'Emotion Distribution:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildEmotionPercentages(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionPercentages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: emotionDistribution.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  String _formatTime(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour}:${dateTime.minute}';
  }
}
