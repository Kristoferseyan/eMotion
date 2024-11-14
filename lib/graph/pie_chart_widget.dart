import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> emotionData;

  PieChartWidget({required this.emotionData});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    List<PieChartSectionData> sections = emotionData.entries.map((entry) {
      String emotionKey = _sanitizeEmotion(entry.key.trim());
      Color color = _getColor(emotionKey);
      double value = entry.value * 100; 

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(0)}%', 
        radius: 60,
        titleStyle: TextStyle(
          fontSize: _getTitleFontSize(value), 
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 250,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              startDegreeOffset: 270,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildLegend(isDarkMode),
      ],
    );
  }

  Widget _buildLegend(bool isDarkMode) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: emotionData.keys.map((emotion) {
        String emotionKey = _sanitizeEmotion(emotion.trim());
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getColor(emotionKey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              emotionKey,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  double _getTitleFontSize(double value) {
    if (value > 20) {
      return 16;
    } else if (value > 10) {
      return 14;
    } else {
      return 12;
    }
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
      case 'Neutral':
        return Colors.grey;
      default:
        return Colors.grey; 
    }
  }

  
  String _sanitizeEmotion(String emotion) {
    final trimmedEmotion = emotion.trim().toLowerCase();
    
    final corrections = {
      'happyness': 'Happiness',
      'hapiness': 'Happiness',
      'sadnes': 'Sadness',
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

  String _capitalize(String text) {
    return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
