import  'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';



class myBarGraph extends StatelessWidget {
  final Map<String, int> scores;
  final bool showEmojis;

  const myBarGraph({
    super.key,
    required this.scores,
    this.showEmojis = false,
  });

  @override
  Widget build(BuildContext context) {
    final sortedScores = Map.fromEntries(
      scores.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)), // Sort by emotion names
    );

    return BarChart(
      BarChartData(
        maxY: 10,
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => getBottomTitles(value, meta, showEmojis, sortedScores),
            ),
          ),
        ),
        barGroups: sortedScores.entries.map((entry) {
          final index = sortedScores.keys.toList().indexOf(entry.key);
          final double barHeight = entry.value.toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: barHeight,
                width: 20,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10,
                  color: Colors.grey[200],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta, bool showEmojis, Map<String, int> sortedScores) { // Add showEmojis parameter
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 11,
  );

  if (value.toInt() >= 0 && value.toInt() < sortedScores.length) {
    final emotion = sortedScores.keys.elementAt(value.toInt());
    return SideTitleWidget(
      child: Text(showEmojis ? getEmojiForEmotion(emotion) : emotion, style: style),
      axisSide: meta.axisSide,
    );
  } else {
    return SideTitleWidget(child: Text(''), axisSide: meta.axisSide);
  }
}

String getEmojiForEmotion(String emotion) {
  switch (emotion) {
    case 'Angry':
      return '😠';
    case 'Happy':
      return '😄';
    case 'Sad':
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
