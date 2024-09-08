import 'dart:convert';
import 'package:flutter/material.dart';
import '../graph/pie_chart_widget.dart';

class TrackingDetailPage extends StatelessWidget {
  final String emotion;
  final String date;
  final String time;
  final String emotionDistributionJson;

  const TrackingDetailPage({
    Key? key,
    required this.emotion,
    required this.date,
    required this.time,
    required this.emotionDistributionJson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Parse the JSON string to a Map<String, double>
    final Map<String, double> emotionDistribution = Map<String, double>.from(
      jsonDecode(emotionDistributionJson).map(
        (key, value) => MapEntry(key, value.toDouble()),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: $date',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: $time',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
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
          ],
        ),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
    );
  }
}
