import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> emotionData;

  PieChartWidget({required this.emotionData});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = emotionData.entries.map((entry) {
      // Trim the emotion key to remove any leading or trailing spaces
      String emotionKey = entry.key.trim();
      Color color = _getColor(emotionKey);
      print('Emotion: $emotionKey, Color: $color'); // Debug log

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value.toInt()}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: emotionData.keys.map((emotion) {
        String emotionKey = emotion.trim(); // Trim the emotion key here as well
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getColor(emotionKey),
            ),
            const SizedBox(width: 8),
            Text(emotionKey),
          ],
        );
      }).toList(),
    );
  }

  Color _getColor(String emotion) {
    switch (emotion) {
      case 'Happiness':
        return Colors.amber;
      case 'Sadness':
        return Colors.blueAccent;
      case 'Anger':
        return Colors.redAccent;
      case 'Surprise':
        return Colors.orangeAccent;
      case 'Disgust':
        return Colors.green;
      case 'Fear':
        return Colors.deepPurpleAccent;
      default:
        return Colors.grey;
    }
  }
}
