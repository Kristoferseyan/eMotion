import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatelessWidget {
  final Map<String, int> scores;
  final bool showEmojis;

  const MyBarGraph({
    super.key,
    required this.scores,
    this.showEmojis = false,
  });

  @override
  Widget build(BuildContext context) {
    
    print("Building MyBarGraph with scores: $scores");

    
    final sortedScores = Map.fromEntries(
      scores.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    
    final maxScore = scores.values.isNotEmpty ? scores.values.reduce((a, b) => a > b ? a : b) : 1;

    
    print("Max score: $maxScore");

    
    final maxY = 100.0; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 2.5, 
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(125, 201, 201, 201), 
          borderRadius: BorderRadius.circular(15), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 4), 
            ),
          ],
        ),
        child: BarChart(
          BarChartData(
            maxY: maxY, 
            minY: 0,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false), 
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}%', style: const TextStyle(color: Colors.grey));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) =>
                      getBottomTitles(value, meta, showEmojis, sortedScores),
                ),
              ),
            ),
            barGroups: sortedScores.entries.map((entry) {
              final index = sortedScores.keys.toList().indexOf(entry.key);
              final double percentage = (entry.value / maxScore) * 100;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: percentage, 
                    width: 24, 
                    color: Colors.blueAccent, 
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY, 
                      color: Colors.grey[300], 
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles(
    double value, TitleMeta meta, bool showEmojis, Map<String, int> sortedScores) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  if (value.toInt() >= 0 && value.toInt() < sortedScores.length) {
    final emotion = sortedScores.keys.elementAt(value.toInt());
    return SideTitleWidget(
      child: Text(showEmojis ? getEmojiForEmotion(emotion) : _sanitizeEmotionName(emotion), style: style),
      axisSide: meta.axisSide,
    );
  } else {
    return SideTitleWidget(child: Text(''), axisSide: meta.axisSide);
  }
}

String getEmojiForEmotion(String emotion) {
  switch (_sanitizeEmotionName(emotion)) { 
    case 'Anger':
      return '😠';
    case 'Happiness':
      return '😄';
    case 'Sadness':
      return '😢';
    case 'Disgust':
      return '🤢';
    case 'Fear':
      return '😨';
    case 'Neutral':
      return '😐';
    case 'Surprise':
      return '😲';
    default:
      return '?';
  }
}


String _sanitizeEmotionName(String emotion) {
  final trimmedEmotion = emotion.trim().toLowerCase();

  final corrections = {
    'happyness': 'Happiness',
    'hapiness': 'Happiness',
    'sadnes': 'Sadness',
    'anger ': 'Anger',
    'suprise': 'Surprise',
    'supprise': 'Surprise',
    'disguist': 'Disgust',
    'fear ': 'Fear',
    'neutral ': 'Neutral',
    ' surprise ': 'Surprise',
  };

  return corrections[trimmedEmotion] ?? _capitalize(trimmedEmotion);
}

String _capitalize(String text) {
  return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}
