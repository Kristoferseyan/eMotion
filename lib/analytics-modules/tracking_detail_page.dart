import 'dart:convert';
import 'package:flutter/material.dart';
import '../graph/pie_chart_widget.dart';

class TrackingDetailPage extends StatelessWidget {
  final String emotion;
  final String date;
  final String time;
  final String duration;
  final String emotionDistributionJson;

  const TrackingDetailPage({
    Key? key,
    required this.emotion,
    required this.date,
    required this.time,
    required this.duration,
    required this.emotionDistributionJson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Duration: $duration');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Map<String, double> emotionDistribution = Map<String, double>.from(
      jsonDecode(emotionDistributionJson).map(
        (key, value) => MapEntry(key, value.toDouble() * 100),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Details'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dominant Emotion: $emotion',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
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
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PieChartWidget(emotionData: emotionDistribution),
            ),
            const SizedBox(height: 20),
            _buildEmotionPercentages(emotionDistribution, isDarkMode),
          ],
        ),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
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

  Widget _buildEmotionPercentages(Map<String, double> emotionDistribution, bool isDarkMode) {
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
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
