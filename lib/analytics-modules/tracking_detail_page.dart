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
    // Parse the JSON string to a Map<String, double>
    final Map<String, double> emotionDistribution = Map<String, double>.from(
      jsonDecode(emotionDistributionJson).map(
        (key, value) => MapEntry(key, value.toDouble()),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dominant Emotion: $emotion',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Date: $date',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Time: $time',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Emotion Distribution:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Display emotion distribution as a pie chart
            Expanded(
              child: PieChartWidget(emotionData: emotionDistribution),
            ),
          ],
        ),
      ),
    );
  }
}
